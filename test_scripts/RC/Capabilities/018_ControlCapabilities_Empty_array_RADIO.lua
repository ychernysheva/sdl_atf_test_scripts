---------------------------------------------------------------------------------------------------
-- Requirement summary:
-- [SDL_RC] Capabilities
--
-- Description:
-- In case:
-- HMI respond with empty array for module to RC.GetCapabilities request from SDL
--
-- SDL must:
-- Reject all RPCs from mobile application to such module with result code UNSUPPORTED_RESOURCE, success:false
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonRC = require('test_scripts/RC/commonRC')

--[[ Local Variables ]]
local disabledModule = "RADIO"
local enabledModule = "CLIMATE"

--[[ Local Functions ]]
local function getHMIParams()
  local hmiCaps = commonRC.buildHmiRcCapabilities(commonRC.DEFAULT, commonRC.DEFAULT, commonRC.DEFAULT)
  hmiCaps.RC.GetCapabilities.params.remoteControlCapability[string.lower(disabledModule) .. "ControlCapabilities"] = { }
  return hmiCaps
end

local function rpcUnsupportedResource(pModuleType, pRPC, self)
  local pAppId = 1
  local mobSession = commonRC.getMobileSession(self, pAppId)
  local cid = mobSession:SendRPC(commonRC.getAppEventName(pRPC), commonRC.getAppRequestParams(pRPC, pModuleType))
  EXPECT_HMICALL(commonRC.getHMIEventName(pRPC), {}):Times(0)
  mobSession:ExpectResponse(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE" })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Backup HMI capabilities file", commonRC.backupHMICapabilities)
runner.Step("Update HMI capabilities file", commonRC.updateDefaultCapabilities, { { enabledModule } })
runner.Step("Clean environment", commonRC.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonRC.start, { getHMIParams() })
runner.Step("RAI, PTU", commonRC.rai_ptu)
runner.Step("Activate App", commonRC.activate_app)

runner.Title("Test - Module enabled: " .. enabledModule .. ", disabled: " .. disabledModule)

runner.Step("GetInteriorVehicleData", rpcUnsupportedResource, { disabledModule, "GetInteriorVehicleData" })
runner.Step("SetInteriorVehicleData", rpcUnsupportedResource, { disabledModule, "SetInteriorVehicleData" })

runner.Title("Postconditions")
runner.Step("Stop SDL", commonRC.postconditions)
runner.Step("Restore HMI capabilities file", commonRC.restoreHMICapabilities)
