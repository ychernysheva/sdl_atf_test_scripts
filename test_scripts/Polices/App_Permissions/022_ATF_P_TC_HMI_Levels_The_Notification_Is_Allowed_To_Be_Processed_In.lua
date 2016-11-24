---------------------------------------------------------------------------------------------
-- UNREADY: Only 5 notifications are covered
-- Requirement summary:
-- HMI Levels the notification is allowed to be processed in
--
-- Description:
-- SDL must not send/ transfer (in case got from HMI) notification to mobile application,
-- in case Policy Table doesn't contain current application's HMILevel
-- defined in Policy Table "functional_groupings" section for a specified notification
--
-- Preconditions:
-- 1. Application with <appID> is registered on SDL.
-- 2. Current HMILevel for application is HMILevel_1
-- 3. Policy Table contains section "functional_groupings",
-- in which for a specified PRC there're defined HMILevels: HMILevel_2, HMILevel_3
-- Steps:
-- 1. Send notification HMI -> SDL
-- 2. Verify SDL not transfer notification to app
--
-- Expected result:
-- SDL -> App: There is no notification
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
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
  testCasesForPolicyAppIdManagament:updatePolicyTable(self, "files/jsons/Policies/App_Permissions/ptu_022.json")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

for k, v in pairs({"UI", "VR"}) do
  local notification = v .. ".OnCommand"
  Test["SendNotification_" .. notification] = function(self)
    self.mobileSession:SendRPC("AddCommand",
      {
        cmdID = k,
        menuParams = {menuName ="UICommand100" .. k},
        vrCommands = { "VRCommand100" .. k}
      })
    EXPECT_HMICALL("UI.AddCommand")
    EXPECT_HMICALL("VR.AddCommand")
    self.hmiConnection:SendNotification("VR.Started",{})
    self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = self.applications["Test Application"], systemContext = "VRSESSION" })
    self.hmiConnection:SendNotification(notification, {cmdID = k, appID = self.applications["Test Application"]})
    EXPECT_NOTIFICATION("OnCommand")
    :Times(0)
    self.hmiConnection:SendNotification("VR.Stopped",{})
    self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = self.applications["Test Application"], systemContext = "MAIN" })
  end
end

for _, v in pairs({"TTS", "UI", "VR"}) do
  local notification = v .. ".OnLanguageChange"
  Test["SendNotification_" .. notification] = function(self)
    self.hmiConnection:SendNotification(notification, {language = "EN-GB"})
    EXPECT_NOTIFICATION("OnLanguageChange")
    :Times(0)
  end
end

return Test
