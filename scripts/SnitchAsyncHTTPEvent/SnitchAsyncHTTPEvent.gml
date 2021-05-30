/// Handles HTTP communication for Snitch
/// This function should be called every frame in the "Async HTTP" event, typically in a persistent controller instance

function SnitchAsyncHTTPEvent()
{
    __SnitchInit();
    
    var _id = string(async_load[? "id"]);
    if (variable_struct_exists(global.__snitchHTTPRequests, _id))
    {
        //Pass the response into the request's response handler
        global.__snitchHTTPRequests[$ _id].HTTPResponse(async_load[? "http_status"], async_load[? "status"]);
    }
}