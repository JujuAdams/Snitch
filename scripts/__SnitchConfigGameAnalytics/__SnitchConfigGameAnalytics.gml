//Controls whether GameAnalytics integration should be allowed at all
//   N.B. The GameAnalytics integration will initially be set to disabled even if SNITCH_GAMEANALYTICS_PERMITTED is <true>
//        Either call SnitchGameAnalyticsSet(true), or set SNITCH_GAMEANALYTICS_ON_BOOT to <true>, to enable logging
#macro  SNITCH_GAMEANALYTICS_PERMITTED  false

//Whether to boot the game with GameAnalytics turned on or off. Logging can be turned on/off manually by calling SnitchGameAnalyticsSet()
#macro  SNITCH_GAMEANALYTICS_ON_BOOT  true