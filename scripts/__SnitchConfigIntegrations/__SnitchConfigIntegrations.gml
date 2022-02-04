//Which integration to use
//There are 4 modes:
//   0:  Don't use any integration at all
//   1:  Use of the Google Analytics integration
//   2:  Use of the sentry.io integration
//   3:  Use the GameAnalytics integration
#macro  SNITCH_INTEGRATION_MODE  1

//Whether to boot the game with integrations turned on or off. Logging can be turned on/off manually by calling SnitchIntegrationSet()
//If this macro is set to <False> then logging will need to be turned on manually by calling SnitchIntegrationSet(true)
//It is recommended that this macro is set to <false> and you ask for user consent before enabling it
#macro  SNITCH_INTEGRATION_ON_BOOT  true

//The endpoint to use for sentry.io
//This can be found via Settings -> Client Keys (under the SDK SETUP header on the left-hand side)
#macro  SNITCH_SENTRY_DSN_URL  ""