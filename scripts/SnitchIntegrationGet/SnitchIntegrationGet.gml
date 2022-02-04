/// Returns whether integrations are enabled
/// This function will always return <false> is SNITCH_UDP_PERMITTED is set to <false>

function SnitchIntegrationGet()
{
    __SnitchInit();
    
    if (SNITCH_INTEGRATION_MODE <= 0) return false;
    
    return global.__snitchIntegrationEnabled;
}