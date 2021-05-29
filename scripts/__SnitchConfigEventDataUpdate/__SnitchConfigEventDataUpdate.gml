function __SnitchConfigEventDataUpdate(_message, _level, _callstack, _breadcrumbs)
{
    //This function is called every time an event is finished (the .Finish() method is called)
    
    //Set the username/user ID to whatever Steam gives us, but only after Steam has initialised fully
    if (steam_initialised())
    {
        user.username = steam_get_persona_name();
        user.id = steam_get_user_account_id();
    }
    
    //Update the OS state
    contexts.os.paused = bool(os_is_paused());
    contexts.os.network_connected = bool(os_is_network_connected(false));
    
    //Update whether we're hooked up to Steam successfully
    contexts.app.steam = bool(steam_initialised());
    
    
    
    #region Internal stuff, don't fiddle with this until you've read the sentry.io documentation
    
    //Create a unique UUID and give the event a Unix timestamp
    event_id  = SnitchGenerateUUID4String();
    timestamp = SnitchConvertToUnixTime(date_current_datetime());
    
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