---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [HMI Status]: The <appID> param in Policies gets 'null' value in case of PTU
--
-- Description:
-- SDL should send OnHMIStatus (NONE, MAIN, NOT_AUDIBLE) to app
-- in case this app is currently in any HMILevel other than in NONE
-- and in result of PTU "<appID>" gets "null" policies
--
-- Preconditions:
-- 1. appID="123_xyz" is not registered to SDL yet
-- 2. appID="123_xyz" has NOT null policies
-- 3. appID="123_xyz" in FULL and AUDIBLE
-- 4. PTU is triggered (by registering new application "456_abc")
-- Steps:
-- 1. After PTU appID="123_xyz" gets "null" policies
-- 2. Verify status of OnHMIStatus notification
--
-- Expected result:
-- OnHMIStatus: hmiLevel="NONE", systemContext="MAIN", audioStreamingState="NOT_AUDIBLE"
--
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
  testCasesForPolicyAppIdManagament:updatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_013_1.json")
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

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:ActivateApp()
  testCasesForPolicyAppIdManagament:activateApp(self, self.mobileSession2)
end

function Test:StartNewSession()
  self.mobileSession3 = mobileSession.MobileSession(self, self.mobileConnection)
  self.mobileSession3:StartService(7)
end

function Test:RegisterNewApp()
  config.application3.registerAppInterfaceParams.appName = "New Application"
  config.application3.registerAppInterfaceParams.appID = "456_abc"
  testCasesForPolicyAppIdManagament:registerApp(self, self.mobileSession3, config.application3)
end

function Test:UpdatePolicy()
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
  testCasesForPolicyAppIdManagament:updatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_013_2.json")
  self.mobileSession2:ExpectNotification("OnHMIStatus",
    {hmiLevel="NONE", systemContext="MAIN", audioStreamingState="NOT_AUDIBLE"})
end

return Test
