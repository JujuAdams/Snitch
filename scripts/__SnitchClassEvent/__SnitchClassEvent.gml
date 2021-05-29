function __SnitchClassEvent(_string) constructor
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
            __show_debug_message__(_logString);
            
            return new __SnitchClassRequest("?", -1);
        }
        else
        {
            return __SnitchSentryEventFinish();
        }
    }
}