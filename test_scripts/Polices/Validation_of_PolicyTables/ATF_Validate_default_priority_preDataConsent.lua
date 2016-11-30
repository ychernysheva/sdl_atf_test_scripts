---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [Policies] "pre_DataConsent" policies assigned to the application and "priority" value
--
-- Description:
--     Providing to HMI app`s default priority value of "pre_DataConsent" if "pre_DataConsent" policies assigned to the application
--     1. Used preconditions:
-- 			SDL and HMI are running
--			Close default connection
--			Connect device
--
--     2. Performed steps
--			Register app-> "pre_DataConsent" policies are assigned to the application
--		    Activate app
--
-- Expected result:
--     PoliciesManager must provide to HMI the app`s priority value(NONE) taken from "priority" field in "pre_DataConsent" section of PolicyTable
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Precondition_Close_default_connection()
  self.mobileConnection:Close()
  commonTestCases:DelayedExp(3000)

end

function Test:Precondition_Connect_device()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
  {
    deviceList = {
      {
        id = config.deviceMAC,
        name = "127.0.0.1",
        transportType = "WIFI"
      }
    }
  }
  ):Do(function(_,data)
  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  :Times(AtLeast(1))
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep1_Priority_NONE_OnAppRegistered()
  commonTestCases:DelayedExp(3000)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {priority ="NONE"})
  :Do(function(_,data)
  self.HMIAppID = data.params.application.appID
  end)
  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
  self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
  end)
end

function Test:TestStep2_Priority_NONE_ActivateApp()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})
  EXPECT_HMIRESPONSE(RequestId, {result = { code = 0, method ="SDL.ActivateApp", priority ="NONE"}})
  :Do(function(_,data)
  if data.result.priority ~= "NONE" then
    commonFunctions:userPrint(31, "Error: wrong behavior of SDL - priority should be NONE")
  end
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN", audioStreamingState = "AUDIBLE"})
  end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_SDLStop()
  StopSDL()
end