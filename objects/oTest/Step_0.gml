if (keyboard_check_pressed(ord("1"))) Snitch("Pressed the 1 key");
if (keyboard_check_pressed(ord("2"))) show_debug_message("Pressed the 2 key");
if (keyboard_check_pressed(ord("3"))) show_error("Pressed the 3 key", true);
if (keyboard_check_pressed(ord("4"))) oInvalidObject.x += 1;
if (keyboard_check_pressed(ord("L"))) SnitchLogSet(!SnitchLogGet());