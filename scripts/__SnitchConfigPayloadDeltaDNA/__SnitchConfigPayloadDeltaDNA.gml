// https://docs.deltadna.com/advanced-integration/rest-api/

function __SnitchConfigPayloadDeltaDNA(_uuid, _message, _longMessage, _callstack, _fatal)
{
    return {
        eventName: "exception",
        userID: SNITCH_SESSION_ID, //Deliberately randomized so that players can't be tracked across sessions
        sessionID: SNITCH_SESSION_ID,
        eventUUID: _uuid,
        eventParams: {
            exceptionMessage:     _message,
            exceptionLongMessage: is_string(_longMessage)? _longMessage : _message,
            exceptionStacktrace:  _callstack,
            exceptionFatal:       _fatal,
        },
    };
}