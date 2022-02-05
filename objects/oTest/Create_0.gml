//Start logging messages to a disk on disk
SnitchLogFileSet(true);

//Try to start our integration
//This'll only work if the relevant information has been set up in __SnitchConfigIntegrations()
SnitchIntegrationSet(true);

//Try to collect crash data from the previous run of the game (if any exists)
crashDump = SnitchCrashDumpCollect();
//Then clean up the crash dump (if one even exists)
SnitchCrashDumpDelete();