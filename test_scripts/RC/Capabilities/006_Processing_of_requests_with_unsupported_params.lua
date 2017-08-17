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
-- Respond resultCode: UNSUPPORTED_RESOURCE, success: true
-- on all requests for module CLIMATE that contains supported and unsupported parameters
-- with info parameter apply template "%capability% is not available on HMI"
-- and resultCode: UNSUPPORTED_RESOURCE, success: false on all requests for module CLIMATE
 -- that contains only unsupported parameters
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

local params_true_params_false = { -- resultCode: UNSUPPORTED_RESOURCE, success: true
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
      -- acMaxEnable = true, -- NOK
      -- autoModeEnable = true  -- NOK
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

local params_true_params_absent = { -- resultCode: UNSUPPORTED_RESOURCE, success: true
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

local params_true = { -- resultCode: SUCCESS, success: true
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

local params_false_params_absent = { -- resultCode: UNSUPPORTED_RESOURCE, success: false
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

local params_true_params_false_params_absent = { -- resultCode: UNSUPPORTED_RESOURCE, success: true
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
  EXPECT_HMICALL(commonRC.getHMIEventName(pRPC),
    {appID = commonRC.getHMIAppId(pAppId), moduleData = pParams.hmiRequest})
    :ValidIf(function(_, data) -- no unsupported parameters exists in request
      for k, _ in pairs(data.params.moduleData.climateControlData) do
        if not pParams.hmiRequest.climateControlData[k] then
          return false, 'Parameter ' .. k .. ' is transfered to HMI with value: ' .. tostring(k)
        end
      end
      return true
    end)
  :Do(function(_, data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {moduleData = pParams.hmiResponse})
    end)
  mobSession:ExpectResponse(cid,
    { success = true, resultCode = "UNSUPPORTED_RESOURCE", info = pParams.info, moduleData = pParams.mobileResponse })
  :ValidIf(function(_, data) -- no unsupported parameters exists in request
      for k, _ in pairs(data.payload.moduleData.climateControlData) do
        if not pParams.mobileResponse.climateControlData[k] then
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
  EXPECT_HMICALL(commonRC.getHMIEventName(pRPC),
    {appID = commonRC.getHMIAppId(pAppId), moduleData = pParams.hmiRequest})
  :Do(function(_, _)
    -- no response from HMI
    end)
  mobSession:ExpectResponse(cid, { success = false, resultCode = "GENERIC_ERROR" })
end

local function rpcSuccess(pRPC, pParams, self)
  local pAppId = 1
  local mobSession = commonRC.getMobileSession(self, pAppId)
  local cid = mobSession:SendRPC(commonRC.getAppEventName(pRPC), {moduleData = pParams.mobileRequest})
  EXPECT_HMICALL(commonRC.getHMIEventName(pRPC),
    {appID = commonRC.getHMIAppId(pAppId), moduleData = pParams.hmiRequest})
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
  { "SetInteriorVehicleData", params_true_params_false })
runner.Step(
  "SetInteriorVehicleData with 2 supported and 1 absent params",
  rpcUnsupportedResourceTrue,
  { "SetInteriorVehicleData", params_true_params_absent })
runner.Step("SetInteriorVehicleData with 2 supported params",
  rpcSuccess,
  { "SetInteriorVehicleData", params_true })
runner.Step("SetInteriorVehicleData with no supported and 1 absent and 1 unsupported params",
  rpcUnsupportedResourceFalse,
  { "SetInteriorVehicleData", params_false_params_absent })
runner.Step("SetInteriorVehicleData with 1 supported and 1 absent and 1 unsupported params",
  rpcUnsupportedResourceTrue,
  { "SetInteriorVehicleData", params_true_params_false_params_absent })

runner.Title("Test no response from HMI")
runner.Step(
  "SetInteriorVehicleData with 1 supported and 2 unsupported params no response from HMI",
  rpcGenericError,
  { "SetInteriorVehicleData", params_true_params_false })
runner.Step(
  "SetInteriorVehicleData with 2 supported and 1 absent params no response from HMI",
  rpcGenericError,
  { "SetInteriorVehicleData", params_true_params_absent })
runner.Step(
  "SetInteriorVehicleData with 2 supported params no response from HMI",
  rpcGenericError,
  { "SetInteriorVehicleData", params_true })
runner.Step(
  "SetInteriorVehicleData with no supported and 1 absent and 1 unsupported params no response from HMI",
  rpcUnsupportedResourceFalse,
  { "SetInteriorVehicleData", params_false_params_absent })
runner.Step("SetInteriorVehicleData with 1 supported and 1 absent and 1 unsupported params no response from HMI",
  rpcGenericError,
  { "SetInteriorVehicleData", params_true_params_false_params_absent })

runner.Title("Postconditions")
runner.Step("Stop SDL", commonRC.postconditions)
runner.Step("Restore HMI capabilities file", commonRC.restoreHMICapabilities)
