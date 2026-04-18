// Feather disable all


function __SnitchServiceName()
{
    switch(SNITCH_SERVICE_MODE)
    {
        case 0: return "None";
        case 1: return "sentry.io";
        case 2: return "GameAnalytics";
        case 3: return "Bugsnag";
        case 4: return "Generic";
        
        default:
            __SnitchError("SNITCH_SERVICE_MODE value ", SNITCH_SERVICE_MODE, " unsupported");
        break;
    }
}
