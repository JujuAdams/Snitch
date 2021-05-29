/// Defines the data that gets sent to sentry.io. This function builds a struct and is called on boot by Snitch
/// The built struct can be accessed at a later time with the SNITCH_SENTRY_DATA e.g. SNITCH_SENTRY_DATA.user.email = "person@email.com";

function __SnitchConfigSentryData()
{
    return {
        //Extra bits of data you might want to send off to sentry.io
        extra: {},
        
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
                paused:            bool(os_is_paused()),                 //Updated when an event is created
                network_connected: bool(os_is_network_connected(false)), //Updated when an event is created
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
                steam:          bool(steam_initialised()), //Updated when an event is created
            },
        },
        
        //Details on any libraries/SDKs you're using
        sdk: {
            name: "Snitch",
            version: SNITCH_VERSION,
        },
        
        
        
        #region Internal Snitch stuff, don't touch this stuff
        
        breadcrumbs: {
            values: SNITCH_BREADCRUMBS_ARRAY, //Automatically updated by Snitch
        },
        
        event_id:  "?",                          //Updated when an event is created
        timestamp: 0,                            //Updated when an event is created
        level:     "info",                       //Updated when an event is created
        logger:    SNITCH_SENTRY_DEFAULT_LOGGER, //Updated when an event is created
        
        stacktrace: {
            frames: [], //Updated when an event is created
        },
        
        #endregion
    }
};