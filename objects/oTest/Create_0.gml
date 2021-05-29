//Start logging messages to a disk on disk
SnitchLogSet(true);

SnitchSentrySet(true);

//Try to collect crash data from the previous run of the game (if any exists)
previousCrashData = SnitchCrashCollect();