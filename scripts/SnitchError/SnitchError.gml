/// Creates a new Snitch error that can be logged/broadcast/transmitted in multiple ways
///
///   N.B. Errors won't do anything unless a method is called!
/// 
/// The error message itself is built from concatenating values passed into the SnitchError()
/// function call. For example:
/// 
///   SnitchError("Player has ", itemCount, " but this doesn't match ", cachedItemCount).SendAll();
/// 
/// This will concatenate those strings and numbers together, then send the error message to
/// all the services that have been configured and enabled.
/// 
/// Snitch error structs have a number of methods that control how the error struct should be
/// shared with other services. These methods can be chained together. For example, the following
/// code will output an error message to the console and to a log file but nothing else:
/// 
///   SnitchError("Player is outside the level?!").SendConsole().SendLog();
/// 
/// Below is all the methods that are available. Make sure you call at least one of these!
/// 
///   .SendConsole()     - Outputs the event to the debug console (i.e. calls show_debug_message())
///   .SendLog()         - Writes the event to the log file, if enabled
///   .SendNetwork()     - Transmits the event over the network, if enabled
///   .SendIntegration() - Transmits the event over HTTP to whichever API integration is enabled (if any)
///                        If request backups are enabled, a request backup is also saved. See SNITCH_REQUEST_BACKUP_ENABLE for more information
///   .SendAll()         - Sends the event to all of the above
///   .SendLocal()       - Calls .SendConsole(), .SendLog(), and .SendNetwork()
/// 
/// @param value
/// @param [value]...

function SnitchError()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    return new __SnitchClassError(_string);
}