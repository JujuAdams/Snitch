/// Concatenates a series of values into a single string and outputs them to the IDE's Output window
/// 
/// If logging is turned on (see SnitchLogFileSet()) then the string is also saved to a log file on disk (in the <game_save_id> directory)
///   N.B. This can cause slowdown if a lot of debug messages are being saved!
/// 
/// If UDP broadcasting is turned on (see SnitchUDPSet()) then the string is also broadcast over UDP for a receiver to pick up
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
    SnitchSendStringToUDP(_string);
    show_debug_message(_string);
}