/// Sets whether Snitch should enable Google Analytics integration
///   N.B. The Google Analytics integration cannot be enabled if SNITCH_GOOGLE_ANALYTICS_PERMITTED is set to <false>
/// Details of the Google Analytics integration, including the HTTP endpoint to use, can be set in __SnitchConfig()
/// 
/// @param state

function SnitchGoogleAnalyticsSet(_state)
{
    __SnitchInit();
    
    if (SnitchGoogleAnalyticsGet() != _state)
    {
        if (_state)
        {
            if (SNITCH_GOOGLE_ANALYTICS_PERMITTED)
            {
                global.__snitchGoogleAnalyticsEnabled = true;
                __SnitchTrace("Google Analytics integration turned on");
            }
            else
            {
                __SnitchTrace("Google Analytics integration cannot be turned on as SNITCH_GOOGLE_ANALYTICS_PERMITTED is set to <false>");
            }
        }
        else
        {
            global.__snitchGoogleAnalyticsEnabled = false;
            __SnitchTrace("Google Analytics integration turned off");
        }
    }
}