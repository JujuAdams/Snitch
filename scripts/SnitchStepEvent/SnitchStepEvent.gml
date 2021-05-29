/// Handles Snitch's update logic
/// This function should be called every frame in the Step event, typically in a persistent controller instance

function SnitchStepEvent()
{
    if (SNITCH_SENTRY_PERMITTED && SNITCH_SENTRY_GET_USER_FROM_STEAM)
    {
        if (!global.__snitchSteamInitialised && steam_initialised())
        {
            global.__snitchSteamInitialised = true;
            
            with(SNITCH_SENTRY_DATA)
            {
                if (variable_struct_exists(self, "user") && is_struct(user))
                {
                    user.username = steam_get_persona_name();
                    user.id       = steam_get_user_account_id();
                    __SnitchTrace("Set username = ", user.username, ", id = ", user.id);
                }
            }
        }
    }
    
    if (global.__snitchUnfinishedEvent != undefined)
    {
        if (SNITCH_FUSSY_ERRORS)
        {
            __SnitchError("Event unfinished. Please call .Finish() at the end of every SnitchEvent()\nmessage = \"", message, "\"\nlogger = \"", logger, "\"\nlevel = \"", level, "\"\ncallstack = \"", callstack, "\"\n \n(Set SNITCH_FUSSY_ERRORS to <false> to hide this error)");
        }
        else
        {
            __SnitchTrace("Event unfinished. Please call .Finish() at the end of every SnitchEvent(), message = \"", message, "\", logger = \"", logger, "\", level = \"", level, "\", callstack = \"", callstack, "\"");
        }
    }
}