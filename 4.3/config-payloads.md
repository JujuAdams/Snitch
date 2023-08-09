# Service Payloads

sentry.io, GameAnalytics, and Bugsnag all have different requirements and capabilities. As a result, the information that Snitch can send to each service (called a "payload") differs substantially between them and each service necessitates a different payload configuration script.

?> The default payloads for each service is quite exhaustive already but you should add game-specific information that you will find useful to debug crashes.

&nbsp;

## sentry.io

The payload to send to sentry.io when encountering an error is defined in `__SnitchConfigPayloadSentry()`. You can find information on what information sentry.io can handle [here](https://develop.sentry.dev/sdk/overview/) and [here](https://develop.sentry.dev/sdk/event-payloads/).

&nbsp;

## GameAnalytics

The payload to send to GameAnalytics when encountering an error is defined in `__SnitchConfigPayloadGameAnalytics()`. You can find information on what information GameAnalytics can handle [here](https://restapidocs.gameanalytics.com/).

!> GameAnalytics is **extremely** fussy with what data it accepts. Please read the link above carefully. You will need to use `SNITCH_GA_GAMEMAKER_VERSION` for the `.engine_version` property.

&nbsp;

## Bugsnag

The payload to send to Bugsnag when encountering an error is defined in `__SnitchConfigPayloadBugsnag()`. You can find information on what information Bugsnag can handle [here](https://bugsnagerrorreportingapi.docs.apiary.io/#reference/0/notify/send-error-reports).

&nbsp;

## Generic HTTP

The generic HTTP service mode allows you to fully customise Snitch's remote reporting. You'll first want to set up your HTTP endpoint and method in `__SnitchConfigServiceKeys()`. Secondly, you should define a payload to send in `__SnitchConfigPayloadGeneric()`. Finally, if you need to add any information to your HTTP request header then you may do so in `__SnitchConfigGenericHeaderMap()`.