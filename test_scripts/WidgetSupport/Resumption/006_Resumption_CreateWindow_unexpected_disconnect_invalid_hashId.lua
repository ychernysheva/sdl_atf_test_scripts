---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0216-widget-support.md
--
-- Description: Check that SDL restored Main window to FULL level after unexpected disconnect
--
-- Preconditions:
-- 1) SDL and HMI are started
-- 2) App is registered and activated (FULL level)
-- 3) App created a widget which is activated (FULL level)
-- Steps:
-- 1) Unexpected disconnect and reconnect are performed
-- 2) App re-register with wrong HashId
-- SDL does:
--  - does not send UI.CreateWindow(params) request to HMI
--  - does not send CreateWindow response to App
-- 3) HMI sends OnSystemCapabilityUpdated(params) notification to SDL for Main window
-- SDL does:
--  - send OnSystemCapabilityUpdated(params) notification to App for Main window
--  - send OnHMIStatus (NONE level) notification for Main window to App
-- 4) Main window is activated on the HMI and has FULL level
-- 5) App send Show(with WindowID for Main window) request to SDL
-- SDL does:
--  - proceed with request successfully
-- 6) App send Show(with WindowID for Widget window) request to SDL
-- SDL does:
--  - respond to App with (success = false, resultCode = INVALID_ID")
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/WidgetSupport/common')

--[[ Test Configuration ]]
config.application1.registerAppInterfaceParams.appHMIType = { "MEDIA" }

--[[ Local Variables ]]
local widgetParams = {
  windowID = 2,
  windowName = "Name",
  type = "WIDGET",
  associatedServiceType = "MEDIA"
}

--[[ Local Functions ]]
local function createWindow(pParams, pAppId)
  if not pAppId then pAppId = 1 end
  common.getMobileSession(pAppId):ExpectNotification("OnHashChange")
  :Do(function(_, data)
      common.setHashId(data.payload.hashID, pAppId)
    end)
  common.createWindow(pParams, pAppId)
end

local function checkResumption_NONE()
  common.getHMIConnection():ExpectRequest("BasicCommunication.ActivateApp")
  :Times(0)
  common.getHMIConnection():ExpectRequest("UI.CreateWindow")
  :Times(0)
  common.expCreateWindowResponse()
  :Times(0)
  common.getMobileSession():ExpectNotification("OnHMIStatus", { windowID = 0, hmiLevel = "NONE" })
  common.getMobileSession():ExpectNotification("OnSystemCapabilityUpdated", common.getOnSCUParams({ 0 }))
end

function common.getHashId()
  return "wrong_hashId"
end

--[[ Scenario ]]
common.Title("Precondition")
common.Step("Clean environment and Back-up/update PPT", common.precondition)
common.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
common.Step("App registration", common.registerAppWOPTU)
common.Step("App activation", common.activateApp)
common.Step("App creates widget", createWindow, { widgetParams })
common.Step("Widget is activated", common.activateWidgetFromNoneToFULL, { widgetParams.windowID })

common.Title("Test")
common.Step("Unexpected disconnect", common.unexpectedDisconnect)
common.Step("Connect mobile", common.connectMobile)
common.Step("Re-register App resumption data RESUME_FAILED", common.reRegisterAppSuccess,
  { nil, 1, checkResumption_NONE, "RESUME_FAILED" })
common.Step("App activation", common.activateApp)
common.Step("Show RPC to Main window", common.sendShowToWindow, { 0 })
common.Step("Show RPC to Widget window", common.sendShowToWindowUnsuccess, { widgetParams.windowID, "INVALID_ID" })

common.Title("Postconditions")
common.Step("Stop SDL, restore SDL settings and PPT", common.postcondition)
