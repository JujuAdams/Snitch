/// Creates a new breadcrumb, adds it to an internal breadcrumb array, and returns the breadcrumb struct itself
/// Breadcrumbs will be attached to any sentry.io events to help you debug your game
/// If SNITCH_OUTPUT_BREADCRUMBS is set to <true>, the breadcrumb will also be outputted to the console (and can also be logged to file)
/// This function is mostly intended to be used with the sentry.io integration but can also be used offline
/// Breadcrumb structs have a few methods that can be used to contextualise data
/// 
/// @param value
/// @param [value]...

function SnitchCrumb()
{
    __SnitchInit();
    
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    if (SNITCH_OUTPUT_BREADCRUMBS)
    {
        __SnitchLogString("[crumb]  " + string(_string));
        __show_debug_message__("[crumb]  " + string(_string));
    }
    
    return new __SnitchClassBreadcrumb(_string);
}