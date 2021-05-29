/// Checks whether a crash happened the last time that the game was run
/// 
/// If so, this function returns the exception struct that was generated
/// If the crash dump couldn't be parsed, this function will return a generic exception struct
/// Otherwise, this function returns <undefined>

function SnitchCrashCollect()
{
    __SnitchInit();
    
    if ((SNITCH_CRASH_NAME != "") && file_exists(SNITCH_CRASH_NAME))
    {
        __SnitchTrace("Crash dump found (", game_save_id, SNITCH_CRASH_NAME, ")");
        
        var _buffer = buffer_load(SNITCH_CRASH_NAME);
        var _string = buffer_read(_buffer, buffer_string);
        buffer_delete(_buffer);
        
        __SnitchTrace("Found \"", _string, "\"");
        
        try
        {
            var _struct = json_parse(_string);
        }
        catch(_error)
        {
            __SnitchTrace("Error! Could not parse crash dump");
            __SnitchTrace(_error);
            
            var _struct = {
                message : "Unknown crash",
                longMessage : "Unknown crash",
                script : "Unknown origin",
                line: 0,
                stacktrace : ["Unknown origin"]
            }
        }
        
        file_delete(SNITCH_CRASH_NAME);
        __SnitchTrace("Deleted crash dump");
        
        return _struct;
    }
    
    return undefined;
}