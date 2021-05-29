/// This script defines two functions that set and modify the data that gets used for Snitch events
/// Event data is used for 1) saving crash dumps 2) sending events to sentry.io (if sentry.io is set up in Snitch)
/// If you're using sentry.io, this JSON packets need to meet their Event Payload specification
/// More information can be found here: https://develop.sentry.dev/sdk/event-payloads/


function __SnitchConfigEventDataOnBoot()
{
    //This function is called once on boot
    
    return {
        //Extra bits of data you might want to send off to sentry.io
        extra: {
            stuff: "i guess",
        },
        
        //User identification. Obviously be careful with what data you're tracking here
        //If SNITCH_SENTRY_GET_USER_FROM_STEAM is set to <true> then the .username and .id variables will be overwritten
        user:  {
            username: "?",
            id: 0,
        },
        
        release:   GM_version, //Game version
        platform:  "other",    //Confusingly, this is the programming language that we're using. GML isn't supported so we just say "other"
        
        //Tags to help filter issues/events inside sentry.io
        tags: {
            device_string: SNITCH_DEVICE_NAME,
            config:        os_get_config(),
            version:       GM_version,
        },
        
        //Information on what environment the code is running in
        contexts: {
            os : {
                name:              SNITCH_OS_NAME,
                version:           SNITCH_OS_VERSION,
                browser:           SNITCH_BROWSER,
                paused:            bool(os_is_paused()),                 //--- Updated when an event is created (see below)
                network_connected: bool(os_is_network_connected(false)), //--- Updated when an event is created (see below)
                language:          os_get_language(),
                region:            os_get_region(),
                info:              SNITCH_OS_INFO,
            },
            
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
                steam:          bool(steam_initialised()), //--- Updated when an event is created (see below)
            },
        },
        
        //Details on any libraries/SDKs you're using
        sdk: {
            name: "Snitch",
            version: SNITCH_VERSION,
        },
        
        
        
        #region Internal stuff, don't fiddle with this until you've read the sentry.io documentation
        
        event_id: "?", //--- Updated when an event is created (see below)
        timestamp: 0,  //--- Updated when an event is created (see below)
        
        breadcrumbs: {
            values: [], //--- Updated when an event is created (see below)
        },
        
        stacktrace: {
            frames: [], //--- Updated when an event is created (see below)
        },
        
        #endregion
    }
};






function __SnitchConfigEventDataUpdate(_message, _level, _callstack, _breadcrumbs)
{
    //This function is called every time an event is finished (the .Finish() method is called)
    
    
    
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