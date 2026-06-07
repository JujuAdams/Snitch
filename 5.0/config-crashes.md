# Crash Configuration

The macros on this page can be found in the `__SnitchConfigCrash` script. They relate to the behaviour of Snitch when the game crashes (or, in technical terms, "throws an unhandled exception").

?> You should edit these macros to suit your own needs when using Snitch.

&nbsp;

## `SNITCH_CRASH_CAPTURE_COMPILED`

*Typical value:* `true`

`SNITCH_CRASH_CAPTURE_COMPILED` controls whether to capture crashes using Snitch's own exception handler. Depending on other configuration options, the crash handler can:
- Save a crash dump which a player can share with you
- Prompt the user to copy error data onto their clipboard
- Immediately send events to bug tracking services (sentry.io, GameAnalytics, Bugsnag)
- Broadcast a crash notification over UDP/TCP for local debugging

?> Snitch's exception handler is *not* mutually exclusive with `exception_unhandled_handler()` (Snitch hijacks calls to that function and executes the handler itself).

&nbsp;

## `SNITCH_CRASH_CAPTURE_FROM_IDE`

*Typical value:* `true`

Whilst Snitch's crash handler is really snazzy, it can make tracking down bugs a bit harder when you're running from the IDE during development. Setting this value to `false` will prevent Snitch from capturing crashes when running in debug mode from the IDE (i.e. running using F5/F6).

&nbsp;

## `SNITCH_CRASH_DUMP_FILENAME`

*Typical value:* `"crash.txt"`

Name of the crash dump file that is saved. This will typically be saved in `game_save_id`.

&nbsp;

## `SWITCH_CRASH_DUMP_MODE`

*Typical value:* `2`

How much data to save to disk when the game crashes. There are 4 modes:
- `0` Don't save any crash data
- `1` Save the exception struct that GameMaker generates to the clipboard. This is usually enough to locate the crash
- `2` Save the full crash event payload to disk. This will allow you to locate the crash as well as having a snapshot of the app state (set in the `__SnitchConfigAppState` script)
- `3` Compress and base64 encode full crash event payload in mode `3`, and save that

&nbsp;

## `SWITCH_CRASH_CLIPBOARD_MODE`

*Typical value:* `1`

Whether to ask the user if they want to copy the error message to their clipboard. This is useful in production to get crash data more easily from players. There are 4 modes:
- `0` Don't ask the player to copy crash data to their clipboard at all and just show the string defined by `SNITCH_CRASH_NO_CLIPBOARD_MESSAGE`
- `1` Allow the player to copy the exception struct that GameMaker generates to the clipboard
- `2` Copy full crash event payload to their clipboard as plaintext JSON
- `3` Compress and base64 encode the full crash event payload and copt that to the player's clipboard

All clipboard data is bookended with five hashes (`##### content #####`) to help make copy-pasting less error-prone.

&nbsp;

## `SNITCH_CRASH_NO_CLIPBOARD_MESSAGE`

*Typical value:* `("Oh no! The game has crashed.\n" + string(_struct.message) + "\n" + string(_struct.stacktrace))`

The pop-up message to show the player when the game crashes. This message will only be shown if `SNITCH_CRASH_OFFER_CLIPBOARD` is set to `0`. You can use the `_struct` variable to show parts of the GameMaker exception struct that triggered the crash.

!> If you don't get an error pop-up then you've got a syntax error somewhere in this macro. Check for typos!

&nbsp;

## `SNITCH_CRASH_CLIPBOARD_REQUEST_MESSAGE`

*Typical value:* `("Oh no! The game has crashed.\rWould you like to copy the error message to your clipboard?")`

The question to show when asking the player if they'd like to copy the error message to their clipboard. This message will only appear if `SWITCH_CRASH_CLIPBOARD_MODE` is set to `1` `2` or `3`.

!> Use \r rather than \n to work around a GameMaker bug in show_question() (runtime GMS2.3.2.426, 2021-05-05)

&nbsp;

## `SNITCH_CRASH_CLIPBOARD_ACCEPT_MESSAGE`

*Typical value:* `("The error message has been copied to your clipboard.")`

The confirmation message to show when the player copies the error message to their clipboard.