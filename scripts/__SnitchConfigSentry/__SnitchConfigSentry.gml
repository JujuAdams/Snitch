//Controls whether sentry.io communication should be allowed at all
//   N.B. The sentry.io integration will default on boot to being disabled even if SNITCH_SENTRY_PERMITTED is <true>
//        SnitchSentrySet(true) should be called to enable it, preferably after asking for user consent
#macro  SNITCH_SENTRY_PERMITTED  false

//Whether to boot the game with sentry.io turned on or off. Logging can be turned on/off manually by calling SnitchSentrySet()
#macro  SNITCH_SENTRY_ON_BOOT  true

//The endpoint to use for sentry.io
//This can be found via Settings -> Client Keys (under the SDK SETUP header on the left-hand side)
#macro  SNITCH_SENTRY_DSN_URL  ""