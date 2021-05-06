/// Sets whether Snitch should log message to a file on disk (in game_save_id)
///
/// @param state

function SnitchLogSet(_state)
{
    __SnitchInit();
    
    if (_state != global.__snitchLogging)
    {
        if (_state && (SNITCH_LOG_COUNT <= 0))
        {
            __SnitchTrace("Warning! SNITCH_LOG_COUNT = ", SNITCH_LOG_COUNT, ", logging cannot be enabled");
        }
        else if (_state)
        {
            global.__snitchLogging = true;
            
            if (global.__snitchLogging && global.__snitchFirstLoggingEnabled)
            {
                global.__snitchFirstLoggingEnabled = false;
                
                if (file_exists(string_replace(SNITCH_LOG_NAME, "#", SNITCH_LOG_COUNT-1))) file_delete(string_replace(SNITCH_LOG_NAME, "#", SNITCH_LOG_COUNT-1));
                
                var _i = SNITCH_LOG_COUNT;
                repeat(SNITCH_LOG_COUNT)
                {
                    file_rename(string_replace(SNITCH_LOG_NAME, "#", _i-1), string_replace(SNITCH_LOG_NAME, "#", _i));
                    --_i;
                }
                
                var _file = file_text_open_append(global.__snitchZerothLogFile);
                file_text_write_string(_file, date_datetime_string(date_current_datetime()));
                file_text_writeln(_file);
                file_text_close(_file);
                
                __SnitchTrace("Logging turned on");
                __SnitchTrace("Opened log file (", game_save_id, global.__snitchZerothLogFile, ")");
            }
            else
            {
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