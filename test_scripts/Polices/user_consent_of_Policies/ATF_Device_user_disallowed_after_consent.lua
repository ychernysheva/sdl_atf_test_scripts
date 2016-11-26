------------- --------------------------------------------------------------------------------
-- Requirement summary:
-- 		[Policies]: User-disallowed device after applications consent
--
-- Description:
-- 		User disallows device via Settings Menu after device and apps on device are consented
--
--  1. Used preconditions:
--		Delete log files and policy table from previous ignition cycle
--		Activate app -> consent device
--		Disallow device via Settings Menu
--  2.Performed steps:
--    Send RPC from default group
--    Allow device
--    Send RPC from default group again
--
-- Expected result:
-- 		App consents must remain the same, app must be rolled back to pre_DataConstented group -> RPC from defult should not be allowed
--    App must be rolled back to default group 
--    RPC from defult should be allowed
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")

--[[ Precondition ]]
function Test:Precondition_ActivateRegisteredApp()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})
  EXPECT_HMIRESPONSE(RequestId, {result = { code = 0, isAppPermissionsRevoked = false, isAppRevoked = false, isSDLAllowed = false, isPermissionsConsentNeeded = true, method ="SDL.ActivateApp", priority ="NONE"}})
  :Do(function(_,data)
  if data.result.isSDLAllowed ~= false then
    commonFunctions:userPrint(31, "Error: wrong behavior of SDL - device needs to be consented on HMI")
  else
    local RequestIdGetMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
    EXPECT_HMIRESPONSE(RequestIdGetMessage)
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

function Test:Precondition_Disallow_device()
    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = false, source = "GUI", device = {id = config.deviceMAC , name = "127.0.0.1"}})
    EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged",{})
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep1_Send_RPC_from_default()
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

function Test:TestStep2_Allow_device()
    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC , name = "127.0.0.1"}})
    EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged",{})
end

function Test:TestStep3_Send_RPC_from_default_again()
    --AddCommand should be allowed
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
  EXPECT_RESPONSE(RequestIDAddCommand, { success = false, resultCode = "SUCCESS" })
  EXPECT_NOTIFICATION("OnHashChange")
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end