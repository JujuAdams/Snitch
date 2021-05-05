#macro  SNITCH_LOG_NAME        "log%.txt"   //Use % symbol for number position
#macro  SNITCH_LOG_COUNT       10
#macro  SNITCH_LOG_DEFAULT     true
#macro  SNITCH_CRASH_LOG_NAME  "crash.txt"
#macro  SNITCH_MESSAGE_PREFIX  "Snitch: "

#macro  SNITCH_ALLOW_LOG_PARAM    true
#macro  SNITCH_LOG_PARAM_MESSAGE  ("Logging enabled! You can find the logs in " + string(game_save_id))

#macro  SNITCH_CRASH_MESSAGE  "Oh no! The game has crashed. Please reboot the game and try again"

#macro  SNITCH_HIJACK_SDM  true