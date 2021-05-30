/// Creates a new event and returns the event struct itself. The event will also be outputted to the console (and can also be logged to file)
/// When used with sentry.io, events will be sent to the sentry.io server so that you can find problem areas to improve upon
/// Whilkst this function is mostly intended to be used with the sentry.io integration, it can also be used offline
/// Event structs have a few methods that can be used to contextualise data
///   N.B. The .Finish() method must be called on each and every event struct
/// 
/// You can (and maybe should?) rename this function to whatever you want e.g. debugEvent()
/// 
/// @param value
/// @param [value]...

function SnitchEvent()
{
    __SnitchInit();
    
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    return new __SnitchClassEvent(_string);
}