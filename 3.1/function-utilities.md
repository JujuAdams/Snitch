# Utilities

The functions on this page are utilities that have general applicability that can be used inside or outside of Snitch. Whether you use them yourself or not, all functions on this page are required for Snitch to operate correctly.

&nbsp;

## `SnitchSteamInitializedSafe()`

_Returns:_ Boolean, whether Steam has been initialized

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Does not crash (and returns `false`) if YoYoGames' Steam extension hasn't been imported into the project.

&nbsp;

## `SnitchConvertToUnixTime(time)`

_Returns:_ Number, the number of seconds that have passed from the Unix epoch to the provided timestamp

|Name  |Datatype|Purpose                                        |
|------|--------|-----------------------------------------------|
|`time`|number  |The target timestamp to use for the calculation|

&nbsp;

## `SnitchFormatTimestamp(time)`

_Returns:_ String, a date-time string formatted according to RFC3339

|Name  |Datatype|Purpose                                       |
|------|--------|----------------------------------------------|
|`time`|number  |The target timestamp to use for the formatting|

You can find the RFC 3339 specification [here](https://www.rfc-editor.org/rfc/rfc3339).

&nbsp;

## `SnitchGenerateUUID4String([hyphenate=false])`

_Returns:_ String, a random UUID-4 string

|Name         |Datatype|Purpose                                                  |
|-------------|--------|---------------------------------------------------------|
|`[hyphenate]`|boolean |Whether to hyphenate the UUID string. Defaults to `false`|

This function does not use native GameMaker randomisation functions and instead uses its own internal PRNG. The UUID returned is formatted according to the RFC 4122 specification, which can be found [here](https://www.cryptosys.net/pki/uuid-rfc4122.html).

&nbsp;

## `SnitchURLEncode(string)`

_Returns:_ String, the URL-encoded equivalent of the input string

|Name    |Datatype|Purpose                 |
|--------|--------|------------------------|
|`string`|string  |The string to URL-encode|

Also known as "percent encoding". This function is approximately built to the RFC 3986 specification, which can be found [here](https://datatracker.ietf.org/doc/html/rfc3986).