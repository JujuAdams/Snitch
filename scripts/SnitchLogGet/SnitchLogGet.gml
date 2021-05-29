/// Gets whether Snitch is saving debug message to file

function SnitchLogGet()
{
    __SnitchInit();
    
    if (!SNITCH_LOG_PERMITTED) return false;
    
    return global.__snitchLogging;
}