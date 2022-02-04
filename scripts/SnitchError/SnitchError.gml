/// Creates a new Snitch event that can be formatted and logged/broadcast/transmitted in multiple ways
/// If an API integration is enabled then the event will be sent to the remote logging server when
/// .SendIntegration() or .SendAll() is called
/// 
/// 
/// 
/// Event structs have a number of methods that can be chained together in a "fluent interface" i.e.:
/// 
///   SnitchError("Player is outside the level?!").Callstack().Send();
/// 
/// Events won't do anything unless a "send method" is called. Send methods for events include:
/// 
///   .SendConsole()     - Outputs the event to the debug console (i.e. calls show_debug_message())
///   .SendLogFile()     - Writes the event to the log file, if enabled
///   .SendUDP()         - Broadcasts the event over UDP, if enabled
///   .SendIntegration() - Transmits the event over HTTP to whichever API integration is enabled (if any)
///                        If request backups are enabled, a request backup is also saved. See SNITCH_REQUEST_BACKUP_ENABLE for more information
///   .SendAll()         - Sends the event to all of the below
///   .SendLocal()       - Calls .SendConsole(), .SendLogFile(), and .SendUDP()
/// 
/// Event methods are used to set properties for the event, such as message level or callstack logging
///     
/// .LongMessage(string)
///     Sets the event's "longMessage" property. This is used to add extra context
///     
/// .Callstack([callstackArray], [trimCount])
///     Sets the event's callstack. If no arguments are provided then the callstack is generated from where this function was called
///     The optional [trimCount] argument allows for the given number of callstack levels to be removed

function SnitchError()
{
    SnitchMessageStartArgument = 0;
    return new __SnitchClassError(SnitchMessage);
}

