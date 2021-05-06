<h1 align="center">Snitch 1.1.1</h1>

<p align="center">Logging and crash handling system for GameMaker Studio 2.3.2</p>

<p align="center"><b>@jujuadams</b></p>

<p align="center">Chat about Snitch on the <a href="https://discord.gg/8krYCqr">Discord server</a></p>

&nbsp;

&nbsp;

Snitch is a logging and crash handling tool that helps smooth the debugging process. Snitch allows you to capture crash information in a file on disk, as well as logging debug messages that the game creates. Additionally, the header for each log file contains a bunch of information about the player's machine as well as details for the build of your game that they're running. Putting all this information together will greatly improve your chances of fixing bugs, especially bugs that have been discovered in the wild by players.

&nbsp;

Snitch has only four functions:

- `Snitch(value, ...)` outputs debug messages (and can be renamed as you wish). If logging is turned on, these messages will be written to a file on disk
- `SnitchCrashCollect()` reads the crash dump from disk and returns it, if any is found
- `SnitchLogSet(state)` turns file logging on and off
- `SnitchLogGet()` returns whether file logging is on or off

Snitch's behaviour can be adjusted by editing macros found in `__SnitchConfig()`. This function is commented with details on what each macro controls.

&nbsp;

### Logging

Logging can be set up to store messages from only a specific function - `Snitch()` - or to capture debug messages from all calls to `show_debug_message()`. Logging can be toggled with a function call, can be set to always be on (via `SNITCH_LOG_DEFAULT`), or can be activated when the game is booted using an execution parameter (`-log`). This last feature is especially useful for production builds as it allows logging to be activated by players. Because behaviour is controlled largely with macros, Snitch can be controlled by using GameMaker's configurations.

**Please note** that because logging involves file access, this can incur a non-trivial performance penalty in your game. It is recommended that you do not release production builds with logging forced on.

&nbsp;

### Crash Dumps

Snitch will save a small file to disk whenever a crash happens - this is just the exception struct JSON encoded. When `SnitchCrashCollect()` is called, Snitch will scan for the crash dump file, attempt to decode it, delete the crash dump, then return the exception struct that was saved to the file (as a struct). You can then do whatever you want with that! A dedicated programmer might send that crash data off to a server (such as [sentry.io](https://sentry.io/)) automatically for later analysis.

Additionally, Snitch can be set up to prompt the user to copy the exception data to their clipboard. This is especially helpful for crash reporting as it reduces the friction for players to report issues with your game.
