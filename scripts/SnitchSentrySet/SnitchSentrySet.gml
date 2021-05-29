/// Sets whether Snitch should send data to a sentry.io endpoint
///   N.B. sentry.io communication cannot be enabled if SNITCH_SENTRY_PERMITTED is set to <false>
/// Details of the sentry.io integration, including the HTTP endpoint to use, can be set in __SnitchConfig()
///
/// @param state

function SnitchSentrySet(_state)
{
    __SnitchInit();
    
    if (SnitchSentryGet() != _state)
    {
        if (_state)
        {
            if (SNITCH_SENTRY_PERMITTED)
            {
                global.__snitchSentryEnabled = true;
                __SnitchTrace("sentry.io integration turned on");
            }
            else
            {
                __SnitchTrace("sentry.io integration cannot be turned on as SNITCH_SENTRY_PERMITTED is set to <false>");
            }
        }
        else
        {
            global.__snitchSentryEnabled = false;
            __SnitchTrace("sentry.io integration turned off");
        }
    }
}