/// Checks whether a crash happened the last time that the game was run
/// 
/// If so, this function returns the exception struct that was generated
/// If the crash dump couldn't be parsed, this function will return a generic exception struct
/// Otherwise, this function returns <undefined>

function SnitchCrashDumpCollect()
{
    __SnitchInit();
    
    var _struct = undefined;
    
    if ((SNITCH_CRASH_EVENT_FILENAME != "") && file_exists(SNITCH_CRASH_EVENT_FILENAME))
    {
        try
        {
            var _buffer = buffer_load(SNITCH_CRASH_EVENT_FILENAME);
            var _string = buffer_read(_buffer, buffer_string);
            buffer_delete(_buffer);
            var _struct = json_parse(_string);
        }
        catch(_error)
        {
            __SnitchTrace("Could not parse crash dump, error was \"", _error.message, "\"");
        }
    }
    
    return _struct;
}