//Redirect exception_unhandled_handler() to our own internal function
//The bound exception handler will still be executed
#macro  exception_unhandled_handler      __SnitchCrashSetGMHandler
#macro  __exception_unhandled_handler__  exception_unhandled_handler

//Redirect show_debug_message() calls to our own SDM hanlder
//This function (__SnitchShowDebugMessage) will check if SNITCH_HIJACK_SDM is <true> and will act accordingly
#macro  show_debug_message      __SnitchShowDebugMessage
#macro  __show_debug_message__  show_debug_message



#macro __SNITCH_VERSION  "1.1.0"
#macro __SNITCH_DATE     "2021-05-06"



//Initialize the library
__SnitchInit();

function __SnitchInit()
{
    if (!variable_global_exists("__snitchLogging"))
    {
        global.__snitchLogging             = false;
        global.__snitchFirstLoggingEnabled = true;
        global.__snitchZerothLogFile       = string_replace(SNITCH_LOG_NAME, "#", "0");
        global.__snitchGMExceptionHandler  = undefined;
        
        if (SNITCH_LOG_DEFAULT) SnitchLogSet(true);
        __SnitchTrace("Welcome to Snitch by @jujuadams! This is version ", __SNITCH_VERSION, ", ", __SNITCH_DATE);
        
        __exception_unhandled_handler__(__SnitchExceptionHandler);
        
        if ((SNITCH_LOG_COUNT > 1) && (string_pos("#", SNITCH_LOG_NAME) <= 0))
        {
            __SnitchError("SNITCH_LOG_NAME must contain a # character");
        }
        
        if (SNITCH_ALLOW_LOG_PARAM && (os_type == os_windows))
        {
            var _i = 0;
            repeat(parameter_count())
            {
                if (parameter_string(_i) == "-log")
                {
                    SnitchLogSet(true);
                    if (global.__snitchLogging && (SNITCH_LOG_PARAM_MESSAGE != "")) show_message(SNITCH_LOG_PARAM_MESSAGE);
                    break;
                }
                
                _i++;
            }
        }
    }
}

function __SnitchShowDebugMessage(_string)
{
    if (SNITCH_HIJACK_SDM)
    {
        __SnitchLogString(_string);
    }
    else
    {
        return __show_debug_message__(_string);
    }
}

function __SnitchLogString(_string)
{
    __SnitchInit();
    
    __show_debug_message__(_string);
    
    if (global.__snitchLogging)
    {
        var _file = file_text_open_append(global.__snitchZerothLogFile);
        file_text_write_string(_file, _string);
        file_text_writeln(_file);
        file_text_close(_file);
    }
    
    return _string;
}

function __SnitchCrashSetGMHandler(_function)
{
    global.__snitchGMExceptionHandler = _function;
}

function __SnitchExceptionHandler(_struct)
{
    var _string = json_stringify(_struct);
    __SnitchTrace("----------------------------------------------------------------------------------------------------");
    __SnitchTrace("Unhandled exception!");
    __SnitchTrace(_string);
    __SnitchTrace("----------------------------------------------------------------------------------------------------");
    
    //Try saving out a file
    try
    {
        if (SNITCH_CRASH_LOG_NAME != "")
        {
            var _file = file_text_open_write(SNITCH_CRASH_LOG_NAME);
            file_text_write_string(_file, _string);
            file_text_close(_file);
            
            __SnitchTrace("Saved crash dump to \"", game_save_id, SNITCH_CRASH_LOG_NAME, "\"");
        }
    }
    catch(_error)
    {
        __SnitchTrace("Exception in crash handler!");
        __SnitchTrace(json_stringify(_error));
    }
    
    //Call the exception handler defined by the native exception_unhandled_handler() function
    try
    {
        if (global.__snitchGMExceptionHandler != undefined) global.__snitchGMExceptionHandler(_struct);
    }
    catch(_error)
    {
        __SnitchTrace("Exception in crash handler!");
        __SnitchTrace(json_stringify(_error));
    }
    
    //Show a pop-up message
    try
    {
        if (SNITCH_CRASH_MESSAGE != "")
        {
            if (SNITCH_CRASH_OFFER_CLIPBOARD)
            {
                if (show_question(SNITCH_CRASH_CLIPBOARD_REQUEST_MESSAGE))
                {
                    clipboard_set_text(_string);
                    show_message(SNITCH_CRASH_CLIPBOARD_ACCEPT_MESSAGE);
                }
            }
            else
            {
                show_message(SNITCH_CRASH_MESSAGE);
            }
        }
    }
    catch(_error)
    {
        __SnitchTrace("Exception in crash handler!");
        __SnitchTrace(json_stringify(_error));
    }
}

function __SnitchTrace()
{
    var _string = "Snitch: ";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    return __SnitchLogString(_string);
}

function __SnitchError()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_error("Snitch:\n" + _string + "\n ", true);
    return _string;
}