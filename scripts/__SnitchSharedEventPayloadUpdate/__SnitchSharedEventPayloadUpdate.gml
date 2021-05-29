/// This function modifies the event payload struct created by __SnitchSharedEventPayload()
/// The event payload struct is used for 1) saving crash dumps 2) sending events to sentry.io (if sentry.io is set up in Snitch)
/// __SnitchSharedEventPayloadUpdate() will always be called in the scope of the struct created by __SnitchSharedEventPayload()
///
///   N.B. The struct modified by this function is reused by every event
///        This removes the need to copy tons of data around whenever an event is created which is a big performance boost
///        However, you have to bear this quirk in mind when configuring this function
/// 
/// If you're using sentry.io, this JSON packets need to meet their Event Payload specification
/// More information can be found here: https://develop.sentry.dev/sdk/event-payloads/

function __SnitchSharedEventPayloadUpdate()
{
    //Snitch will always automatically overwrite the following attributes:
    //  .event_id           = A UUID to identify the event (and HTTP request)
    //  .timestamp          = Number of seconds since the Unix epoch
    //  .level              = The message level
    //  .breadcrumbs.values = Breadcrumbs currently added to Snitch (up to the limit defined by SNITCH_BREADCRUMB_LIMIT)
    //
    //For non-errors, Snitch will overwrite:
    //  .stacktrace.frames           = The callstack for the event. If no callstack was provided then this attribute will be omitted
    //  ."sentry.interfaces.Message" = The message set when creating the event
    //
    //For errors, Snitch will overwrite:
    //  .exception = Exception data
    
    
    
    //We set the username/user ID to whatever Steam gives us only after Steam has fully initialised
    //  N.B. This code is for demonstration purposes and you might want to remove this in production owing to user data privacy
    if (steam_initialised())
    {
        user.username = steam_get_persona_name();
        user.id = steam_get_user_account_id();
    }
    
    //Update some miscellanous variables given our new state
    contexts.vars.mousex = mouse_x;
    contexts.vars.mousey = mouse_y;
    
    //Update the OS state
    contexts.os.paused = bool(os_is_paused());
    contexts.os.network_connected = bool(os_is_network_connected(false));
    
    //Update whether we're hooked up to Steam successfully
    contexts.app.steam = bool(steam_initialised());
}