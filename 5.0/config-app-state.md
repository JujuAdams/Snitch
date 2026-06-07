# App State

Snitch will record the state of the game application in a few different situations:

1. When opening a new log file
2. When saving a crash dump, and `SWITCH_CRASH_DUMP_MODE` is set to `2` or `3`
3. When copying an error message to the player's clipboard, and `SWITCH_CRASH_CLIPBOARD_MODE` is set to `2` or `3`

The app state itself is, in reality, a struct and is defined in `__SnitchConfigAppState()`. This function will be executed every time Snitch requires the app state and, as such, this function can track changing values (such as what level the player is on).

?> You should expand and adapt the app state struct to make debugging easier.

!> Be very careful when writing dynamic values into the app state struct! If GameMaker fails to read the variable you're referencing then that could result in numerous hard-to-diagnose problems including crash dumps not being created, error messages on the clipboard being corrupted etc.