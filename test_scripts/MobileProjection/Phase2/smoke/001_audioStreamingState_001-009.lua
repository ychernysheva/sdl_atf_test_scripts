---------------------------------------------------------------------------------------------------
-- Issue: https://github.com/smartdevicelink/sdl_core/issues/2129
---------------------------------------------------------------------------------------------------
-- Description:
-- In case:
-- 1) Mobile app is activated
-- SDL must:
-- 1) Send OnHMIStatus notification with appropriate value of 'audioStreamingState' parameter
-- Particular value depends on app's 'appHMIType' and 'isMediaApplication' flag, and described in 'testCases' table below
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/MobileProjection/Phase2/common')
local runner = require('user_modules/script_runner')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local testCases = {
  [001] = { t = "PROJECTION",    m = false, s = "NOT_AUDIBLE" },
  [003] = { t = "NAVIGATION",    m = false, s = "AUDIBLE" },
  [005] = { t = "NAVIGATION",    m = true,  s = "AUDIBLE" },
  [007] = { t = "PROJECTION",    m = true,  s = "AUDIBLE" }
}

--[[ Local Functions ]]
local function activateApp(pTC, pAudioSS)
  local requestId = common.getHMIConnection():SendRequest("SDL.ActivateApp", { appID = common.getHMIAppId() })
  common.getHMIConnection():ExpectResponse(requestId)
  common.getMobileSession():ExpectNotification("OnHMIStatus")
  :ValidIf(function(_, data)
      return common.checkAudioSS(pTC, "App1", pAudioSS, data.payload.audioStreamingState)
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
  runner.Step("Activate App, audioState:" .. tc.s, activateApp, { n, tc.s })
  runner.Step("Clean sessions", common.cleanSessions)
  runner.Step("Stop SDL", common.postconditions)
end
runner.Step("Print failed TCs", common.printFailedTCs)
