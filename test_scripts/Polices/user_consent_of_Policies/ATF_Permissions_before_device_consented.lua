---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [Policies]: Permissions assignment in case device is not yet consented (didn't get any user response yet)
--
-- Description:
--     Condition for assigning by PoliciesManager policies from 'pre_DataConsent' section ('default_hmi', 'groups' and other) to the app.
--     PoliciesManager has not yet received the User`s response on data consent prompt for the corresponding device
--     1. Used preconditions:
--      Delete log files and policy table
--      Close current connection
--      Connect unconsented device
--      Register application
--     2. Performed steps
--        Activate application
--        Perform phone call
--        Activate app again
--
-- Expected result:
--     PoliciesManager must assign policies from 'pre_DataConsent' section ('default_hmi', 'groups' and other) to the app ->
--        Step1:
--        HMI->SDL: SDL.ActivateApp{appID}
--        SDL->HMI: SDL.ActivateApp_response{isSDLAllowed: false, params} * //HMI does not activete the app, PoliciesManager assigns HMILevel from default_hmi' in 'pre_DataConsent' section to the <App>*
--        HMI->SDL: GetUserFriendlyMessage{params},
--        SDL->HMI: GetUserFriendlyMessage_response{params}
--        HMI: display the 'data consent' message.
--        Some system event (for exmaple, incoming pnonecall) aborts the data consent dialog.
--        PoliciesManager keeps HMILevel, groups, etc from default_hmi' in 'pre_DataConsent' section to the <App>.
--        Step2:
--        HMI->SDL: SDL.ActivateApp{appID}
--        SDL->HMI: SDL.ActivateApp_response{isSDLAllowed: false, params}
-------------------------------------------------------------------------------------------------------
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
local Preconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Precondition_CloseDefaultConnection()
  self.mobileConnection:Close()
  commonTestCases:DelayedExp(3000)
end

Preconditions:BackupFile("sdl_preloaded_pt.json")
testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/NoneForAddCommand_preloaded_pt.json")

function Test:Precondition_ConnectUnconsentedDevice()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
  {
    deviceList = {
      {
        id = config.deviceMAC,
        isSDLAllowed = false,
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

function Test:Precondition_RegisterApp_on_unconsented_device()
  commonTestCases:DelayedExp(3000)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
  :Do(function(_,data)
  self.HMIAppID = data.params.application.appID
  end)
  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
  self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
  end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep1_ActivateApp_on_unconsented_device()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})
  EXPECT_HMIRESPONSE(RequestId, {result = { code = 0, device = { id = config.deviceMAC, name = "127.0.0.1" }, isAppPermissionsRevoked = false, isAppRevoked = false, isSDLAllowed = false,
  method ="SDL.ActivateApp", priority ="NONE"}})
  :Do(function(_,data)
  if data.result.isSDLAllowed ~= false then
    commonFunctions:userPrint(31, "Error: wrong behavior of SDL - device needs to be consented on HMI")
  else
    EXPECT_HMINOTIFICATION("SDL.OnSDLConsentNeeded", {})
    :Do(function()
    local RequestIdGetMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
    EXPECT_HMIRESPONSE(RequestIdGetMessage)
    --Data consent is interrupted by phone call
    self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= true, eventName="PHONE_CALL"})
    self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
    EXPECT_HMICALL("BasicCommunication.ActivateApp")
    :Times(0)
    end)
  end
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN", audioStreamingState = "AUDIBLE"})
  :Times(0)
end

function Test:TestStep2_Send_RPC_from_default_group()
  --AddCommand belongs to default permissions, so should be disallowed
  local RequestIDAddCommand = self.mobileSession:SendRPC("AddCommand",
  {
    cmdID = 111,
    menuParams =
    {
      position = 1,
      menuName ="Command111"
    }
  })
  EXPECT_HMICALL("UI.AddCommand",{})
  :Times(0)
  EXPECT_RESPONSE(RequestIDAddCommand, { success = false, resultCode = "DISALLOWED" })
  EXPECT_NOTIFICATION("OnHashChange")
  :Times(0)
end

function Test:TestStep3_ActivateApp_again_on_unconsented_device()
  self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive = false, eventName ="PHONE_CALL"})
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})
  --Device is still not consented, isSDLAllowed should be "false"
  EXPECT_HMIRESPONSE(RequestId, {result = { code = 0, device = { id = config.deviceMAC, name = "127.0.0.1" }, isAppPermissionsRevoked = false, isAppRevoked = false, isSDLAllowed = false,
  method ="SDL.ActivateApp", priority ="NONE"}})
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end

function Test.Postcondition_RestorePreloadedPT()
  testCasesForPolicyTable:Restore_preloaded_pt()
end