/// Sets whether Snitch should log message to a file on disk (in game_save_id)
///
/// @param state

function SnitchLogSet(_state)
{
    __SnitchInit();
    
    //If we've changed state...
    if (_state != global.__snitchLogging)
    {
        if (_state) //If we're turning logging on...
        {
            if (SNITCH_LOG_COUNT <= 0)
            {
                //Report a warning if we can never log anything but we try to turn logging on
                __SnitchTrace("Warning! SNITCH_LOG_COUNT = ", SNITCH_LOG_COUNT, ", logging cannot be enabled");
            }
            else
            {
                global.__snitchLogging = true;
                
                if (global.__snitchLogging && global.__snitchFirstLoggingEnabled)
                {
                    //If this is first time we've tried to turn logging on for this game instance, we need to create a new log file to write to
                    global.__snitchFirstLoggingEnabled = false;
                    
                    //Delete the nth log file
                    if (file_exists(string_replace(SNITCH_LOG_NAME, "#", SNITCH_LOG_COUNT-1))) file_delete(string_replace(SNITCH_LOG_NAME, "#", SNITCH_LOG_COUNT-1));
                    
                    //Iterate over other log files and increment their index
                    var _i = SNITCH_LOG_COUNT;
                    repeat(SNITCH_LOG_COUNT)
                    {
                        file_rename(string_replace(SNITCH_LOG_NAME, "#", _i-1), string_replace(SNITCH_LOG_NAME, "#", _i));
                        --_i;
                    }
                    
                    //Build a string for the OS info
                    var _file = file_text_open_append(global.__snitchZerothLogFile);
                    file_text_write_string(_file, "date = " + date_datetime_string(date_current_datetime())); //Write a timestamp to the file
                    file_text_writeln(_file);
                    file_text_write_string(_file, "config = " + string(os_get_config()));
                    if (debug_mode)
                    {
                        file_text_writeln(_file);
                        file_text_write_string(_file, "debug mode = " + string(debug_mode));
                    }
                    file_text_writeln(_file);
                    file_text_write_string(_file, "yyc = " + string(code_is_compiled()));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "build date = " + date_datetime_string(GM_build_date));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "version = " + string(GM_version));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "GM runtime = " + string(GM_runtime_version));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "boot parameters = " + SNITCH_BOOT_PARAMETERS);
                    file_text_writeln(_file);
                    file_text_write_string(_file, "browser = " + SNITCH_BROWSER);
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os type = " + SNITCH_OS_NAME);
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os version = " + SNITCH_OS_VERSION);
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os language = " + string(os_get_language()));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os region = " + string(os_get_region()));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os info = " + json_stringify(SNITCH_OS_INFO));
                    file_text_writeln(_file);
                    file_text_writeln(_file);
                    file_text_writeln(_file);
                    file_text_writeln(_file);
                    file_text_close(_file);
                    
                    if (debug_mode)
                    {
                        __SnitchTrace("Opened log file (", game_save_id, global.__snitchZerothLogFile, ")");
                    }
                }
                
                __SnitchTrace("Logging turned on");
            }
        }
        else
        {
            __SnitchTrace("Logging turned off");
            global.__snitchLogging = false;
        }
    }
}