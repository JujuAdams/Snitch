/// This function initialises the shared event payload struct that'll be used throughout Snitch's operation
/// Event payloads are used for 1) saving crash dumps 2) sending events to sentry.io (if sentry.io is set up in Snitch)
/// 
///   N.B. The struct modified by this function is reused by every event. Changes will persist across multiple events if not properly managed!
///        This removes the need to copy tons of data around whenever an event is created which is a big performance boost
///        However, you have to bear this quirk in mind when configuring this function
/// 
/// Event payload is updated every time an event is finished by the __SnitchSentrySharedEventPayloadUpdate() function (which can/should also be editted)
/// The SNITCH_SHARED_EVENT_PAYLOAD macro can be used to manually access the event payload struct later if needed
/// 
/// 
/// 
/// If you're using sentry.io, this JSON packets need to meet their Event Payload specification
/// More information can be found here: https://develop.sentry.dev/sdk/event-payloads/
/// 
/// In light of the above, Snitch will always automatically overwrite the following attributes so that an event is recognised by sentry.io:
///   .event_id  = A UUID to identify the event (and HTTP request)
///   .timestamp = Number of seconds since the Unix epoch
///   .level     = The message level
/// 
/// For non-errors, Snitch will overwrite:
///   .stacktrace.frames           = The callstack for the event. If no callstack was provided then this attribute will be omitted
///   ."sentry.interfaces.Message" = The message set when creating the event
/// 
/// For errors, Snitch will overwrite:
///   .exception.values[0].type       = Exception struct's .message variable
///   .exception.values[0].value      = Exception struct's .longMessage variable if provided, otherwise a copy of .exception.values[0].type
///   .exception.values[0].stacktrace = The callstack for the exception, based on the exception struct's .stacktrace variable if provided
/// 
/// 
/// 
/// The following macros are available for use in this function (and elsewhere too if you need them):
///   SNITCH_OS_NAME         = Human-readable name for the operating system e.g. "Windows", "Mac OS X" etc.
///   SNITCH_OS_VERSIONon    = Human-readable version for the operating system e.g. "10", "Lollipop"
///   SNITCH_BROWSER         = Web browser that the game is running in
///   SNITCH_DEVICE_NAME     = OS name + OS version, or if the game is running in a web browser, the name of the web browser
///   SNITCH_OS_INFO         = The same as os_get_info() but as a struct instead of a ds_map
///   SNITCH_BOOT_PARAMETERS = Array of boot parameters used to execute the game
/// 
/// You can otherwise use GameMaker features as you see fit. Bear in mind that ds_* data structures will not be serialised properly as this is a struct

function __SnitchSentrySharedEventPayload()
{
    return {
        release: GM_version, //Game version
        
        //Extra bits of data you might want to send off to sentry.io
        extra: {
            stuff: "i guess",
        },
        
        //Tags to help filter issues/events inside sentry.io
        tags: {
            device_string: SNITCH_DEVICE_NAME,
            config:        os_get_config(),
            version:       GM_version,
        },
        
        //Information on what environment the code is running in
        contexts: {
            
            //GML-side variables that you might want to track
            //This could be player health, what level they're on, what weapon they're using etc. etc.
            vars : {
                mousex: mouse_x, //--- Updated via __SnitchSentrySharedEventPayloadUpdate()
                mousey: mouse_y, //--- Updated via __SnitchSentrySharedEventPayloadUpdate()
            },
            
            //OS-level data
            os : {
                name:              SNITCH_OS_NAME,
                version:           SNITCH_OS_VERSION,
                //browser:           SNITCH_BROWSER, //Feel free to use this but, realistically, it's unlikely that you'll be using HTML5
                paused:            bool(os_is_paused()),                 //--- Updated via __SnitchSentrySharedEventPayloadUpdate()
                network_connected: bool(os_is_network_connected(false)), //--- Updated via __SnitchSentrySharedEventPayloadUpdate()
                language:          os_get_language(),
                region:            os_get_region(),
                info:              SNITCH_OS_INFO,
            },
            
            //What version of GameMaker are you using?
            runtime: {
                name: "GameMaker Studio",
                version: GM_runtime_version,
            },
            
            app: {
                app_start_time: SnitchFormatTimestamp(date_current_datetime()), //This has to be formatted as a string unfortunately <_<
                config:         os_get_config(),
                yyc:            bool(code_is_compiled()),
                app_name:       game_display_name,
                app_version:    GM_version,
                debug:          bool(debug_mode),
                app_build:      SnitchFormatTimestamp(GM_build_date),
                parameters:     SNITCH_BOOT_PARAMETERS,
                steam:          bool(steam_initialised()), //--- Updated via __SnitchSentrySharedEventPayloadUpdate()
            },
        }
    }
};