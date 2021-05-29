function SnitchGenerateUUID4String()
{
    //FIXME - Do this without using MD5 and without random()/choose() calls
    var _UUID = md5_string_utf8(string(current_time) + string(date_current_datetime()) + string(random(1000000)));
    _UUID = string_set_byte_at(_UUID, 13, ord("4"));
    _UUID = string_set_byte_at(_UUID, 17, ord(choose("8", "9", "a", "b")));
    return _UUID;
}