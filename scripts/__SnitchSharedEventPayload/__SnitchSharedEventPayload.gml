/// This script defines the base event data that'll be used throughout Snitch's operation
/// Event data is used for 1) saving crash dumps 2) sending events to sentry.io (if sentry.io is set up in Snitch)
///
///   N.B. The struct modified by this function is reused by every event
///        This removes the need to copy tons of data around whenever an event is created which is a big performance boost
///        However, you have to bear this quirk in mind when configuring this function
/// 
/// If you're using sentry.io, this JSON packets need to meet their Event Payload specification
/// More information can be found here: https://develop.sentry.dev/sdk/event-payloads/

function __SnitchSharedEventPayload()
{
    return {
        release: GM_version, //Game version
        
        //User identification. Obviously be careful with what data you're tracking here
        //This code is for demonstration purposes and you might want to remove this in production
        user:  {
            username: "?", //--- Updated via __SnitchSharedEventPayloadUpdate()
            id: 0,         //--- Updated via __SnitchSharedEventPayloadUpdate()
        },
        
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
                mousex: mouse_x, //--- Updated via __SnitchSharedEventPayloadUpdate()
                mousey: mouse_y, //--- Updated via __SnitchSharedEventPayloadUpdate()
            },
            
            //OS-level data
            os : {
                name:              SNITCH_OS_NAME,
                version:           SNITCH_OS_VERSION,
                paused:            bool(os_is_paused()),                 //--- Updated via __SnitchSharedEventPayloadUpdate()
                network_connected: bool(os_is_network_connected(false)), //--- Updated via __SnitchSharedEventPayloadUpdate()
                language:          os_get_language(),
                region:            os_get_region(),
                info:              SNITCH_OS_INFO,
                //browser:           SNITCH_BROWSER, //Feel free to use this but, realistically, it's unlikely that you'll be using HTML5
            },
            
            //What version of GameMaker are you using?
            runtime: {
                //name: "GameMaker Studio", //You can specify a name here but... that feels a bit redundant
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
                steam:          bool(steam_initialised()), //--- Updated via __SnitchSharedEventPayloadUpdate()
            },
        },
        
        
        
        #region Internal stuff, don't fiddle with this until you've read the sentry.io documentation
        
        platform:  "other", //Confusingly, this is the programming language that we're using. GML isn't supported (of course) so we just say "other"
        
        event_id: "?", //--- Updated via __SnitchSharedEventPayloadUpdate()
        timestamp: 0,  //--- Updated via __SnitchSharedEventPayloadUpdate()
        
        breadcrumbs: {
            values: [], //--- Updated via __SnitchSharedEventPayloadUpdate()
        },
        
        stacktrace: {
            frames: [], //--- Updated via __SnitchSharedEventPayloadUpdate()
        },
        
        #endregion
    }
};