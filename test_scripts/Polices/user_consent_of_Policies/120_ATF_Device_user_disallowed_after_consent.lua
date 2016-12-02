------------- --------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies]: User-disallowed device after applications consent
--
-- Description:
-- User disallows device via Settings Menu after device and apps on device are consented
--
-- 1. Used preconditions:
-- Delete log files and policy table from previous ignition cycle
-- Activate app -> consent device
-- Disallow device via Settings Menu
-- 2.Performed steps:
-- Send RPC from default group
-- Allow device
-- Send RPC from default group again
--
-- Expected result:
-- App consents must remain the same, app must be rolled back to pre_DataConstented group -> RPC from defult should not be allowed
-- App must be rolled back to default group
-- RPC from defult should be allowed
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local testCasesForPolicyTable = require("user_modules/shared_testcases/testCasesForPolicyTable")

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")

--[[ Precondition ]]
function Test:Precondition_ActivateRegisteredApp()
  testCasesForPolicyTable:trigger_getting_device_consent(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)

  --TODO(istoimenova): Waiting for debug: pull 303
  -- local pre_dataconsent = commonFunctions:Get_data_policy_sql(" \"SELECT id FROM functional_group WHERE name = \\\"BaseBeforeDataConsent\\\"\"")
  -- --print("pre_dataconsent = "..pre_dataconsent)
  -- local group_app_id = commonFunctions:Get_data_policy_sql(" \"SELECT functional_group_id FROM app_group where application_id = \\\"0000001\\\"")
  -- --print("group_app_id = "..group_app_id)
  -- if(group_app_id ~= pre_dataconsent) then
  -- commonFunctions:printError("Application is not in pre_DataConsent. Group: "..group_app_id)

end

function Test:Precondition_Disallow_device()
  --TODO(istoimenova): Waiting for debug: pull 303
  -- local pre_dataconsent = commonFunctions:Get_data_policy_sql(" \"SELECT id FROM functional_group WHERE name = \\\"BaseBeforeDataConsent\\\"\"")
  -- --print("pre_dataconsent = "..pre_dataconsent)
  -- local group_app_id = commonFunctions:Get_data_policy_sql(" \"SELECT functional_group_id FROM app_group where application_id = \\\"0000001\\\"")
  -- --print("group_app_id = "..group_app_id)
  -- if(group_app_id ~= pre_dataconsent) then
  -- commonFunctions:printError("Application is not in pre_DataConsent. Group: "..group_app_id)
  self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
    {allowed = false, source = "GUI", device = {id = config.deviceMAC , name = "127.0.0.1"}})
  EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged",{})

end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep1_Send_RPC_from_default()
  --AddCommand belongs to default permissions, so should be disallowed
  local RequestIDAddCommand = self.mobileSession:SendRPC("AddCommand", { cmdID = 111, menuParams = { position = 1, menuName ="Command111" } })
  EXPECT_HMICALL("UI.AddCommand",{})
  :Times(0)
  EXPECT_RESPONSE(RequestIDAddCommand, { success = false, resultCode = "DISALLOWED" })
  EXPECT_NOTIFICATION("OnHashChange")
  :Times(0)
end

function Test:TestStep2_Allow_device()
  testCasesForPolicyTable:trigger_getting_device_consent(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
  EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged",{})
end

function Test:TestStep3_Send_RPC_from_default_again()
  --TODO(istoimenova): Waiting for debug: pull 303
  -- local pre_dataconsent = commonFunctions:Get_data_policy_sql(" \"SELECT id FROM functional_group WHERE name = \\\"BaseBeforeDataConsent\\\"\"")
  -- --print("pre_dataconsent = "..pre_dataconsent)
  -- local group_app_id = commonFunctions:Get_data_policy_sql(" \"SELECT functional_group_id FROM app_group where application_id = \\\"0000001\\\"")
  -- --print("group_app_id = "..group_app_id)
  -- if(group_app_id ~= pre_dataconsent) then
  -- commonFunctions:printError("Application is not in pre_DataConsent. Group: "..group_app_id)
  --AddCommand should be allowed
  local RequestIDAddCommand = self.mobileSession:SendRPC("AddCommand", { cmdID = 111, menuParams = { position = 1, menuName ="Command111" } })
  EXPECT_HMICALL("UI.AddCommand",{})
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  EXPECT_RESPONSE(RequestIDAddCommand, { success = true, resultCode = "SUCCESS" })
  EXPECT_NOTIFICATION("OnHashChange")
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end
