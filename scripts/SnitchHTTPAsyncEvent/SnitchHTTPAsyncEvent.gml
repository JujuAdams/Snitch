/// If you're using an integrations then this function must be called in an Async HTTP event
/// every frame. This is typically done in a persistent instance. Be careful that instance
/// doesn't get deactivated if you're using instance deactivation in your game!

function SnitchHTTPAsyncEvent()
{
    __SnitchInit();
    
    if (global.__snitchHTTPTestTime != undefined) global.__snitchHTTPTestTime = undefined;
    
    if ((event_type == ev_other) && (event_number == ev_async_web))
    {
        var _id = string(async_load[? "id"]);
        if (variable_struct_exists(global.__snitchHTTPRequests, _id))
        {
            //Pass the response into the request's response handler
            global.__snitchHTTPRequests[$ _id].__HTTPResponse(async_load[? "http_status"], async_load[? "status"]);
        }
    }
    else
    {
        __SnitchError("SnitchHTTPAsyncEvent() should only be placed in an HTTP Async event");
    }
}