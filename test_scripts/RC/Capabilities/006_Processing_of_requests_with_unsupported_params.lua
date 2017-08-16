---------------------------------------------------------------------------------------------------
-- Requirement summary:
-- [SDL_RC] Capabilities
--
-- Description:
-- In case:
-- SDL send RC.GetCapabilities request to HMI
-- and HMI respond on this request with CLIMATE capabilities with part of parameters are false or absent
--
-- SDL must:
-- Respond resultCode: UNSUPPORTED_RESOURCE, success: true on all requests for module CLIMATE that contains supported and unsupported parameters
-- with info parameter apply template "%capability% is not available on HMI"
-- and resultCode: UNSUPPORTED_RESOURCE, success: false on all requests for module CLIMATE that contains only unsupported parameters
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonRC = require('test_scripts/RC/commonRC')
local commonTestCases = require("user_modules/shared_testcases/commonTestCases")

--[[ Local Variables ]]
local moduleWithUnsupportedParams = "CLIMATE"
local fullSupportedModule = "RADIO"

local capabilities =  {
  {
    moduleName = "Climate",
    acEnableAvailable = true,
    acMaxEnableAvailable = false,
    autoModeEnableAvailable = false,
    circulateAirEnableAvailable = false,
    currentTemperatureAvailable = true,
    dualModeEnableAvailable = true,
    -- defrostZoneAvailable = true,
    -- desiredTemperatureAvailable = true,
    -- fanSpeedAvailable = true,
    -- ventilationModeAvailable = true
  }
}

local params1ok2nok = { -- resultCode: UNSUPPORTED_RESOURCE, success: true
  mobileRequest = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      acMaxEnable = true, -- NOK
      autoModeEnable = true  -- NOK
    }
  },
  hmiRequest = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
    }
  },
  hmiResponse = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      -- acMaxEnable = true, -- NOK
      -- autoModeEnable = true  -- NOK
    }
  },
  mobileResponse = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      -- acMaxEnable = true, -- NOK
      -- autoModeEnable = true  -- NOK
    }
  },
  info = "acMaxEnableAvailable, autoModeEnableAvailable is not available on HMI"
}

local params2ok1dis = { -- resultCode: UNSUPPORTED_RESOURCE, success: true
  mobileRequest = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      dualModeEnable = true, --OK
      fanSpeed = 30  -- absent
    }
  },
  hmiRequest = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      dualModeEnable = true, --OK
      -- fanSpeed = 30  -- absent
    }
  },
  hmiResponse = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      dualModeEnable = true, --OK
      -- fanSpeed = 30  -- absent
    }
  },
  mobileResponse = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      dualModeEnable = true, --OK
      -- fanSpeed = 30  -- absent
    }
  },
  info = "fanSpeedAvailable is not available on HMI"
}

local param2ok0nok = { -- resultCode: SUCCESS, success: true
  mobileRequest = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      dualModeEnable = true --OK
    }
  },
  hmiRequest = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      dualModeEnable = true --OK
    }
  },
  hmiResponse = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      dualModeEnable = true --OK
    }
  },
  mobileResponse = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      dualModeEnable = true --OK
    }
  },
  info = nil
}

local param0ok1nok1dis = { -- resultCode: UNSUPPORTED_RESOURCE, success: false
  mobileRequest = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acMaxEnable = true, -- NOK
      fanSpeed = 30  -- absent
    }
  },
  hmiRequest = nil,
  hmiResponse = nil,
  mobileResponse = nil,
  info = nil
}

local param1ok1nok1dis = { -- resultCode: UNSUPPORTED_RESOURCE, success: true
  mobileRequest = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      acMaxEnable = true, -- NOK
      fanSpeed = 30  -- absent
    }
  },
  hmiRequest = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      -- acMaxEnable = true, -- NOK
      -- fanSpeed = 30  -- absent
    }
  },
  hmiResponse = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      -- acMaxEnable = true, -- NOK
      -- fanSpeed = 30  -- absent
    }
  },
  mobileResponse = {
    moduleType = "CLIMATE",
    climateControlData =
    {
      acEnable = true, -- OK
      -- acMaxEnable = true, -- NOK
      -- fanSpeed = 30  -- absent
    }
  },
  info = "acMaxEnableAvailable, fanSpeedAvailable is not available on HMI"
}

--[[ Local Functions ]]
local function getHMIParams()
  local function getHMICapsParams()
    if fullSupportedModule == "CLIMATE" then
      return { commonRC.DEFAULT, capabilities, commonRC.DEFAULT }
    elseif fullSupportedModule == "RADIO" then
      return { capabilities, commonRC.DEFAULT, commonRC.DEFAULT }
    end
  end
  local hmiCaps = commonRC.buildHmiRcCapabilities(unpack(getHMICapsParams()))
  local buttonCaps = hmiCaps.RC.GetCapabilities.params.remoteControlCapability.buttonCapabilities
  local buttonId = commonRC.getButtonIdByName(buttonCaps, commonRC.getButtonNameByModule(moduleWithUnsupportedParams))
  table.remove(buttonCaps, buttonId)
  return hmiCaps
end

