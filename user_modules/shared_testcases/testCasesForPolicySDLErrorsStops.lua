local testCasesForPolicySDLErrorsStops = {}
local json = require("modules/json")

--The function will check if 'message' is printed in SmartDeviceLinkCore.log
-- should return:
--               true if 'message' is found
--               false if 'message' is not found
--TODO: DEV team should give list of [ERROR] messages printed from ApplicationManager
function testCasesForPolicySDLErrorsStops.ReadSpecificMessage(message)
  return false
end

--The function will corrupt specific 'section' with data 'specificParameters'
function testCasesForPolicySDLErrorsStops.updatePreloadedPT(section, specificParameters)

  local pathToFile = config.pathToSDL .. "sdl_preloaded_pt.json"

  local file = io.open(pathToFile, "r")
  local json_data = file:read("*a")
  file:close()

  local data = json.decode(json_data)
  if data then
    for key, value in pairs(specificParameters) do
    	-- TODO: should be done for all possible sections of preloaded_pt.json
    	-- Example:
      if(section == "data.policy_table.module_config") then
        data.policy_table.module_config[key] = value
      end
    end
  end

  local dataToWrite = json.encode(data)
  file = io.open(pathToFile, "w")
  file:write(dataToWrite)
  file:close()
end

return testCasesForPolicySDLErrorsStops


