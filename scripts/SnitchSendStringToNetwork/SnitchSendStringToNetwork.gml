/// Transmits a string over a network connection, either UDP or TCP. Useful for transmitting packets manually
/// 
/// @param string  String to transmit

function SnitchSendStringToNetwork(_string)
{
    __SnitchInit();
    
    if (SnitchNetworkGet())
    {
        if ((SNITCH_NETWORK_MODE == 2) && (!__SnitchState().__NetworkConnected || (array_length(__SnitchState().__NetworkPendingMessages) > 0)))
        {
            if (!__SnitchState().__NetworkAbandoned)
            {
                array_push(__SnitchState().__NetworkPendingMessages, _string);
                array_delete(__SnitchState().__NetworkPendingMessages, 0, max(0, array_length(__SnitchState().__NetworkPendingMessages) - SNITCH_NETWORK_PENDING_MESSAGE_LIMIT));
            }
        }
        else
        {
            __SnitchSendStringToNetwork(_string);
        }
    }
}

function __SnitchSendStringToNetwork(_string)
{
    //https://logging.apache.org/log4j/2.x/manual/layouts.html
    //https://logging.apache.org/log4j/2.x/log4j-1.2-api/apidocs/src-html/org/apache/log4j/layout/Log4j1XmlLayout.html
    
    static _buffer = buffer_create(1024, buffer_grow, 1);
    buffer_seek(_buffer, buffer_seek_start, 0);
    buffer_write(_buffer, buffer_string, _string);
    
    switch(SNITCH_NETWORK_MODE)
    {
        case 0:
            //Disabled
        break;
        
        case 1:
            if (__SnitchState().__NetworkTargetIP == undefined)
            {
            	network_send_broadcast(__SnitchState().__NetworkSocket, __SnitchState().__NetworkTargetPort, _buffer, buffer_tell(_buffer));
            }
            else
            {
            	network_send_udp_raw(__SnitchState().__NetworkSocket, __SnitchState().__NetworkTargetIP, __SnitchState().__NetworkTargetPort, _buffer, buffer_tell(_buffer));
            }
        break;
        
        case 2:
            network_send_raw(__SnitchState().__NetworkSocket, _buffer, buffer_tell(_buffer));
        break;
    }
}