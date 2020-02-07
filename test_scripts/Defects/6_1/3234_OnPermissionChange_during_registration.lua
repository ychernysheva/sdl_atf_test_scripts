---------------------------------------------------------------------------------------------
-- GitHub issue https://github.com/SmartDeviceLink/sdl_core/issues/3234
---------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonDefects = require('test_scripts/Defects/4_5/commonDefects')
local mobile_session = require("mobile_session")

--[[ Local Functions ]]
local function rai_n(self)
  local id = 1
  self["mobileSession" .. id] = mobile_session.MobileSession(self, self.mobileConnection)
  self["mobileSession" .. id]:StartService(7)
  :Do(function()
      local corId = self["mobileSession" .. id]:SendRPC
      ("RegisterAppInterface", config["application" .. id].registerAppInterfaceParams)
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered",
        { application = { appName = config["application" .. id].registerAppInterfaceParams.appName } })
      self["mobileSession" .. id]:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
      :Do(function()
          self["mobileSession" .. id]:ExpectNotification("OnHMIStatus",
            { hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN" })
          :Times(AtLeast(1))
          self["mobileSession" .. id]:ExpectNotification("OnPermissionsChange")
          self["mobileSession" .. id]:ExpectNotification("OnDriverDistraction", { state = "DD_OFF" })
        end)
    end)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonDefects.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonDefects.start)

runner.Title("Test")

runner.Step("RAI", rai_n)
runner.Step("Ignition Off", commonDefects.ignitionOff)
runner.Step("Start SDL, HMI, connect Mobile", commonDefects.start)
runner.Step("RAI", rai_n)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonDefects.postconditions)
