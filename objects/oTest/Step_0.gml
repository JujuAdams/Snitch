//Simple message logging
if (keyboard_check_pressed(ord("1"))) Snitch("Pressed the 1 key");

//If SNITCH_HIJACK_SDM is set to <true> then show_debug_message() calls will also be logged
if (keyboard_check_pressed(ord("2"))) show_debug_message("Pressed the 2 key");

//Since oInvalidObject doesn't exist, pressing the 4 key will generate a real error
if (keyboard_check_pressed(ord("3"))) oInvalidObject.x += 1;

//show_error() also works with the crash handler
if (keyboard_check_pressed(ord("4"))) show_error("Pressed the 4 key", true);

//Toggle logging on and off
if (keyboard_check_pressed(ord("L"))) SnitchLogSet(!SnitchLogGet());