local function rpcUnsupportedResourceFalse(pRPC, pParams, self)
  local pAppId = 1
  local mobSession = commonRC.getMobileSession(self, pAppId)
  local cid = mobSession:SendRPC(commonRC.getAppEventName(pRPC), {moduleData = pParams.mobileRequest})
  EXPECT_HMICALL(commonRC.getHMIEventName(pRPC), {}):Times(0)
  mobSession:ExpectResponse(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE" })
  commonTestCases:DelayedExp(commonRC.timeout)
end

local function rpcUnsupportedResourceTrue(pRPC, pParams, self)
  local pAppId = 1
  local mobSession = commonRC.getMobileSession(self, pAppId)
  local cid = mobSession:SendRPC(commonRC.getAppEventName(pRPC), {moduleData = pParams.mobileRequest})
  EXPECT_HMICALL(commonRC.getHMIEventName(pRPC), {appID = commonRC.getHMIAppId(pAppId), moduleData = pParams.hmiRequest})
    :ValidIf(function(_, data) -- no unsupported parameters exists in request
      for k, _ in pairs(data.payload.moduleData) do
        if not pParams.hmiRequest[k] then
          return false, 'Parameter ' .. k .. ' is transfered to HMI with value: ' .. tostring(k)
        end
      end
      return true
    end)
  :Do(function(_, data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {moduleData = pParams.hmiResponse})
    end)
  mobSession:ExpectResponse(cid,{ success = true, resultCode = "UNSUPPORTED_RESOURCE", info = pParams.info, moduleData = pParams.mobileResponse })
  :ValidIf(function(_, data) -- no unsupported parameters exists in request
      for k, _ in pairs(data.payload.moduleData) do
        if not pParams.mobileResponse[k] then
          return false, 'Parameter ' .. k .. ' is transfered to App with value: ' .. tostring(k)
        end
      end
      return true
    end)
end

local function rpcGenericError(pRPC, pParams,  self)
  local pAppId = 1
  local mobSession = commonRC.getMobileSession(self, pAppId)
  local cid = mobSession:SendRPC(commonRC.getAppEventName(pRPC), {moduleData = pParams.mobileRequest})
  EXPECT_HMICALL(commonRC.getHMIEventName(pRPC), {appID = commonRC.getHMIAppId(pAppId), moduleData = pParams.hmiRequest})
  :Do(function(_, _)
    -- no response from HMI
    end)
  mobSession:ExpectResponse(cid, { success = false, resultCode = "GENERIC_ERROR" })
end

local function rpcSuccess(pRPC, pParams, self)
  local pAppId = 1
  local mobSession = commonRC.getMobileSession(self, pAppId)
  local cid = mobSession:SendRPC(commonRC.getAppEventName(pRPC), {moduleData = pParams.mobileRequest})
  EXPECT_HMICALL(commonRC.getHMIEventName(pRPC), {appID = commonRC.getHMIAppId(pAppId), moduleData = pParams.hmiRequest})
  :Do(function(_, data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {moduleData = pParams.hmiResponse})
    end)
  mobSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS", moduleData = pParams.mobileResponse })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Backup HMI capabilities file", commonRC.backupHMICapabilities)
runner.Step("Update HMI capabilities file", commonRC.updateDefaultCapabilities, { { fullSupportedModule } })
runner.Step("Clean environment", commonRC.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonRC.start, { getHMIParams() })
runner.Step("RAI, PTU", commonRC.rai_ptu)
runner.Step("Activate App", commonRC.activate_app)

runner.Title("Test UNSUPPORTED_RESOURCE")
runner.Step(
  "SetInteriorVehicleData with 1 supported and 2 unsupported params",
  rpcUnsupportedResourceTrue,
  { "SetInteriorVehicleData", params1ok2nok })
runner.Step(
  "SetInteriorVehicleData with 2 supported and 1 absent params",
  rpcUnsupportedResourceTrue,
  { "SetInteriorVehicleData", params2ok1dis })
runner.Step("SetInteriorVehicleData with 2 supported params",
  rpcSuccess,
  { "SetInteriorVehicleData", param2ok0nok })
runner.Step("SetInteriorVehicleData with no supported and 1 absent and 1 unsupported params",
  rpcUnsupportedResourceFalse,
  { "SetInteriorVehicleData", param0ok1nok1dis })
runner.Step("SetInteriorVehicleData with 1 supported and 1 absent and 1 unsupported params",
  rpcUnsupportedResourceTrue,
  { "SetInteriorVehicleData", param1ok1nok1dis })

runner.Title("Test no response from HMI")
runner.Step(
  "SetInteriorVehicleData with 1 supported and 2 unsupported params no response from HMI",
  rpcGenericError,
  { "SetInteriorVehicleData", params1ok2nok })
runner.Step(
  "SetInteriorVehicleData with 2 supported and 1 absent params no response from HMI",
  rpcGenericError,
  { "SetInteriorVehicleData", params2ok1dis })
runner.Step(
  "SetInteriorVehicleData with 2 supported params no response from HMI",
  rpcGenericError,
  { "SetInteriorVehicleData", param2ok0nok })
runner.Step(
  "SetInteriorVehicleData with no supported and 1 absent and 1 unsupported params no response from HMI",
  rpcUnsupportedResourceFalse,
  { "SetInteriorVehicleData", param0ok1nok1dis })
runner.Step("SetInteriorVehicleData with 1 supported and 1 absent and 1 unsupported params no response from HMI",
  rpcGenericError,
  { "SetInteriorVehicleData", param1ok1nok1dis })

runner.Title("Postconditions")
runner.Step("Stop SDL", commonRC.postconditions)
runner.Step("Restore HMI capabilities file", commonRC.restoreHMICapabilities)
