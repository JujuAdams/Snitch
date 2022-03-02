/// Broadcasts a string over UDP. Useful for managing the UDP broadcasts manually
/// 
/// @param string  String to broadcast over UDP

global.__snitchUDPSocket = network_create_socket(network_socket_udp);

function SnitchSendStringToUDP(_string)
{
    __SnitchInit();
    
    if (SnitchUDPGet())
    {
        //https://logging.apache.org/log4j/2.x/manual/layouts.html
        //https://logging.apache.org/log4j/2.x/log4j-1.2-api/apidocs/src-html/org/apache/log4j/layout/Log4j1XmlLayout.html
        
        var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
        buffer_write(_buffer, buffer_text, _string);
        
        if (SNITCH_UDP_DEFAULT_IP == undefined)
        {
    	    network_send_broadcast(global.__snitchUDPSocket, SNITCH_UDP_DEFAULT_PORT, _buffer, buffer_get_size(_buffer));
        }
        else
        {
    	    network_send_udp_raw(global.__snitchUDPSocket, SNITCH_UDP_DEFAULT_IP, SNITCH_UDP_DEFAULT_PORT, _buffer, buffer_get_size(_buffer));
        }
        
    	buffer_delete(_buffer);
    }
}