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
    
    if (SNITCH_OUTPUT_BREADCRUMBS) __SnitchLogString("[crumb]  " + string(_string));
    
    return new __SnitchClassSentryBreadcrumb(_string);
}

function __SnitchClassSentryBreadcrumb(_string) constructor
{
    message = _string;
    
    array_push(SNITCH_BREADCRUMBS_ARRAY, self);
    var _count = array_length(SNITCH_BREADCRUMBS_ARRAY) - SNITCH_BREADCRUMB_LIMIT;
    if (_count > 0) array_delete(SNITCH_BREADCRUMBS_ARRAY, 0, _count);
    
    static Category = function(_string)
    {
        category = _string;
        return self;
    }
    
    static Info = function()
    {
        level = "info";
        if (!variable_struct_exists(self, "type")) type = "info";
        return self;
    }
    
    static Debug = function()
    {
        level = "debug";
        if (!variable_struct_exists(self, "type")) type = "debug";
        return self;
    }
    
    static Warning = function()
    {
        level = "warning";
        if (!variable_struct_exists(self, "type")) type = "error";
        return self;
    }
    
    static Error = function()
    {
        level = "error";
        if (!variable_struct_exists(self, "type")) type = "error";
        return self;
    }
    
    static Fatal = function()
    {
        level = "fatal";
        if (!variable_struct_exists(self, "type")) type = "error";
        return self;
    }
    
    static Navigation = function(_from, _to)
    {
        type = "navigation";
        AddData("from", _from);
        AddData("to", _to);
        if (!variable_struct_exists(self, "level")) level = "info";
        return self;
    }
    
    static HTTP = function(_url, _method, _statusCode)
    {
        type = "http";
        AddData("url", _url);
        AddData("method", _method);
        AddData("status_code", _statusCode);
        if (!variable_struct_exists(self, "level")) level = "info";
        return self;
    }
    
    static Query = function()
    {
        type = "query";
        if (!variable_struct_exists(self, "level")) level = "info";
        return self;
    }
    
    static Transaction = function()
    {
        type = "transaction";
        if (!variable_struct_exists(self, "level")) level = "info";
        return self;
    }
    
    static UI = function()
    {
        type = "ui";
        if (!variable_struct_exists(self, "level")) level = "info";
        return self;
    }
    
    static User = function()
    {
        type = "user";
        if (!variable_struct_exists(self, "level")) level = "info";
        return self;
    }
    
    static AddData = function(_key, _value)
    {
        if (!variable_struct_exists(self, "data")) data = {};
        data[$ _key] = _value;
        return self;
    }
}