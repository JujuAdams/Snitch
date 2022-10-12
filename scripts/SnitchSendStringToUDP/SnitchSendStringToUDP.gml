/// Broadcasts a string over UDP. Useful for managing the UDP broadcasts manually
/// 
/// @param string  String to broadcast over UDP

function SnitchSendStringToUDP(_string)
{
    __SnitchInit();
    
    if (SnitchUDPGet())
    {
        //https://logging.apache.org/log4j/2.x/manual/layouts.html
        //https://logging.apache.org/log4j/2.x/log4j-1.2-api/apidocs/src-html/org/apache/log4j/layout/Log4j1XmlLayout.html
        
        static _socket = network_create_socket(network_socket_udp);
        static _buffer = buffer_create(1024, buffer_grow, 1);
        buffer_seek(_buffer, buffer_seek_start, 0);
        buffer_write(_buffer, buffer_text, _string);
        
        if (global.__snitchUDPIP == undefined)
        {
    	    network_send_broadcast(_socket, global.__snitchUDPPort, _buffer, buffer_tell(_buffer));
        }
        else
        {
    	    network_send_udp_raw(_socket, global.__snitchUDPIP, global.__snitchUDPPort, _buffer, buffer_tell(_buffer));
        }
    }
}