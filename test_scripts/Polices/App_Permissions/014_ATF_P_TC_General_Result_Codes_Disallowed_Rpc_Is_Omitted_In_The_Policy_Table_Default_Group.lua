---------------------------------------------------------------------------------------------
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

--[[ Required Shared libraries ]]
local testCasesForPolicyAppIdManagament = require("user_modules/shared_testcases/testCasesForPolicyAppIdManagament")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ Local Variables ]]
local rpc = {}
rpc["AddCommand"] = {cmdID = 1, menuParams = {menuName = "Options"}, vrCommands = {"Options"}}
rpc["AddSubMenu"] = {menuID = 1000, position = 500, menuName ="SubMenupositive"}
rpc["Alert"] = {alertText1 = "alertText1"}
rpc["Show"] = {mainField1 = "mainField1"}
rpc["SystemRequest"] = {requestType = "PROPRIETARY", fileName = "PolicyTableUpdate"}

local ntf = {}
ntf["TTS.OnLanguageChange"] ={language = "EN-GB"}
ntf["UI.OnLanguageChange"] = {language = "EN-GB"}
ntf["VR.OnLanguageChange"] = {language = "EN-GB"}

--[[ Local Functions ]]
local function split(s, d)
  local out = {}
  local i = 1
  for word in string.gmatch(s, '([^'.. d ..']+)') do
    out[i] = word
    i = i + 1
  end
  return out
end

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

for k, v in pairs(rpc) do
  Test["SendRPC_" .. k] = function(self)
    local corId = self.mobileSession:SendRPC(k, v)
    self.mobileSession:ExpectResponse(corId, {success = false, resultCode = "DISALLOWED"})
  end
end

for k, v in pairs(ntf) do
  Test["SendNotification_" .. k] = function(self)
    self.hmiConnection:SendNotification(k, v.p)
    EXPECT_NOTIFICATION(split(k, '.')[2])
    :Times(0)
  end
end

return Test
