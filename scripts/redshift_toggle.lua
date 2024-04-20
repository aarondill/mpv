-- Toggle redshift when viewing videos with mpv
local mp = require("mp")

if os.execute("pgrep -x redshift &>/dev/null") ~= 0 then return end

-- Consider that redshift is enabled when starting
local rs_enabled = true

local function rs_toggle()
  os.execute('pid=$(pgrep -x redshift) && kill -USR1 "$pid"')
  mp.msg.log("info", (rs_enabled and "Dis" or "Reen") .. "abling redshift")
  rs_enabled = not rs_enabled
end

local vo_configured = false
mp.observe_property("vo-configured", "bool", function(_, value)
  vo_configured = value
  if value ~= rs_enabled then return end
  return rs_toggle()
end)

local paused
mp.observe_property("pause", "bool", function(_, value)
  paused = value
  if not vo_configured or value == rs_enabled then return end
  return rs_toggle()
end)

mp.register_event("shutdown", function()
  if paused or not mp.get_property_bool("vo-configured") then return end
  return rs_toggle()
end)
