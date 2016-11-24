---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [GeneralResultCodes] DISALLOWED: RPC is omitted in the PolicyTable group(s) assigned to the application
--
-- Description:
-- SDL must return DISALLOWED resultCode and success = "false" to the RPC requested by the application
-- in case the successfully registered application sends an RPC that is NOT included (omitted)
-- in the PolicyTable group(s) assigned to the application
--
-- Preconditions:
-- 1. Application with <appID> is registered on SDL.
-- 2. Policy Table contains section "functional_groupings", where in group that assigned for app
-- PRC is not specified
-- Steps:
-- 1. Send RPC App -> SDL
-- 2. Verify status of response
--
-- Expected result:
-- SDL -> App: RPC (DISALLOWED, success: "false")
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
  testCasesForPolicyAppIdManagament:updatePolicyTable(self, "files/jsons/Policies/App_Permissions/ptu_020.json")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:SendRPC_AddCommand()
  local corId = self.mobileSession:SendRPC("AddCommand", {cmdID = 1,menuParams = {menuName = "Options"}, vrCommands = {"Options"} })
  self.mobileSession:ExpectResponse(corId, {success = false, resultCode = "DISALLOWED"})
end

function Test:SendRPC_AddSubMenu()
  local corId = self.mobileSession:SendRPC("AddSubMenu", {menuID = 1000, position = 500, menuName ="SubMenupositive"})
  self.mobileSession:ExpectResponse(corId, {success = false, resultCode = "DISALLOWED"})
end

function Test:SendRPC_Alert()
  local corId = self.mobileSession:SendRPC("Alert", {alertText1 = "alertText1"})
  self.mobileSession:ExpectResponse(corId, {success = false, resultCode = "DISALLOWED"})
end

function Test:SendRPC_Show()
  local corId = self.mobileSession:SendRPC("Show", {mainField1 = "mainField1"})
  self.mobileSession:ExpectResponse(corId, {success = false, resultCode = "DISALLOWED"})
end

function Test:SendRPC_SystemRequest()
  local corId = self.mobileSession:SendRPC("SystemRequest", {requestType = "PROPRIETARY", fileName = "PolicyTableUpdate"})
  self.mobileSession:ExpectResponse(corId, {success = false, resultCode = "DISALLOWED"})
end

function Test:SendRPC_UnregisterAppInterface()
  local corId = self.mobileSession:SendRPC("UnregisterAppInterface",{})
  self.mobileSession:ExpectResponse(corId, {success = false, resultCode = "DISALLOWED"})
end

return Test
