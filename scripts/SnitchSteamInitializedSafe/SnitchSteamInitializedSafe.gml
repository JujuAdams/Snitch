/// Returns whether the Steam API has been initialized...
/// ...without crashing the game if the Steam API isn't in use to begin with

function SnitchSteamInitializedSafe()
{
    if (global.__snitchSteamState == undefined)
    {
        try
        {
            var _initialized = steam_initialised();
            __SnitchTrace("Steam API in use");
            global.__snitchSteamState = true;
            return _initialized;
        }
        catch(_error)
        {
            global.__snitchSteamState = false;
            __SnitchTrace("Steam API unused");
            return false;
        }
    }
    else if (global.__snitchSteamState)
    {
        return steam_initialised();
    }
    else
    {
        return false;
    }
}