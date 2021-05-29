function __SnitchSentryEventFinish()
{
    //Update the event backbone
    var _backbone = SNITCH_SENTRY_DATA;
    with(_backbone)
    {
        event_id  = __SnitchUUID4String();
        timestamp = SnitchConvertToUnixTime(date_current_datetime());
        
        if (variable_struct_exists(other, "level" )) level  = other.level;
        if (variable_struct_exists(other, "logger")) logger = other.logger;
        
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
    
    //Turn the JSON packet into a string, turn it into a buffer, and compress it
    var _json = json_stringify(_backbone);
    var _buffer = buffer_create(string_byte_length(_json), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _json);
    var _compressedBuffer = buffer_compress(_buffer, 0, buffer_tell(_buffer));
    buffer_delete(_buffer);
    
    //Create a new request struct
    var _request = new __SnitchClassRequest(_backbone.event_id, _compressedBuffer);
    _request.SaveBackup();
    
    var _logString = "[" + string(level) + " " + string(_request.UUID) + "]  " + string(message);
    if (logCallstack) _logString += "   " + string(rawCallstack);
    __SnitchLogString(_logString);
    __show_debug_message__(_logString);
    
    //Send it off
    __SnitchSentryHTTPRequest(_request);
    
    return _request;
}

function __SnitchSentryHTTPRequest(_request)
{
    //Set up the headers...
    global.__snitchHTTPHeaderMap[? "Content-Type" ] = "application/json";
    global.__snitchHTTPHeaderMap[? "X-Sentry-Auth"] = global.__snitchAuthString + string(SnitchConvertToUnixTime(date_current_datetime()));
    
    //And fire off the request!
    //Good luck little packet
    _request.Send(global.__snitchSentryEndpoint, "POST", global.__snitchHTTPHeaderMap);
    
    ds_map_clear(global.__snitchHTTPHeaderMap);
}