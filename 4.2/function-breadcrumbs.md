# sentry.io Breadcrumbs

The sentry.io service supports "breadcrumbs", a trail of user interaction events that give clues as to what the user was doing before an error occurs.

You can read more about the breadcrumb feature on [sentry.io's website](https://develop.sentry.dev/sdk/event-payloads/breadcrumbs).

&nbsp;

## `SnitchSentryBreadcrumb(message, [data])`

_Returns:_ N/A (`undefined`)

|Name     |Datatype|Purpose                                                  |
|---------|--------|---------------------------------------------------------|
|`message`|string  |Human-readable message for the breadcrumb                |
|`[data]` |struct  |Custom struct with optional extra data for the breadcrumb|

Adds a breadcrumb to an array of breadcrumbs which will be send to the sentry.io service whenever the game encounter an error.

&nbsp;

## `SnitchSentryBreadcrumbExt(struct)`

_Returns:_ N/A (`undefined`)

|Name     |Datatype|Purpose                         |
|---------|--------|--------------------------------|
|`struct` |struct  |Custom struct for the breadcrumb|

Adds a custom breadcrumb struct to an array of breadcrumbs which will be send to the sentry.io service whenever the game encounter an error. Read the sentry.io [event payload documentation](https://develop.sentry.dev/sdk/event-payloads/breadcrumbs) to find out more about what kind of data this struct can contain.

&nbsp;

## `SnitchSentryBreadcrumb(message, [data])`

_Returns:_ Array, the breadcrumbs that are currently stored

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This array will be empty if `SNITCH_BREADCRUMBS_MAX` is less than or equal to 0.