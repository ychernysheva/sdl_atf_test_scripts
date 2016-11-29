---------------------------------------------------------------------------------------------
-- Requirement summary:
--     [Policies]:Storage of user-consent for device in LocalPT
--
-- Description:
--    Storing by Policies Manager user consent for device
-- 1. Used preconditions:
--    SDL and HMI are running
--    Local PT does not have user_consent_records for <Device>
--    <Device> is connected, <App> is running on that device
--    <App> is registered with SDL and is present in HMI list of registered apps
-- 2. Performed steps:
--    Activate App -> consent device on HMI
--    Check local pt for device consent
--
-- Expected result:
--    PoliciesManager must store the User`s consent for device (data consent) records in "device" subsection of "user_consent_records" subsection 
--    of "<device_identifier>" section of "device_data" section in Local PT:
--       Step1:
--       HMI->SDL: SDL.ActivateApp {appID}
--       SDL->HMI: SDL.ActivateApp_response{isPermissionsConsentNeeded: true, params}
--       HMI->SDL: GetUserFriendlyMessage{params},
--       SDL->HMI: GetUserFriendlyMessage_response{params}
--       HMI: display the 'data consent' message
--       Step2:
--       HMI->SDL: SDL.OnAllowSDLFunctionality(isSDLAllowed=true) 
--       PoliciesManager records the consent-related information in "device" subsection of "user_consent_records" subsection
--       of "<device_identifier>" section of "device_data" section in Local PT.
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
require('user_modules/AppTypes')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local mobile_session = require('mobile_session')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_Connect_device()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
  {
    deviceList = {
      {
        id = config.deviceMAC,
        name = "127.0.0.1",
        transportType = "WIFI",
        isSDLAllowed = false
      }
    }
  }
  ):Do(function(_,data)
  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  :Times(AtLeast(1))
end

function Test:Precondition_Register_app()
  commonTestCases:DelayedExp(3000)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
  local RequestIDRai1 = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
  :Do(function(_,data)
  self.HMIAppID = data.params.application.appID
  end)
  self.mobileSession:ExpectResponse(RequestIDRai1, { success = true, resultCode = "SUCCESS" })
  self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
  end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep1_Device_consent_on_activate_app()
  local RequestIdActivate = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID})
  EXPECT_HMIRESPONSE(RequestIdActivate, {result = { code = 0, device = { id = config.deviceMAC, name = "127.0.0.1" }, isSDLAllowed = false, method ="SDL.ActivateApp", priority ="NONE"}})
  :Do(function()
    local RequestIdGetMes = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
    EXPECT_HMIRESPONSE(RequestIdGetMes, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
    :Do(function()
      self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
      {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1", isSDLAllowed = true }})
    end)
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
end

function Test:TestStep2_check_LocalPT_for_consent_storage()
  local test_fail = false
    local data_consent = testCasesForPolicyTableSnapshot:get_data_from_PTS("device_data."..config.deviceMAC..".user_consent_records.".."device"..".consent_groups.DataConsent-2")
    print("data_consent" ..tostring(data_consent))
    if(data_consent ~= true) then
      commonFunctions:printError("Error: consent_groups.DataConsent-2 for device should be true")
      test_fail = true
    end
    if(test_fail == true) then
      self:FailTestCase("Test failed")
    end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end
