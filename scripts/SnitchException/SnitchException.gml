/// Creates a new Snitch error, based on a GameMaker exception struct, that can be logged in multiple ways
/// Please see SnitchError() for more information
/// 
/// @param exceptionStruct  A GameMaker exception struct e.g. created by try...catch, or passed into an unhandled exception handler

function SnitchException(_struct)
{
    return (new __SnitchClassError("")).__SetException(_struct);
}