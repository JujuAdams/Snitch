/// Returns whether log-to-file is enabled
/// This function will always return <false> is SNITCH_LOG_FILE_PERMITTED is set to <false>

function SnitchLogFileGet()
{
    __SnitchInit();
    
    if (!SNITCH_LOG_FILE_PERMITTED) return false;
    
    return global.__snitchLogToFileEnabled;
}