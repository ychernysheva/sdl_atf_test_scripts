---------------------------------------------------------------------------------------------
-- UNREADY: Only 6 RPCs and 3 notifications are covered
-- Requirement summary:
-- [GeneralResultCodes]DISALLOWED: RPC is omitted in the PolicyTable "default" group(s) assigned to the application
--
-- Description:
-- SDL must return DISALLOWED resultCode and success = "false" to the RPC requested by the application
-- in case the successfully registered application with assigned "default" policies,
-- sends an RPC that is NOT included (omitted) in the PolicyTable "default" group(s) assigned to the application
--
-- Preconditions:
-- 1. Application with <appID> is registered on SDL.
-- 2. Default permissions are assigned for <appID>
-- 2. PRC is not specified in default permissions
-- Steps:
-- 1. Send RPC App -> SDL
-- 2. Verify status of response
--
-- Expected result:
-- SDL -> App: RPC (DISALLOWED, success: "false")
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Local Functions ]]
local function verifyResponse(test, corId)
  test.mobileSession:ExpectResponse(corId)
  :ValidIf(function(_, d)
      local exp = {success = false, resultCode = "DISALLOWED"}
      if (d.payload.success == exp.success) and (d.payload.resultCode == exp.resultCode) then
        return true
      else
        return false, "Expected: {success = '" .. tostring(exp.success) .. "', resultCode = '" .. exp.resultCode
        .. "'}, got: {success = '" .. tostring(d.payload.success) .. "', resultCode = '" .. d.payload.resultCode .. "'}"
      end
    end)
end

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
  testCasesForPolicyAppIdManagament:updatePolicyTable(self, "files/jsons/Policies/App_Permissions/ptu_014.json")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:SendRPC_AddCommand()
  local corId = self.mobileSession:SendRPC("AddCommand", {cmdID = 1,menuParams = {menuName = "Options"}, vrCommands = {"Options"} })
  verifyResponse(self, corId)
end

function Test:SendRPC_AddSubMenu()
  local corId = self.mobileSession:SendRPC("AddSubMenu", {menuID = 1000, position = 500, menuName ="SubMenupositive"})
  verifyResponse(self, corId)
end

function Test:SendRPC_Alert()
  local corId = self.mobileSession:SendRPC("Alert", {alertText1 = "alertText1"})
  verifyResponse(self, corId)
end

function Test:SendRPC_Show()
  local corId = self.mobileSession:SendRPC("Show", {mainField1 = "mainField1"})
  verifyResponse(self, corId)
end

function Test:SendRPC_SystemRequest()
  local corId = self.mobileSession:SendRPC("SystemRequest", {requestType = "PROPRIETARY", fileName = "PolicyTableUpdate"})
  verifyResponse(self, corId)
end

function Test:SendRPC_UnregisterAppInterface()
  local corId = self.mobileSession:SendRPC("UnregisterAppInterface",{})
  verifyResponse(self, corId)
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
