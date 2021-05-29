//Redirect exception_unhandled_handler() to our own internal function
//The bound exception handler will still be executed
#macro  exception_unhandled_handler      __SnitchCrashSetGMHandler
#macro  __exception_unhandled_handler__  exception_unhandled_handler

//Redirect show_debug_message() calls to our own SDM hanlder
//This function (__SnitchShowDebugMessage) will check if SNITCH_HIJACK_SDM is <true> and will act accordingly
#macro  show_debug_message      __SnitchShowDebugMessage
#macro  __show_debug_message__  show_debug_message



#macro SNITCH_VERSION            "2.0.0"
#macro SNITCH_DATE               "2021-05-28"
#macro SNITCH_SENTRY_DATA        global.__snitchSentryData
#macro SNITCH_BREADCRUMBS_ARRAY  global.__snitchBreadcrumbsArray
#macro SNITCH_OS_NAME            global.__snitchOSName
#macro SNITCH_OS_VERSION         global.__snitchOSVersion
#macro SNITCH_DEVICE_NAME        global.__snitchDeviceName
#macro SNITCH_BROWSER            global.__snitchBrowser
#macro SNITCH_OS_INFO            global.__snitchOSInfo
#macro SNITCH_BOOT_PARAMETERS    global.__snitchBootParameters



//Initialize the library
__SnitchInit();

