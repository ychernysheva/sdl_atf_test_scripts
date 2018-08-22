
---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [ResetGlobalProperties] "MENUNAME" reset
-- [INI file] [ApplicationManager] MenuTitle
--
-- Description:
-- Check that SDL correctly retrievs menuTitle from INI file in case ResetGlobalProperties
-- is sent only with MENUNAME in Properties array.
--
-- 1. Used preconditions:
-- Check in INI file menuTitle = "MENU"
-- ResetGlobalProperties and SetGlobalProperties is allowed by policy.
-- Send SetGlobalProperties(menuTitle = "Menu Title")
--
-- 2. Performed steps
-- Send ResetGlobalProperties(properties = "MENUNAME")
--
-- Expected result:
-- 1. UI.SetGlobalProperties(menuTitle = "MENU")
-- 2. TTS.SetGlobalProperties is not sent.
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonPreconditions = require ('user_modules/shared_testcases/commonPreconditions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require ('user_modules/shared_testcases/testCasesForPolicyTable')
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local testCasesForMenuIconMenuTitleParameters = require ('user_modules/shared_testcases/testCasesForMenuIconMenuTitleParameters')

--[[ Local Variables ]]
local title_to_check = "MENU"

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonPreconditions:BackupFile("sdl_preloaded_pt.json")
commonPreconditions:BackupFile("smartDeviceLink.ini")

testCasesForPolicyTable:precondition_updatePolicy_AllowFunctionInHmiLeves({"BACKGROUND", "FULL", "LIMITED", "NONE"},"SetGlobalProperties")
testCasesForPolicyTable:precondition_updatePolicy_AllowFunctionInHmiLeves({"BACKGROUND", "FULL", "LIMITED", "NONE"},"ResetGlobalProperties")

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_CheckINI_menuTitle()
  local result = testCasesForMenuIconMenuTitleParameters:CheckINI_menuTitle()

  if (result == false) then
    self:FailTestCase()
  end
end

function Test:Precondition_ActivateApp()
  testCasesForMenuIconMenuTitleParameters:ActivateAppDiffPolicyFlag(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

function Test:Precondition_SetGlobalProperties_menuTitle()
  local cid = self.mobileSession:SendRPC("SetGlobalProperties",{ menuTitle = "Menu Title" })

  EXPECT_HMICALL("UI.SetGlobalProperties", { menuTitle = "Menu Title" })
  :Do(function(_,data) self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {}) end)

  EXPECT_HMICALL("TTS.SetGlobalProperties",{}):Times(0)
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
  EXPECT_NOTIFICATION("OnHashChange")
  :Do(function(_, data) self.currentHashID = data.payload.hashID end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_menuTitle_INI_Prec_SGP()
  local cid = self.mobileSession:SendRPC("ResetGlobalProperties",{ properties = { "MENUNAME" }})

  EXPECT_HMICALL("UI.SetGlobalProperties",{ menuTitle = title_to_check })
  :Do(function(_,data) self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {}) end)

  EXPECT_HMICALL("TTS.SetGlobalProperties",{}):Times(0)
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
  EXPECT_NOTIFICATION("OnHashChange")

end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_RestoreConfigFiles()
  commonPreconditions:RestoreFile("smartDeviceLink.ini")
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end

function Test.Postcondition_StopSDL()
  StopSDL()
end

return Test