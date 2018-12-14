data:extend({
    {
        type = "string-setting",
        name = "FactoLog-2-solid-production-statistics",
        setting_type = "runtime-global",
        default_value = "none",
        allowed_values = {"none", "both", "input", "output"}
    }
})

data:extend({
    {
        type = "string-setting",
        name = "FactoLog-2-fluid-production-statistics",
        setting_type = "runtime-global",
        default_value = "none",
        allowed_values = {"none", "both", "input", "output"}
    }
})

data:extend({
    {
        type = "string-setting",
        name = "FactoLog-2-kill-count-statistics",
        setting_type = "runtime-global",
        default_value = "none",
        allowed_values = {"none", "both", "input", "output"}
    }
})

data:extend({
    {
        type = "string-setting",
        name = "FactoLog-2-entity-build-statistics",
        setting_type = "runtime-global",
        default_value = "none",
        allowed_values = {"none", "both", "input", "output"}
    }
})

data:extend({
    {
        type = "string-setting",
        name = "FactoLog-1-statistics-logging-interval",
        setting_type = "runtime-global",
        default_value = "1m",
        allowed_values = {"5s", "10s", "30s", "1m", "5m", "10m", "30m", "1h", "5h"}
    }
})

data:extend({
    {
        type = "string-setting",
        name = "FactoLog-1-logfile-name",
        setting_type = "runtime-global",
        default_value = "default"
    }
})

data:extend({
    {
        type = "bool-setting",
        name = "FactoLog-3-logging-activated",
        setting_type = "runtime-global",
        default_value = false
    }
})

data:extend({
    {
        type = "bool-setting",
        name = "FactoLog-2-launched-items-statistics",
        setting_type = "runtime-global",
        default_value = false
    }
})

data:extend({
    {
        type = "bool-setting",
        name = "FactoLog-2-launched-rockets-statistics",
        setting_type = "runtime-global",
        default_value = false
    }
})

data:extend({
    {
        type = "bool-setting",
        name = "FactoLog-2-evolution-factor-statistics",
        setting_type = "runtime-global",
        default_value = false
    }
})