function __SnitchInit()
{
    if (!variable_global_exists("__snitchLogging"))
    {
        global.__snitchLogging             = false;
        global.__snitchFirstLoggingEnabled = true;
        global.__snitchZerothLogFile       = string_replace(SNITCH_LOG_NAME, "#", "0");
        global.__snitchZerothCrashDump     = string_replace(SNITCH_CRASH_NAME, "#", "0");
        global.__snitchGMExceptionHandler  = undefined;
        global.__snitchUnfinishedEvent     = undefined;
        global.__snitchSentryEnabled       = false;
        global.__snitchHTTPHeaderMap       = ds_map_create(); //Has to be a map due to GameMaker's HTTP request API
        global.__snitchHTTPRequests        = {};
        global.__snitchSteamInitialised    = false;
        SNITCH_BREADCRUMBS_ARRAY           = [];
        
        //Build a string for the boot parameters
        if (parameter_count() <= 0)
        {
            SNITCH_BOOT_PARAMETERS = "(none)";
        }
        else
        {
            SNITCH_BOOT_PARAMETERS = "";
            var _i = 0;
            repeat(parameter_count())
            {
                SNITCH_BOOT_PARAMETERS += "\"" + parameter_string(_i) + "\"";
                if (_i < parameter_count() - 1) SNITCH_BOOT_PARAMETERS += ", ";
                ++_i;
            }
        }
        
        
        
        #region Set SNITCH_OS_NAME, SNITCH_OS_VERSION, SNITCH_DEVICE_NAME, SNITCH_BROWSER, SNITCH_OS_INFO
        
        SNITCH_OS_NAME     = "Unknown (=" + string(os_type) + ")"
        SNITCH_OS_VERSION  = "Unknown (=" + string(os_version) + ")"
        SNITCH_DEVICE_NAME = global.__snitchOSName + " " + global.__snitchOSVersion;
        SNITCH_BROWSER     = "Unknown browser";
        
        switch(os_type)
        {
            case os_windows:
            case os_win8native:
                SNITCH_OS_NAME = "Windows";
                    
                switch(os_version)
                {
                    case 327680: SNITCH_OS_VERSION = "2000";  break;
                    case 327681: SNITCH_OS_VERSION = "XP";    break;
                    case 237862: SNITCH_OS_VERSION = "XP";    break;
                    case 393216: SNITCH_OS_VERSION = "Vista"; break;
                    case 393217: SNITCH_OS_VERSION = "7";     break;
                    case 393218: SNITCH_OS_VERSION = "8";     break;
                    case 393219: SNITCH_OS_VERSION = "8.1";   break;
                    case 655360: SNITCH_OS_VERSION = "10";    break;
                }
                
                SNITCH_DEVICE_NAME = SNITCH_OS_NAME + " " + SNITCH_OS_VERSION;
            break;
            
            case os_uwp:
                SNITCH_OS_NAME     = "UWP";
                SNITCH_OS_VERSION  = string(os_version);
                SNITCH_DEVICE_NAME = SNITCH_OS_NAME + " " + SNITCH_OS_VERSION;
            break;
            
            case os_linux:
                SNITCH_OS_NAME     = "Linux";
                SNITCH_OS_VERSION  = string(os_version);
                SNITCH_DEVICE_NAME = SNITCH_OS_NAME + " " + SNITCH_OS_VERSION;
            break;
            
            case os_macosx:
                SNITCH_OS_NAME     = "Mac OS X";
                SNITCH_OS_VERSION  = string(os_version >> 24) + "." + string((os_version >> 12) & 0xfff);
                SNITCH_DEVICE_NAME = SNITCH_OS_NAME + " " + SNITCH_OS_VERSION;
            break;
            
            case os_ios:
                SNITCH_OS_NAME     = "iOS";
                SNITCH_OS_VERSION  = string(os_version >> 24) + "." + string((os_version >> 12) & 0xfff);
                SNITCH_DEVICE_NAME = SNITCH_OS_NAME + " " + SNITCH_OS_VERSION;
            break;
            
            case os_android:
                SNITCH_OS_NAME = "Android";
                
                switch (os_version)
                {
                    case 21: SNITCH_OS_VERSION = "Lollipop";    break;
                    case 22: SNITCH_OS_VERSION = "Lollipop";    break;
                    case 23: SNITCH_OS_VERSION = "Marshmallow"; break;
                    case 24: SNITCH_OS_VERSION = "Nougat";      break;
                    case 25: SNITCH_OS_VERSION = "Oreo";        break;
                    case 26: SNITCH_OS_VERSION = "Pie";         break;
                    case 27: SNITCH_OS_VERSION = "v10";         break;
                    case 28: SNITCH_OS_VERSION = "v11";         break;
                    case 29: SNITCH_OS_VERSION = "v12";         break;
                }
                
                SNITCH_DEVICE_NAME = SNITCH_OS_NAME + " " + SNITCH_OS_VERSION;
            break;
            
            case os_ps3:     SNITCH_OS_NAME = "PlayStation 3";    break;
            case os_ps4:     SNITCH_OS_NAME = "PlayStation 4";    break;
            case os_psvita:  SNITCH_OS_NAME = "PlayStation Vita"; break;
            case os_xboxone: SNITCH_OS_NAME = "Xbox One";         break;
            case os_switch:  SNITCH_OS_NAME = "Switch";           break;
        }
            
        //Figure out what browser we're using
        switch(os_browser)
        {
            case browser_not_a_browser: SNITCH_BROWSER = "Not a browser";     break;
            case browser_ie:            SNITCH_BROWSER = "Internet Explorer"; break;
            case browser_ie_mobile:     SNITCH_BROWSER = "Internet Explorer"; break;
            case browser_firefox:       SNITCH_BROWSER = "Firefox";           break;
            case browser_chrome:        SNITCH_BROWSER = "Chrome";            break;
            case browser_safari:        SNITCH_BROWSER = "Safari";            break;
            case browser_safari_mobile: SNITCH_BROWSER = "Safari";            break;
            case browser_opera:         SNITCH_BROWSER = "Opera";             break;
        }
            
        if (os_browser != browser_not_a_browser) SNITCH_DEVICE_NAME = SNITCH_BROWSER;
            
        //Turn the os_get_info() map into a struct for serialization
        SNITCH_OS_INFO = {};
        var _infoMap = os_get_info();
        var _key = ds_map_find_first(_infoMap);
        repeat(ds_map_size(_infoMap))
        {
            SNITCH_OS_INFO[$ _key] = _infoMap[? _key];
            _key = ds_map_find_next(_infoMap, _key);
        }
        ds_map_destroy(_infoMap);
        
        #endregion
        
        
        
        if (SNITCH_LOG_DEFAULT) SnitchLogSet(true);
        __SnitchTrace("Welcome to Snitch by @jujuadams! This is version ", SNITCH_VERSION, ", ", SNITCH_DATE);
        
        if (SNITCH_CRASH_CAPTURE)
        {
            __exception_unhandled_handler__(__SnitchExceptionHandler);
        }
        
        if ((SNITCH_LOG_COUNT > 1) && (string_pos("#", SNITCH_LOG_NAME) <= 0))
        {
            __SnitchError("SNITCH_LOG_NAME must contain a # character");
        }
        
        if (SNITCH_ALLOW_LOG_BOOT_PARAMETER && (os_type == os_windows))
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
        
        if (SNITCH_SENTRY_PERMITTED)
        {
            var _DSN = SNITCH_SENTRY_DSN_URL;
            
            var _protocolPosition = string_pos("://", _DSN);
            if (_protocolPosition == 0) __SnitchError("No protocol found in DSN string");
            var _protocol = string_copy(_DSN, 1, _protocolPosition-1);
            
            var _atPosition = string_pos("@", _DSN);
            if (_atPosition == 0) __SnitchError("No @ found in DSN string");
            
            global.__snitchSentryPublicKey = string_copy(_DSN, _protocolPosition + 3, _atPosition - (_protocolPosition + 3));
            if (global.__snitchSentryPublicKey == "") __SnitchError("No public key found in DSN string");
            
            var _slashPosition = string_last_pos("/", _DSN);
            
            var _DSNHostPath = string_copy(_DSN, _atPosition + 1, _slashPosition - (_atPosition + 1));
            if (_DSNHostPath == "") __SnitchError("No host/path found in DSN string");
            
            var _DSNProject = string_copy(_DSN, _slashPosition + 1, string_length(_DSN) - _slashPosition);
            if (_DSNProject == "") __SnitchError("No project found in DSN string");
    
            global.__snitchSentryEndpoint = _protocol + "://" + _DSNHostPath + "/api/" + _DSNProject + "/store/";
            
            //Build an auth string for later HTTP requests
            //We fill in the timestamp later when sending the request
            global.__snitchAuthString = "Sentry sentry_version=7, sentry_client=" + game_project_name + "/" + GM_version + ", sentry_key=" + global.__snitchSentryPublicKey + ", sentry_timestamp=";
            
            if (debug_mode)
            {
                __SnitchTrace("Sentry public key = \"", global.__snitchSentryPublicKey, "\"");
                __SnitchTrace("Sentry endpoint = \"", global.__snitchSentryEndpoint, "\"");
            }
            
            //Build the event backbone
            SNITCH_SENTRY_DATA = __SnitchConfigSentryData();
        }
    }
}

