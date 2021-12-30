/// Returns whether Google Analytics integration is enabled
/// This function will always return <false> is SNITCH_UDP_PERMITTED is set to <false>

function SnitchGoogleAnalyticsGet()
{
    __SnitchInit();
    
    if (!SNITCH_GOOGLE_ANALYTICS_PERMITTED) return false;
    
    return global.__snitchGoogleAnalyticsEnabled;
}