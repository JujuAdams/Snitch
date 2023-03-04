/// Writes a string to Snitch's log file. Useful for managing the log file manually
/// 
/// @param data  Value to write to the log file

function SnitchSendStringToLogFile(_data)
{
    __SnitchInit();
    
    if (SnitchLogGet())
    {
        buffer_write(__SnitchState().__LogFileBuffer, buffer_text, string(_data));
        buffer_write(__SnitchState().__LogFileBuffer, buffer_u8, 10);
        buffer_save_ext(__SnitchState().__LogFileBuffer, __SnitchState().__ZerothLogFile, 0, buffer_tell(__SnitchState().__LogFileBuffer));
    }
}