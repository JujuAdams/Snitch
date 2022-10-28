# Aysnc Event Hooks

When using networking or bug tracking services, Snitch has to be able to collect events that GameMaker produces. As a result, for Snitch to work properly, both of these functions must be present in a persistent instance that is never deactivated.

&nbsp;

## `SnitchNetworkingAsyncEvent()`

_Returns:_ N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Required for the UDP/TCP networking feature. This should be executed once a frame in the `Async - Networking` event in a single persistent instance that is never deactivated.

&nbsp;

## `SnitchHTTPAsyncEvent()`

_Returns:_ N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Required for the bug tracking feature. This should be executed once a frame in the `Async - HTTP` event in a single persistent instance that is never deactivated.