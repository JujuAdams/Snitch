global.__snitchFrames++;

if (!os_is_paused() && window_has_focus())
{
    global.__snitchFocusFrames++;
    global.__snitchFocusTime += delta_time/1000;
}

if (SNITCH_NETWORK_MODE == 2)
{
    if (global.__snitchNetworkConnected)
    {
        //Churn through the pending messages and clear them out
        repeat(ceil(sqrt(array_length(global.__snitchNetworkPendingMessages))))
        {
            __SnitchSendStringToNetwork(global.__snitchNetworkPendingMessages[0]);
            array_delete(global.__snitchNetworkPendingMessages, 0, 1);
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
                    if (SNITCH_REQUEST_BACKUP_OUTPUT_ATTEMPT) __SnitchTrace("Trying to resend event ", _uuid);
                    
                    switch(SNITCH_SERVICE_MODE)
                    {
                        case 1: __SnitchSentryHTTPRequest(self);        break;
                        case 2: __SnitchGameAnalyticsHTTPRequest(self); break;
                        case 3: __SnitchBugsnagHTTPRequest(self);       break;
                    }
                    
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