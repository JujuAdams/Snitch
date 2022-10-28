# `Snitch()`

_Returns:_ N/A (`undefined`)

|Name   |Datatype|Purpose                        |
|-------|--------|-------------------------------|
|`value`|any     |A value to concatenate together|
|`...`  |        |Further values to concatenate  |

This function is the fundamental message logging function in Snitch, and it effectively replaces `show_debug_message()` in your game.

`Snitch()` stringifies and concatenates all supplied values together. The resulting string is then:

1. Sent to the console
2. If logging is enabled, written to the log file
3. If networking is enabled, broadcast over UDP/TCP