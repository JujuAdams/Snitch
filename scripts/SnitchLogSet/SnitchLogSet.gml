/// Sets whether Snitch should log messages to a file on disk (in the directory given by <game_save_id>)
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
            if (!SNITCH_LOG_PERMITTED)
            {
                __SnitchTrace("Logging cannot be turned on as SNITCH_LOG_PERMITTED is set to <false>");
            }
            else
            {
                if (SNITCH_LOG_COUNT < 1)
                {
                    __SnitchError("SNITCH_LOG_COUNT must be greater than zero");
                }
                
                if (string_pos("#", SNITCH_LOG_FILENAME) <= 0)
                {
                    __SnitchError("SNITCH_LOG_FILENAME must contain a # character");
                }
                
                global.__snitchLogToFileEnabled = true;
                
                if (SnitchLogGet() && !global.__snitchWroteLogFileHeader)
                {
                    //If this is first time we've tried to turn logging on for this game instance, we need to create a new log file to write to
                    global.__snitchWroteLogFileHeader = true;
                    
                    //Delete the nth log file
                    if (file_exists(string_replace(SNITCH_LOG_FILENAME, "#", SNITCH_LOG_COUNT-1))) file_delete(string_replace(SNITCH_LOG_FILENAME, "#", SNITCH_LOG_COUNT-1));
                    
                    //Iterate over other log files and increment their index
                    var _i = SNITCH_LOG_COUNT;
                    repeat(SNITCH_LOG_COUNT)
                    {
                        file_rename(string_replace(SNITCH_LOG_FILENAME, "#", _i-1), string_replace(SNITCH_LOG_FILENAME, "#", _i));
                        --_i;
                    }
                    
                    //Output lots of data to the log
                    var _logDataArray = __SnitchConfigLogHeader();
                    var _i = 0;
                    repeat(array_length(_logDataArray))
                    {
                        buffer_write(global.__snitchLogFileBuffer, buffer_text, string(_logDataArray[_i]));
                        ++_i;
                    }
                    
                    buffer_save_ext(global.__snitchLogFileBuffer, global.__snitchZerothLogFile, 0, buffer_tell(global.__snitchLogFileBuffer));
                    
                    __SnitchTrace("Opened log file (", game_save_id, global.__snitchZerothLogFile, ")");
                }
                
                __SnitchTrace("Logging turned on");
            }
        }
        else
        {
            __SnitchTrace("Logging turned off");
            global.__snitchLogToFileEnabled = false;
        }
    }
}