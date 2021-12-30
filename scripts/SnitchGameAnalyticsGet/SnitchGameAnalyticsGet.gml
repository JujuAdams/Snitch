/// Returns whether the GameAnalytics integration is enabled
/// This function will always return <false> is SNITCH_GAMEANALYTICS_PERMITTED is set to <false>

function SnitchGameAnalyticsGet()
{
    __SnitchInit();
    
    if (!SNITCH_GAMEANALYTICS_PERMITTED) return false;
    
    return global.__snitchGameAnalyticsEnabled;
}