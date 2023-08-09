# Direct Logging/Networking

Whilst the `Snitch()` and `SnitchSoftError()` functions will write strings to the log file or broadcast over the local network, it may be useful to manage these two features yourself directly.

&nbsp;

## `SnitchLogGetString()`

_Returns:_ String, logged by a call to `Snitch()`, `SnitchSoftError()`, or an internal Snitch debug message

|Name   |Datatype|Purpose                                                                                              |
|-------|--------|-----------------------------------------------------------------------------------------------------|
|`index`|integer |Which logged string to retrieve, from `0` (most recent) to `SNITCH_IN_GAME_LOG_SIZE-1` (least recent)|

If an invalid index is passed to this function then and empty string is returned. If the `index` argument is specified as the keyboard `all` then a newline-separated string that contains all logged strings is returned.

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