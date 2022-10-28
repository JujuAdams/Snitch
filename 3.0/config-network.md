# Network Configuration

The macros on this page can be found in the `__SnitchConfigNetwork` script. They relate to the behaviour of Snitch when sending packets over UDP/TCP to local debugging tools.

!> You should edit these macros to suit your own needs when using Snitch.

&nbsp;

## `SNITCH_NETWORK_MODE`

*Typical value:* `0`

What kind of networking connection to use for transmitting log packets. There are 2 modes:
- `0` No network transmission permitted
- `1` UDP (either LAN broadcast or to a specific IP, see below)
- `2` TCP

!> When using TCP connection mode, Snitch will call `network_set_config()` and change the timeout for connections to 5 seconds. In GameMaker, this is regretably a global setting and will affect all other networking connections.

&nbsp;

## `SNITCH_NETWORK_ON_BOOT`

*Typical value:* `SNITCH_RUNNING_FROM_IDE`

Whether to boot the game with network transmission turned on or off. Network transmission can be turned on/off manually by calling `SnitchNetworkSet()`.

!> Unless supplying builds for QA etc. you'll usually only want to set this macro to `true` if you're creating development builds. Emitting lots of packets can adversely affect performance of your game but, more importantly, it can also represent a privacy and security risk for players.

&nbsp;

## `SNITCH_NETWORK_DEFAULT_OUTGOING_PORT`

*Typical value:* `undefined`

Default outgoing port to use to for packets. This can be overridden with `SnitchNetworkSet()`. Set to `undefined` to automatically choose an open port.

&nbsp;

## `SNITCH_NETWORK_DEFAULT_RECEIVER_PORT`

*Typical value:* `9993`

Default target port to use to for packets. This can be overridden with `SnitchNetworkSet()`.

&nbsp;

## `SNITCH_NETWORK_DEFAULT_RECEIVER_IP`

*Typical value:* `undefined`

Default target IP address to send packets to. This can be overridden with `SnitchNetworkSet()`. If you're using UDP transmission, set this macro to `undefined` to broadcast packets over LAN. Any device listening for packets on the correct port will be able to receive them.

&nbsp;

## `SNITCH_NETWORK_PENDING_MESSAGE_LIMIT`

*Typical value:* `50`

How many messages to queue when a TCP connection is pending.

&nbsp;

## `SNITCH_NETWORK_CONNECTION_TIMEOUT`

*Typical value:* `5000`

How long to wait, in milliseconds, before giving up on a pending TCP connection and retrying.

&nbsp;

## `SNITCH_NETWORK_CONNECTION_ATTEMPTS`

*Typical value:* `5`

How many times to attempt a TCP connection before giving up for good.