# `SnitchSoftError()`

_Returns:_ N/A (`undefined`)

|Name   |Datatype|Purpose                        |
|-------|--------|-------------------------------|
|`value`|any     |A value to concatenate together|
|`...`  |        |                               |

This function allows you to record and track warnings and **non-fatal** errors in your game. This is very useful when combined with `try...catch` or other edge-case defensive programming techniques.

`SnitchSoftError()` stringifies and concatenates all supplied values together, and attaches a UUID such that the specific error event can be identified later. The resulting string is then:

1. Sent to the console
2. If logging is enabled, written to the log file
3. If networking is enabled, broadcast over UDP/TCP
4. If a bug tracking service is enabled, sent to the chosen service