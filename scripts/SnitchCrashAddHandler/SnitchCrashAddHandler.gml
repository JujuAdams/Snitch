/// Adds a function to be called when the game crashes
/// 
/// Multiple functions can be added and they are executed in the order that they're added
/// Functions added with SnitchCrashAddHandler() are executed after the function added by
/// the native exception_unhandled_handler() feature

function SnitchCrashAddHandler(_function)
{
    __SnitchInit();
    
    var _array = global.__snitchExceptionHandlerArray;
    var _i = 0;
    repeat(array_length(_array))
    {
        if (_array[_i] == _function)
        {
            __SnitchTrace("Warning! Function already added as a function handler (", _array[_i], ")");
            break;
        }
        
        ++_i;
    }
    
    array_push(_array, _function);
}