function Snitch()
{
    __SnitchInit();
    
    var _string = SNITCH_MESSAGE_PREFIX;
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