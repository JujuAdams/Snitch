/// Gets whether Snitch is saving debug message to file

function SnitchLogGet()
{
    __SnitchInit();
    
    return global.__snitchLogging;
}