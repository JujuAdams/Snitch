/// Concatenates a series of values into a single string and outputs them to the IDE's Output window
/// 
/// If logging is turned on (see SnitchLogSet()) then the string is also saved to a log file on disk (in the <game_save_id> directory)
///   N.B. This can cause slowdown if a lot of debug messages are being saved!
/// 
/// If network transmission is turned on (see SnitchNetworkSet()) then the string is also broadcast over the network for a receiver to pick up
/// 
/// @param value
/// @param [value]...

function Snitch()
{
    var _string = "";
    
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    SnitchSendStringToLogFile(_string);
    SnitchSendStringToNetwork(_string); //FIXME - Format this string for consumption (LogCat?)
    
    show_debug_message(_string);
}