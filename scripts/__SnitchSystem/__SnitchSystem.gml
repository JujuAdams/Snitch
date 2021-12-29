//Redirect exception_unhandled_handler() to our own internal function
//The bound exception handler will still be executed
#macro  exception_unhandled_handler      __SnitchCrashSetGMHandler
#macro  __exception_unhandled_handler__  exception_unhandled_handler

//Redirect show_debug_message() calls to our own SDM hanlder
//This function (__SnitchShowDebugMessage) will check if SNITCH_HIJACK_SDM is <true> and will act accordingly
#macro  show_debug_message      __SnitchShowDebugMessage
#macro  __show_debug_message__  show_debug_message



#macro SNITCH_VERSION               "2.0.0"
#macro SNITCH_DATE                  "2021-05-29"
#macro SNITCH_SHARED_EVENT_PAYLOAD  global.__snitchSharedEventPayload
#macro SNITCH_OS_NAME               global.__snitchOSName
#macro SNITCH_OS_VERSION            global.__snitchOSVersion
#macro SNITCH_DEVICE_NAME           global.__snitchDeviceName
#macro SNITCH_BROWSER               global.__snitchBrowser
#macro SNITCH_OS_INFO               global.__snitchOSInfo
#macro SNITCH_BOOT_PARAMETERS       global.__snitchBootParameters
#macro __SNITCH_HTTP_NEEDED         (SNITCH_SENTRY_PERMITTED)



//Initialize the library
__SnitchInit();

