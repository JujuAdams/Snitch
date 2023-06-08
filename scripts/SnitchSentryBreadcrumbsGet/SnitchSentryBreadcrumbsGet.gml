/// Returns all currently collected breadcrumbs

function SnitchSentryBreadcrumbsGet()
{
	return __SnitchState().__breadcrumbArray;
}