# Services Configuration

The macros on this page can be found in the `__SnitchConfigServices` script. They relate to the behaviour of Snitch when communicating with various third-party bug tracking services (sentry.io, GameAnalytics, Bugsnag).

?> You should edit these macros to suit your own needs when using Snitch.

&nbsp;

## `SNITCH_INTEGRATION_MODE`

*Typical value:* `0`

Which bug tracking service you're using. Snitch can only use one bug tracking service at a time. There are 4 modes:
- `0` Don't use any service at all
- `1` sentry.io
- `2` GameAnalytics
- `3` Bugsnag

Setting this macro to `0` is equivalent to turning off bug tracking services completely.

&nbsp;

## `SNITCH_INTEGRATION_ON_BOOT`

*Typical value:* `false`

Whether to boot the game with bug tracking services turned on or off. Logging can be turned on/off manually by calling `SnitchIntegrationSet()`. If this macro is set to `false` then your chosen service will need to be turned on manually by calling `SnitchIntegrationSet(true)`.

!> It is recommended that this macro is set to `false` and you ask for user consent before enabling bug tracking services.

&nbsp;

# Advanced Settings

The following settings are exposed for customising the specifics of bug tracking. You likely will never need to touch these, but if you find you're running into issues then you may find altering these macros will assist you when debugging.

&nbsp;

## `SNITCH_REQUEST_BACKUP_ENABLE`

*Typical value:* `true`

Whether to allow backups to be made for HTTP requests. Any requests that fail will be reattempted at a later time.

&nbsp;

## `SNITCH_REQUEST_BACKUP_MANIFEST_FILENAME`

*Typical value:* `"event_manifest.dat"`

Name of the request backup manifest. This file records how many request backups exist and where to find them. The request backup manifest is typically saved in `game_save_id`.

&nbsp;

## `SNITCH_REQUEST_BACKUP_FILENAME`

*Typical value:* `"event_#.dat"`

Name of the request backup files to save. Request backups are typically saved in `game_save_id`.

!> Use a # symbol for the position of the event UUID. If this isn't present then request backups will overwrite each other!

&nbsp;

## `SNITCH_REQUEST_BACKUP_COUNT`

*Typical value:* `10`

How many request backups to keep, with the oldest backups being discarded when newer backups are created.

&nbsp;

## `SNITCH_REQUEST_BACKUP_RESEND_DELAY`

*Typical value:* `5000`

The time, in milliseconds, between attempts to resend HTTP requests.

&nbsp;

## `SNITCH_REQUEST_BACKUP_RESEND_MAX_FAILURES`

*Typical value:* `5`

How many sequential HTTP request failures before Snitch decides to not try to resend request backups for a while. This is useful behaviour for mobile games where the player may lose their connection for some unpredictable reason.

&nbsp;

## `SNITCH_REQUEST_BACKUP_RESEND_MAX_FAILURES`

*Typical value:* `5`

How many sequential HTTP request failures before Snitch decides to not try to resend request backups for a while. This is useful behaviour for mobile games where the player may lose their connection for some unpredictable reason.

&nbsp;

## `SNITCH_REQUEST_BACKUP_RESEND_FAILURE_TIMEOUT`

*Typical value:* `600000`

How long to wait after sequential failed backup resends before Snitch will try all over again. This value is in milliseconds, so `600000` is the same as 10 minutes.

&nbsp;

## `SNITCH_REQUEST_BACKUP_OUTPUT_ATTEMPT`

*Typical value:* `SNITCH_RUNNING_FROM_IDE`

Whether to output request backup send attempts to the console. This is handy for confirming request backups are being processed properly. If logging is enabled, this information will also be outputted to the log file.

## `SNITCH_OUTPUT_HTTP_FAILURE_DETAILS`

*Typical value:* `SNITCH_RUNNING_FROM_IDE`

Whether to output the details of failed request backup send attempts to the console. This is especially useful when customising 

&nbsp;

## `SNITCH_OUTPUT_HTTP_SUCCESS`

*Typical value:* `SNITCH_RUNNING_FROM_IDE`

Whether to output HTTP success to the console. This is handy for confirming HTTP requests are being processed properly. If logging is enabled, this information will also be outputted to the log file.
   N.B. HTTP warnings/failures will always be reported