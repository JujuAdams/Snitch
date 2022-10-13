//What kind of networking connection to use for transmitting log packets
//There are 2 modes:
//   0:  No network transmission permitted
//   1:  UDP
//   2:  TCP
#macro SNITCH_NETWORK_MODE  0

//Whether to boot the game with network transmission turned on or off. Network transmission can be turned on/off manually by calling SnitchNetworkSet()
//Generally, you'll only want to set this to <true> if you're running dev/debug builds as emitting lots of packets can adversely affect your players
#macro SNITCH_NETWORK_ON_BOOT  (SNITCH_RUNNING_FROM_IDE)

//Default outgoing port to use to for packets. This can be overridden with SnitchNetworkSet()
//Set to <undefined> to automatically choose an open port
#macro SNITCH_NETWORK_DEFAULT_OUTGOING_PORT  undefined

//Default target port to use to for packets. This can be overridden with SnitchNetworkSet()
#macro SNITCH_NETWORK_DEFAULT_RECEIVER_PORT  9992

//Default target IP address to send packets to. This can be overridden with SnitchNetworkSet()
//If you're using UDP transmission, set this macro to <undefined> to broadcast packets over LAN
//Any device listening for packets on the correct port will be able to receive them
#macro SNITCH_NETWORK_DEFAULT_RECEIVER_IP  undefined