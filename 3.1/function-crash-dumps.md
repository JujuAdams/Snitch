# Crash Dumps

Snitch has two functions to interact with the automatically-created crash dumps. If you're using bug tracking services you can largely ignore these functions, but if you'd like to create your own bug reporting system then you may find them useful.

&nbsp;

## `SnitchCrashDumpCollect()`

_Returns:_ N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Checks whether a crash dump exists on disk and returns it if so. If the crash dump couldn't be parsed or no crash dump exists, this function returns `undefined`.

If a crash dump exists, this function returns either a GameMaker exception struct or the app state struct, depending on what `SWITCH_CRASH_DUMP_MODE` was used to create the crash dump.

&nbsp;

## `SnitchCrashDumpDelete()`

_Returns:_ N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Deletes the crash dump from disk, if one exists.