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
                    
                    //Build a string for the boot parameters
                    if (parameter_count() <= 0)
                    {
                        var _boot_parameters = "(none)";
                    }
                    else
                    {
                        var _boot_parameters = "";
                        var _i = 0;
                        repeat(parameter_count())
                        {
                            _boot_parameters += "\"" + parameter_string(_i) + "\"";
                            if (_i < parameter_count() - 1) _boot_parameters += ", ";
                            ++_i;
                        }
                    }
                    
                    //Build a string for the OS info
                    var _os_info_map = os_get_info();
                    var _os_info_string = json_encode(_os_info_map);
                    
                    var _file = file_text_open_append(global.__snitchZerothLogFile);
                    file_text_write_string(_file, "date = " + date_datetime_string(date_current_datetime())); //Write a timestamp to the file
                    file_text_writeln(_file);
                    file_text_write_string(_file, "config = " + string(os_get_config()));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "debug_mode = " + string(debug_mode));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "code_is_compiled = " + string(code_is_compiled()));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "GM_build_date = " + date_datetime_string(GM_build_date));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "GM_version = " + string(GM_version));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "GM_runtime_version = " + string(GM_runtime_version));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "boot parameters = " + _boot_parameters);
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os_browser = " + string(os_browser));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os_device = " + string(os_device));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os_type = " + string(os_type));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os_version = " + string(os_version));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os_get_language = " + string(os_get_language()));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os_get_region = " + string(os_get_region()));
                    file_text_writeln(_file);
                    file_text_write_string(_file, "os_get_info = " + _os_info_string);
                    file_text_writeln(_file);
                    file_text_writeln(_file);
                    file_text_writeln(_file);
                    file_text_writeln(_file);
                    file_text_writeln(_file);
                    file_text_writeln(_file);
                    file_text_close(_file);
                    
                    __SnitchTrace("Opened log file (", game_save_id, global.__snitchZerothLogFile, ")");
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