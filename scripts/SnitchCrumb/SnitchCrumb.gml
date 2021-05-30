/// Concatenates a series of values into a single string, creates a breadcrumb struct, and adds it to Snitch's internal breadcrumb array
/// This function returns 
/// You can (and maybe should?) rename this function to whatever you want e.g. crumb()
/// 
/// Breadcrumbs will be attached to any events (see SnitchEvent()) to help you debug your game
/// If SNITCH_OUTPUT_BREADCRUMBS is set to <true>, the breadcrumb will also be outputted to the console (and can also be logged to file)
/// 
/// Breadcrumb structs have a number of methods that can be chained together in a "fluent interface" i.e.:
/// 
///   SnitchCrumb("Shop has no items remaining").Debug().Category("Shop UI");
/// 
/// Breadcrumb methods are used to set properties for the breadcrumb, such as message level or category
/// These are as follows:
/// 
/// .Info()
///     Sets the breadcrumb level to "info". If no type has been set, this sets the type to "info"
///     
/// .Debug()
///     Sets the breadcrumb level to "debug". If no type has been set, this sets the type to "debug"
///     
/// .Warning()
///     Sets the breadcrumb level to "warning". If no type has been set, this sets the type to "warning"
///     
/// .Error()
///     Sets the breadcrumb level to "error". If no type has been set, this sets the type to "error"
///     
/// .Fatal()
///     Sets the breadcrumb level to "fatal". If no type has been set, this sets the type to "error" (not a typo)
///     
/// .Navigation(from, to)
///     Sets the breadcrumb type to "navigation", and sets the start/end points to the given values
///     If no level has been set, this sets the level to "info"
///     
/// .HTTP(url, method, statusCode)
///     Sets the breadcrumb level to "http". The URL/method/statusCode arguments are recorded as well
///     If no level has been set, this sets the level to "info"
///     
/// .Query()
///     Sets the breadcrumb type to "query". If no level has been set, this sets the level to "info"
///     
/// .Transaction()
///     Sets the breadcrumb type to "transaction". If no level has been set, this sets the level to "info"
///     
/// .UI()
///     Sets the breadcrumb type to "ui". If no level has been set, this sets the level to "info"
///     
/// .User()
///     Sets the breadcrumb type to "user". If no level has been set, this sets the level to "info"
///     
/// .Category(string)
///     Sets the breadcrumb's category to the given string
///     
/// .AddData(key, value)
///     Adds a key-value pair of data to the breadcrumb
///     
/// .Logger(string)
///     Sets the logger name to the given string
///     
/// 
/// 
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
    
    if (SNITCH_OUTPUT_BREADCRUMBS) __SnitchTrace("[crumb] " + string(_string));
    
    return new __SnitchClassBreadcrumb(_string);
}