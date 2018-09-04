---------------------------------------------------------------------------------------------------
-- Issue: https://github.com/smartdevicelink/sdl_core/issues/2129
---------------------------------------------------------------------------------------------------
-- Description:
-- In case:
-- 1) Mobile app is in some state
-- 2) Mobile app is moving to another state by one of the events:
--   App activation, App deactivation, Deactivation of HMI, User exit
-- SDL must:
-- 1) Send (or not send) OnHMIStatus notification with appropriate value of 'hmiLevel' parameter
-- Particular behavior and value depends on initial state and event, and described in 'testCases' table below
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/MobileProjection/Phase2/common')
local runner = require('user_modules/script_runner')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false
config.checkAllValidations = true

--[[ Event Functions ]]
local action = {
  activateApp = {
    name = "Activation",
    func = function()
      local requestId = common.getHMIConnection():SendRequest("SDL.ActivateApp", {
        appID = common.getHMIAppId() })
      common.getHMIConnection():ExpectResponse(requestId)
    end
  },
 deactivateApp = {
    name = "De-activation",
    func = function()
      common.getHMIConnection():SendNotification("BasicCommunication.OnAppDeactivated", {
        appID = common.getHMIAppId() })
    end
  },
  deactivateHMI = {
    name = "HMI De-activation",
    func = function()
      common.getHMIConnection():SendNotification("BasicCommunication.OnEventChanged", {
        eventName = "DEACTIVATE_HMI",
        isActive = true })
    end
  },
  activateHMI = {
    name = "HMI Activation",
    func = function()
      common.getHMIConnection():SendNotification("BasicCommunication.OnEventChanged", {
        eventName = "DEACTIVATE_HMI",
        isActive = false })
    end
  },
  exitApp = {
    name = "User Exit",
    func = function()
      common.getHMIConnection():SendNotification("BasicCommunication.OnExitApplication", {
        appID = common.getHMIAppId(),
        reason = "USER_EXIT" })
    end
  }
}

--[[ Local Variables ]]
local testCases = {
  [002] = { t = "PROJECTION", m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [2] = { e = action.deactivateApp, l = "LIMITED",    a = "NOT_AUDIBLE", v = "STREAMABLE" }
  }},
  [004] = { t = "DEFAULT",    m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" },
    [2] = { e = action.deactivateHMI, l = "BACKGROUND", a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" }
  }},
  [006] = { t = "PROJECTION", m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [2] = { e = action.deactivateHMI, l = "BACKGROUND", a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" }
  }},
  [009] = { t = "PROJECTION", m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [2] = { e = action.deactivateApp, l = "LIMITED",    a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [3] = { e = action.deactivateHMI, l = "BACKGROUND", a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" }
  }},
  [012] = { t = "PROJECTION", m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [2] = { e = action.exitApp,       l = "NONE",       a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" }
  }},
  [014] = { t = "DEFAULT",    m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" },
    [2] = { e = action.exitApp,       l = "NONE",       a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" }
  }},
  [016] = { t = "PROJECTION", m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" }
  }},
  [018] = { t = "DEFAULT",    m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" }
  }},
  [020] = { t = "PROJECTION", m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [2] = { e = action.deactivateApp, l = "LIMITED",    a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [3] = { e = action.exitApp,       l = "NONE",       a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" }
  }},
  [023] = { t = "PROJECTION", m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [2] = { e = action.deactivateHMI, l = "BACKGROUND", a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" },
    [3] = { e = action.exitApp,       l = "NONE",       a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" }
  }},
  [027] = { t = "PROJECTION", m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [2] = { e = action.deactivateApp, l = "LIMITED",    a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [3] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" }
  }},
  [030] = { t = "PROJECTION", m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" },
    [2] = { e = action.deactivateHMI, l = "BACKGROUND", a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" },
    [3] = { e = action.activateHMI,   l = "FULL",       a = "NOT_AUDIBLE", v = "STREAMABLE" }
  }},
  [032] = { t = "DEFAULT",    m = false, s = {
    [1] = { e = action.activateApp,   l = "FULL",       a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" },
    [2] = { e = action.deactivateHMI, l = "BACKGROUND", a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" },
    [3] = { e = action.activateHMI,   l = "FULL",       a = "NOT_AUDIBLE", v = "NOT_STREAMABLE" }
  }}
}

--[[ Local Functions ]]
local function doAction(pTC, pSS)
  pSS.e.func()
  common.getMobileSession():ExpectNotification("OnHMIStatus")
  :ValidIf(function(_, data)
      return common.checkAudioSS(pTC, pSS.e.name, pSS.a, data.payload.audioStreamingState)
    end)
  :ValidIf(function(_, data)
      return common.checkVideoSS(pTC, pSS.e.name, pSS.v, data.payload.videoStreamingState)
    end)
  :ValidIf(function(_, data)
      return common.checkHMILevel(pTC, pSS.e.name, pSS.l, data.payload.hmiLevel)
    end)
end

--[[ Scenario ]]
for n, tc in common.spairs(testCases) do
  runner.Title("TC[" .. string.format("%03d", n) .. "]: "
    .. "[hmiType:" .. tc.t .. ", isMedia:" .. tostring(tc.m) .. "]")
  runner.Step("Clean environment", common.preconditions)
  runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
  runner.Step("Set App Config", common.setAppConfig, { 1, tc.t, tc.m })
  runner.Step("Register App", common.registerApp)
  for i = 1, #tc.s do
    runner.Step("Action:" .. tc.s[i].e.name .. ",hmiLevel:" .. tc.s[i].l, doAction, { n, tc.s[i] })
  end
  runner.Step("Clean sessions", common.cleanSessions)
  runner.Step("Stop SDL", common.postconditions)
end
runner.Step("Print failed TCs", common.printFailedTCs)
