__SnitchState().__Frames++;

if (!os_is_paused() && window_has_focus())
{
    __SnitchState().__FocusFrames++;
    __SnitchState().__FocusTime += delta_time/1000;
}

if (SNITCH_NETWORK_MODE == 2)
{
    if (__SnitchState().__NetworkConnected)
    {
        //Churn through the pending messages and clear them out
        repeat(ceil(sqrt(array_length(__SnitchState().__NetworkPendingMessages))))
        {
            __SnitchSendStringToNetwork(__SnitchState().__NetworkPendingMessages[0]);
            array_delete(__SnitchState().__NetworkPendingMessages, 0, 1);
        }
    }
}

if (__SnitchState().__RequestBackupFailures < SNITCH_REQUEST_BACKUP_RESEND_MAX_FAILURES)
{
    if (current_time - __SnitchState().__RequestBackupResendTime > SNITCH_REQUEST_BACKUP_RESEND_DELAY)
    {
        var _backupCount = array_length(__SnitchState().__RequestBackupOrder);
        if (_backupCount > 0)
        {
            //Step round the request backup array
            __SnitchState().__RequestBackupResendIndex = (__SnitchState().__RequestBackupResendIndex + 1) mod _backupCount;
            
            //Pull out a backup...
            var _uuid = __SnitchState().__RequestBackupOrder[__SnitchState().__RequestBackupResendIndex];
            with(__SnitchState().__RequestBackups[$ _uuid])
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
                    
                    __SnitchState().__RequestBackupResendTime = current_time;
                }
            }
        }
    }
}
else
{
    if (current_time - __SnitchState().__RequestBackupResendTime > SNITCH_REQUEST_BACKUP_RESEND_FAILURE_TIMEOUT)
    {
        __SnitchState().__RequestBackupFailures = 0;
        __SnitchTrace("Retrying backup resending");
    }
}