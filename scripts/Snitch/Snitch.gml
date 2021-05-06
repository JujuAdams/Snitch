/// Concatenates a series of values into a single string and outputs them to the IDE's Output window
/// 
/// If Snitch is turned on then the string is also saved to a log file on disk (in game_save_id)
/// N.B. This can cause slowdown if a lot of debug messages are being saved!
/// 
/// @param value
/// @param [value]...

function Snitch()
{
    __SnitchInit();
    
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
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