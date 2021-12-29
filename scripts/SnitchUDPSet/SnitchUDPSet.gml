/// @param state
/// @param [port=SNITCH_UDP_DEFAULT_PORT]
/// @paarm [IP=SNITCH_UDP_DEFAULT_IP]

function SnitchSentrySet(_state, _port = SNITCH_UDP_DEFAULT_PORT, _ip = SNITCH_UDP_DEFAULT_IP)
{
    __SnitchInit();
    
    if (SnitchUDPGet() != _state)
    {
        if (_state)
        {
            if (SNITCH_UDP_PERMITTED)
            {
                global.__snitchUDPEnabled = true;
                global.__snitchUDPPort    = _port;
                global.__snitchUDPIP      = _ip;
                __SnitchTrace("UDP broadcast turned on. Using port ", _port, " and targetting IP address ", _ip);
            }
            else
            {
                __SnitchTrace("UDP broadcast cannot be turned on as SNITCH_UDP_PERMITTED is set to <false>");
            }
        }
        else
        {
            global.__snitchUDPEnabled = false;
            __SnitchTrace("UDP broadcast turned off");
        }
    }
    else if (_state)
    {
        if ((_port != global.__snitchUDPPort) || (_ip != global.__snitchUDPIP))
        {
            //TODO - Change port/IP as necessary
        }
    }
}