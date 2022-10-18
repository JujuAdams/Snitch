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
        if (!is_array(__rawCallstackArray))
        {
            __Callstack(undefined, 3);
        }
        
        return __rawCallstackArray;
    }
    
    static __Callstack = function(_callstack = debug_get_callstack(), _trim = 0)
    {
        __rawCallstackArray = array_create(array_length(_callstack) - _trim);
        array_copy(__rawCallstackArray, 0, _callstack, _trim, array_length(_callstack) - _trim);
        
        return __rawCallstackArray;
    }
    
    static __GuaranteeSimpleCallstack = function()
    {
        if (!is_array(__simpleCallstack))
        {
            __simpleCallstack = is_array(__rawCallstackArray)? __SnitchProcessRawCallstack(__rawCallstackArray, 0) : [];
        }
        
        return __simpleCallstack;
    }
    
    static __GuaranteeIntegrationCallstack = function()
    {
        if (!is_array(__integrationCallstack))
        {
            __integrationCallstack = is_array(__rawCallstackArray)? __SnitchProcessRawCallstack(__rawCallstackArray, 0) : [];
        }
        
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
        //Make a new request struct
        __payload = __SnitchConfigPayloadSentry(__uuid, __message, __longMessage, __GuaranteeIntegrationCallstack(), __fatal);
        __request = new __SnitchClassRequest(__uuid, json_stringify(__payload));
        
        //If we have sentry.io enabled then actually send the request and make a backup in case the request fails
        if ((SNITCH_INTEGRATION_MODE == 1) && SnitchIntegrationGet())
        {
            __SnitchSentryHTTPRequest(__request);
            __request.__SaveBackup();
        }
        
        return self;
    }
    
    static __SendGameAnalytics = function()
    {
        //Make a new request struct
        __payload = __SnitchConfigPayloadGameAnalytics(__uuid, __message, __longMessage, __GuaranteeIntegrationCallstack(), __fatal);
        __request = new __SnitchClassRequest(__uuid, json_stringify(__payload));
        
        //If we have GameAnalytics enabled then actually send the request and make a backup in case the request fails
        if ((SNITCH_INTEGRATION_MODE == 2) && SnitchIntegrationGet())
        {
            __SnitchGameAnalyticsHTTPRequest(__request);
            __request.__SaveBackup();
        }
        
        return self;
    }
    
    static __SendBugsnag = function()
    {
        
        //Make a new request struct
        __payload = __SnitchConfigPayloadBugsnag(__uuid, __message, __longMessage, __GuaranteeIntegrationCallstack(), __fatal);
        __request = new __SnitchClassRequest(__uuid, json_stringify(__payload));
        
        //If we have Bugsnag enabled then actually send the request and make a backup in case the request fails
        if ((SNITCH_INTEGRATION_MODE == 3) && SnitchIntegrationGet())
        {
            __SnitchBugsnagHTTPRequest(__request);
            __request.__SaveBackup();
        }
        
        return self;
    }
    
    static __SendDeltaDNA = function()
    {
        //Make a new request struct
        __payload = __SnitchConfigPayloadDeltaDNA(__uuid, __message, __longMessage, __GuaranteeIntegrationCallstack(), __fatal);
        __request = new __SnitchClassRequest(__uuid, json_stringify(__payload));
        
        //If we have DeltaDNA enabled then actually send the request and make a backup in case the request fails
        if ((SNITCH_INTEGRATION_MODE == 4) && SnitchIntegrationGet())
        {
            __SnitchDeltaDNAHTTPRequest(__request);
            __request.__SaveBackup();
        }
        
        return self;
    }
}