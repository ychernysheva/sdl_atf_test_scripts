----------------------------------------------------------------------------------------------------
-- Script verifies issue https://github.com/SmartDeviceLink/sdl_core/issues/1206
-- Flow: HTTP
----------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require("user_modules/script_runner")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local mobile_session = require("mobile_session")
local common = require("test_scripts/Defects/4_5/commonDefects")
local color = require("user_modules/consts").color

--[[ Local Functions ]]
local function registerApplicationAndWaitPTUStart(self)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
      local corId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
      self.mobileSession:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {
        application = { appName = config.application1.registerAppInterfaceParams.appName }
      })
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", { status = "UPDATE_NEEDED" })
      :Do(function()
          commonFunctions:userPrint(color.blue, "Received OnStatusUpdate: UPDATE_NEEDED")
        end)
    end)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile", common.start)
runner.Step("SDL Configuration", common.printSDLConfig)

runner.Title("Test")
runner.Step("Application Registration and wait for UPDATE_NEEDED", registerApplicationAndWaitPTUStart)
runner.Step("Ignition Off", common.ignitionOff)
runner.Step("Start SDL, HMI, connect Mobile", common.start)
runner.Step("Application Registration and wait for UPDATE_NEEDED", registerApplicationAndWaitPTUStart)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
