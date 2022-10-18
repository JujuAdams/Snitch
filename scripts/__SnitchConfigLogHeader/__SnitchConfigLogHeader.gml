function __SnitchConfigLogHeader()
{
    return [
        "date = ",             date_datetime_string(date_current_datetime()), "\n",
        "config = ",           os_get_config(),                               "\n",
        "running from ide = ", SNITCH_RUNNING_FROM_IDE,                       "\n",
        "yyc = ",              code_is_compiled(),                            "\n",
        "build date = ",       date_datetime_string(GM_build_date),           "\n",
        "version = ",          GM_version,                                    "\n",
        "GM runtime = ",       GM_runtime_version,                            "\n",
        "boot parameters = ",  SNITCH_BOOT_PARAMETERS,                        "\n",
        "browser = ",          SNITCH_BROWSER,                                "\n",
        "os type = ",          SNITCH_OS_NAME,                                "\n",
        "os version = ",       SNITCH_OS_VERSION,                             "\n",
        "os language = ",      os_get_language(),                             "\n",
        "os region = ",        os_get_region(),                               "\n",
        "os info = ",          json_stringify(SNITCH_OS_INFO),                "\n",
        "\n",
        "\n",
        "\n",
    ];
}