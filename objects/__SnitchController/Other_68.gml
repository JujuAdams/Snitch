switch(async_load[? "type"])
{
    case network_type_disconnect:
        __SnitchTrace("TCP connection lost, retrying");
        __SnitchState().__NetworkConnectionAttempts = 0;
        __SnitchState().__NetworkConnected = false;
        __SnitchState().__NetworkAbandoned = false;
        __SnitchAttemptTCPConnection();
    break;
    
    case network_type_non_blocking_connect:
        if (async_load[? "succeeded"])
        {
            __SnitchTrace("TCP connection established");
            __SnitchState().__NetworkConnected = true;
            __SnitchState().__NetworkAbandoned = false;
        }
        else
        {
            __SnitchState().__NetworkConnectionAttempts++;
            if (__SnitchState().__NetworkConnectionAttempts >= SNITCH_NETWORK_CONNECTION_ATTEMPTS)
            {
                __SnitchTrace("TCP connection failed to establish despite ", __SnitchState().__NetworkConnectionAttempts, " attempts, giving up");
                __SnitchState().__NetworkConnected = false;
                __SnitchState().__NetworkAbandoned = true;
            }
            else
            {
                __SnitchTrace("TCP connection failed to establish, retrying");
                __SnitchAttemptTCPConnection();
            }
        }
    break;
}