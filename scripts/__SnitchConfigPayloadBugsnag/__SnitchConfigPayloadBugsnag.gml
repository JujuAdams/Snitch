// https://bugsnagerrorreportingapi.docs.apiary.io/#reference/0/notify/send-error-reports

function __SnitchConfigPayloadBugsnag(_uuid, _message, _longMessage, _callstack, _fatal)
{
    return {
        payloadVersion: "5",
        notifier: {
            name: "Snitch",
            version: SNITCH_VERSION,
            url: "https://github.com/jujuAdams/snitch/",
        },
        events: [
            {
                exceptions: [
                    {
                        errorClass: _message,
                        message: _longMessage,
                        stacktrace: _callstack,
                    },
                ],
                severity: _fatal? "error" : "warning",
            },
        ],
    };
}