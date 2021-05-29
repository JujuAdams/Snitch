function __SnitchClassRequest(_uuid, _buffer) constructor
{
    UUID         = _uuid;
    buffer       = _buffer;
    savedBackup  = false;
    
    asyncID      = -1;
    responseCode = 0;
    status       = 0;
    
    static Send = function(_url, _method, _headerMap)
    {
        if (os_is_network_connected(false))
        {
            asyncID = http_request(_url, _method, _headerMap, buffer_base64_encode(buffer, 0, buffer_get_size(buffer)));
            
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
    
    static SaveBackup = function()
    {
        //Don't bother saving a backup if there's no buffer to save. we've already saved a backup, or we don't want to save any backups at all
        if ((buffer < 0) || savedBackup || !SNITCH_REQUEST_BACKUP_ENABLE) return undefined;
        
        //Add the request to our tracking data structures
        global.__snitchRequestBackups[$ UUID] = self;
        array_push(global.__snitchRequestBackupOrder, UUID);
        
        //If we've exceeded our maximum number of backups, delete a few until we're back within limits
        repeat(array_length(global.__snitchRequestBackupOrder) - SNITCH_REQUEST_BACKUP_COUNT)
        {
            global.__snitchRequestBackupOrder[0].Destroy();
        }
        
        __SnitchRequestBackupSaveManifest();
        
        //Save our event buffer
        buffer_save(buffer, __SnitchRequestBackupFilename(UUID));
        
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
    
    static Destroy = function()
    {
        //Delete the buffer we're holding internally
        if (buffer >= 0)
        {
            buffer_delete(buffer);
            buffer = -1;
        }
        
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
    return string_replace(SNITCH_REQUEST_BACKUP_NAME, "#", _uuid);
}

function __SnitchRequestBackupSaveManifest()
{
    buffer_seek(global.__snitchRequestBackupManifestBuffer, buffer_seek_start, 0);
    buffer_write(global.__snitchRequestBackupManifestBuffer, buffer_string, json_stringify(global.__snitchRequestBackupOrder));
    buffer_save_ext(global.__snitchRequestBackupManifestBuffer, SNITCH_REQUEST_BACKUP_MANIFEST_NAME, 0, buffer_tell(global.__snitchRequestBackupManifestBuffer));
}