---------------------------------------------------------------------------------------------
-- Requirement summary:
--      [Policies]: HMI Level assignment in case user did not accept the Data Consent prompt
--
-- Description:
--        HMI status assigning if user did not accept the Data Consent prompt, all registered apps shall be given an HMI status 
--     PoliciesManager has not yet received the User`s response on data consent prompt for the corresponding device
--     1. Used preconditions:
--        Delete log files and policy table
--        Close current connection
--        Overwrite preloaded PT with BACKGROUNG as default_hmi for pre_DataConsent
--        Connect unconsented device
--        Register application
--     2. Performed steps
--        Activate application
--        Press "NO" for data consent on HMI
--       
-- Expected result:
--     Registered app should be given  HMI status of 'default_hmi' from "pre_dataConsent" section->
--        Step1:
--        HMI->SDL: SDL.ActivateApp{appID}
--        SDL->HMI: SDL.ActivateApp_response{isSDLAllowed: false, params}
--        HMI->SDL: GetUserFriendlyMessage{params},
--        SDL->HMI: GetUserFriendlyMessage_response{params}
--        HMI: display the 'data consent' message
--        Step2:
--        HMI->SDL: OnAllowSDLFunctionality {allowed: false, params}
--        SDL->app: OnPermissionChanged{params}// "pre_DataConsent" sub-section of "app_policies" section of PT, app`s HMI level corresponds to one from "default_hmi" field
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
testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/BACKGROUNDForPreconsented_preloaded_pt.json")

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
  end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:ActivateApp_on_unconsented_device()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})
  EXPECT_HMIRESPONSE(RequestId, {result = { code = 0, device = { id = config.deviceMAC, name = "127.0.0.1" }, isAppPermissionsRevoked = false, isAppRevoked = false, isSDLAllowed = false, 
    isPermissionsConsentNeeded = true, method ="SDL.ActivateApp", priority ="NONE"}})
  :Do(function(_,data)
    --Consent for device is needed
    if data.result.isSDLAllowed ~= false then
      commonFunctions:userPrint(31, "Error: wrong behavior of SDL - device needs to be consented on HMI")
    else
      local RequestIdGetMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
      {language = "EN-US", messageCodes = {"DataConsent"}})
      EXPECT_HMIRESPONSE(RequestIdGetMessage)
      :Do(function()
        --Press "NO"on data consent
        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
        {allowed = false, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}}) 
        self.mobileSession:ExpectNotification("OnPermissionsChange", {})
        EXPECT_HMICALL("BasicCommunication.ActivateApp")
        :Times(0)
      end)
    end
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "BACKGROUND", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE"})
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end

function Test.Postcondition_RestorePreloadedPT()
  testCasesForPolicyTable:Restore_preloaded_pt()
end