function __SnitchClassError(_message) constructor
{
    __message           = _message;
    longMessage         = undefined;
    level               = "error";
    __addCallstack      = false;
    callstack           = undefined;
    __rawCallstackArray = undefined;
    payload             = undefined;
    __request           = undefined;
    
    static LongMessage = function(_string)
    {
        var _i = 0;
        longMessage = "";
        repeat(argument_count)
        {
            longMessage += string(argument[_i]);
            ++_i;
        }
        
        return self;
    }
    
    static Callstack = function(_callstack = debug_get_callstack(), _trim = 0)
    {
        __addCallstack = true;
        __rawCallstackArray = array_create(array_length(_callstack) - _trim);
        array_copy(__rawCallstackArray, 0, _callstack, _trim, array_length(_callstack) - _trim);
        return self;
    }
    
    static SendAll = function()
    {
        SendConsole();
        SendLogFile();
        SendUDP();
        SendIntegration();
        
        return self;
    }
    
    static SendLocal = function()
    {
        SendConsole();
        SendLogFile();
        SendUDP();
        
        return self;
    }
    
    static SendConsole = function()
    {
        //We don't need to make a request. Log some basic data and return nothing
        var _logString = __message;
        if (__addCallstack) _logString += "   " + string(__rawCallstackArray);
        show_debug_message(_logString);
        
        return self;
    }
    
    static SendLogFile = function()
    {
        SnitchSendStringToLogFile(__GetString());
        return self;
    }
    
    static SendUDP = function()
    {
        SnitchSendStringToUDP(__GetString());
        return self;
    }
    
    static SendIntegration = function()
    {
        switch(SNITCH_INTEGRATION_MODE)
        {
            case 1: __SendGoogleAnalytics(); break;
            case 2: __SendSentry();          break;
            case 3: __SendGameAnalytics();   break;
        }
        
        return self;
    }
    
    static __Exception = function(_exceptionStruct)
    {
        //Extract information from the GameMaker exception struct we were given
        __message = _exceptionStruct.message;
        longMessage = _exceptionStruct.longMessage;
        Callstack(_exceptionStruct.stacktrace, 0);
        level = "fatal";
        
        return self;
    }
    
    static __SendGoogleAnalytics = function()
    {
        return self;
    }
    
    static __SendSentry = function()
    {
        //Process the raw callstack, if we have it
        if (is_array(__rawCallstackArray)) callstack = __SnitchProcessRawCallstack(__rawCallstackArray);
        
        var _payload = payload;
        if (_payload == undefined)
        {
            _payload = SNITCH_SHARED_EVENT_PAYLOAD;
            
            //Update our event payload
            with(SNITCH_SHARED_EVENT_PAYLOAD) __SnitchSentrySharedEventPayloadUpdate();
        }
        
        with(_payload)
        {
            //Create a unique UUID and give the event a Unix timestamp
            event_id  = SnitchGenerateUUID4String();
            timestamp = SnitchConvertToUnixTime(date_current_datetime());
            
            //Set the message level
            level = other.level;
            
            if ((level != "error") && (level != "fatal"))
            {
                if (is_array(other.callstack))
                {
                    //Set the callstack if we have one
                    stacktrace = { frames: other.callstack };
                }
                else
                {
                    //Otherwise make sure we don't have this attribute
                    variable_struct_remove(self, "stacktrace");
                }
                
                //...janky
                //Only way to set this key though unfortunately
                self[$ "sentry.interfaces.Message"] = { formatted: other.message };
                    
                //Also make sure we don't have any exception data lingering
                variable_struct_remove(self, "exception");
            }
            else
            {
                //Build an exception struct to send
                var _exceptionData =  { type: other.message };
                    
                if (other.longMessage != undefined)
                {
                    _exceptionData.value = other.longMessage;
                }
                else
                {
                    _exceptionData.value = other.message;
                }
                    
                //Only add callstack/module information if we have it
                if (is_array(other.callstack))
                {
                    if (array_length(other.callstack) > 0) _exceptionData.module = other.callstack[0].module;
                    _exceptionData.stacktrace = { frames: other.callstack };
                }
                    
                //Pack the error data in such a way that sentry.io will understand it
                exception = { values: [_exceptionData] };
                    
                //Also make sure we don't have any non-exception data lingering
                variable_struct_remove(self, "sentry.interfaces.Message");
                variable_struct_remove(self, "stacktrace");
            }
        }
            
        //Pull out our UUID
        var _uuid = _payload.event_id;
            
        //Log this momentous occasion
        var _logString = "[" + string(level) + " " + string(_uuid) + "] " + string(message);
        if (__addCallstack) _logString += "   " + string(__rawCallstackArray);
        __SnitchTrace(_logString);
            
        //Make a new request struct
        __request = new __SnitchClassRequest(_uuid, json_stringify(_payload));
            
        //Clean up our payload
        with(_payload)
        {
            variable_struct_remove(self, "event_id");
            variable_struct_remove(self, "timestamp");
            variable_struct_remove(self, "level");
            variable_struct_remove(self, "stacktrace");
            variable_struct_remove(self, "sentry.interfaces.Message");
            variable_struct_remove(self, "exception");
        }
            
        //If we have sentry.io enabled then actually send the request and make a backup in case the request fails
        if ((SNITCH_INTEGRATION_MODE == 2) && SnitchIntegrationGet())
        {
            __SnitchSentryHTTPRequest(__request);
            __request.__SaveBackup();
        }
            
        return self;
    }
    
    static __SendGameAnalytics = function()
    {
        return self;
    }
    
    static __GetString = function()
    {
        return json_stringify(payload);
    }
    
    static __GetCompressedString = function()
    {
        //If we want to compress the buffer, do the ol' swaperoo
        var _string = __GetString();
        var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
        buffer_write(_buffer, buffer_text, _string);
        var _compressedBuffer = buffer_compress(_buffer, 0, buffer_get_size(_buffer));
        
        var _string = buffer_base64_encode(_compressedBuffer, 0, buffer_get_size(_compressedBuffer));
        
        //Clean up!
        buffer_delete(_buffer);
        buffer_delete(_compressedBuffer);
        
        return _string;
    }
}