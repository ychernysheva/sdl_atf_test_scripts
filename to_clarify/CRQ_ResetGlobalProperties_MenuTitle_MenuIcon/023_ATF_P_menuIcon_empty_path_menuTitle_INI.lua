---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [ResetGlobalProperties] "MENUICON" reset
-- [ResetGlobalProperties] "MENUNAME" reset
-- [INI file] [ApplicationManager] MenuTitle
-- [INI file] [ApplicationManager] MenuIcon
--
-- Description:
-- Check that SDL correctly retrievs menuIcon and menuTitle from INI file in case ResetGlobalProperties
-- is sent with MENUICON and MENUNAME in Properties array.
--
-- 1. Used preconditions:
-- Check that menuIcon exists and menuTitle = "MENU" in INI file.
-- Update menuIcon =
-- SetGlobalProperties is not sent at all.
--
-- 2. Performed steps
-- Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" )
--
-- Expected result:
-- 1. UI.SetGlobalProperties(menuTitle = "MENU"), menuIcon is not sent.
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
local empty_menuIcon
local title_to_check = "MENU"

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonPreconditions:BackupFile("sdl_preloaded_pt.json")
commonPreconditions:BackupFile("smartDeviceLink.ini")

testCasesForPolicyTable:precondition_updatePolicy_AllowFunctionInHmiLeves({"BACKGROUND", "FULL", "LIMITED", "NONE"},"SetGlobalProperties")
testCasesForPolicyTable:precondition_updatePolicy_AllowFunctionInHmiLeves({"BACKGROUND", "FULL", "LIMITED", "NONE"},"ResetGlobalProperties")
empty_menuIcon = testCasesForMenuIconMenuTitleParameters:UpdateINI("empty")

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

function Test:Precondition_CheckINI_menuIcon()
  if (empty_menuIcon == true) then
    self:FailTestCase("menuIcon is not found in INI file.")
  end
end

function Test:Precondition_ActivateApp()
  testCasesForMenuIconMenuTitleParameters:ActivateAppDiffPolicyFlag(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_menuIcon_empty_path_menuTitle_INI()
  local cid = self.mobileSession:SendRPC("ResetGlobalProperties",{ properties = { "MENUICON", "MENUNAME" }})

  EXPECT_HMICALL("UI.SetGlobalProperties",{ menuTitle = title_to_check})
  :Do(function(_,data) self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {}) end)
  :ValidIf(function(_,data)
    if(data.params.menuIcon) then
      self:FailTestCase("menuIcon is sent within ResetGlobalProperties response. Expected: nil, Real: " ..data.params.menuIcon.value)
      return false
    else
      xmlReporter.AddMessage("EXPECT_HMIRESPONSE", {"EXPECTED_RESULT"}," menuIcon is nil")
      return true
    end
  end)

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