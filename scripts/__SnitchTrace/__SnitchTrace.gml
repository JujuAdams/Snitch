function __SnitchTrace()
{
    var _string = "Snitch: ";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    SnitchSendStringToLogFile(_string);
    SnitchSendStringToNetwork(_string);
    show_debug_message(_string);
}