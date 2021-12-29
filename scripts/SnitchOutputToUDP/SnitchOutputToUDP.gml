/// @param data      Value to write to the log file
/// @param [format]  Format to use for the data. If not specified, the input data is stringified

function SnitchOutputToUDP(_data, _format = undefined)
{
    if (argument_count == 0) __SnitchError("SnitchOutputToUDP() must be given data to output");
    
    __SnitchInit();
    
    if (SnitchUDPGet())
    {
        switch(_format)
        {
            case undefined:
                buffer_write(global.__snitchBuffer, buffer_text, _data);
                buffer_write(global.__snitchBuffer, buffer_u8, 10);
            break;
            
            default:
                __SnitchError("Data format \"", _format, "\" not recognised");
            break;
        }
        
        //TODO - Broadcast UDP data
    }
}