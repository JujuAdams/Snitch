/// Handles Snitch's update logic
/// This function should be called every frame in the Step event, typically in a persistent controller instance

function SnitchStepEvent()
{
    __SnitchInit();
    
    if (SNITCH_SENTRY_PERMITTED)
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
    
    //Check for any unfinished events
    if (global.__snitchUnfinishedEvent != undefined)
    {
        if (SNITCH_UNFINISHED_EVENT_ERROR)
        {
            __SnitchError("Event unfinished. Please call .Finish() at the end of every SnitchEvent()\nmessage = \"", message, "\"\nlogger = \"", logger, "\"\nlevel = \"", level, "\"\ncallstack = \"", rawCallstack, "\"\n \n(Set SNITCH_UNFINISHED_EVENT_ERROR to <false> to hide this error)");
        }
        else
        {
            __SnitchTrace("Event unfinished. Please call .Finish() at the end of every SnitchEvent(), message = \"", message, "\", logger = \"", logger, "\", level = \"", level, "\", callstack = \"", rawCallstack, "\"");
        }
    }
}