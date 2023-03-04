/// Sets whether Snitch should enable network transmission
///   N.B. Network transmission cannot be enabled unless the relevant macros in __SnitchConfigNetwork() are set to <true>
/// 
/// @param state
/// @param [outgoingPort]
/// @param [targetPort]
/// @paarm [targetIP]

function SnitchNetworkSet(_state, _outgoingPort = SNITCH_NETWORK_DEFAULT_OUTGOING_PORT, _receiverPort = SNITCH_NETWORK_DEFAULT_RECEIVER_PORT, _receiverIP = SNITCH_NETWORK_DEFAULT_RECEIVER_IP)
{
    __SnitchInit();
    
    if (SnitchNetworkGet() != _state)
    {
        var _funcCloseSocket = function()
        {
            if (__SnitchState().__NetworkSocket != undefined)
            {
                __SnitchTrace("Destroying socket ", __SnitchState().__NetworkSocket);
                network_destroy(__SnitchState().__NetworkSocket);
                __SnitchState().__NetworkSocket = undefined;
                __SnitchState().__NetworkConnected = false;
            }
        }
        
        var _funcOpenSocket = function()
        {
            if (__SnitchState().__NetworkSocket == undefined)
            {
                var _type = (SNITCH_NETWORK_MODE == 1)? network_socket_udp : network_socket_tcp;
                if (__SnitchState().__NetworkOutgoingPort == undefined)
                {
                    __SnitchState().__NetworkSocket = network_create_socket(_type);
                }
                else
                {
                    __SnitchState().__NetworkSocket = network_create_socket_ext(_type, __SnitchState().__NetworkOutgoingPort);
                }
                
                if (__SnitchState().__NetworkSocket >= 0)
                {
                    __SnitchTrace("Created socket ", __SnitchState().__NetworkSocket, " for ", (SNITCH_NETWORK_MODE == 1)? "UDP" : "TCP", " traffic");
                    __SnitchTrace("Attempting TCP connection");
                    __SnitchAttemptTCPConnection();
                }
                else
                {
                    __SnitchTrace("Failed to create socket");
                    __SnitchState().__NetworkConnected = false;
                }
            }
        }
        
        if (_state)
        {
            if (SNITCH_NETWORK_MODE > 0)
            {
                __SnitchState().__NetworkEnabled      = true;
                __SnitchState().__NetworkOutgoingPort = _outgoingPort;
                __SnitchState().__NetworkTargetPort   = _receiverPort;
                __SnitchState().__NetworkTargetIP     = _receiverIP;
                
                _funcCloseSocket();
                _funcOpenSocket();
                
                __SnitchTrace("Network transmission turned on, using ", (SNITCH_NETWORK_MODE == 1)? "UDP" : "TCP", ", outgoing port ", _outgoingPort, ", target port ", _receiverPort, ", target IP ", _receiverIP);
            }
            else
            {
                __SnitchTrace("Network transmission cannot be toggled as it has not been enabled (see SNITCH_NETWORK_MODE)");
            }
        }
        else
        {
            _funcCloseSocket();
            
            __SnitchState().__NetworkEnabled = false;
            __SnitchTrace("Network transmission turned off");
        }
    }
    else if (_state)
    {
        if ((_receiverPort != __SnitchState().__NetworkOutgoingPort) || (_receiverPort != __SnitchState().__NetworkTargetPort) || (_receiverIP != __SnitchState().__NetworkTargetIP))
        {
            _funcCloseSocket();
            _funcOpenSocket();
            
            __SnitchState().__NetworkOutgoingPort = _outgoingPort;
            __SnitchState().__NetworkTargetPort   = _receiverPort;
            __SnitchState().__NetworkTargetIP     = _receiverIP;
            
            __SnitchTrace("Networking details changed, using ", (SNITCH_NETWORK_MODE == 1)? "UDP" : "TCP", ", outgoing port ", _outgoingPort, ", target port ", _receiverPort, ", target IP ", _receiverIP);
        }
    }
}