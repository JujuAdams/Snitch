var _string = "";
_string += "Snitch by @jujuadams " + SNITCH_VERSION + ", " + SNITCH_DATE + "\n";
_string += "Log files can be found in " + game_save_id + "\n";
_string += "\n";
_string += "Press 1 to log a message\n";
_string += "Press 2 to crash the game\n";
_string += "Press 3 to call show_error()\n";
_string += "Press 4 to trigger a soft (non-fatal) error\n";
_string += "Press L to toggle logging (currently = " + string(SnitchLogGet()) + ")\n";
_string += "Press N to toggle network transmission (currently = " + string(SnitchNetworkGet()) + ")\n";
_string += "Press S to toggle service (currently = " + string(SnitchServiceGet()) + ")\n";
_string += "\n";
_string += "\n";
_string += "\n";

//Display crash data if we have any
//  N.B. This particular code expects SWITCH_CRASH_DUMP_MODE to be set to 1
if (is_struct(crashDump))
{
    _string += "Previous crash data:\n";
    
    try
    {
        _string += "message = \"" + string(crashDump.message) + "\"\n";
        _string += "\n";
        _string += "longMessage = \"" + string(crashDump.longMessage) + "\"\n";
        _string += "\n";
        _string += "script = \"" + string(crashDump.script) + "\"\n";
        _string += "\n";
        _string += "line = " + string(crashDump.line) + "\n";
        _string += "\n";
        _string += "stacktrace = " + string(crashDump.stacktrace) + "\n";
        _string += "\n";
    }
    catch(_error)
    {
        _string += "(Crash data in unexpected format)";
    }
}
else
{
    _string += "No previous crash detected";
}

draw_text(10, 10, _string);