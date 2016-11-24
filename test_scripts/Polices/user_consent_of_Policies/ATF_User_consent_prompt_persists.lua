---------------------------------------------------------------------------------------------
-- Requirement summary:
--		[Policies]: "user_consent_prompt" field is included to the <appID>`s policies
--
-- Description:
--     Functional grouping that has "user_consent_prompt" field, is included to the <appID>`s policies
--     1. Used preconditions:
--			Delete log files and policy table
--			Unregister default application
-- 			Register application
--			Activate application
--			Send RPC -> should be disallowed
--			Perform PTU with new permissions that require User consent
--			Activate application and consent new permissions
--
--     2. Performed steps
--			Send RPC from <functional grouping>
--
-- Expected result:
--  	PoliciesManager must apply <functional grouping> only after the User has consented it -> RPC should be allowed
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('connecttest')
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

function Test:Precondition_Unregister_default_app()
  local CorIdUAI = self.mobileSession:SendRPC("UnregisterAppInterface",{})
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications["SyncProxyTester"], unexpectedDisconnect = false})
  EXPECT_RESPONSE(CorIdUAI, { success = true, resultCode = "SUCCESS"})
  :Timeout(2000)
end

function Test:Precondition_Register_app()
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

function Test:Precondition_ActivateApp()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID})
  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,data)
  if data.result.isSDLAllowed ~= true then
    local RequestIdGetMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
    EXPECT_HMIRESPONSE(RequestIdGetMessage)
    :Do(function()
    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
    EXPECT_HMICALL("BasicCommunication.ActivateApp")
    :Do(function()
    self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
    EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
    end)
    end)
  end
  end)
end

function Test:Precondition_GetVehicleData_disallowed()
  local RequestiDGetVData = self.mobileSession:SendRPC("GetVehicleData",{speed = true})
  EXPECT_HMICALL("VehicleInfo.GetVehicleData",{speed = true})
  :Times(0)
  EXPECT_RESPONSE(RequestiDGetVData, { success = false, resultCode = "DISALLOWED", info = "'speed' is disallowed by policies."})
end

function Test:Precondition_PTU_user_consent_prompt_present()
  local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
  :Do(function()
  self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
  {
    requestType = "PROPRIETARY",
    fileName = "filename"
  }
  )
  EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
  :Do(function()
  local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
  {
    fileName = "PolicyTableUpdate",
    requestType = "PROPRIETARY"
  }, "files/PTU_NewPermissionsForUserConsent.json")
  local systemRequestId
  EXPECT_HMICALL("BasicCommunication.SystemRequest")
  :Do(function(_,data)
  systemRequestId = data.id
  self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
  {
    policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
  })
  local function to_run()
    self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
  end
  RUN_AFTER(to_run, 500)
  end)
  EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged", {appID = self.HMIAppID, appPermissionsConsentNeeded = true })
  :Do(function()
  local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", { appID = self.HMIAppID })
  EXPECT_HMIRESPONSE(RequestIdListOfPermissions,{result = {code = 0, method = "SDL.GetListOfPermissions", allowedFunctions = {{name = "Location-1"}, {name = "DrivingCharacteristics-3"}}}})
  :Do(function()
  local ReqIDGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"allowedFunctions"}})
  EXPECT_HMIRESPONSE(ReqIDGetUserFriendlyMessage)
  end)
  self.mobileSession:ExpectResponse(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
  end)
  end)
  end)
end

function Test:Precondition_Activate_app_with_new_functional_grouping()
  local RequestIdActivateApp = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID})
  EXPECT_HMIRESPONSE(RequestIdActivateApp, {result = {code = 0, method = "SDL.ActivateApp", isPermissionsConsentNeeded = true, isSDLAllowed = true, priority = "NONE"}})
  :Do(function(_,data)
  if data.result.isPermissionsConsentNeeded == true then
    local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
    EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage, { result = { code = 0, messages = {{ messageCode = "DataConsent"}}, method = "SDL.GetUserFriendlyMessage"}})
    local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", { appID = self.HMIAppID })
    EXPECT_HMIRESPONSE(RequestIdListOfPermissions,{result = {code = 0, method = "SDL.GetListOfPermissions", allowedFunctions = {{ name = "Location-1"}, { name = "DrivingCharacteristics-3"}}}})
    :Do(function()
    local ReqIDGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"allowedFunctions"}})
    EXPECT_HMIRESPONSE(ReqIDGetUserFriendlyMessage)
    :Do(function()
    self.hmiConnection:SendNotification("SDL.OnAppPermissionsConsent", {})
    end)
    end)
  else
    commonFunctions:userPrint(31, "Wrong SDL behavior: there are app permissions for consent, isPermissionsConsentNeeded should be true")
    return false
  end
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN" })
  EXPECT_NOTIFICATION("OnPermissionsChange", {})
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:New_functional_grouping_applied_GetVehicleData_allowed()
  local RequestIDGVD = self.mobileSession:SendRPC("GetVehicleData",
  {
    speed = true
  })
  EXPECT_HMICALL("VehicleInfo.GetVehicleData",{speed = true})
  :Do(function(_,data)
  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {speed = 80.5})
  end)
  EXPECT_RESPONSE(RequestIDGVD, {success = true, resultCode = "SUCCESS", speed = 80.5})
  DelayedExp(300)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end
