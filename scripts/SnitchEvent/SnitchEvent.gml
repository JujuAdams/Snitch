/// Creates a new event and returns the event struct itself. The event will also be outputted to the console (and can also be logged to file)
/// When used with sentry.io, events will be sent to the sentry.io server so that you can find problem areas to improve upon
/// Whilkst this function is mostly intended to be used with the sentry.io integration, it can also be used offline
/// Event structs have a few methods that can be used to contextualise data
///   N.B. The .Finish() method must be called on each and every event struct
/// 
/// @param value
/// @param [value]...

function SnitchEvent()
{
    __SnitchInit();
    
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    return new __SnitchClassSentryEvent(_string);
}

function __SnitchClassSentryEvent(_string) constructor
{
    message      = _string;
    logger       = SNITCH_SENTRY_DEFAULT_LOGGER;
    level        = "info";
    logCallstack = false;
    callstack    = undefined;
    rawCallstack = undefined;
    
    global.__snitchUnfinishedEvent = self;
    
    static LogCallstack = function()
    {
        logCallstack = true;
        return self;
    }
    
    static Callstack = function()
    {
        if ((argument_count > 0) && (argument[0] != undefined))
        {
            var _callstack = argument[0];
            var _trim      = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : 0;
        }
        else
        {
            var _callstack = debug_get_callstack();
            var _trim      = 1;
        }
        
        rawCallstack = array_create(array_length(_callstack) - _trim);
        array_copy(rawCallstack, 0, _callstack, _trim, array_length(_callstack) - _trim);
        
        callstack = [];
        
        var _i = array_length(_callstack) - 1;
        repeat(array_length(_callstack) - _trim)
        {
            var _script = _callstack[_i];
            if (is_real(_script))
            {
                --_i;
                continue;
            }
            
            var _lineText = "";
            var _linePos = string_pos(":", _script);
            if (_linePos > 0)
            {
                _lineText = string_copy(_script, _linePos + 1, string_length(_script) - _linePos);
            }
            else
            {
                _linePos = string_pos(" (line ", _script);
                if (_linePos > 0) _lineText = string_copy(_script, _linePos + 7, string_length(_script) - (_linePos + 7));
            }
            
            if (_linePos > 0)
            {
                var _func = string_copy(_script, 1, _linePos - 1);
                
                try
                {
                    var _lineNumber = real(_lineText);
                }
                catch(_)
                {
                    var _lineNumber = 0;
                }
                
                var _frame = {};
                
                if (string_pos("gml_Script_", _func) == 1)
                {
                    _func = string_delete(_func, 1, 11);
                    _frame.module = _func;
                }
                else if (string_pos("gml_Object_", _func) == 1)
                {
                    _func = string_delete(_func, 1, 11);
                    
                    var _pos = string_last_pos("_", _func);
                    _pos = string_last_pos_ext("_", _func, _pos - 1);
                    
                    var _module = string_delete(_func, 1, _pos);
                    _func = string_copy(_func, 1, _pos - 1);
                    _frame.module = _module;
                }
                
                _frame[$ "function"] = _func; //ლ(ಠ_ಠლ)
                _frame.lineno = _lineNumber;
                
                array_push(callstack, _frame);
            }
            
            --_i;
        }
        
        return self;
    }
    
    static Info = function()
    {
        level = "info";
        return self;
    }
    
    static Debug = function()
    {
        level = "debug";
        return self;
    }
    
    static Warning = function()
    {
        level = "warning";
        return self;
    }
    
    static Error = function()
    {
        level = "error";
        return self;
    }
    
    static Fatal = function()
    {
        level = "fatal";
        return self;
    }
    
    static Finish = function()
    {
        if (global.__snitchUnfinishedEvent == self) global.__snitchUnfinishedEvent = undefined;
        
        if (!SnitchSentryGet())
        {
            var _logString = "[" + string(level) + "]  " + string(message);
            
            if (logCallstack)
            {
                if (callstack == undefined)
                {
                    rawCallstack = debug_get_callstack();
                    array_delete(rawCallstack, array_length(rawCallstack)-1, 1);
                }
                
                _logString += "   " + string(rawCallstack);
            }
            
            __SnitchLogString(_logString);
            
            return new __SnitchClassSentryRequest("?", -1, -1, -1, -1);
        }
        else
        {
            //Update the event backbone
            var _backbone = SNITCH_SENTRY_DATA;
            with(_backbone)
            {
                event_id  = __SnitchUUID4String();
                timestamp = SnitchConvertToUnixTime(date_current_datetime());
                level     = other.level;
                logger    = other.logger;
                
                if (variable_struct_exists(self, "contexts") && is_struct(contexts))
                {
                    with(contexts)
                    {
                        if (variable_struct_exists(self, "os") && is_struct(os))
                        {
                            os.paused            = bool(os_is_paused());
                            os.network_connected = bool(os_is_network_connected(false));
                        }
                        
                        if (variable_struct_exists(self, "app") && is_struct(app))
                        {
                            app.steam = bool(steam_initialised());
                        }
                    }
                }
                
                if (variable_struct_exists(self, "stacktrace") && is_struct(stacktrace))
                {
                    stacktrace.frames = other.callstack;
                }
            }
            
            //Somewhat janky
            _backbone[$ "sentry.interfaces.Message"] = { formatted: message };
            
            var _request = __SnitchSentryHTTPRequest(_backbone);
            
            var _logString = "[" + string(level) + " " + string(_request.UUID) + "]  " + string(message);
            if (logCallstack) _logString += "   " + string(rawCallstack);
            __SnitchLogString(_logString);
            
            return _request;
        }
    }
}

