---------------------------------------------------------------------------------------------------
-- Common module
---------------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local actions = require("user_modules/sequences/actions")
local hmi_values = require('user_modules/hmi_values')

--[[ Module ]]
local m = actions

m.type = "FILE"

local startOrigin = m.start
function m.start()
  local params = hmi_values.getDefaultHMITable()
  table.insert(params.TTS.GetCapabilities.params.speechCapabilities, m.type)
  startOrigin(params)
end

return m
