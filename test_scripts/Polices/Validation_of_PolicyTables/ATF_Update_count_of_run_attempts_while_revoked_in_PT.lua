---------------------------------------------------------------------------------------------
-- Requirement summary:
--   [Policies] "usage_and_error_counts" and "count_of_run_attempts_while_revoked" update
--
-- Description:
--     Incrementing value in 'count_of_run_attempts_while_revoked' section of LocalPT
--     1. Used preconditions:
--      SDL and HMI running
--		Consent device
--		Update policy apps permissions
--		Add session
--		Register second app 
--		Activate second app
--		Set to null(PTU) permissions for second app 
--      Try to activate second(revoked) app
--
--     2. Performed steps
--      Check "count_of_run_attempts_while_revoked" value of LocalPT
--
-- Expected result:
--    PoliciesManager increments "count_of_run_attempts_while_revoked" at PolicyTable
---------------------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local testCasesForPolicyAppIdManagament = require("user_modules/shared_testcases/testCasesForPolicyAppIdManagament")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local testCasesForPolicyTable = require("user_modules/shared_testcases/testCasesForPolicyTable")

config.defaultProtocolVersion = 2
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")
local mobile_session = require("mobile_session")

--[[ Local Variables ]]
local HMIAppID

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:Pecondition_trigger_getting_device_consent()
  testCasesForPolicyTable:trigger_getting_device_consent(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

function Test:Precondition_Start_session()
  self.mobileSession2 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartService(7)
end

function Test:Precondition_Register_app()
  config.application2.registerAppInterfaceParams.appName = "App_test"
  config.application2.registerAppInterfaceParams.appID = "123abc"
  local correlationId = self.mobileSession2:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
  :Do(function(_,data)
      HMIAppID = data.params.application.appID
      self.applications[config.application2.registerAppInterfaceParams.appName] = data.params.application.appID
    end)
  self.mobileSession2:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE" })
  self.mobileSession2:ExpectResponse(correlationId, { success = true })
end

function Test:Precondition_Activate_app()
  local RequestIdActivate = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppID})
  EXPECT_HMIRESPONSE(RequestIdActivate)
  :Do(function(_,data)
  if data.result.isSDLAllowed ~= true then
    local RequestIdgetmes = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
    {language = "EN-US", messageCodes = {"DataConsent"}})
    EXPECT_HMIRESPONSE(RequestIdgetmes)
    :Do(function()
    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
    {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
    EXPECT_HMICALL("BasicCommunication.ActivateApp")
    :Do(function()
    self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
    end)
    :Times(2)
    end)
  end
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN", audioStreamingState = "AUDIBLE"})
end

function Test:Precondition_PTU_to_revoke_app()
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
  testCasesForPolicyAppIdManagament:updatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_23511.json")
  EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged", { appRevoked = true, appID = HMIAppID})
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "NONE", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE"})
end

function Test:Precondition_SDL_disallows_activate_app()
  local RequestIdActivate = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppID})
  EXPECT_HMIRESPONSE(RequestIdActivate)
  :Do(function()
    EXPECT_HMICALL("BasicCommunication.ActivateApp")
    :Times(0)
  end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Check_count_of_run_attempts_while_revoked_incremented_in_PT()
  local db_path = config.pathToSDL.."storage/policy.sqlite"
  local sql_query = "SELECT count_of_run_attempts_while_revoked FROM app_level WHERE application_id = "..config.application2.registerAppInterfaceParams.appID
  local exp_result = 1
  if commonFunctions:is_db_contains(db_path, sql_query, exp_result) == false then
    self:FailTestCase("DB doesn't include expected value")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_SDLStop()
  StopSDL()
end