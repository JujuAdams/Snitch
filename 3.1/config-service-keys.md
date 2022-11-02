# Service Keys Configuration

The macros on this page can be found in the `__SnitchConfigServiceKeys` script. They relate to the behaviour of Snitch when communicating with various third-party bug tracking services (sentry.io, GameAnalytics, Bugsnag).

?> You must edit these macros to enable bug tracking services.

!> You should `.gitignore` the source script file for `__SnitchConfigServiceKeys` if you are working on a public project.

&nbsp;

## `SNITCH_SENTRY_DSN_URL`

*Typical value:* `""`

Endpoint required to communicate with sentry.io. This can be found by selecting your project via the sentry.io dashboard, then selecting Settings then Client Keys (under the SDK SETUP header on the left-hand side).

&nbsp;

## `SNITCH_GAMEANALYTICS_GAME_KEY`

*Typical value:* `""`

One of the two keys required to communicate with GameAnalytics. Found via the Settings -> Game Keys for your game in the GameAnalytics dashboard.

&nbsp;

## `SNITCH_GAMEANALYTICS_SECRET_KEY`

*Typical value:* `""`

One of the two keys required to communicate with GameAnalytics. Found via Settings -> Game Keys for your game in the GameAnalytics dashboard.


&nbsp;

## `SNITCH_BUGSNAG_NOTIFIER_API_KEY`

*Typical value:* `""`

Key required to communicate with Bugsnag. Found via Settings (top-right on the project page) -> Project Settings - Notifier API key.