#region Basic Settings

//Turns off a handful of validation checks so that unnecessary showstopper errors don't appear
//It's recommended to set this macro to <false> for production builds
//Setting this macro to <false> turns off the following checks:
//   1. Events must have their .Finish() method called, and this macro controls whether to throw an error when Snitch detects an unfinished event
#macro  SNITCH_FUSSY_ERRORS  false

//Name of the log files to save. Use a # symbol for number position
#macro  SNITCH_LOG_NAME  "log#.txt"

//Number of log files to store. A new log file is created every time the game is run (the 0th log file is always the latest)
//Set SNITCH_LOG_COUNT to 0 to permanently turn off logging. Turning off logging will not prevent the crash handler from running
#macro  SNITCH_LOG_COUNT  10

//Whether to boot the game with logging turned on or off
//Logging can be turned on/off manually by calling SnitchLogSet()
//Generally, you'll only want to set this to <true> if you're running dev/debug builds as logging messages to a file can be slow
//See SNITCH_ALLOW_LOG_BOOT_PARAMETER below for information on toggling logging on/off for production builds
#macro  SNITCH_LOG_DEFAULT  true

//Whether to redirect all uses of show_debug_message() to the Snitch() logging function
//This means show_debug_message() calls will be loggged to a file (provided Snitch is logging)
//   N.B. This can cause slowdown if a lot of debug messages are being saved!
#macro  SNITCH_HIJACK_SDM  true



//Whether to capture crashes using an exception handler
//This can make tracking down bugs a bit harder when you're running from the IDE
//The default value here ("!debug_mode") will prevent Snitch from capturing crashes when running in debug mode from the IDE (i.e. running using F6)
//Please make sure this macro is set to <true> for production builds!
#macro  SNITCH_CRASH_CAPTURE  (!debug_mode)

//Name of the crash dump file. Set this to an empty string to not save a crash dump
//This file contains the contents of the exception struct, encoded as JSON
#macro  SNITCH_CRASH_NAME  "crash.txt"

//Pop-up message to show when the game crashes
//This message will only be shown if SNITCH_CRASH_OFFER_CLIPBOARD is set to <false>
//   N.B. If you don't get an error pop-up then you've got a syntax error somewhere in the macro. Check for typos!
#macro  SNITCH_CRASH_MESSAGE  ("Oh no! The game has crashed. Please reboot the game and try again.\n\nThe error was:\n\"" + string(_struct.message) + "\"\n" + string(_struct.stacktrace))

//Whether to ask the user if they want to copy the error message to their clipboard
//This is useful in production to get crash data more easily from players
#macro  SNITCH_CRASH_OFFER_CLIPBOARD  false

//Messages to show when asking the player if they'd like to copy the error message to their clipboard
//   N.B. Use \r rather than \n to work around a GameMaker bug in show_question() (runtime GMS2.3.2.426, 2021-05-05)
#macro  SNITCH_CRASH_CLIPBOARD_REQUEST_MESSAGE  ("Oh no! The game has crashed. Please reboot the game and try again.\r\r\rThe error was:\r\"" + string(_struct.message) + "\"\r" + string(_struct.stacktrace) + "\r\r\rWould you like to copy the error message to your clipboard?")
#macro  SNITCH_CRASH_CLIPBOARD_ACCEPT_MESSAGE   ("The error message has been copied to your clipboard.")



//Whether to allow logging to be toggled on by using the "-log" execution parameter
//This is mostly useful for in-production testing
#macro  SNITCH_ALLOW_LOG_BOOT_PARAMETER  true

//Pop-up message to show when the game is booted with the "-log" execution parameter
#macro  SNITCH_LOG_PARAM_MESSAGE  ("Logging enabled! You can find the logs in " + string(game_save_id))


//Whether to output HTTP success to the console
//If logging is enabled, this information will also be outputted to a log file
//   N.B. HTTP warnings/failures will always be reported
#macro  SNITCH_OUTPUT_HTTP_SUCCESS  true

//Maximum number of breadcrumbs to store
#macro  SNITCH_BREADCRUMB_LIMIT  100

//Whether to output breadcrumbs to the console
//If logging is enabled, this information will also be outputted to a log file
#macro  SNITCH_OUTPUT_BREADCRUMBS  true

#endregion



#region sentry.io Integration

//Controls whether sentry.io communication should be allowed at all
//   N.B. The sentry.io integration will default to being disabled even if SNITCH_SENTRY_PERMITTED is <true>
//        SnitchSentrySet(true) should be called to enable it, preferably after asking for user consent
#macro  SNITCH_SENTRY_PERMITTED  true

//The endpoint to use for sentry.io
#macro  SNITCH_SENTRY_DSN_URL  "https://77614a06f703442781754e59aa3816d2@o732552.ingest.sentry.io/5784362"

//Whether to send a "fatal" event to sentry.io automatically when the game crashes
//This requires SNITCH_SENTRY_PERMITTED to be set to <true> and SnitchSentrySet(true) having been called
//   N.B. This feature will not work is SNITCH_CRASH_CAPTURE is set to <false> (see above)
#macro  SNITCH_SENTRY_SEND_CRASH  true

//Default name of the sentry.io logger to use
#macro  SNITCH_SENTRY_DEFAULT_LOGGER  "logger"

//Tries to get user data from Steam if possible
//This will overwrite SNITCH_SENTRY_DATA.user.username and SNITCH_SENTRY_DATA.user.id
#macro SNITCH_SENTRY_GET_USER_FROM_STEAM  true

#macro SNITCH_SENTRY_BACKUP_NAME   "sentry#.dat"
#macro SNITCH_SENTRY_BACKUP_COUNT  20

#endregion