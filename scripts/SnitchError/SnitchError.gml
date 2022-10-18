/// Creates a new Snitch error that i logged/broadcast/transmitted in multiple ways.
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
    
    return (new __SnitchClassError()).__SetMessage(_string);
}