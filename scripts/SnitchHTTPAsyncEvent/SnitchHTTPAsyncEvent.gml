/// This function *must* be called once per frame in a Step event or many Snitch behaviours
/// will not work. This is typically done by calling this function in the Step event of a
/// persistent instance. Be careful that instance doesn't get deactivated if you're
/// using instance deactivation in your game!
/// 
/// If you're using the Google Analytics, sentry.io, or GameAnalytics integrations then
/// this function must also be called in an Async HTTP event every frame. Again, this is
/// typically done in a persistent instance that is never deactivated.

function SnitchHTTPAsyncEvent()
{
    __SnitchInit();
    
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