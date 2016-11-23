---------------------------------------------------------------------------------------------
-- UNREADY: Please see TODO
-- Requirement summary:
-- [HMI Status]: The value of <appID> in LocalPT is null
--
-- Description:
-- SDL should only allow an HMILevel of NONE to the app
-- in case PolicyTable has "<appID>": "null" in the Local PolicyTable
--
-- Preconditions:
-- 1. appID="123_xyz" is registered to SDL yet
-- 2. appID="123_xyz" has null policies
-- Steps:
-- 1. Activate app
-- 2. Verify status of activation
-- 3. Verify app hmi level
--
-- Expected result:
-- 2. status = "REJECTED"
-- 3. hmiLevel = "NONE"
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

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:UpdatePolicy()
  testCasesForPolicyAppIdManagament:updatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_014_1.json")
end

function Test:StartNewSession()
  self.mobileSession2 = mobileSession.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartService(7)
end

function Test:RegisterNewApp()
  config.application2.registerAppInterfaceParams.appName = "Media Application"
  config.application2.registerAppInterfaceParams.appID = "123_xyz"
  testCasesForPolicyAppIdManagament:registerApp(self, self.mobileSession2, config.application2)
  self.mobileSession2:ExpectNotification("OnHMIStatus", { hmiLevel = "NONE" })
end

function Test:UpdatePolicy()
  testCasesForPolicyAppIdManagament:updatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_014_2.json")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:ActivateApp()
  local requestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.mobileSession2.applicationId})
  EXPECT_HMIRESPONSE(requestId)
  :Do(function(_, _)
      --TODO: verify that status is "REJECTED"
    end)
  self.mobileSession2:ExpectNotification("OnHMIStatus", { hmiLevel = "NONE" })
end

return Test
