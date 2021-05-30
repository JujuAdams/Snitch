/// Concatenates a series of values into a string, and creates a new event using the string
/// If communication with sentry.io is enabled then the event will be sent to the remote logging server
/// Events automatically have breadcrumbs attached to them. Breadcrumbs can be created using SnitchCrumb()
/// You can (and maybe should?) rename this function to whatever you want e.g. debugEvent()
/// 
/// 
/// 
/// This function returns an event struct. The event struct *must* have its .Finish() method called i.e.:
///   
///   SnitchEvent("Player found a secret level").Finish();
///   
/// Event structs have a number of methods that can be chained together in a "fluent interface" i.e.:
/// 
///   SnitchEvent("Player is outside the level?!").Debug().LogCallstack().Finish();
/// 
/// Event methods are used to set properties for the event, such as message level or callstack logging
/// These are as follows:
/// 
/// .Info()
///     Sets the event level to "info", the lowest event level
///     
/// .Debug()
///     Sets the event level to "debug"
///     
/// .Warning()
///     Sets the event level to "warning"
///     
/// .Error()
///     Sets the event level to "error"
///     
/// .Fatal()
///     Sets the event level to "fatal", the highest event level
///     
/// .Finish()
///     Finalises the event, outputting information to the debug console if required
///     Additionally, if sentry.io communication is enabled, .Finish() will send the HTTP request
///     If request backups are enabled, a request backup is also saved. See SNITCH_REQUEST_BACKUP_ENABLE for more information
///     This function typically returns <undefined>, but if an HTTP request has been sent, this function returns the request struct
///     If .ForceRequest() has been called for the event then .Finish() will awlays return a request struct
///     
/// .Exception(exceptionStruct)
///     Sets a number of attributes based on a standard GameMaker exception struct
///     This function overwrites values set by .LongMessage() and .Callstack()
///     Additionally, any message set when creating the event will be overwritten by the .message variable in the exception struct
///     
/// .LongMessage(string)
///     Sets the event's "longMessage" property. This is used for error-level and fatal-level events to add extra context
///     
/// .Callstack([callstackArray], [trimCount])
///     Sets the event's callstack. If no arguments are provided then the callstack is generated from where this function was called
///     The optional [trimCount] argument allows for the given number of callstack levels to be removed
///     
/// .LogCallstack()
///      Instructs the event to output its callstack to the console
///      If logging is enabled, this information will also be outputted to the log file
///     
/// .ForceRequest()
///      Instructs the event to always return a request struct, even if sentry.io communication is disabled
///      
/// .Payload(struct)
///      Overrides the use of the shared event payload (see __SnitchSharedEventPayload()) for a custom struct
///      The following member variables will always be automatically set by Snitch no matter what payload is used:
///        .event_id
///        .timestamp
///        .level
///        .breadcrumbs
///        .stacktrace
///        ."sentry.interfaces.Message"
///        .exception
/// 
/// 
/// 
/// @param value
/// @param [value]...

function SnitchEvent()
{
    __SnitchInit();
    
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    return new __SnitchClassEvent(_string);
}