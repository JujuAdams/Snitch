//Controls whether UDP broadcast should be allowed at all
//This very likely should be turned off for production as you don't want to be broadcasting UDP packets unnecessarily
//   N.B. UDP broadcast will default on boot to being disabled even if SNITCH_UDP_PERMITTED is <true>
//        SnitchUDPSet(true) should be called to enable it only if the game is running in a development or debugging mode
#macro SNITCH_UDP_PERMITTED  false

//Default port to use to broadcast UDP packets. This can be overridden with SnitchUDPSet()
#macro SNITCH_UDP_DEFAULT_PORT  9991

//Default IP address to send UDP packets to for receiving. This can be overridden with SnitchUDPSet()
//Set his macro to <undefined> to broadcast packets over LAN. Any device listening for packets on the correct port will be able to receive them
#macro SNITCH_UDP_DEFAULT_IP  undefined