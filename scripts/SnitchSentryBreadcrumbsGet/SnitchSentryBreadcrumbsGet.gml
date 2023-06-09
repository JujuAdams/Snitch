// https://develop.sentry.dev/sdk/event-payloads/breadcrumbs

/// Returns all currently collected breadcrumbs
/// This array will be empty if SNITCH_BREADCRUMBS_MAX is less than, or equal to 0

function SnitchSentryBreadcrumbsGet()
{
	return __SnitchState().__breadcrumbArray;
}