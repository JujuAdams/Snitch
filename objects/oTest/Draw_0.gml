var _string = "";
_string += "Snitch by @jujuadams " + __SNITCH_VERSION + ", " + __SNITCH_DATE + "\n";
_string += "Log files can be found in " + game_save_id + "\n\n";
_string += "Press 1 to log a message\n";
_string += "Press 2 to call show_debug_message() (redirected to Snitch() by default)\n";
_string += "Press 3 to crash the game\n";
_string += "Press 4 to call show_error()\n";
_string += "Press L to toggle logging (currently = " + string(SnitchLogGet()) + ")\n";
_string += "\n";
_string += "\n";
_string += "\n";

//Display crash data if we have any
if (is_struct(previousCrashData))
{
    _string += "Previous crash data:\n";
    _string += "message = \"" + string(previousCrashData.message) + "\"\n\n";
    _string += "longMessage = \"" + string(previousCrashData.longMessage) + "\"\n\n";
    _string += "script = \"" + string(previousCrashData.script) + "\"\n\n";
    _string += "line = " + string(previousCrashData.line) + "\n\n";
    _string += "stacktrace = " + string(previousCrashData.stacktrace) + "\n\n";
}
else
{
    _string += "No previous crash detected";
}

draw_text(10, 10, _string);