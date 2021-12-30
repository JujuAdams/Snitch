/// Returns whether the sentry.io integration is enabled
/// This function will always return <false> is SNITCH_SENTRY_PERMITTED is set to <false>

function SnitchSentryGet()
{
    __SnitchInit();
    
    if (!SNITCH_SENTRY_PERMITTED) return false;
    
    return global.__snitchSentryEnabled;
}