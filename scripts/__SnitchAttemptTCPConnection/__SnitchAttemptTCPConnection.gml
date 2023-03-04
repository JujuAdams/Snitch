function __SnitchAttemptTCPConnection()
{
    if ((__SnitchState().__NetworkSocket != undefined) && (__SnitchState().__NetworkSocket >= 0) && (SNITCH_NETWORK_MODE == 2))
    {
        network_connect_raw_async(__SnitchState().__NetworkSocket, __SnitchState().__NetworkTargetIP ?? "127.0.0.1", __SnitchState().__NetworkTargetPort);
        __SnitchState().__NetworkConnected = false;
    }
    else if (SNITCH_NETWORK_MODE == 1)
    {
        //UDP is always connected cos we're sending packets blind
        __SnitchState().__NetworkConnected = true;
    }
    else
    {
        __SnitchState().__NetworkConnected = false;
    }
}