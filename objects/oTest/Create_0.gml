//Try to collect crash data from the previous run of the game (if any exists)
crashDump = SnitchCrashDumpCollect();

//Then clean up the crash dump (if one even exists)
SnitchCrashDumpDelete();