function __SnitchClassError() constructor
{
    __message              = undefined;
    __longMessage          = undefined;
    __script               = undefined;
    __line                 = undefined;
    __fatal                = false;
    __rawCallstackArray    = undefined;
    __simpleCallstack      = undefined;
    __integrationCallstack = undefined;
    __payload              = undefined;
    __request              = undefined;
    __uuid                 = SnitchGenerateUUID4String();
    
    static __SetMessage = function(_message)
    {
        __message = _message;
        
        __SetRawCallstack(undefined, 3);
        __SendAll();
    }
    
    static __SetException = function(_exceptionStruct)
    {
        //Extract information from the GameMaker exception struct we were given
        __message     = _exceptionStruct.message;
        __longMessage = _exceptionStruct.longMessage;
        __script      = _exceptionStruct.script;
        __line        = _exceptionStruct.line;
        
        __fatal = true;
        
        __SetRawCallstack(_exceptionStruct.stacktrace, 0);
        __SendAll();
    }
    
    static __SetRawCallstack = function(_callstack = debug_get_callstack(), _trim = 0)
    {
        var _size = max(1, array_length(_callstack) - _trim - 1);
        
        __rawCallstackArray = array_create(_size);
        array_copy(__rawCallstackArray, 0, _callstack, _trim, _size);
        
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
    
    static __SendAll = function()
    {
        switch(SNITCH_INTEGRATION_MODE)
        {
            case 1: __SendSentry();        break;
            case 2: __SendGameAnalytics(); break;
            case 3: __SendBugsnag();       break;
            case 4: __SendDeltaDNA();      break;
        }
        
        var _string = "[" + (__fatal? "fatal" : "error") + " " + __uuid + "] " + __message;
        if (is_array(__rawCallstackArray)) _string += " " + string(__GuaranteeSimpleCallstack());
        
        show_debug_message(_string);
        SnitchSendStringToLogFile(_string);
        SnitchSendStringToNetwork(_string);
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
    }
}