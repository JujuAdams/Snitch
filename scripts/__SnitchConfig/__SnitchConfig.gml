/// This script defines macros that control Snitch's behaviour
/// Please read through all of it! There's a lot of good stuff tucked away in here



#region ---------- Logging ----------

//Controls whether logging should be allowed at all
//   N.B. Logging will initially be set to disabled even if SNITCH_LOG_PERMITTED is <true>
//        Either call SnitchLogSet(true), or set SNITCH_LOG_DEFAULT to <true>, to enable logging
#macro  SNITCH_LOG_PERMITTED  false

//Whether to boot the game with logging turned on or off. Logging can be turned on/off manually by calling SnitchLogSet()
//Generally, you'll only want to set this to <true> if you're running dev/debug builds as logging messages to a file can be slow
//See SNITCH_ALLOW_LOG_BOOT_PARAMETER below for information on toggling logging on/off for production builds
#macro  SNITCH_LOG_DEFAULT  true

//Whether to allow logging to be toggled on by using the "-log" execution parameter
//This is useful for in-production testing so you can turn on logging without the option normally being available to the end-user
#macro  SNITCH_ALLOW_LOG_BOOT_PARAMETER  true

//Pop-up message to show when the game is booted with the "-log" execution parameter
#macro  SNITCH_LOG_BOOT_PARAMETER_CONFIRMATION  ("Logging enabled! You can find the logs in " + string(game_save_id))

//Whether to redirect all uses of show_debug_message() to Snitch's logging function
//This means show_debug_message() calls will be loggged to a file (provided Snitch logging is turned on)
//   N.B. This can cause slowdown if a lot of debug messages are being saved!
#macro  SNITCH_HIJACK_SDM  true

//Name of the log files to save. Use a # symbol for number position
#macro  SNITCH_LOG_NAME  "log_#.txt"

//Number of log files to store on disk
//A new log file is created every time the game is run. The 0th log file is always the most recent
#macro  SNITCH_LOG_COUNT  10

//Starting size of the Snitch logging buffer, in bytes. 1024*1024 bytes is 1 megabyte
//This buffer is a "buffer_grow" type and will dynamically resize as more data is added
#macro  SNITCH_LOG_BUFFER_START_SIZE  1024*1024

#endregion



#region ---------- Crashes ----------

//Whether to capture crashes using Snitch's own exception handler. The crash handler can save a crash dump (see below) and/or send a sentry.io event (see way below)
//Snitch's exception handler is *not* mutually exclusive with exception_unhandled_handler() (Snitch hijacks calls to that function and executes the handler itself)
//Whilst Snitch's crash handler is really snazzy, it can make tracking down bugs a bit harder when you're running from the IDE during development
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

#endregion



#region ---------- Breadcrumbs ----------

//Maximum number of breadcrumbs to store
#macro  SNITCH_BREADCRUMB_LIMIT  100

//Whether to output breadcrumbs to the console
//If logging is enabled, this information will also be outputted to a log file
#macro  SNITCH_OUTPUT_BREADCRUMBS  true

#endregion



#region ---------- Miscellaneous ----------

//Events must have their .Finish() method called, and this macro controls whether to throw an error when Snitch detects an unfinished event
//This macro should probably be set to <false> for production builds
#macro  SNITCH_UNFINISHED_EVENT_ERROR  true

#endregion



#region ---------- HTTP ----------

//Whether to allow backups to be made for HTTP requests
//Any requests that fail will be reattempted at a later time
#macro  SNITCH_REQUEST_BACKUP_ENABLE  true

//Name of the request backup manifest
//This file records how many request backups exist and where to find them on disk
#macro  SNITCH_REQUEST_BACKUP_MANIFEST_NAME  "request_backup_manifest.dat"

//Name of request backup files. Use a # symbol for UUID position
#macro  SNITCH_REQUEST_BACKUP_NAME  "request_backup_#.dat"

//How many request backups to keep
#macro  SNITCH_REQUEST_BACKUP_COUNT  10

//The time, in milliseconds, between attempts to resend HTTP requests. 5000 = 5 seconds
#macro  SNITCH_REQUEST_BACKUP_RESEND_DELAY  5000

//How many sequential HTTP request failures before Snitch decides to not try to resend request backups for a while
//This is useful behaviour for mobile games where the player may lose their connection for some reason
#macro  SNITCH_REQUEST_BACKUP_RESEND_MAX_FAILURES  5

//How long to wait after multiple failed backup resends before Snitch will try resending HTTP request backups
//This value is in milliseconds, so 900000 is the same as 15 minutes
#macro  SNITCH_REQUEST_BACKUP_RESEND_FAILURE_TIMEOUT  900000

//Whether to output HTTP success to the console. This is handy for confirming HTTP requests are being processed properly
//If logging is enabled, this information will also be outputted to the log file
//   N.B. HTTP warnings/failures will always be reported
#macro  SNITCH_OUTPUT_HTTP_SUCCESS  true

#endregion



#region ---------- sentry.io ----------

//Controls whether sentry.io communication should be allowed at all
//   N.B. The sentry.io integration will default to being disabled even if SNITCH_SENTRY_PERMITTED is <true>
//        SnitchSentrySet(true) should be called to enable it, preferably after asking for user consent
#macro  SNITCH_SENTRY_PERMITTED  true

//The endpoint to use for sentry.io
#macro  SNITCH_SENTRY_DSN_URL  "https://77614a06f703442781754e59aa3816d2@o732552.ingest.sentry.io/5784362"

//Whether to create a "fatal" event automatically when the game crashes
//This requires SNITCH_SENTRY_PERMITTED to be set to <true> and SnitchSentrySet(true) having been called
//   N.B. This feature will not work is SNITCH_CRASH_CAPTURE is set to <false> (see above)
#macro  SNITCH_SENTRY_AUTO_CRASH_EVENT  true

//Default name of the sentry.io logger to use
#macro  SNITCH_SENTRY_DEFAULT_LOGGER  "logger"

//Tries to get user data from Steam if possible
//This will overwrite SNITCH_SENTRY_DATA.user.username and SNITCH_SENTRY_DATA.user.id
#macro SNITCH_SENTRY_GET_USER_FROM_STEAM  true

#endregion