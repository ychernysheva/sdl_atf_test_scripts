---------------------------------------------------------------------------------------------------
-- Requirement summary:
-- [SDL_RC] Capabilities
--
-- Description:
-- In case:
-- SDL send RC.GetCapabilities request to HMI
-- and HMI respond on this request with CLIMATE capabilities with all parameters are false
--
-- SDL must:
-- Respond UNSUPPORTED_RESOURCE on all requests for module CLIMATE with unsupported parameters
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonRC = require('test_scripts/RC/commonRC')
local commonTestCases = require("user_modules/shared_testcases/commonTestCases")

--[[ Local Variables ]]
local disabledModule = "CLIMATE"
local enabledModule = "RADIO"

local disabledCapabilities =  {
        {
          moduleName = "Climate",
          acEnableAvailable = false,
          acMaxEnableAvailable = false,
          autoModeEnableAvailable = false,
          circulateAirEnableAvailable = false,
          currentTemperatureAvailable = false,
          defrostZoneAvailable = false,
          desiredTemperatureAvailable = false,
          dualModeEnableAvailable = false,
          fanSpeedAvailable = false,
          ventilationModeAvailable = false
        }
    }

--[[ Local Functions ]]
local function getHMIParams()
  local function getHMICapsParams()
    if enabledModule == "CLIMATE" then
      return { commonRC.DEFAULT, disabledCapabilities, commonRC.DEFAULT }
    elseif enabledModule == "RADIO" then
      return { disabledCapabilities, commonRC.DEFAULT, commonRC.DEFAULT }
    end
  end
  local hmiCaps = commonRC.buildHmiRcCapabilities(unpack(getHMICapsParams()))
  local buttonCaps = hmiCaps.RC.GetCapabilities.params.remoteControlCapability.buttonCapabilities
  local buttonId = commonRC.getButtonIdByName(buttonCaps, commonRC.getButtonNameByModule(disabledModule))
  table.remove(buttonCaps, buttonId)
  return hmiCaps
end

local function rpcUnsupportedResource(pModuleType, pRPC, self)
  local pAppId = 1
  local mobSession = commonRC.getMobileSession(self, pAppId)
  local cid = mobSession:SendRPC(commonRC.getAppEventName(pRPC), commonRC.getAppRequestParams(pRPC, pModuleType))
  EXPECT_HMICALL(commonRC.getHMIEventName(pRPC), {}):Times(0)
  mobSession:ExpectResponse(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE" })
  commonTestCases:DelayedExp(commonRC.timeout)
end

local function rpcSuccess(pModuleType, pRPC, self)
  local pAppId = 1
  local mobSession = commonRC.getMobileSession(self, pAppId)
  local cid = mobSession:SendRPC(commonRC.getAppEventName(pRPC), commonRC.getAppRequestParams(pRPC, pModuleType))
  EXPECT_HMICALL(commonRC.getHMIEventName(pRPC), commonRC.getHMIRequestParams(pRPC, pModuleType, pAppId))
  :Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", commonRC.getHMIResponseParams(pRPC, pModuleType))
    end)
  mobSession:ExpectResponse(cid, commonRC.getAppResponseParams(pRPC, true, "SUCCESS", pModuleType))
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

runner.Step("GetInteriorVehicleData_UNSUPPORTED_RESOURCE", rpcSuccess, { disabledModule, "GetInteriorVehicleData" })
runner.Step("SetInteriorVehicleData_UNSUPPORTED_RESOURCE", rpcUnsupportedResource, { disabledModule, "SetInteriorVehicleData" })
runner.Step("ButtonPress_UNSUPPORTED_RESOURCE", rpcUnsupportedResource, { disabledModule, "ButtonPress" })

runner.Step("GetInteriorVehicleData_SUCCESS", rpcSuccess, { enabledModule, "GetInteriorVehicleData" })
runner.Step("SetInteriorVehicleData_SUCCESS", rpcSuccess, { enabledModule, "SetInteriorVehicleData" })
runner.Step("ButtonPress_SUCCESS", rpcSuccess, { enabledModule, "ButtonPress" })

runner.Title("Postconditions")
runner.Step("Stop SDL", commonRC.postconditions)
runner.Step("Restore HMI capabilities file", commonRC.restoreHMICapabilities)
