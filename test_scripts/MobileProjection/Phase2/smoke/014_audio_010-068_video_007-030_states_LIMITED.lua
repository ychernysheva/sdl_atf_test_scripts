---------------------------------------------------------------------------------------------------
-- Issue: https://github.com/smartdevicelink/sdl_core/issues/2129
---------------------------------------------------------------------------------------------------
-- Description:
-- In case:
-- 1) There are 2 mobile apps:
--   app1: is video source ('videoStreamingState' = STREAMABLE)
--   app2: is not video source ('audioStreamingState' = NOT_STREAMABLE)
-- 2) Mobile app1 is deactivated
-- 3) Mobile app2 is activated
-- SDL must:
-- 1) Send OnHMIStatus notification for both apps with appropriate value of 'videoStreamingState' parameter
-- Particular value depends on app's 'appHMIType' and described in 'testCases' table below
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/MobileProjection/Phase2/common')
local runner = require('user_modules/script_runner')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local testCases = {
  [010] = {
    [1] = { t = "NAVIGATION",    m = false, aSS = { "AUDIBLE", "AUDIBLE" }, vSS = { "STREAMABLE", "NOT_STREAMABLE" } },
    [2] = { t = "PROJECTION",    m = false, aSS = { nil, "NOT_AUDIBLE" },   vSS = { nil, "STREAMABLE" } }
  },
  [024] = {
    [1] = { t = "NAVIGATION",    m = false, aSS = { "AUDIBLE", "NOT_AUDIBLE" }, vSS = { "STREAMABLE", "NOT_STREAMABLE" } },
    [2] = { t = "NAVIGATION",    m = false, aSS = { nil, "AUDIBLE" },           vSS = { nil, "STREAMABLE" } }
  },
  [032] = {
    [1] = { t = "NAVIGATION",    m = false, aSS = { "AUDIBLE", "AUDIBLE" }, vSS = { "STREAMABLE", "NOT_STREAMABLE" } },
    [2] = { t = "PROJECTION",    m = true,  aSS = { nil, "AUDIBLE" },       vSS = { nil, "STREAMABLE" } }
  },
  [048] = {
    [1] = { t = "PROJECTION",    m = true,  aSS = { "AUDIBLE", "AUDIBLE" }, vSS = { "STREAMABLE", "NOT_STREAMABLE" } },
    [2] = { t = "NAVIGATION",    m = false, aSS = { nil, "AUDIBLE" },       vSS = { nil, "STREAMABLE" } }
  },
  [060] = {
    [1] = { t = "PROJECTION", m = true,  aSS = { "AUDIBLE", "NOT_AUDIBLE" }, vSS = { "STREAMABLE", "NOT_STREAMABLE" } },
    [2] = { t = "PROJECTION", m = true,  aSS = { nil, "AUDIBLE" },           vSS = { nil, "STREAMABLE" } }
  }
}

--[[ Local Functions ]]
local function activateApp2(pTC, pAudioSSApp1, pVideoSSApp1, pAudioSSApp2, pVideoSSApp2)
  local count = 1
  if pAudioSSApp1 == nil and pVideoSSApp1 == nil then count = 0 end
  local requestId = common.getHMIConnection():SendRequest("SDL.ActivateApp", { appID = common.getHMIAppId(2) })
  common.getHMIConnection():ExpectResponse(requestId)
  common.getMobileSession(1):ExpectNotification("OnHMIStatus")
  :ValidIf(function(_, data)
      return common.checkAudioSS(pTC, "App1", pAudioSSApp1, data.payload.audioStreamingState)
    end)
  :ValidIf(function(_, data)
      return common.checkVideoSS(pTC, "App1", pVideoSSApp1, data.payload.videoStreamingState)
    end)
  :Times(count)
  common.getMobileSession(2):ExpectNotification("OnHMIStatus")
  :ValidIf(function(_, data)
      return common.checkAudioSS(pTC, "App2", pAudioSSApp2, data.payload.audioStreamingState)
    end)
  :ValidIf(function(_, data)
      return common.checkVideoSS(pTC, "App2", pVideoSSApp2, data.payload.videoStreamingState)
    end)
end

local function deactivateApp1(pTC, pAudioSSApp1, pVideoSSApp1)
  common.getHMIConnection():SendNotification("BasicCommunication.OnAppDeactivated", { appID = common.getHMIAppId() })
  common.getMobileSession(1):ExpectNotification("OnHMIStatus")
  :ValidIf(function(_, data)
      return common.checkAudioSS(pTC, "App1", pAudioSSApp1, data.payload.audioStreamingState)
    end)
  :ValidIf(function(_, data)
      return common.checkVideoSS(pTC, "App1", pVideoSSApp1, data.payload.videoStreamingState)
    end)
  common.getMobileSession(2):ExpectNotification("OnHMIStatus")
  :Times(0)
end

local function getMsg(pTC, pAppId, pNotifId)
  if pTC[pAppId].aSS[pNotifId] == nil and pTC[pAppId].vSS[pNotifId] == nil then
    return "NO"
  else
    return pTC[pAppId].aSS[pNotifId] .. ":" .. pTC[pAppId].vSS[pNotifId]
  end
end

--[[ Scenario ]]
for n, tc in common.spairs(testCases) do
  runner.Title("TC[" .. string.format("%03d", n) .. "]: "
    .. "App1[hmiType:" .. tc[1].t .. ", isMedia:" .. tostring(tc[1].m) .. "], "
    .. "App2[hmiType:" .. tc[2].t .. ", isMedia:" .. tostring(tc[2].m) .. "]")
  runner.Step("Clean environment", common.preconditions)
  runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
  runner.Step("Set App 1 Config", common.setAppConfig, { 1, tc[1].t, tc[1].m })
  runner.Step("Set App 2 Config", common.setAppConfig, { 2, tc[2].t, tc[2].m })
  runner.Step("Register App 1", common.registerApp, { 1 })
  runner.Step("Register App 2", common.registerApp, { 2 })
  runner.Step("Activate App 1", common.activateApp, { 1 })
  runner.Step("Deact. App 1:" .. "App1:" .. getMsg(tc, 1, 1) .. " App2:" .. getMsg(tc, 2, 1),
    deactivateApp1, { n, tc[1].aSS[1], tc[1].vSS[1] })
  runner.Step("Act. App 2:" .. "App1:" .. getMsg(tc, 1, 2) .. " App2:" .. getMsg(tc, 2, 2),
    activateApp2, { n, tc[1].aSS[2], tc[1].vSS[2], tc[2].aSS[2], tc[2].vSS[2] })
  runner.Step("Clean sessions", common.cleanSessions)
  runner.Step("Stop SDL", common.postconditions)
end
runner.Step("Print failed TCs", common.printFailedTCs)
