function __SnitchConfigPayloadGameAnalytics(_uuid, _message, _longMessage, _callstack, _fatal)
{
    return [
        {
            device: "unknown",
            v: int64(2),
            user_id: SNITCH_SESSION_ID, //Deliberately randomized so that players can't be tracked across sessions
            client_ts: floor(1000*SnitchConvertToUnixTime(date_current_datetime())),
            sdk_version: "rest api v2",
            os_version: SNITCH_GA_OS_VERSION,
            manufacturer: "unknown",
            platform: SNITCH_GA_PLATFORM,
            session_id: SNITCH_SESSION_ID,
            session_num: int64(1),
            limit_ad_tracking: true,
            category: "error",
            severity: __fatal? "critical" : "error",
            message: _message + " " + string(_callstack),
        },
    ];
}