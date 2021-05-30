/// Returns whether Snitch is able to log messages to disk
/// This function will always return <false> is SNITCH_LOG_PERMITTED is set to <false>

function SnitchLogGet()
{
    __SnitchInit();
    
    if (!SNITCH_LOG_PERMITTED) return false;
    
    return global.__snitchLogging;
}