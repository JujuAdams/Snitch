function __SnitchClassRequest(_uuid, _string) constructor
{
    content          = _string;
    UUID             = _uuid;
    buffer           = -1;
    compressedBuffer = -1;
    savedBackup      = false;
    
    asyncID      = -1;
    responseCode = 0;
    status       = 0;
    
    static MakeBuffer = function()
    {
        if (buffer < 0)
        {
            buffer = buffer_create(string_byte_length(content), buffer_fixed, 1);
            buffer_write(buffer, buffer_text, content);
        }
        
        return buffer;
    }
    
    static Compress = function()
    {
        if (compressedBuffer < 0)
        {
            MakeBuffer();
            compressedBuffer = buffer_compress(buffer, 0, buffer_get_size(buffer));
        }
        
        return compressedBuffer;
    }
    
    static Send = function(_url, _method, _headerMap, _compress)
    {
        if (os_is_network_connected(false))
        {
            if (_compress)
            {
                Compress();
                asyncID = http_request(_url, _method, _headerMap, buffer_base64_encode(compressedBuffer, 0, buffer_get_size(compressedBuffer)));
            }
            else
            {
                MakeBuffer();
                asyncID = http_request(_url, _method, _headerMap, buffer_base64_encode(buffer, 0, buffer_get_size(buffer)));
            }
            
            if (asyncID >= 0)
            {
                global.__snitchHTTPRequests[$ string(asyncID)] = self;
            }
            else
            {
                HTTPResponse(-1, -1);
            }
        }
    }
    
    static GetCompressedString = function(_autoCleanUp)
    {
        if (compressedBuffer >= 0)
        {
            //We have a compressed buffer, return that base64 encoded
            return buffer_base64_encode(compressedBuffer, 0, buffer_get_size(compressedBuffer));
        }
        else if (buffer >= 0)
        {
            //We don't have a compressed buffer but we do have a plaintext buffer
            //Make a temporary compressed buffer and call this function again
            Compress();
            var _string = GetCompressedString(_autoCleanUp);
            
            if (_autoCleanUp)
            {
                buffer_delete(compressedBuffer);
                compressedBuffer = -1;
            }
            
            return _string;
        }
        else if (buffer >= 0)
        {
            //We don't have a compressed buffer nor do we have a plaintext buffer
            //Make a temporary plaintext buffer and call this function again
            MakeBuffer();
            var _string = GetCompressedString(_autoCleanUp);
            
            if (_autoCleanUp)
            {
                buffer_delete(buffer);
                buffer = -1;
            }
            
            return _string;
        }
    }
    
    static GetRawString = function()
    {
        return content;
    }
    
    static SaveAs = function(_filename, _autoCleanUp)
    {
        if (buffer >= 0)
        {
            buffer_save(buffer, _filename);
        }
        else
        {
            //We don't have a plaintext buffer
            //Make a temporary one and call this function again
            MakeBuffer();
            SaveAs(_filename, _autoCleanUp);
            
            if (_autoCleanUp)
            {
                buffer_delete(buffer);
                buffer = -1;
            }
        }
        
        return file_exists(_filename);
    }
    
    static SaveBackup = function()
    {
        //Don't bother saving a backup if there's no buffer to save. we've already saved a backup, or we never want to save any backups at all
        if (savedBackup || !SNITCH_REQUEST_BACKUP_ENABLE) return undefined;
        
        //Add the request to our tracking data structures
        global.__snitchRequestBackups[$ UUID] = self;
        array_push(global.__snitchRequestBackupOrder, UUID);
        
        //If we've exceeded our maximum number of backups, delete a few until we're back within limits
        repeat(array_length(global.__snitchRequestBackupOrder) - SNITCH_REQUEST_BACKUP_COUNT)
        {
            global.__snitchRequestBackupOrder[0].Destroy();
        }
        
        //Make sure the manifest is updated on disk
        __SnitchRequestBackupSaveManifest();
        
        //Actually do the saving
        SaveAs(__SnitchRequestBackupFilename(UUID), true);
        
        savedBackup = true;
    }
    
    static HTTPResponse = function(_responseCode, _status)
    {
        responseCode = _responseCode;
        status       = _status;
        
        if (responseCode == 200)
        {
            if (SNITCH_OUTPUT_HTTP_SUCCESS) SnitchCrumb("Request ", UUID, " complete (HTTP 200)").HTTP("sentry.io", "POST", responseCode);
            Destroy();
            
            //Reset the failure count
            global.__snitchRequestBackupFailures = 0;
        }
        else if (status == 0)
        {
            SnitchCrumb("Request ", UUID, " complete but may have been unsuccessful (HTTP ", responseCode, ")").Warning().HTTP("sentry.io", "POST", responseCode);
            Destroy();
            
            //Don't touch the failure count as this state is indeterminate
        }
        else if (status != 1)
        {
            SnitchCrumb("Request ", UUID, " failed (HTTP ", responseCode, ")").Warning().HTTP("sentry.io", "POST", responseCode);
            
            if (global.__snitchRequestBackupFailures < SNITCH_REQUEST_BACKUP_RESEND_MAX_FAILURES)
            {
                //Increment the failure count
                global.__snitchRequestBackupFailures++;
                
                if (global.__snitchRequestBackupFailures >= SNITCH_REQUEST_BACKUP_RESEND_MAX_FAILURES)
                {
                    __SnitchTrace("Too many failed requests (", global.__snitchRequestBackupFailures, "), retrying later");
                }
            }
        }
        else
        {
            //Pending, do nothing
        }
    }
    
    static CleanUp = function()
    {
        //Delete the buffers we're holding internally
        if (buffer >= 0)
        {
            buffer_delete(buffer);
            buffer = -1;
        }
        
        if (compressedBuffer >= 0)
        {
            buffer_delete(compressedBuffer);
            compressedBuffer = -1;
        }
    }
    
    static Destroy = function()
    {
        //Delete the buffers we're holding internally
        CleanUp();
        
        variable_struct_remove(global.__snitchHTTPRequests, asyncID);
        
        //Delete any backup on disk
        file_delete(__SnitchRequestBackupFilename(UUID));
        
        //Remove this request from our backup records
        variable_struct_remove(global.__snitchRequestBackups, UUID);
        var _i = array_length(global.__snitchRequestBackupOrder) - 1
        repeat(_i + 1)
        {
            if (global.__snitchRequestBackupOrder[_i] == UUID) array_delete(global.__snitchRequestBackupOrder, _i, 1);
            --_i;
        }
    }
}

