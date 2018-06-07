---------------------------------------------------------------------------------------------------
-- Issue: https://github.com/smartdevicelink/sdl_core/issues/2129
---------------------------------------------------------------------------------------------------
-- Description:
-- In case:
-- 1) There are 2 mobile apps:
--   app1: NAVIGATION, isMediaApplication = true
--   app2: COMMUNICATION, isMediaApplication = false
-- 2) And app1 activated, starts Video streaming and then deactivated
-- 3) And app2 activated and then deactivated
-- SDL must: (in case of deactivation of app1)
-- 1) Send 'OnHMIStatus' notification to app1: 'audioStreamingState' = AUDIBLE and 'videoStreamingState' = STREAMABLE
-- 2) Not send 'OnHMIStatus' notification to app2
-- SDL must: (in case of deactivation of app2)
-- 1) Not send 'OnHMIStatus' notification to app1
-- 2) Send 'OnHMIStatus' notification to app2: 'audioStreamingState' = ATTENUATED and 'videoStreamingState' = NOT_STREAMABLE
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/MobileProjection/Phase2/common')
local runner = require('user_modules/script_runner')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local testCases = {
  [001] = { [1] = { t = "NAVIGATION", m = true }, [2] = { t = "COMMUNICATION", m = false }},
}

--[[ Local Functions ]]
local function deactivateApp1()
  common.getHMIConnection():SendNotification("BasicCommunication.OnAppDeactivated", {
    appID = common.getHMIAppId(1) })
  common.getMobileSession(1):ExpectNotification("OnHMIStatus", {
    hmiLevel = "LIMITED",
    systemContext = "MAIN",
    audioStreamingState = "AUDIBLE",
    videoStreamingState = "STREAMABLE"
  })
  :Times(1)
  common.getMobileSession(2):ExpectNotification("OnHMIStatus")
  :Times(0)
end

local function deactivateApp2()
  common.getHMIConnection():SendNotification("BasicCommunication.OnAppDeactivated", {
    appID = common.getHMIAppId(2) })
  common.getMobileSession(2):ExpectNotification("OnHMIStatus", {
    hmiLevel = "LIMITED",
    systemContext = "MAIN",
    audioStreamingState = "ATTENUATED",
    videoStreamingState = "NOT_STREAMABLE"
  })
  :Times(1)
  common.getMobileSession(1):ExpectNotification("OnHMIStatus")
  :Times(0)
end

local function appStartVideoStreaming()
  common.getMobileSession():StartService(11)
  :Do(function()
      common.getHMIConnection():ExpectRequest("Navigation.StartStream")
      :Do(function(_, data)
          common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
          common.getMobileSession():StartStreaming(11, "files/MP3_4555kb.mp3")
          common.getHMIConnection():ExpectNotification("Navigation.OnVideoDataStreaming", { available = true })
        end)
    end)
  common.getMobileSession(1):ExpectNotification("OnHMIStatus")
  :Times(0)
  common.getMobileSession(2):ExpectNotification("OnHMIStatus")
  :Times(0)
end

local function onHMIStatus2Apps()
  common.getMobileSession(2):ExpectNotification("OnHMIStatus", {
    hmiLevel = "FULL",
    systemContext = "MAIN",
    audioStreamingState = "ATTENUATED",
    videoStreamingState = "NOT_STREAMABLE"
  })
  common.getMobileSession(1):ExpectNotification("OnHMIStatus")
  :Times(0)
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
  runner.Step("App 1 starts Video streaming", appStartVideoStreaming)
  runner.Step("Deactivate App 1", deactivateApp1)
  runner.Step("Activate App 2", common.activateAppCustomOnHMIStatusExpectation, { 2, onHMIStatus2Apps })
  runner.Step("Deactivate App 2", deactivateApp2)
  runner.Step("Clean sessions", common.cleanSessions)
  runner.Step("Stop SDL", common.postconditions)
end