function __SnitchInit()
{
    if (!variable_global_exists("__snitchLogging"))
    {
        global.__snitchLogging             = false;
        global.__snitchFirstLoggingEnabled = true;
        global.__snitchZerothLogFile       = string_replace(SNITCH_LOG_FILENAME, "#", "0");
        global.__snitchGMExceptionHandler  = undefined;
        global.__snitchUnfinishedEvent     = undefined;
        global.__snitchSentryEnabled       = false;
        global.__snitchBuffer              = buffer_create(SNITCH_LOG_BUFFER_START_SIZE, buffer_grow, 1);
        global.__snitchBreadcrumbsArray    = [];
        
        //HTTP-related tracking
        global.__snitchHTTPHeaderMap               = ds_map_create(); //Has to be a map due to GameMaker's HTTP request API
        global.__snitchHTTPRequests                = {};
        global.__snitchRequestBackups              = {};
        global.__snitchRequestBackupOrder          = [];
        global.__snitchRequestBackupManifestBuffer = buffer_create(512, buffer_grow, 1);
        global.__snitchRequestBackupResendTime     = -SNITCH_REQUEST_BACKUP_RESEND_DELAY; //Try to send a request backup immediately on boot
        global.__snitchRequestBackupResendIndex    = 0;
        global.__snitchRequestBackupFailures       = 0;
        
        global.__snitchMessageBuffer    = buffer_create(1024, buffer_grow, 1);
        global.__snitchMessageTellArray = [];
        global.__snitchMessageRead      = false;
        global.__snitchMessageString    = "";
        
        //Build an array for the boot parameters
        SNITCH_BOOT_PARAMETERS = [];
        var _i = 0;
        repeat(parameter_count())
        {
            array_push(SNITCH_BOOT_PARAMETERS,  parameter_string(_i));
            ++_i;
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
        
        //If we're on a browser, use the browser's name instead
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
        __SnitchTrace("Welcome to Snitch by @jujuadams! This is version " + string(SNITCH_VERSION) + ", " + string(SNITCH_DATE));
        
        if (SNITCH_CRASH_CAPTURE)
        {
            __exception_unhandled_handler__(__SnitchExceptionHandler);
        }
        
        if (SNITCH_LOG_COUNT < 1)
        {
            __SnitchError("SNITCH_LOG_COUNT must be greater than zero");
        }
        
        if (string_pos("#", SNITCH_LOG_FILENAME) <= 0)
        {
            __SnitchError("SNITCH_LOG_FILENAME must contain a # character");
        }
        
        if (SNITCH_REQUEST_BACKUP_COUNT < 1)
        {
            __SnitchError("SNITCH_REQUEST_BACKUP_COUNT must be greater than zero");
        }
        
        if (SNITCH_ALLOW_LOG_BOOT_PARAMETER && (os_type == os_windows))
        {
            var _i = 0;
            repeat(parameter_count())
            {
                if (parameter_string(_i) == "-log")
                {
                    SnitchLogSet(true);
                    if (SnitchLogGet() && (SNITCH_LOG_BOOT_PARAMETER_CONFIRMATION != "")) show_message(SNITCH_LOG_BOOT_PARAMETER_CONFIRMATION);
                    break;
                }
                
                _i++;
            }
        }
        
        //Create the shared event payload
        SNITCH_SHARED_EVENT_PAYLOAD = __SnitchSharedEventPayload();
        
        if (SNITCH_REQUEST_BACKUP_ENABLE && __SNITCH_HTTP_NEEDED)
        {
            var _lsoadedManifest = false;
            try
            {
                var _buffer = buffer_load(SNITCH_REQUEST_BACKUP_MANIFEST_FILENAME);
                _loadedManifest = true;
                
                var _json = buffer_read(_buffer, buffer_string);
                global.__snitchRequestBackupOrder = json_parse(_json);
            }
            catch(_)
            {
                if (!_loadedManifest)
                {
                    __SnitchTrace("Could not find request backup manifest");
                }
                else
                {
                    __SnitchTrace("Request backup manifest was corrupted");
                }
            }
            
            if (_loadedManifest)
            {
                var _expected = array_length(global.__snitchRequestBackupOrder);
                var _missing = 0;
                
                var _i = _expected - 1;
                repeat(_expected)
                {
                    var _uuid = global.__snitchRequestBackupOrder[_i];
                    
                    var _filename = __SnitchRequestBackupFilename(_uuid);
                    if (!file_exists(_filename))
                    {
                        _missing++;
                        array_delete(global.__snitchRequestBackupOrder, _i, 1);
                    }
                    else
                    {
                        var _buffer = buffer_load(_filename);
                        
                        if (buffer_get_size(_buffer) <= 0)
                        {
                            //If the buffer is empty, delete the file on disk and report this event as missing
                            _missing++;
                            file_delete(_filename);
                        }
                        else
                        {
                            //Otherwise read out a string from the buffer and create a new request
                            var _request = new __SnitchClassRequest(_uuid, buffer_read(_buffer, buffer_text));
                            _request.savedBackup = true;
                            global.__snitchRequestBackups[$ _uuid] = _request;
                        }
                        
                        buffer_delete(_buffer);
                    }
                    
                    --_i;
                }
                
                __SnitchTrace("Found ", array_length(global.__snitchRequestBackupOrder), " request backups (", _expected, " in manifest, of which ", _missing, " missing)");
            }
            
            __SnitchRequestBackupSaveManifest();
        }
        
        
        
        if (SNITCH_SENTRY_PERMITTED)
        {
            //Force a network connection if possible
            os_is_network_connected(true);
            
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
            global.__snitchSentryAuthString = "Sentry sentry_version=7, sentry_client=Snitch/" + string(SNITCH_VERSION) + ", sentry_key=" + global.__snitchSentryPublicKey + ", sentry_timestamp=";
            
            if (debug_mode)
            {
                __SnitchTrace("Sentry public key = \"", global.__snitchSentryPublicKey, "\"");
                __SnitchTrace("Sentry endpoint = \"", global.__snitchSentryEndpoint, "\"");
            }
        }
    }
}

function __SnitchShowDebugMessage(_string)
{
    if (SNITCH_HIJACK_SDM) __SnitchLogString(string(_string));
    __show_debug_message__(_string);
}

function __SnitchLogString(_string)
{
    if (SnitchLogGet())
    {
        buffer_write(global.__snitchBuffer, buffer_text, _string);
        buffer_write(global.__snitchBuffer, buffer_u8, 10);
        buffer_save_ext(global.__snitchBuffer, global.__snitchZerothLogFile, 0, buffer_tell(global.__snitchBuffer));
    }
}

function __SnitchCrashSetGMHandler(_function)
{
    global.__snitchGMExceptionHandler = _function;
}

function __SnitchExceptionHandler(_struct)
{
    __SnitchTrace("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    
    //Generate a crash event and output it
    //We guarantee that it returns a request struct, and we also indicate we want the callstack to be outputted as well for easier debugging
    var _request = (new __SnitchClassEvent(""))
                   .Fatal()
                   .Exception(_struct)
                   .LogCallstack()
                   .ForceRequest()
                   .Finish();
    
    __SnitchTrace("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    
    
    
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
    
    
    
    //Save out the crash dump
    try
    {
        var _text = "No data available";
        switch(SWITCH_CRASH_DUMP_MODE)
        {
            case 1: _text = json_stringify(_struct);        break;
            case 2: _text = _request.content;               break;
            case 3: _text = _request.GetCompressedString(); break;
        }
        
        var _buffer = buffer_create(string_byte_length(_text), buffer_fixed, 1);
        buffer_write(_buffer, buffer_text, _text);
        buffer_save(_buffer, SNITCH_CRASH_DUMP_FILENAME);
        buffer_delete(_buffer);
        
        __SnitchTrace("Saved crash dump to \"", SNITCH_CRASH_DUMP_FILENAME, "\"");
    }
    catch(_error)
    {
        __SnitchTrace("Exception in crash handler!");
        __SnitchTrace(json_stringify(_error));
    }
    
    
    
    //Show a pop-up message
    try
    {
        if (SWITCH_CRASH_CLIPBOARD_MODE > 0)
        {
            if (show_question(SNITCH_CRASH_CLIPBOARD_REQUEST_MESSAGE))
            {
                var _text = "No data available";
                switch(SWITCH_CRASH_CLIPBOARD_MODE)
                {
                    case 1: _text = json_stringify(_struct);        break;
                    case 2: _text = _request.content;               break;
                    case 3: _text = _request.GetCompressedString(); break;
                }
                
                clipboard_set_text("#####" + _text + "#####"); break;
                show_message(SNITCH_CRASH_CLIPBOARD_ACCEPT_MESSAGE);
            }
        }
        else if (SNITCH_CRASH_NO_CLIPBOARD_MESSAGE != "")
        {
            show_message(SNITCH_CRASH_NO_CLIPBOARD_MESSAGE);
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
    
    __SnitchLogString(_string);
    __show_debug_message__(_string);
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
}

#macro SnitchMessageStartArgument  __SnitchInit();\
                                  var _snitchMessageBuffer    = global.__snitchMessageBuffer;\
                                  var _snitchMessageTellArray = global.__snitchMessageTellArray;\
                                  global.__snitchMessageRead = false;\
                                  buffer_seek(_snitchMessageBuffer, buffer_seek_start, 0);\
                                  array_resize(_snitchMessageTellArray, 0);\\
                                  var _i = 0;\
                                  repeat(argument_count)\
                                  {\
                                      array_push(_snitchMessageTellArray, buffer_tell(_snitchMessageBuffer));\
                                      buffer_write(_snitchMessageBuffer, buffer_text, argument[_i]);\
                                      ++_i;\
                                  }\
                                  buffer_write(_snitchMessageBuffer, buffer_u8, 0x00);\
                                  var _snitchMessageStartIndex

#macro SnitchMessage  __SnitchMessageString(_snitchMessageStartIndex)

function __SnitchMessageString(_startIndex)
{
    __SnitchInit();
    
    if (!global.__snitchMessageRead)
    {
        global.__snitchMessageRead = true;
        buffer_seek(global.__snitchMessageBuffer, buffer_seek_start, global.__snitchMessageTellArray[_startIndex]);
        global.__snitchMessageString = buffer_read(global.__snitchMessageBuffer, buffer_string);
    }
    
    return global.__snitchMessageString;
}