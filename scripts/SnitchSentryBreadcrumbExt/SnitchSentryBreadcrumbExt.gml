// https://develop.sentry.dev/sdk/event-payloads/breadcrumbs/

/// Adds a custom breadcrumb struct to an array of breadcrumbs which will be send to Sentry whenever the game crashes
/// Read the sentry event payload documentation to find out more about what kind of data this struct can contain

function SnitchSentryBreadcrumbExt(_struct)
{
	if SNITCH_BREADCRUMBS_MAX == 0 return;
	
	static array = __SnitchState().__breadcrumbArray;
	
	array_push(array,_struct);
	
	//Automatically add timestamp if struct doesn't have this member
	if variable_struct_exists(_struct,"timestamp") == false
	{
		_struct.timestamp = SnitchFormatTimestamp(date_current_datetime());
	}
	
	//Prunes oldest breadcrumb if too many exist
	if array_length(array) > SNITCH_BREADCRUMBS_MAX
	{
		array_delete(array,0,1);
	}
}