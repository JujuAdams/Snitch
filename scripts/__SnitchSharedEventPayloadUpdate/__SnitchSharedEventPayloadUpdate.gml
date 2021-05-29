/// This function modifies the event data struct created by __SnitchSharedEventPayload()
/// Event data is used for 1) saving crash dumps 2) sending events to sentry.io (if sentry.io is set up in Snitch)
/// __SnitchSharedEventPayloadUpdate() will always be called in the scope of the struct created by __SnitchSharedEventPayload()
///
///   N.B. The struct modified by this function is reused by every event
///        This removes the need to copy tons of data around whenever an event is created which is a big performance boost
///        However, you have to bear this quirk in mind when configuring this function
/// 
/// If you're using sentry.io, this JSON packets need to meet their Event Payload specification
/// More information can be found here: https://develop.sentry.dev/sdk/event-payloads/

function __SnitchSharedEventPayloadUpdate(_message, _level, _callstack, _breadcrumbs)
{
    //Set the username/user ID to whatever Steam gives us, but only after Steam has initialised fully
    //This code is for demonstration purposes and you might want to remove this in production
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
    
    
    
    #region Internal stuff, don't fiddle with this until you've read the sentry.io documentation
    
    //Create a unique UUID and give the event a Unix timestamp
    event_id  = SnitchGenerateUUID4String();
    timestamp = SnitchConvertToUnixTime(date_current_datetime());
    
    //Set the message level
    level = _level;
    
    //Update the callstack
    //If no callstack was provided, the "_callstack" argument will be an empty array
    stacktrace.frames = _callstack;
    
    //aaaand update the breadcrumbs too
    breadcrumbs.values = _breadcrumbs;
    
    //...janky
    //Only way to set this key though unfortunately
    self[$ "sentry.interfaces.Message"] = { formatted: _message };
    
    #endregion
}