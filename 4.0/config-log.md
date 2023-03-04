# Log Configuration

The macros on this page can be found in the `__SnitchConfigLog` script. They relate to the behaviour of Snitch when saving log messages (typically )

?> You should edit these macros to suit your own needs when using Snitch.

&nbsp;

## `SNITCH_LOG_PERMITTED`

*Typical value:* `true`

Controls whether logging to file should be allowed at all.

&nbsp;

## `SNITCH_LOG_ON_BOOT`

*Typical value:* `SNITCH_RUNNING_FROM_IDE`

Whether to boot the game with logging to file turned on or off. Logging to file can be turned on/off manually by calling `SnitchLogSet()`. Generally, you'll only want to set this to `true` if you're running development builds as logging messages to a file can be slow.

&nbsp;

## `SNITCH_ALLOW_LOG_BOOT_PARAMETER`

*Typical value:* `true`

Whether to allow logging to be toggled on by using the `-log` execution parameter. This is useful for in-production testing so you can turn on logging without the option normally being available to the end-user.

&nbsp;

## `SNITCH_LOG_BOOT_PARAMETER_CONFIRMATION`

*Typical value:* `("Logging enabled! You can find the logs in " + string(game_save_id))`

Pop-up message to show when the game is booted with the `-log` execution parameter.

&nbsp;

## `SNITCH_LOG_FILENAME`

*Typical value:* `"log#.txt"`

Name of the log files to save. Log files are typically saved in `game_save_id`.

!> Use a # symbol for the position of the log file index. If this isn't present then log files will overwrite each other!

&nbsp;

## `SNITCH_LOG_COUNT`

*Typical value:* `10`

Number of log files to store on disk. A new log file is created per game session (provided logging isn't disabled). The 0th log file is always the most recent.

&nbsp;

## `SNITCH_LOG_BUFFER_START_SIZE`

*Typical value:* `(1024*1024)`

Starting size of the Snitch logging buffer, in bytes. `1024*1024` bytes is 1 megabyte. This buffer is a `buffer_grow` type and will dynamically resize as more data is added.

?> The logging buffer is only created when a message is logged for the first time in a game session.