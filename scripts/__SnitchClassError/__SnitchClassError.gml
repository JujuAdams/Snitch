function __SnitchClassError(_message) constructor
{
    __message              = _message;
    __longMessage          = undefined;
    __script               = undefined;
    __line                 = undefined;
    __fatal                = false;
    __callstack            = undefined;
    __rawCallstackArray    = undefined;
    __simpleCallstack      = undefined;
    __integrationCallstack = undefined;
    __payload              = undefined;
    __request              = undefined;
    __uuid                 = SnitchGenerateUUID4String();
    
    static __GuaranteeCallstack = function()
    {
        if (!is_array(__rawCallstackArray)) __Callstack(undefined, 3);
    }
    
    static __Callstack = function(_callstack = debug_get_callstack(), _trim = 0)
    {
        __rawCallstackArray = array_create(array_length(_callstack) - _trim);
        array_copy(__rawCallstackArray, 0, _callstack, _trim, array_length(_callstack) - _trim);
        
        return self;
    }
    
    static __GuaranteeSimpleCallstack = function()
    {
        if (!is_array(__simpleCallstack)) __simpleCallstack = __SnitchProcessRawCallstack(__rawCallstackArray, 0);
        return __simpleCallstack;
    }
    
    static __GuaranteeIntegrationCallstack = function()
    {
        if (!is_array(__integrationCallstack)) __integrationCallstack = __SnitchProcessRawCallstack(__rawCallstackArray, 0);
        return __integrationCallstack;
    }
    
    static SendAll = function()
    {
        SendIntegration();
        SendConsole();
        SendLog();
        SendNetwork();
        return self;
    }
    
    static SendLocal = function()
    {
        SendConsole();
        SendLog();
        SendNetwork();
        return self;
    }
    
    static SendConsole = function()
    {
        show_debug_message(__GetReadableString());
        return self;
    }
    
    static SendLog = function()
    {
        SnitchSendStringToLogFile(__GetReadableString());
        return self;
    }
    
    static SendNetwork = function()
    {
        SnitchSendStringToNetwork(__GetReadableString());
        return self;
    }
    
    static __SetException = function(_exceptionStruct)
    {
        //Extract information from the GameMaker exception struct we were given
        __message     = _exceptionStruct.message;
        __longMessage = _exceptionStruct.longMessage;
        __script      = _exceptionStruct.script;
        __line        = _exceptionStruct.line;
        
        __Callstack(_exceptionStruct.stacktrace, 0);
        __fatal = true;
        
        return self;
    }
    
    static __GetReadableString = function()
    {
        __GuaranteeCallstack();
        var _string = "[" + (__fatal? "fatal" : "error") + " " + __uuid + "] " + __message;
        if (is_array(__rawCallstackArray)) _string += " " + string(__GuaranteeSimpleCallstack());
        return _string;
    }
    
    static __GetExceptionString = function()
    {
        //Repackage information from the GameMaker exception struct we were given
        return json_stringify({
            message:     __message,
            longMessage: __longMessage,
            stacktrace:  __GuaranteeSimpleCallstack(),
            script:      __script,
            line:        __line,
        });
    }
    
    static __GetCompressedExceptionString = function()
    {
        //If we want to compress the buffer, do the ol' swaperoo
        var _string = __GetExceptionString();
        var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
        buffer_write(_buffer, buffer_text, _string);
        var _compressedBuffer = buffer_compress(_buffer, 0, buffer_get_size(_buffer));
        
        var _string = buffer_base64_encode(_compressedBuffer, 0, buffer_get_size(_compressedBuffer));
        
        //Clean up!
        buffer_delete(_buffer);
        buffer_delete(_compressedBuffer);
        
        return _string;
    }
    
    static SendIntegration = function()
    {
        __GuaranteeCallstack();
        __GuaranteeIntegrationCallstack();
        
        switch(SNITCH_INTEGRATION_MODE)
        {
            case 1: __SendSentry();          break;
            case 2: __SendGameAnalytics();   break;
            case 3: __SendBugsnag();         break;
            case 4: __SendDeltaDNA();        break;
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
                message: __message + (is_array(__integrationCallstack)? (" " + string(__integrationCallstack)) : ""),
            },
        ];
        
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
                url: "https://github.com/jujuAdams/snitch/",
            },
            events: [
                {
                    exceptions: [
                        {
                            errorClass: __message,
                            message: __longMessage,
                            stacktrace: (is_array(__integrationCallstack)? __integrationCallstack : []),
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
        _eventParams[$ SNITCH_DELTADNA_STACKTRACE_PARAM ] = is_array(__integrationCallstack)? __integrationCallstack : [];
        
        __payload = {
            eventName: SNITCH_DELTADNA_EVENT_NAME,
            userID: global.__snitchSessionID, //Deliberately randomized so that players can't be tracked across sessions
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
}