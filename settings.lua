data:extend({
    {
        type = "string-setting",
        name = "solid-production-statistics",
        setting_type = "runtime-global",
        default_value = "none",
        allowed_values = {"none", "both", "input", "output"}
    }
})

data:extend({
    {
        type = "string-setting",
        name = "fluid-production-statistics",
        setting_type = "runtime-global",
        default_value = "none",
        allowed_values = {"none", "both", "input", "output"}
    }
})

data:extend({
    {
        type = "string-setting",
        name = "kill-count-statistics",
        setting_type = "runtime-global",
        default_value = "none",
        allowed_values = {"none", "both", "input", "output"}
    }
})

data:extend({
    {
        type = "string-setting",
        name = "entity-build-statistics",
        setting_type = "runtime-global",
        default_value = "none",
        allowed_values = {"none", "both", "input", "output"}
    }
})

data:extend({
    {
        type = "string-setting",
        name = "statistics-logging-interval",
        setting_type = "runtime-global",
        default_value = "1m",
        allowed_values = {"5s", "10s", "30s", "1m", "5m", "10m", "30m", "1h", "5h"}
    }
})

data:extend({
    {
        type = "string-setting",
        name = "logfile-folder-name",
        setting_type = "runtime-global",
        default_value = "default"
    }
})