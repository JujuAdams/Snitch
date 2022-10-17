/// Returns whether integrations are enabled
/// This function will always return <false> if SNITCH_INTEGRATION_MODE is set to 0

function SnitchIntegrationGet()
{
    __SnitchInit();
    
    if (SNITCH_INTEGRATION_MODE <= 0) return false;
    
    return global.__snitchIntegrationEnabled;
}