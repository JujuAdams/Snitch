//Name of the log files to save. Use a # symbol for number position
#macro  SNITCH_LOG_NAME  "log#.txt"

//Number of log files to store. A new log file is created every time the game is run (the 0th log file is always the latest)
//Set SNITCH_LOG_COUNT to 0 to permanently turn off logging. Turning off logging will not prevent the crash handler from running
#macro  SNITCH_LOG_COUNT  10

//Whether to boot the game with logging turned on or off
//Logging can be turned on/off manually by calling SnitchLogSet()
#macro  SNITCH_LOG_DEFAULT  true

//Whether to redirect all uses of show_debug_message() to the Snitch() logging function
//This means show_debug_message() calls will be loggged to a file (provided Snitch is logging)
//  N.B. This can cause slowdown if a lot of debug messages are being saved!
#macro  SNITCH_HIJACK_SDM  true



//Name of the crash dump file
//This file contains the contents of the exception struct, encoded as JSON
#macro  SNITCH_CRASH_LOG_NAME  "crash.txt"

//Pop-up message to show when the game crashes
//This message will only be shown if SNITCH_CRASH_OFFER_CLIPBOARD is set to <false>
//  N.B. If you don't get an error pop-up then you've got a syntax error somewhere in the macro. Check for typos!
#macro  SNITCH_CRASH_MESSAGE  ("Oh no! The game has crashed. Please reboot the game and try again.\n\nThe error was:\n\"" + string(_struct.message) + "\"\n" + string(_struct.stacktrace))

//Whether to ask the user if they want to copy the error message to their clipboard
//This is useful in production to get crash data more easily from players
#macro  SNITCH_CRASH_OFFER_CLIPBOARD  true

//Messages to show when asking the player if they're like to copy their
//  N.B. Use \r rather than \n to work around a GameMaker bug in show_question() (runtime GMS2.3.2.426, 2021-05-05)
#macro  SNITCH_CRASH_CLIPBOARD_REQUEST_MESSAGE  ("Oh no! The game has crashed. Please reboot the game and try again.\r\r\rThe error was:\r\"" + string(_struct.message) + "\"\r" + string(_struct.stacktrace) + "\r\r\rWould you like to copy the error message to your clipboard?")
#macro  SNITCH_CRASH_CLIPBOARD_ACCEPT_MESSAGE   ("The error message has been copied to your clipboard.")



//Whether to allow logging to be toggled on by using the "-log" execution parameter
//This is mostly useful for in-production testing
#macro  SNITCH_ALLOW_LOG_PARAM  true

//Pop-up message to show when the game is booted with the "-log" execution parameter
#macro  SNITCH_LOG_PARAM_MESSAGE  ("Logging enabled! You can find the logs in " + string(game_save_id))