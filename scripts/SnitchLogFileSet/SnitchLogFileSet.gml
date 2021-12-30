/// Sets whether Snitch should log message to a file on disk (in the directory given by <game_save_id>)
/// 
/// @param state

function SnitchLogFileSet(_state)
{
    __SnitchInit();
    
    //If we've changed state...
    if (_state != SnitchLogFileGet())
    {
        if (_state) //If we're turning logging on...
        {
            if (!SNITCH_LOG_FILE_PERMITTED)
            {
                __SnitchTrace("Logging cannot be turned on as SNITCH_LOG_FILE_PERMITTED is set to <false>");
            }
            else
            {
                if (SNITCH_LOG_FILE_COUNT < 1)
                {
                    __SnitchError("SNITCH_LOG_FILE_COUNT must be greater than zero");
                }
                
                if (string_pos("#", SNITCH_LOG_FILE_FILENAME) <= 0)
                {
                    __SnitchError("SNITCH_LOG_FILE_FILENAME must contain a # character");
                }
                
                global.__snitchLogToFileEnabled = true;
                
                if (SnitchLogFileGet() && !global.__snitchWroteLogFileHeader)
                {
                    //If this is first time we've tried to turn logging on for this game instance, we need to create a new log file to write to
                    global.__snitchWroteLogFileHeader = true;
                    
                    //Delete the nth log file
                    if (file_exists(string_replace(SNITCH_LOG_FILE_FILENAME, "#", SNITCH_LOG_FILE_COUNT-1))) file_delete(string_replace(SNITCH_LOG_FILE_FILENAME, "#", SNITCH_LOG_FILE_COUNT-1));
                    
                    //Iterate over other log files and increment their index
                    var _i = SNITCH_LOG_FILE_COUNT;
                    repeat(SNITCH_LOG_FILE_COUNT)
                    {
                        file_rename(string_replace(SNITCH_LOG_FILE_FILENAME, "#", _i-1), string_replace(SNITCH_LOG_FILE_FILENAME, "#", _i));
                        --_i;
                    }
                    
                    //Output lots of data to the log
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "date = " + date_datetime_string(date_current_datetime()));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "config = " + string(os_get_config()));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    if (debug_mode)
                    {
                        buffer_write(global.__snitchLogFileBuffer, buffer_text, "debug mode = " + string(debug_mode));
                        buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    }
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "yyc = " + string(code_is_compiled()));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "build date = " + date_datetime_string(GM_build_date));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "version = " + string(GM_version));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "GM runtime = " + string(GM_runtime_version));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "boot parameters = " + string(SNITCH_BOOT_PARAMETERS));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "browser = " + string(SNITCH_BROWSER));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "os type = " + string(SNITCH_OS_NAME));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "os version = " + string(SNITCH_OS_VERSION));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "os language = " + string(os_get_language()));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "os region = " + string(os_get_region()));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, "os info = " + json_stringify(SNITCH_OS_INFO));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    buffer_save_ext(global.__snitchLogFileBuffer, global.__snitchZerothLogFile, 0, buffer_tell(global.__snitchLogFileBuffer));
                    
                    if (debug_mode)
                    {
                        __SnitchTrace("Opened log file (", game_save_id, global.__snitchZerothLogFile, ")");
                    }
                    
                    __SnitchTrace("Logging turned on");
                }
            }
        }
        else
        {
            __SnitchTrace("Logging turned off");
            global.__snitchLogToFileEnabled = false;
        }
    }
}