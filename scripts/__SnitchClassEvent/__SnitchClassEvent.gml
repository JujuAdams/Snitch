function __SnitchClassEvent(_string) constructor
{
    message      = _string;
    longMessage  = undefined;
    level        = "info";
    logCallstack = false;
    forceRequest = false;
    callstack    = undefined;
    rawCallstack = undefined;
    payload      = undefined;
    
    global.__snitchUnfinishedEvent = self;
    
    static Payload = function(_struct)
    {
        payload = _struct;
        return self;
    }
    
    static LongMessage = function(_string)
    {
        longMessage = _string;
        return self;
    }
    
    static Exception = function(_struct)
    {
        //Extract information from the GameMaker exception struct we were given
        message = _struct.message;
        longMessage = _struct.longMessage;
        Callstack(_struct.stacktrace);
        
        //Ensure we're at at least an "error" level of severity
        if (level != "fatal") level = "error";
        
        return self;
    }
    
    static LogCallstack = function()
    {
        logCallstack = true;
        return self;
    }
    
    static ForceRequest = function()
    {
        forceRequest = true;
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
        //Reset our unfinished event tracker
        if (global.__snitchUnfinishedEvent == self) global.__snitchUnfinishedEvent = undefined;
        
        //Ensure we have a callstack if we weren't passed one by a call to .Callstack()
        if (logCallstack && (rawCallstack == undefined))
        {
            Callstack(rawCallstack, 1);
        }
        
        if (!forceRequest && !SnitchSentryGet())
        {
            //We don't need to make a request. Log some basic data and return nothing
            var _logString = "[" + string(level) + "] " + string(message);
            if (logCallstack) _logString += "   " + string(rawCallstack);
            __SnitchTrace(_logString);
            
            return undefined;
        }
        else
        {
            //Process the raw callstack, if we have it
            if (is_array(rawCallstack)) callstack = __SnitchProcessRawCallstack(rawCallstack);
            
            var _payload = payload;
            if (_payload == undefined)
            {
                _payload = SNITCH_SHARED_EVENT_PAYLOAD;
                
                //Update our event payload
                with(SNITCH_SHARED_EVENT_PAYLOAD) __SnitchSharedEventPayloadUpdate();
            }
            
            with(_payload)
            {
                //Create a unique UUID and give the event a Unix timestamp
                event_id  = SnitchGenerateUUID4String();
                timestamp = SnitchConvertToUnixTime(date_current_datetime());
                
                //Set the message level
                level = other.level;
                
                //aaaand update the breadcrumbs too
                breadcrumbs = { values: global.__snitchBreadcrumbsArray };
                
                if ((level != "error") && (level != "fatal"))
                {
                    if (is_array(other.callstack))
                    {
                        //Set the callstack if we have one
                        stacktrace = { frames: other.callstack };
                    }
                    else
                    {
                        //Otherwise made double-sure we don't have this attribute
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
            if (logCallstack) _logString += "   " + string(rawCallstack);
            __SnitchTrace(_logString);
            
            //Make a new request struct
            var _request = new __SnitchClassRequest(_uuid, json_stringify(_payload));
            
            //Clean up our payload
            with(_payload)
            {
                variable_struct_remove(self, "event_id");
                variable_struct_remove(self, "timestamp");
                variable_struct_remove(self, "level");
                variable_struct_remove(self, "breadcrumbs");
                variable_struct_remove(self, "stacktrace");
                variable_struct_remove(self, "sentry.interfaces.Message");
                variable_struct_remove(self, "exception");
            }
            
            //If we have sentry.io enabled then actually send the request and make a backup in case the request fails
            if (SnitchSentryGet())
            {
                __SnitchSentryHTTPRequest(_request);
                _request.SaveBackup();
            }
            
            return _request;
        }
    }
}

function __SnitchProcessRawCallstack(_rawCallstack)
{
    var _callstack = [];
    
    var _i = array_length(_rawCallstack) - 1;
    repeat(array_length(_rawCallstack))
    {
        var _script = _rawCallstack[_i];
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
            
            array_push(_callstack, _frame);
        }
        
        --_i;
    }
    
    return _callstack;
}