function __SnitchSentryHTTPRequest(_backbone)
{
    //Turn the JSON packet into a string
    var _json = json_stringify(_backbone);
    
    //Compress it
    var _buffer = buffer_create(string_byte_length(_json), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _json);
    var _compressedBuffer = buffer_compress(_buffer, 0, buffer_tell(_buffer));
    buffer_delete(_buffer);
    
    //Delete the nth log file
    if (file_exists(string_replace(SNITCH_SENTRY_BACKUP_NAME, "#", SNITCH_SENTRY_BACKUP_COUNT-1))) file_delete(string_replace(SNITCH_SENTRY_BACKUP_NAME, "#", SNITCH_SENTRY_BACKUP_COUNT-1));
    
    //Iterate over other log files and increment their index
    var _i = SNITCH_SENTRY_BACKUP_COUNT;
    repeat(SNITCH_SENTRY_BACKUP_COUNT)
    {
        file_rename(string_replace(SNITCH_SENTRY_BACKUP_NAME, "#", _i-1), string_replace(SNITCH_SENTRY_BACKUP_NAME, "#", _i));
        --_i;
    }
    
    buffer_save(_compressedBuffer, string_replace(SNITCH_SENTRY_BACKUP_NAME, "#", 0));
    
    //Set up the headers...
    global.__snitchHTTPHeaderMap[? "Content-Type" ] = "application/json";
    global.__snitchHTTPHeaderMap[? "X-Sentry-Auth"] = global.__snitchAuthString + string(SnitchConvertToUnixTime(date_current_datetime()));
    
    //And fire off the request!
    //Good luck, little JSON packet
    var _id = http_request(global.__snitchSentryEndpoint, "POST", global.__snitchHTTPHeaderMap, buffer_base64_encode(_compressedBuffer, 0, buffer_get_size(_compressedBuffer)));
    
    ds_map_clear(global.__snitchHTTPHeaderMap);
    
    return new __SnitchClassSentryRequest(_backbone.event_id, _compressedBuffer, _id, 0, 0);
}

function __SnitchClassSentryRequest(_uuid, _buffer, _asyncID, _responseCode, _status) constructor
{
    UUID         = _uuid;
    buffer       = _buffer;
    asyncID      = _asyncID;
    responseCode = _responseCode;
    status       = _status;
    backupFile   = undefined;
    
    if (_asyncID >= 0) global.__snitchHTTPRequests[$ string(_asyncID)] = self;
}