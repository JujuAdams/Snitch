function __SnitchClassBreadcrumb(_string) constructor
{
    message = _string;
    
    array_push(global.__snitchBreadcrumbsArray, self);
    var _count = array_length(global.__snitchBreadcrumbsArray) - SNITCH_BREADCRUMB_LIMIT;
    if (_count > 0) array_delete(global.__snitchBreadcrumbsArray, 0, _count);
    
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
    
    static Logger = function(_logger)
    {
        logger = _logger;
        return self;
    }
}