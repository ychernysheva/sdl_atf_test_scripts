------------- --------------------------------------------------------------------------------
-- Requirement summary:
-- [RegisterAppInterface] Without data consent, assign "pre_DataConsent" policies
-- to the application which appID does not exist in LocalPT
--
-- Description:
-- SDL should assign "pre_DataConsent" permissions in case the application registers
-- (sends RegisterAppInterface request) with the appID that does not exist in Local Policy Table,
-- and Data Consent either has been denied or has not yet been asked for the device
-- this application registers from
--
-- Preconditions:
-- 1. appID="456_abc" is not registered to SDL yet
-- Steps:
-- 1. Register new application with appID="456_abc"
-- 2. Send "Alert" RPC in order to verify that "pre_DataConsent" permissions are assigned
-- This RPC is not allowed.
-- 3. Verify RPC's respond status
-- 4. Activate application
-- 5. Send "Alert" RPC in order to verify that "default" permissions are assigned
-- This RPC is allowed.
-- 6. Verify RPC's respond status
--
-- Expected result:
-- 3. Status of response: sucess = false, resultCode = "DISALLOWED"
-- 6. Status of response: sucess = true, resultCode = "SUCCESS"

---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local mobileSession = require("mobile_session")
local testCasesForPolicyAppIdManagament = require("user_modules/shared_testcases/testCasesForPolicyAppIdManagament")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTERNAL_PROPRIETARY")
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")

--[[ Local Variables ]]
Test.applicationId = nil

--[[ Local Functions ]]
local function verifyRPC(test, status, code)
  local corId = test.mobileSession:SendRPC("Alert",
    {
      alertText1 = "alertText1",
      duration = 3000,
      playTone = false
    })
  test.mobileSession:ExpectResponse(corId, {sucess = status, resultCode = code })
end

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:StartNewSession()
  self.mobileSession2 = mobileSession.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartService(7)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:RegisterNewApp()
  config.application2.registerAppInterfaceParams.appName = "ABC Application"
  config.application2.registerAppInterfaceParams.appID = "456_abc"
  local corId = self.mobileSession2:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = "ABC Application" }})
  :Do(function(_, data)
      self.applicationId = data.params.application.appID
      -- self.mobileSession2:ExpectNotification("OnHMIStatus", { hmiLevel = "NONE" })
    end)
  self.mobileSession2:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })

end

function Test:VerifyRPC()
  verifyRPC(self, false, "DISALLOWED")
end

function Test:ActivateApp()
  testCasesForPolicyAppIdManagament:activateApp(self, self.applicationId)
end

function Test:VerifyRPC()
  verifyRPC(self, true, "SUCCESS")
end

return Test
