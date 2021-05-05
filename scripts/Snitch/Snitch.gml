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
    
    var _final_string = SNITCH_MESSAGE_PREFIX + _string;
    __show_debug_message__(_final_string);
    
    if (global.__snitchLogging)
    {
        var _file = file_text_open_append(global.__snitchZerothLogFile);
        file_text_write_string(_file, _final_string);
        file_text_writeln(_file);
        file_text_close(_file);
    }
    
    return _string;
}