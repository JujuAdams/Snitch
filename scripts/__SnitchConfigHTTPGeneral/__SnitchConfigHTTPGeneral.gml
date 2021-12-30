//Whether to allow backups to be made for HTTP requests
//Any requests that fail will be reattempted at a later time
#macro  SNITCH_REQUEST_BACKUP_ENABLE  true

//Name of the request backup manifest
//This file records how many request backups exist and where to find them on disk
#macro  SNITCH_REQUEST_BACKUP_MANIFEST_FILENAME  "event_manifest.dat"

//Name of request backup files. Use a # symbol for UUID position
#macro  SNITCH_REQUEST_BACKUP_FILENAME  "event_#.dat"

//How many request backups to keep
#macro  SNITCH_REQUEST_BACKUP_COUNT  10

//The time, in milliseconds, between attempts to resend HTTP requests. 5000 = 5 seconds
#macro  SNITCH_REQUEST_BACKUP_RESEND_DELAY  5000

//How many sequential HTTP request failures before Snitch decides to not try to resend request backups for a while
//This is useful behaviour for mobile games where the player may lose their connection for some unpredictable reason
#macro  SNITCH_REQUEST_BACKUP_RESEND_MAX_FAILURES  5

//How long to wait after sequential failed backup resends before Snitch will try all over again
//This value is in milliseconds, so 900000 is the same as 15 minutes
#macro  SNITCH_REQUEST_BACKUP_RESEND_FAILURE_TIMEOUT  900000

//Whether to output request backup send attempts to the console
//This is handy for confirming request backups are being processed properly
//If logging is enabled, this information will also be outputted to the log file
#macro  SNITCH_REQUEST_BACKUP_OUTPUT_ATTEMPT  false

//Whether to output HTTP success to the console. This is handy for confirming HTTP requests are being processed properly
//If logging is enabled, this information will also be outputted to the log file
//   N.B. HTTP warnings/failures will always be reported
#macro  SNITCH_OUTPUT_HTTP_SUCCESS  false