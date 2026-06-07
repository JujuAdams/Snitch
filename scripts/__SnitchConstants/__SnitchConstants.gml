// Feather disable all

// The version of Snitch being used, as a string.
#macro SNITCH_VERSION  "5.0.0"

// The build date for this version of Snitch, as a string.
#macro SNITCH_DATE     "2026-06-07"

// Whether the application was booted from the GameMaker IDE. Very useful for adding safety checks
// to prevent debug behaviour from being executed when in production.
#macro SNITCH_RUNNING_FROM_IDE  (__SnitchState().__RunningFromIDE)

// Human-readable name for the current OS, as a string. The following are values that this macro
// can hold:
//   "Windows"  "UWP"  "Linux"  "macOS"  "iOS"  "tvOS"  "Android"  "PlayStation 3"
//   "PlayStation 4"  "PlayStation 5"  "PlayStation Vita"  "Xbox One"  "Xbox Series X/S"
//   "Switch"  "GX.games"
#macro SNITCH_OS_NAME  (__SnitchState().__OSName)

// Human-readable version of the current OS, as a string. There is no definitive list of values that
// this macro can hold.
#macro SNITCH_OS_VERSION  (__SnitchState().__OSVersion)

// Human-readable name that either:
//   - Is the name of the browser that the game is being played in, or
//   - Is a combination of the OS and the OS version together as a string.
#macro SNITCH_ENVIRONMENT_NAME (__SnitchState().__EnvironmentName)

// Human-readable browser name, as a string. The following are values that this macro can hold:
//   "Internet Explorer"  "Firefox"  "Chrome"  "Safari"  "Opera"
#macro SNITCH_BROWSER  (__SnitchState().__Browser)

// Persistent struct containing data relating to the OS enviroment. This holds the same data as the
// ds_map returned by os_get_info() but in struct format for easier handling.
#macro SNITCH_OS_INFO  (__SnitchState().__OSInfo)

// Persistent array of boot parameters that were used to start the application. This holds the same
// data as parameter_string() etc. but in array format for easier handling.
#macro SNITCH_BOOT_PARAMETERS  (__SnitchState().__BootParameters)

// A unique identifier for each time the game is run.
#macro SNITCH_SESSION_ID  (__SnitchState().__SessionID)

// UTC time that the session was started.
#macro SNITCH_SESSION_START_TIME  (__SnitchState().__SessionBootTime)

// How many milliseconds have elapsed since the game was started. This may include time that the
// game window is backgrounded and/or out of focus, depending on platform.
#macro SNITCH_SESSION_TIME  (current_time - __SnitchState().__SessionStartTime)

// How many rendering frames have been drawn since the game started.
#macro SNITCH_FRAMES  (__SnitchState().__Frames)

// How many rendering frames have been drawn whilst the game window has been in focus.
#macro SNITCH_FOCUS_FRAMES  (__SnitchState().__FocusFrames)

// How long the game has been running in focus in milliseconds.
#macro SNITCH_FOCUS_TIME  (__SnitchState().__FocusTime)

// Special macro that gives a platform name that's compatible with GameAnalytics. This will be one
// of the following values:
//   "tvos" "ps3" "ps4" "psm" "vita" "xboxone" "xboxone" "wiiu" "windows"
//   "uwp_console" "linux" "mac_osx" "ios" "android"
#macro SNITCH_GA_PLATFORM  (__SnitchState().__GAPlatform)

// Special macro that gives an OS version that's compatible with GameAnalytics. There are too many
// to list here but broadly this macro will return a string that's the OS platform plus a version
// number.
#macro SNITCH_GA_OS_VERSION  (__SnitchState().__GAOSVersion)

// 
#macro SNITCH_GA_GAMEMAKER_VERSION  (__SnitchState().__GAGameMakerVersion)