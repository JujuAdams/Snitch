//Simple message logging
if (keyboard_check_pressed(ord("1"))) Snitch("Pressed the 1 key");

//Since oInvalidObject doesn't exist, pressing the 4 key will generate a real error
if (keyboard_check_pressed(ord("2"))) oInvalidObject.x += 1;

//show_error() also works with the crash handler
if (keyboard_check_pressed(ord("3"))) show_error("Pressed the 3 key", true);

//Trigger a debug event
if (keyboard_check_pressed(ord("4"))) SnitchSoftError("Wow! An error!");

//Toggle logging on and off
if (keyboard_check_pressed(ord("L"))) SnitchLogSet(!SnitchLogGet());

//Toggle networking on and off
if (keyboard_check_pressed(ord("N"))) SnitchNetworkSet(!SnitchNetworkGet());

//Toggle service on and off
if (keyboard_check_pressed(ord("S"))) SnitchServiceSet(!SnitchServiceGet());