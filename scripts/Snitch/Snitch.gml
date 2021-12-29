/// Concatenates a series of values into a single string and outputs them to the IDE's Output window
/// You can (and maybe should?) rename this function to whatever you want e.g. Log()
/// 
/// If logging is turned on (see SnitchLogSet()) then the string is also saved to a log file on disk (in game_save_id)
///   N.B. This can cause slowdown if a lot of debug messages are being saved!
/// 
/// 
/// @param value
/// @param [value]...

function Snitch()
{
    SnitchMessageStartArgument = 0;
    SnitchOutputToFile(SnitchMessage);
    show_debug_message(SnitchMessage);
}