function __SnitchShowDebugMessage(_string)
{
    if (SNITCH_HIJACK_SDM)
    {
        __SnitchLogString(string(_string));
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

function __SnitchUUID4String()
{
    //FIXME - Do this without using MD5
    var _UUID = md5_string_utf8(string(current_time) + string(date_current_datetime()) + string(random(1000000)));
    _UUID = string_set_byte_at(_UUID, 13, ord("4"));
    _UUID = string_set_byte_at(_UUID, 17, ord(choose("8", "9", "a", "b")));
    return _UUID;
}

function __SnitchExceptionHandler(_struct)
{
    var _string = json_stringify(_struct);
    __SnitchTrace("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    __SnitchTrace("Unhandled exception!");
    __SnitchTrace(_string);
    __SnitchTrace("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    
    //Try saving out a file
    try
    {
        if (SNITCH_CRASH_NAME != "")
        {
            ////Delete the nth crash dump
            //if (file_exists(string_replace(SNITCH_CRASH_NAME, "#", SNITCH_CRASH_COUNT-1))) file_delete(string_replace(SNITCH_CRASH_NAME, "#", SNITCH_CRASH_COUNT-1));
            //
            ////Iterate over other crash dumps and increment their index
            //var _i = SNITCH_CRASH_COUNT;
            //repeat(SNITCH_CRASH_COUNT)
            //{
            //    file_rename(string_replace(SNITCH_CRASH_NAME, "#", _i-1), string_replace(SNITCH_CRASH_NAME, "#", _i));
            //    --_i;
            //}
            
            var _filename = SNITCH_CRASH_NAME;
            var _file = file_text_open_write(_filename);
            file_text_write_string(_file, _string);
            file_text_close(_file);
            
            __SnitchTrace("Saved crash dump");
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
    
    try
    {
        if (SnitchSentryGet() && SNITCH_SENTRY_SEND_CRASH) SnitchEvent(_struct.message).Fatal().Callstack(_struct.stacktrace).Finish();
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