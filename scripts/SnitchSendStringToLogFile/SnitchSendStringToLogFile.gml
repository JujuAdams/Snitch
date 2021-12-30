/// Writes a string to Snitch's log file. Useful for managing the log file manually
/// 
/// @param dataStruct  String to write to the log file

function SnitchSendStringToLogFile(_data)
{
    __SnitchInit();
    
    if (SnitchLogFileGet())
    {
        switch(SNITCH_LOG_FILE_FORMAT)
        {
            case 0:
                if (is_struct(_data))
                {
                    if (variable_struct_exists(_data, "message"))
                    {
                        buffer_write(global.__snitchLogFileBuffer, buffer_text, _data.message);
                        buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    }
                    else
                    {
                        buffer_write(global.__snitchLogFileBuffer, buffer_text, json_stringify(_data));
                        buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                    }
                }
                else
                {
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, _data);
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                }
            break;
            
            case 1:
                if (is_struct(_data))
                {
                    buffer_write(global.__snitchLogFileBuffer, buffer_text, json_stringify(_data));
                    buffer_write(global.__snitchLogFileBuffer, buffer_u8, 10);
                }
                else
                {
                    __SnitchError("Data must be provided as a struct for JSON log file format");
                }
            break;
            
            default:
                __SnitchError("File format \"", SNITCH_LOG_FILE_FORMAT, "\" not recognised");
            break;
        }
        
        buffer_save_ext(global.__snitchLogFileBuffer, global.__snitchZerothLogFile, 0, buffer_tell(global.__snitchLogFileBuffer));
    }
}