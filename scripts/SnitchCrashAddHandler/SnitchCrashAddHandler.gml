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