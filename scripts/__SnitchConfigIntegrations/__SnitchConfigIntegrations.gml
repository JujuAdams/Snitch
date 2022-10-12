//Which integration to use
//There are 4 modes:
//   0:  Don't use any integration at all
//   1:  Use the Google Analytics integration
//   2:  Use the sentry.io integration
//   3:  Use the GameAnalytics integration
//   4:  Use the Bugsnag integration
//   5:  Use the DeltaDNA integration
#macro  SNITCH_INTEGRATION_MODE  5

//Whether to boot the game with integrations turned on or off. Logging can be turned on/off manually by calling SnitchIntegrationSet()
//If this macro is set to <False> then logging will need to be turned on manually by calling SnitchIntegrationSet(true)
//It is recommended that this macro is set to <false> and you ask for user consent before enabling it
#macro  SNITCH_INTEGRATION_ON_BOOT  true

//The API secret for your property
//This is set up in the admin section of the Google Analytics backend
//https://developers.google.com/analytics/devguides/collection/protocol/ga4/
#macro  SNITCH_GOOGLE_ANALYTICS_API_SECRET  ""

//The measurement ID that's generataed for your property
//This can be found in the admin section of the Google Analytics backend
//https://support.google.com/analytics/answer/9539598
#macro  SNITCH_GOOGLE_ANALYTICS_MEASUREMENT_ID  ""

//The endpoint to use for sentry.io
//This can be found via Settings -> Client Keys (under the SDK SETUP header on the left-hand side)
#macro  SNITCH_SENTRY_DSN_URL  ""

#macro  SNITCH_GAMEANALYTICS_GAME_KEY    "5c6bcb5402204249437fb5a7a80a4959"
#macro  SNITCH_GAMEANALYTICS_SECRET_KEY  "16813a12f718bc5c620f56944e1abc3ea13ccbac"

#macro  SNITCH_BUGSNAG_API_KEY  ""

#macro  SNITCH_DELTADNA_COLLECT_URL        "https://collect93954026tsttl.deltadna.net/collect/api"
#macro  SNITCH_DELTADNA_ENVIRONMENT_KEY    ""
#macro  SNITCH_DELTADNA_SECRET_KEY         ""
#macro  SNITCH_DELTADNA_EVENT_NAME         "exception"
#macro  SNITCH_DELTADNA_MESSAGE_PARAM      "exceptionMessage"
#macro  SNITCH_DELTADNA_LONGMESSAGE_PARAM  "exceptionLongMessage"
#macro  SNITCH_DELTADNA_FATAL_PARAM        "exceptionFatal"
#macro  SNITCH_DELTADNA_STACKTRACE_PARAM   "exceptionStacktrace"