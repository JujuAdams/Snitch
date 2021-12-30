/// Broadcasts a string over UDP. Useful for managing the UDP broadcasts manually
/// 
/// @param string  String to broadcast over UDP

function SnitchSendStringToUDP(_string)
{
    __SnitchInit();
    
    if (SnitchUDPGet())
    {
        //TODO
    }
}