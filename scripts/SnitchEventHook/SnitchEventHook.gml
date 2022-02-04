/// This function *must* be called once per frame in a Step event or many Snitch behaviours
/// will not work. This is typically done by calling this function in the Step event of a
/// persistent instance. Be careful that instance doesn't get deactivated if you're
/// using instance deactivation in your game!
/// 
/// If you're using the Google Analytics, sentry.io, or GameAnalytics integrations then
/// this function must also be called in an Async HTTP event every frame. Again, this is
/// typically done in a persistent instance that is never deactivated.

function SnitchEventHook()
{
    __SnitchInit();
    
    if ((event_type == ev_step) || (event_type == ev_draw))
    {
        if (SNITCH_INTEGRATION_MODE == 2)
        {
            if (global.__snitchRequestBackupFailures < SNITCH_REQUEST_BACKUP_RESEND_MAX_FAILURES)
            {
                if (current_time - global.__snitchRequestBackupResendTime > SNITCH_REQUEST_BACKUP_RESEND_DELAY)
                {
                    var _backupCount = array_length(global.__snitchRequestBackupOrder);
                    if (_backupCount > 0)
                    {
                        //Step round the request backup array
                        global.__snitchRequestBackupResendIndex = (global.__snitchRequestBackupResendIndex + 1) mod _backupCount;
                        
                        //Pull out a backup...
                        var _uuid = global.__snitchRequestBackupOrder[global.__snitchRequestBackupResendIndex];
                        with(global.__snitchRequestBackups[$ _uuid])
                        {
                            //...and if we're not waiting for a response for this particular request, resend it
                            if (asyncID < 0)
                            {
                                if (SNITCH_REQUEST_BACKUP_OUTPUT_ATTEMPT) __SnitchTrace("Trying to resend event ", _uuid);
                                __SnitchSentryHTTPRequest(self);
                                global.__snitchRequestBackupResendTime = current_time;
                            }
                        }
                    }
                }
            }
            else
            {
                if (current_time - global.__snitchRequestBackupResendTime > SNITCH_REQUEST_BACKUP_RESEND_FAILURE_TIMEOUT)
                {
                    global.__snitchRequestBackupFailures = 0;
                    __SnitchTrace("Retrying backup resending");
                }
            }
        }
    }
    else if ((event_type == ev_other) && (event_number == ev_async_web))
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
        __SnitchError("Snitch object event hook should only be placed in a Step event or an HTTP Async event");
    }
}