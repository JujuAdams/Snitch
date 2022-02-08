/// Creates a new Snitch error that can be logged/broadcast/transmitted in multiple ways
///
///   N.B. Errors won't do anything unless a method is called!
/// 
/// The error message itself is built from concatenating values passed into the SnitchError()
/// function call. For example:
/// 
///   SnitchError("Player has ", itemCount, " but this doesn't match ", cachedItemCount).SendAll();
/// 
/// This will concatenate those strings and numbers together, then send the error message to
/// all the services that have been configured and enabled.
/// 
/// Snitch error structs have a number of methods that control how the error struct should be
/// shared with other services. These methods can be chained together. For example, the following
/// code will output an error message to the console and to a log file but nothing else:
/// 
///   SnitchError("Player is outside the level?!").SendConsole().SendLogFile();
/// 
/// Below is all the methods that are available. Make sure you call at least one of these!
/// 
///   .SendConsole()     - Outputs the event to the debug console (i.e. calls show_debug_message())
///   .SendLogFile()     - Writes the event to the log file, if enabled
///   .SendUDP()         - Broadcasts the event over UDP, if enabled
///   .SendIntegration() - Transmits the event over HTTP to whichever API integration is enabled (if any)
///                        If request backups are enabled, a request backup is also saved. See SNITCH_REQUEST_BACKUP_ENABLE for more information
///   .SendAll()         - Sends the event to all of the above
///   .SendLocal()       - Calls .SendConsole(), .SendLogFile(), and .SendUDP()
/// 
/// @param value
/// @param [value]...

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
    
    static __GuaranteeCallstack = function()
    {
        if (!is_array(__rawCallstackArray)) __Callstack(undefined, 3);
    }
    
    static __Callstack = function(_callstack = debug_get_callstack(), _trim = 0)
    {
        __rawCallstackArray = array_create(array_length(_callstack) - _trim);
        array_copy(__rawCallstackArray, 0, _callstack, _trim, array_length(_callstack) - _trim);
        
        //Process the raw callstack, if we have it
        if (is_array(__rawCallstackArray)) __callstack = __SnitchProcessRawCallstack(__rawCallstackArray);
        
        return self;
    }
    
    static SendAll = function()
    {
        __GuaranteeCallstack();
        SendConsole();
        SendLogFile();
        SendUDP();
        SendIntegration();
        
        return self;
    }
    
    static SendLocal = function()
    {
        __GuaranteeCallstack();
        SendConsole();
        SendLogFile();
        SendUDP();
        
        return self;
    }
    
    static SendConsole = function()
    {
        __GuaranteeCallstack();
        
        //We don't need to make a request. Log some basic data and return nothing
        var _logString = "[" + (__fatal? "fatal" : "error") + " " + __uuid + "] " + __message;
        if (__addCallstack) _logString += "   " + string(__rawCallstackArray);
        show_debug_message(_logString);
        
        return self;
    }
    
    static SendLogFile = function()
    {
        __GuaranteeCallstack();
        SnitchSendStringToLogFile(__GetString()); //FIXME
        return self;
    }
    
    static SendUDP = function()
    {
        __GuaranteeCallstack();
        SnitchSendStringToUDP(__GetString()); //FIXME
        return self;
    }
    
    static SendIntegration = function()
    {
        __GuaranteeCallstack();
        
        switch(SNITCH_INTEGRATION_MODE)
        {
            case 1: __SendGoogleAnalytics(); break;
            case 2: __SendSentry();          break;
            case 3: __SendGameAnalytics();   break;
            case 4: __SendBugsnag();         break;
            case 5: __SendDeltaDNA();        break;
        }
        
        return self;
    }
    
    static __Exception = function(_exceptionStruct)
    {
        //Extract information from the GameMaker exception struct we were given
        __message = _exceptionStruct.message;
        __longMessage = _exceptionStruct.longMessage;
        __Callstack(_exceptionStruct.stacktrace, 0);
        __fatal = true;
        
        return self;
    }
    
    static __SendGoogleAnalytics = function()
    {
        if (__payload == undefined) __payload = {};
        
        var _paramsStruct = {
            message: string(__message),
            fatal: __fatal? "true" : "false",
        };
        
        //Add the crash location if we have a callstack to work with
        //We have very limited space so we can only send the first callstack location
        if (is_array(__callstack))
        {
            _paramsStruct.location = __callstack[array_length(__callstack)-1];
        }
        
        with(__payload) //TODO - Optimize by building this string manually without needing to allocate a struct that is then immediately JSONified
        {
            client_id            = global.__snitchClientID;
            //TODO - Add user_properties
            non_personalized_ads = true;
            timestamp_micros     = floor(1000000*SnitchConvertToUnixTime(date_current_datetime()));
            events               = [
                {
                    name: "exception",
                    params: _paramsStruct,
                }
            ];
        };
        
        //Make a new request struct
        __request = new __SnitchClassRequest(__uuid, json_stringify(__payload));
        
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
        }
        
        //Make a new request struct
        __request = new __SnitchClassRequest(__uuid, json_stringify(_payload));
        
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
        __payload = [
            {
                device: "unknown",
                v: int64(2),
                user_id: global.__snitchSessionID,
                client_ts: floor(1000*SnitchConvertToUnixTime(date_current_datetime())),
                sdk_version: "rest api v2",
                os_version: "windows 10",
                manufacturer: "unknown",
                platform: "windows",
                session_id: global.__snitchSessionID,
                session_num: int64(1),
                limit_ad_tracking: true,
                category: "error",
                severity: __fatal? "critical" : "error",
                message: __message + (is_array(__callstack)? (" " + string(__callstack)) : ""),
            },
        ]
        
        //Make a new request struct
        __request = new __SnitchClassRequest(__uuid, json_stringify(__payload));
        
        //If we have GameAnalytics enabled then actually send the request and make a backup in case the request fails
        if ((SNITCH_INTEGRATION_MODE == 3) && SnitchIntegrationGet())
        {
            __SnitchGameAnalyticsHTTPRequest(__request);
            __request.__SaveBackup();
        }
        
        return self;
    }
    
    static __SendBugsnag = function()
    {
        __payload = {
            apiKey: SNITCH_BUGSNAG_API_KEY,
            payloadVersion: "5",
            notifier: {
                name: "Snitch",
                version: SNITCH_VERSION,
                url: "https://github.com/jujuAdams/snitch",
            },
            events: [
                {
                    exceptions: [
                        {
                            errorClass: __message,
                            message: __longMessage,
                            stacktrace: (__callstack == undefined)? [] : __callstack,
                        },
                    ],
                    severity: __fatal? "error" : "warning",
                },
            ],
        };
        
        //Make a new request struct
        __request = new __SnitchClassRequest(__uuid, json_stringify(__payload));
        
        //If we have Bugsnag enabled then actually send the request and make a backup in case the request fails
        if ((SNITCH_INTEGRATION_MODE == 4) && SnitchIntegrationGet())
        {
            __SnitchBugsnagHTTPRequest(__request);
            __request.__SaveBackup();
        }
        
        return self;
    }
    
    static __SendDeltaDNA = function()
    {
        var _eventParams = {};
        _eventParams[$ SNITCH_DELTADNA_MESSAGE_PARAM    ] = __message;
        _eventParams[$ SNITCH_DELTADNA_LONGMESSAGE_PARAM] = is_string(__longMessage)? __longMessage : __message;
        _eventParams[$ SNITCH_DELTADNA_FATAL_PARAM      ] = __fatal;
        _eventParams[$ SNITCH_DELTADNA_STACKTRACE_PARAM ] = is_array(__callstack)? string(__callstack[0]) : "unknown";
        
        __payload = {
            eventName: SNITCH_DELTADNA_EVENT_NAME,
            userID: global.__snitchSessionID, //Deliberately chosen so that players can't be tracked across sessions
            sessionID: global.__snitchSessionID,
            eventUUID: __uuid,
            eventParams: _eventParams,
        };
        
        //Make a new request struct
        __request = new __SnitchClassRequest(__uuid, json_stringify(__payload));
        
        //If we have DeltaDNA enabled then actually send the request and make a backup in case the request fails
        if ((SNITCH_INTEGRATION_MODE == 5) && SnitchIntegrationGet())
        {
            __SnitchDeltaDNAHTTPRequest(__request);
            __request.__SaveBackup();
        }
        
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