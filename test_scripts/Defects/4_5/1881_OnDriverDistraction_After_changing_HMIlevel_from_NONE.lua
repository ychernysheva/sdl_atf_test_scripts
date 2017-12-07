---------------------------------------------------------------------------------------------
-- GitHub issue: https://github.com/SmartDeviceLink/sdl_core/issues/1881
-- In case
-- mobile app registers and gets NONE HMILevel
-- and SDL receives OnDriverDistraction (<state>) fom HMI
-- SDL must:
-- transfer the last known (actual) OnDriverDistraction (<state>) to this mobile app right after this mobile app
-- changes HMILevel to any other than NONE
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonDefects = require('test_scripts/Defects/4_5/commonDefects')
local mobile_session = require("mobile_session")

--[[ Local Variables ]]
config.application1.registerAppInterfaceParams.isMediaApplication = true
config.application1.registerAppInterfaceParams.appHMIType = {"DEFAULT"}
config.application2.registerAppInterfaceParams.isMediaApplication = false
config.application2.registerAppInterfaceParams.appHMIType = {"DEFAULT"}

--[[ Local Functions ]]
local function OnDDinNONE(id, params, self)
  self.hmiConnection:SendNotification("UI.OnDriverDistraction", params)
  self["mobileSession" .. id]:ExpectNotification("OnDriverDistraction")
  :Times(0)
  commonDefects.delayedExp(2000)
end

local function OnDD(id, params, self)
  self.hmiConnection:SendNotification("UI.OnDriverDistraction", params)
  self["mobileSession" .. id]:ExpectNotification("OnDriverDistraction", params)
end

local function OnDD2Apps(idres, id, params, self)
  self.hmiConnection:SendNotification("UI.OnDriverDistraction", params)
  self["mobileSession" .. id]:ExpectNotification("OnDriverDistraction")
  :Times(0)
  self["mobileSession" .. idres]:ExpectNotification("OnDriverDistraction", params)
  commonDefects.delayedExp(2000)
end

local function ActivationAppWithOnDD( params, self)
  local hmiAppId = commonDefects.getHMIAppId(1)
  local requestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = hmiAppId })
  EXPECT_HMIRESPONSE(requestId)
  self.mobileSession1:ExpectNotification("OnHMIStatus",
    { hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN" })
  self.mobileSession1:ExpectNotification("OnDriverDistraction", params)
end

local function RegisterAppWithOnDDResumption( params, self)
  self.mobileSession1 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession1:StartService(7)
  :Do(function()
      local corId = self.mobileSession1:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered",
        { application = { appName = config.application1.registerAppInterfaceParams.appName } })
      self.mobileSession1:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
      :Do(function()
          self.mobileSession1:ExpectNotification("OnHMIStatus",
            { hmiLevel = "NONE" },
            { hmiLevel = "LIMITED" })
          :Times(2)
          self.mobileSession1:ExpectNotification("OnPermissionsChange")
          self.mobileSession2:ExpectNotification("OnDriverDistraction")
          :Times(0)
          self.mobileSession1:ExpectNotification("OnDriverDistraction", params)
          commonDefects.delayedExp(1000)
        end)
    end)
end

local function ActivationAppWithOnDD2Apps( params, self)
  local hmiAppId = commonDefects.getHMIAppId(2)
  local requestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = hmiAppId })
  EXPECT_HMIRESPONSE(requestId)
  self.mobileSession2:ExpectNotification("OnHMIStatus",
    { hmiLevel = "FULL"})
  self.mobileSession2:ExpectNotification("OnDriverDistraction", params)
  self.mobileSession1:ExpectNotification("OnDriverDistraction")
  :Times(0)
  self.mobileSession1:ExpectNotification("OnHMIStatus",
    { hmiLevel = "LIMITED"})
  commonDefects.delayedExp(1000)
end

local function CloseSession(self)
  self.mobileSession1:Stop()
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonDefects.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonDefects.start)
runner.Step("RAI, PTU", commonDefects.rai_ptu)

runner.Title("Test")
runner.Step("Absence_OnDriverDistraction_in_NONE", OnDDinNONE, {1, {state = "DD_ON"}})
runner.Step("OnDriverDistraction_in_FULL", ActivationAppWithOnDD, {{state = "DD_ON"}})
runner.Step("UnregisterRegisterApp", commonDefects.unregisterApp, {1})

runner.Step("RAI_first_app", commonDefects.rai_n, {1})
runner.Step("RAI_second_app", commonDefects.rai_ptu_n, {2})
runner.Step("Activate_first_app", commonDefects.activate_app)
runner.Step("OnDriverDistraction_in_FULL_ansence_in_NONE", OnDD2Apps, {1, 2, {state = "DD_ON"}})
runner.Step("OnDriverDistraction_changed_in_FULL_ansence_in_NONE", OnDD2Apps, {1, 2, {state = "DD_OFF"}})
runner.Step("OnDriverDistraction_after_app_activation", ActivationAppWithOnDD2Apps, {{state = "DD_OFF"}})

runner.Step("CloseSession", CloseSession)
runner.Step("OnDriverDistraction_change_in_FULL", OnDD, {2,{state = "DD_ON"}})
runner.Step("OnDriverDistraction_in_LIMITED_after_resumption", RegisterAppWithOnDDResumption, {{state = "DD_ON"}})

runner.Title("Postconditions")
runner.Step("Stop SDL", commonDefects.postconditions)
