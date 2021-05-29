/// Sets whether Snitch should log message to a file on disk (in game_save_id)
///
/// @param state

function SnitchLogSet(_state)
{
    __SnitchInit();
    
    //If we've changed state...
    if (_state != SnitchLogGet())
    {
        if (_state) //If we're turning logging on...
        {
            if (SNITCH_LOG_PERMITTED)
            {
                __SnitchTrace("Logging cannot be turned on as SNITCH_LOG_PERMITTED is set to <false>");
            }
            else
            {
                global.__snitchLogging = true;
                
                if (SnitchLogGet() && global.__snitchFirstLoggingEnabled)
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
                    buffer_write(global.__snitchBuffer, buffer_text, "date = " + date_datetime_string(date_current_datetime()));
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "config = " + string(os_get_config()));
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    if (debug_mode)
                    {
                        buffer_write(global.__snitchBuffer, buffer_text, "debug mode = " + string(debug_mode));
                        buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    }
                    buffer_write(global.__snitchBuffer, buffer_text, "yyc = " + string(code_is_compiled()));
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "build date = " + date_datetime_string(GM_build_date));
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "version = " + string(GM_version));
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "GM runtime = " + string(GM_runtime_version));
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "boot parameters = " + SNITCH_BOOT_PARAMETERS);
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "browser = " + SNITCH_BROWSER);
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "os type = " + SNITCH_OS_NAME);
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "os version = " + SNITCH_OS_VERSION);
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "os language = " + string(os_get_language()));
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "os region = " + string(os_get_region()));
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_text, "os info = " + json_stringify(SNITCH_OS_INFO));
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchBuffer, buffer_u8, 10);
                    buffer_save_ext(global.__snitchBuffer, global.__snitchZerothLogFile, 0, buffer_tell(global.__snitchBuffer));
                    
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