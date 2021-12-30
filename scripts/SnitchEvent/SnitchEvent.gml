/// Creates a new Snitch event that can be formatted and logged/broadcast/transmitted in multiple ways
/// If an API integration is enabled then the event will be sent to the remote logging server when
/// .Send() is called. You can (and maybe should?) rename this function to whatever you want e.g. DebugEvent()
/// 
/// 
/// 
/// Event structs have a number of methods that can be chained together in a "fluent interface" i.e.:
/// 
///   SnitchEvent("Player is outside the level?!").Debug().Callstack().Send();
/// 
/// Events won't do anything unless a "send method" is called. Send methods for events include:
/// 
///   .SendToConsole()     - Outputs the event to the debug console (i.e. calls show_debug_message())
///   .SendToLogFile()     - Writes the event to the log file, if enabled
///   .SendToUDP()         - Broadcasts the event over UDP, if enabled
///   .SendToIntegration() - Transmits the event over HTTP to whichever API integration is enabled (if any)
///   .Send()              - Sends the event to all of the above
/// 
/// Event methods are used to set properties for the event, such as message level or callstack logging
/// These are as follows:
///     
/// .Message(string)
///     Sets the event's "longMessage" property. This is used for error-level and fatal-level events to add extra context
///     
/// .LongMessage(string)
///     Sets the event's "longMessage" property. This is used for error-level and fatal-level events to add extra context
/// 
/// .Info()
///     Sets the event level to "info", the lowest event level
///     
/// .Debug()
///     Sets the event level to "debug"
///     
/// .Warning()
///     Sets the event level to "warning"
///     
/// .Error()
///     Sets the event level to "error"
///     
/// .Fatal()
///     Sets the event level to "fatal", the highest event level
///     
/// .Exception(exceptionStruct)
///     Sets a number of attributes based on a standard GameMaker exception struct
///     This function overwrites values set by .LongMessage() and .Callstack()
///     Additionally, any message set when creating the event will be overwritten by the .message variable in the exception struct
///     
/// .Callstack([callstackArray], [trimCount])
///     Sets the event's callstack. If no arguments are provided then the callstack is generated from where this function was called
///     The optional [trimCount] argument allows for the given number of callstack levels to be removed
///     
/// .SendToConsole()
///     Outputs the event to the debug console (i.e. calls show_debug_message())
///     
/// .SendToLogFile()
///     Writes the event to the log file, if enabled
///     
/// .SendToUDP()
///     Broadcasts the event over UDP, if enabled
///     
/// .SendToIntegration()
///     Transmits the event over HTTP to whichever API integration is enabled (if any)
///     If request backups are enabled, a request backup is also saved. See SNITCH_REQUEST_BACKUP_ENABLE for more information
///     
/// .Send()
///     Sends the event to all of the above i.e. calls SendToConsole(), SendToLogFile(), SendToUDP(), and SendToIntegration()
/// 
/// .GetString()
///     Returns a human-readable string representation of the event
/// 
/// .GetCompressedString()
///     Returns a compressed and base64-encoded representation of the event
/// 
/// .GetRequest()
///      Return the HTTP request struct that's created by sending to event to an integration
///      If no request has been made, this function returns <undefined>

function SnitchEvent()
{
    return new __SnitchClassEvent();
}

function __SnitchClassEvent() constructor
{
    
    __message           = "";
    longMessage         = undefined;
    level               = "info";
    __addCallstack      = false;
    forceRequest        = false;
    callstack           = undefined;
    __rawCallstackArray = undefined;
    payload             = undefined;
    __request           = undefined;
    
    static Message = function()
    {
        var _i = 0;
        __message = "";
        repeat(argument_count)
        {
            __message += string(argument[_i]);
            ++_i;
        }
        
        return self;
    }
    
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
    
    static Exception = function(_exceptionStruct)
    {
        //Extract information from the GameMaker exception struct we were given
        __message = _exceptionStruct.message;
        longMessage = _exceptionStruct.longMessage;
        SetCallstack(_exceptionStruct.stacktrace, 0);
        
        //Ensure we're at at least an "error" level of severity
        if (level != "fatal") level = "error";
        
        return self;
    }
    
    static Callstack = function(_callstack = debug_get_callstack(), _trim = 0)
    {
        __rawCallstackArray = array_create(array_length(_callstack) - _trim);
        array_copy(__rawCallstackArray, 0, _callstack, _trim, array_length(_callstack) - _trim);
        
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
    
    static Send = function()
    {
        SendToConsole();
        SendToLogFile();
        SendToUDP();
        SendToIntegration();
        
        return self;
    }
    
    static SendToConsole = function()
    {
        //We don't need to make a request. Log some basic data and return nothing
        var _logString = "[" + string(level) + "] " + string(__message);
        if (__addCallstack) _logString += "   " + string(__rawCallstackArray);
        show_debug_message(_logString);
        
        return self;
    }
    
    static SendToLogFile = function()
    {
        return self;
    }
    
    static SendToUDP = function()
    {
        return self;
    }
    
    static SendToIntegration = function()
    {
        if (SNITCH_GOOGLE_ANALYTICS_PERMITTED)
        {
            __SendToGoogleAnalytics();
        }
        else if (SNITCH_SENTRY_PERMITTED)
        {
            __SendToSentry();
        }
        else if (SNITCH_GAMEANALYTICS_PERMITTED)
        {
            __SendToGameAnalytics();
        }
        
        return self;
    }
    
    static __SendToGoogleAnalytics = function()
    {
        return self;
    }
    
    static __SendToSentry = function()
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
        if (SnitchSentryGet())
        {
            __SnitchSentryHTTPRequest(__request);
            __request.__SaveBackup();
        }
            
        return self;
    }
    
    static __SendToGameAnalytics = function()
    {
        return self;
    }
    
    static GetRequest = function()
    {
        return __request;
    }
    
    static GetString = function()
    {
        return json_stringify(payload);
    }
    
    static GetCompressedString = function()
    {
        //If we want to compress the buffer, do the ol' swaperoo
        var _string = GetString();
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