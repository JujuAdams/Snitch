/// Transmits a string over a network connection, either UDP or TCP. Useful for transmitting packets manually
/// 
/// @param string  String to transmit

function SnitchSendStringToNetwork(_string)
{
    __SnitchInit();
    
    if (SnitchNetworkGet())
    {
        //https://logging.apache.org/log4j/2.x/manual/layouts.html
        //https://logging.apache.org/log4j/2.x/log4j-1.2-api/apidocs/src-html/org/apache/log4j/layout/Log4j1XmlLayout.html
        
        static _buffer = buffer_create(1024, buffer_grow, 1);
        buffer_seek(_buffer, buffer_seek_start, 0);
        buffer_write(_buffer, buffer_text, _string);
        
        switch(SNITCH_NETWORK_MODE)
        {
            case 0:
                //Disabled
            break;
            
            case 1:
                if (global.__snitchNetworkTargetIP == undefined)
                {
            	    network_send_broadcast(global.__snitchNetworkSocket, global.__snitchNetworkTargetPort, _buffer, buffer_tell(_buffer));
                }
                else
                {
            	    network_send_udp_raw(global.__snitchNetworkSocket, global.__snitchNetworkTargetIP, global.__snitchNetworkTargetPort, _buffer, buffer_tell(_buffer));
                }
            break;
            
            case 2:
            	network_send_udp_raw(global.__snitchNetworkSocket, global.__snitchNetworkTargetIP, global.__snitchNetworkTargetPort ?? "127.0.0.1", _buffer, buffer_tell(_buffer));
            break;
        }
    }
}