/// This function modifies the event payload struct created by __SnitchSentrySharedEventPayload()
/// The event payload struct is used for 1) saving crash dumps 2) sending events to sentry.io (if sentry.io is set up in Snitch)
/// __SnitchSentrySharedEventPayloadUpdate() will always be called in the scope of the struct created by __SnitchSentrySharedEventPayload()
/// 
///   N.B. The struct modified by this function is reused by every event. Changes will persist across multiple events if not properly managed!
///        This removes the need to copy tons of data around whenever an event is created which is a big performance boost
///        However, you have to bear this quirk in mind when configuring this function
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
///   .exception.values[0].type       = Exception struct's .message variable if provided, otherwise
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

function __SnitchSentrySharedEventPayloadUpdate()
{
    //Update some miscellanous variables given our new state
    contexts.vars.mousex = mouse_x;
    contexts.vars.mousey = mouse_y;
    
    //Update the OS state
    contexts.os.paused = bool(os_is_paused());
    contexts.os.network_connected = bool(os_is_network_connected(false));
    
    //Update whether we're hooked up to Steam successfully
    contexts.app.steam = bool(SnitchSteamInitializedSafe());
}