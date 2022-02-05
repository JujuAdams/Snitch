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
    __longMessage       = undefined;
    __fatal             = false;
    __addCallstack      = false;
    __callstack         = undefined;
    __rawCallstackArray = undefined;
    __payload           = undefined;
    __request           = undefined;
    __uuid              = SnitchGenerateUUID4String();
    
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
        
        //Process the raw callstack, if we have it
        if (is_array(__rawCallstackArray)) __callstack = __SnitchProcessRawCallstack(__rawCallstackArray);
        
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
        var _logString = "[" + (__fatal? "fatal" : "error") + " " + __uuid + "] " + __message;
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
        __longMessage = _exceptionStruct.longMessage;
        __fatal = true;
        Callstack(_exceptionStruct.stacktrace, 0);
        
        return self;
    }
    
    static __SendGoogleAnalytics = function()
    {
        if (__payload == undefined) __payload = {};
        
        var _paramsStruct = {
            message: string(__message),
            fatal: __fatal? "true" : "false",
            debug_mode: true,
        };
        
        if (is_array(__callstack))
        {
            var _arrayIndex = array_length(__callstack)-1;
            var _count = min(25 - variable_struct_names_count(_paramsStruct), array_length(__callstack));
            var _callstackIndex = 0;
            repeat(_count)
            {
                var _callstackStage = __callstack[_arrayIndex];
                
                var _stageString = _callstackStage[$ "function"];
                if (_stageString != _callstackStage.module) _stageString += " " + _callstackStage.module;
                
                var _lineNumber = " L" + string(_callstackStage.lineno);
                var _maxLength = 100 -1 - string_length(_lineNumber);
                
                if (string_length(_stageString) > _maxLength)
                {
                    _maxLength -= 1;
                    _stageString = string_copy(_stageString, 1, floor(_maxLength/2)) + "…" + string_copy(_stageString, string_length(_stageString) + 1 - floor(_maxLength/2), ceil(_maxLength/2));
                }
                
                _paramsStruct[$ "callstack" + string(_callstackIndex)] = _stageString + _lineNumber;
                
                --_arrayIndex;
                ++_callstackIndex;
            }
        }
        
        with(__payload) //TODO - Optimize by building this string manually without needing to allocate a struct that is then immediately JSONified
        {
            client_id            = global.__snitchGoogleAnalyticsClientID;
            //TODO - Add user_properties
            non_personalized_ads = true;
            timestamp_micros     = floor(1000000*SnitchConvertToUnixTime(date_current_datetime()));
            events               = [
                {
                    name: "snitch",
                    params: _paramsStruct,
                }
            ];
        };
        
        //Make a new request struct
        __request = new __SnitchClassRequest(SnitchGenerateUUID4String(), json_stringify(__payload));
        
        //If we have sentry.io enabled then actually send the request and make a backup in case the request fails
        if ((SNITCH_INTEGRATION_MODE == 1) && SnitchIntegrationGet())
        {
            __SnitchGoogleAnalyticsHTTPRequest(__request);
            __request.__SaveBackup();
        }
        
        return self;
    }
    
    static __SendSentry = function()
    {
        var _payload = __payload;
        if (_payload == undefined)
        {
            _payload = SNITCH_SHARED_EVENT_PAYLOAD;
            
            //Update our event payload
            with(SNITCH_SHARED_EVENT_PAYLOAD) __SnitchSentrySharedEventPayloadUpdate();
        }
        
        with(_payload)
        {
            //Create a unique UUID and give the event a Unix timestamp
            event_id  = other.__uuid;
            timestamp = SnitchConvertToUnixTime(date_current_datetime());
            
            //Set the message level
            level = other.__fatal? "fatal" : "error";
            
            //Build an exception struct to send
            var _exceptionData =  { type: other.__message };
            
            if (other.__longMessage != undefined)
            {
                _exceptionData.value = other.__longMessage;
            }
            else
            {
                _exceptionData.value = other.__message;
            }
            
            //Only add callstack/module information if we have it
            if (is_array(other.__callstack))
            {
                if (array_length(other.__callstack) > 0) _exceptionData.module = other.__callstack[0].module;
                _exceptionData.stacktrace = { frames: other.__callstack };
            }
            
            //Pack the error data in such a way that sentry.io will understand it
            exception = { values: [_exceptionData] };
            
            //Also make sure we don't have any non-exception data lingering
            variable_struct_remove(self, "sentry.interfaces.Message");
            variable_struct_remove(self, "stacktrace");
        }
        
        //Make a new request struct
        __request = new __SnitchClassRequest(__uuid, json_stringify(_payload));
        
        //Clean up our payload
        //TODO - Do we need to do this?
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
        //TODO
        return self;
    }
    
    static __GetString = function()
    {
        return json_stringify(__payload);
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