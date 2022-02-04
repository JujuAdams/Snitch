/// Sets whether Snitch should enable integrations
///   N.B. Integrations cannot be enabled unless the relevant macros in __SnitchConfigIntegrations() are set to <true>
/// 
/// @param state

function SnitchIntegrationSet(_state)
{
    __SnitchInit();
    
    if (SnitchIntegrationGet() != _state)
    {
        if (_state)
        {
            if (SNITCH_INTEGRATION_MODE > 0)
            {
                global.__snitchIntegrationEnabled = true;
                __SnitchTrace("Integration turned on");
            }
            else
            {
                __SnitchTrace("Integration cannot be turned on as no integration has been enabled\nPlease set SNITCH_INTEGRATION_MODE");
            }
        }
        else
        {
            global.__snitchIntegrationEnabled = false;
            __SnitchTrace("Integration turned off");
        }
    }
}