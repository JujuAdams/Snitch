/// Handles Snitch's update logic
/// This function should be called every frame in the Step event, typically in a persistent controller instance

function SnitchStepEvent()
{
    __SnitchInit();
    
    if (SNITCH_SENTRY_PERMITTED)
    {
        if (SNITCH_SENTRY_GET_USER_FROM_STEAM)
        {
            //Set the username/user ID to whatever Steam gives us, but only after Steam has initialised fully
            if (!global.__snitchSteamInitialised && steam_initialised())
            {
                global.__snitchSteamInitialised = true;
                
                with(SNITCH_SENTRY_DATA)
                {
                    var _set = false;
                    if (variable_struct_exists(self, "user"))
                    {
                        if (is_struct(user)) _set = true;
                    }
                    else
                    {
                        user = {};
                        _set = true;
                    }
                    
                    if (_set)
                    {
                        user.username = steam_get_persona_name();
                        user.id       = steam_get_user_account_id();
                        __SnitchTrace("Set username = ", user.username, ", id = ", user.id);
                    }
                }
            }
        }
        
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
                            __SnitchTrace("Trying to resend event ", _uuid);
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
    
    if (global.__snitchUnfinishedEvent != undefined)
    {
        if (SNITCH_UNFINISHED_EVENT_ERROR)
        {
            __SnitchError("Event unfinished. Please call .Finish() at the end of every SnitchEvent()\nmessage = \"", message, "\"\nlogger = \"", logger, "\"\nlevel = \"", level, "\"\ncallstack = \"", callstack, "\"\n \n(Set SNITCH_UNFINISHED_EVENT_ERROR to <false> to hide this error)");
        }
        else
        {
            __SnitchTrace("Event unfinished. Please call .Finish() at the end of every SnitchEvent(), message = \"", message, "\", logger = \"", logger, "\", level = \"", level, "\", callstack = \"", callstack, "\"");
        }
    }
}