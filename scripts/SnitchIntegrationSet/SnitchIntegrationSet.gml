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
                global.__snitchIntegrationEnabled = _state;
                __SnitchTrace(__SnitchIntegrationName(), " integration turned ", global.__snitchIntegrationEnabled? "on" : "off");
            }
        }
        else
        {
            __SnitchTrace("Integration cannot be toggled as no integration has been enabled (see SNITCH_INTEGRATION_MODE)");
        }
    }
}