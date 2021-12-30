/// Sets whether Snitch should enable GameAnalytics integration
///   N.B. The GameAnalytics integration cannot be enabled if SNITCH_GAMEANALYTICS_PERMITTED is set to <false>
/// Details of the GameAnalytics integration, including the HTTP endpoint to use, can be set in __SnitchConfig()
/// 
/// @param state

function SnitchGameAnalyticsSet(_state)
{
    __SnitchInit();
    
    if (SnitchGameAnalyticsGet() != _state)
    {
        if (_state)
        {
            if (SNITCH_GAMEANALYTICS_PERMITTED)
            {
                global.__snitchGameAnalyticsEnabled = true;
                __SnitchTrace("GameAnalytics integration turned on");
            }
            else
            {
                __SnitchTrace("GameAnalytics integration cannot be turned on as SNITCH_GAMEANALYTICS_PERMITTED is set to <false>");
            }
        }
        else
        {
            global.__snitchGameAnalyticsEnabled = false;
            __SnitchTrace("GameAnalytics integration turned off");
        }
    }
}