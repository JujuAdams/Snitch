/// Concatenates a series of values into a single string and outputs them to the IDE's Output window
/// You can (and maybe should?) rename this function to whatever you want e.g. log()
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
    
    __SnitchLogString(_string);
    __show_debug_message__(_string);
}