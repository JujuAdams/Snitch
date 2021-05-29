/// Handles HTTP communication for Snitch
/// This function should be called every frame in the "Async HTTP" event, typically in a persistent controller instance

function SnitchAsyncHTTPEvent()
{
    __SnitchInit();
    
    var _id           = string(async_load[? "id"]);
    var _status       = async_load[? "status"     ];
    var _responseCode = async_load[? "http_status"];
    var _result       = async_load[? "result"     ];
    
    if (variable_struct_exists(global.__snitchHTTPRequests, _id))
    {
        var _requestData = global.__snitchHTTPRequests[$ _id];
        var _UUID = _requestData.UUID;
        var _destroy = false;
        
        _requestData.responseCode = _responseCode;
        _requestData.status       = _status;
        
        if (_responseCode == 200)
        {
            if (SNITCH_OUTPUT_HTTP_SUCCESS) SnitchCrumb("HTTP ", _UUID, " complete (200)").HTTP("sentry.io", "POST", 200);
            _destroy = true;
        }
        else if (_status == 0)
        {
            SnitchCrumb("HTTP ", _UUID, " complete but may have been unsuccessful (", _responseCode, ")").Warning().HTTP("sentry.io", "POST", _responseCode);
            _destroy = true;
        }
        else if (_status != 1)
        {
            SnitchCrumb("HTTP ", _UUID, " failed (", _responseCode, ")").Warning().HTTP("sentry.io", "POST", _responseCode);
            _destroy = true;
        }
        else
        {
            //Pending, do nothing
        }
        
        if (_destroy)
        {
            buffer_delete(_requestData.buffer);
            variable_struct_remove(global.__snitchHTTPRequests, _id);
        }
        
        return true;
    }
    
    return false;
}