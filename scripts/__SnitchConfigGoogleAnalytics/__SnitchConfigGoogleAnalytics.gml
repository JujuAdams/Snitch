//Controls whether Google Analytics should be allowed at all
//   N.B. Google Analytics will initially be set to disabled even if SNITCH_GOOGLE_ANALYTICS_PERMITTED is <true>
//        Either call SnitchGoogleAnalyticsSet(true), or set SNITCH_GOOGLE_ANALYTICS_ON_BOOT to <true>, to enable logging
#macro  SNITCH_GOOGLE_ANALYTICS_PERMITTED  true

//Whether to boot the game with Google Analytics turned on or off. Logging can be turned on/off manually by calling SnitchGoogleAnalyticsSet()
#macro  SNITCH_GOOGLE_ANALYTICS_ON_BOOT  true