/// Creates a new Snitch error, based on a GameMaker exception struct, that can be logged in multiple ways
/// Please see SnitchError() for more information
/// 
/// @param exceptionStruct  A GameMaker exception struct e.g. created by try...catch, or passed into an unhandled exception handler

function SnitchException(_struct)
{
    var _event = new __SnitchClassError();
    _event.__SetException(_struct);
    return _event;
}