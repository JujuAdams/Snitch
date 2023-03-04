# Direct Logging/Networking

Whilst the `Snitch()` and `SnitchSoftError()` functions will write strings to the log file or broadcast over the local network, it may be useful to manage these two features yourself directly.

&nbsp;

## `SnitchSendStringToLogFile()`

_Returns:_ N/A (`undefined`)

|Name   |Datatype|Purpose                        |
|-------|--------|-------------------------------|
|`value`|any     |A value to concatenate together|
|`...`  |        |Further values to concatenate  |

This function stringifies and concatenates all supplied values together and write it to the log file. This function only works if logging is enabled.

&nbsp;

## `SnitchSendStringToNetwork()`

_Returns:_ N/A (`undefined`)

|Name   |Datatype|Purpose                        |
|-------|--------|-------------------------------|
|`value`|any     |A value to concatenate together|
|`...`  |        |Further values to concatenate  |

This function stringifies and concatenates all supplied values together and broadcasts it over UDP/TCP. This function only works if networking is enabled.