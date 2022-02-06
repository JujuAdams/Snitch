//Keep Snitch up to date
SnitchEventHook();

//Simple message logging
if (keyboard_check_pressed(ord("1"))) Snitch("Pressed the 1 key");

//Since oInvalidObject doesn't exist, pressing the 4 key will generate a real error
if (keyboard_check_pressed(ord("2"))) oInvalidObject.x += 1;

//show_error() also works with the crash handler
if (keyboard_check_pressed(ord("3"))) show_error("Pressed the 3 key", true);

//Trigger a debug event
if (keyboard_check_pressed(ord("4"))) SnitchError("Wow! An error!").SendAll();

//Toggle logging on and off
if (keyboard_check_pressed(ord("L"))) SnitchLogFileSet(!SnitchLogFileGet());

//Toggle integration on and off
if (keyboard_check_pressed(ord("I"))) SnitchIntegrationSet(!SnitchIntegrationGet());