/// Returns whether UDP broadcast is enabled
/// This function will always return <false> is SNITCH_UDP_PERMITTED is set to <false>

function SnitchUDPGet()
{
    __SnitchInit();
    
    if (!SNITCH_UDP_PERMITTED) return false;
    
    return global.__snitchUDPEnabled;
}