function __SnitchRequestBackupFilename(_uuid)
{
    return string_replace(SNITCH_REQUEST_BACKUP_FILENAME, "#", _uuid);
}

function __SnitchRequestBackupSaveManifest()
{
    buffer_seek(global.__snitchRequestBackupManifestBuffer, buffer_seek_start, 0);
    buffer_write(global.__snitchRequestBackupManifestBuffer, buffer_string, json_stringify(global.__snitchRequestBackupOrder));
    buffer_save_ext(global.__snitchRequestBackupManifestBuffer, SNITCH_REQUEST_BACKUP_MANIFEST_FILENAME, 0, buffer_tell(global.__snitchRequestBackupManifestBuffer));
}

function __SnitchSentryHTTPRequest(_request)
{
    //Set up the headers...
    global.__snitchHTTPHeaderMap[? "Content-Type" ] = "application/json";
    global.__snitchHTTPHeaderMap[? "X-Sentry-Auth"] = global.__snitchAuthString + string(SnitchConvertToUnixTime(date_current_datetime()));
    
    //And fire off the request!
    //Good luck little packet
    _request.Send(global.__snitchSentryEndpoint, "POST", global.__snitchHTTPHeaderMap, true);
    
    ds_map_clear(global.__snitchHTTPHeaderMap);
}