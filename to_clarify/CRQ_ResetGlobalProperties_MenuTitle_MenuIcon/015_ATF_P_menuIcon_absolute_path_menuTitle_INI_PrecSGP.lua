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
-- Update menuIcon = absolute path
-- Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }, menuTitle = "Menu Title")
--
-- 2. Performed steps
-- Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" )
--
-- Expected result:
-- 1. UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = absolute path}, menuTitle = "MENU")
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
local icon_to_check
local title_to_check = "MENU"
local absolute_path = testCasesForMenuIconMenuTitleParameters:ReadCmdLine("pwd")
local SGP_path = absolute_path .. "/SDL_bin/./".. "storage/" ..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"
local SGP_path1 = absolute_path .. "/SDL_bin/".. "storage/" ..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonPreconditions:BackupFile("sdl_preloaded_pt.json")
commonPreconditions:BackupFile("smartDeviceLink.ini")

testCasesForPolicyTable:precondition_updatePolicy_AllowFunctionInHmiLeves({"BACKGROUND", "FULL", "LIMITED", "NONE"},"SetGlobalProperties")
testCasesForPolicyTable:precondition_updatePolicy_AllowFunctionInHmiLeves({"BACKGROUND", "FULL", "LIMITED", "NONE"},"ResetGlobalProperties")
empty_menuIcon, icon_to_check = testCasesForMenuIconMenuTitleParameters:UpdateINI("absolute")

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

commonSteps:PutFile("Precondition_PutFile_action.png", "action.png")

function Test:Precondition_SetGlobalProperties_menuIcon_menuTitle()
  local cid = self.mobileSession:SendRPC("SetGlobalProperties",{
      menuIcon = { value = "action.png", imageType = "DYNAMIC" },
      menuTitle = "Menu Title"
    })

  EXPECT_HMICALL("UI.SetGlobalProperties", {
      menuIcon = { imageType = "DYNAMIC"},--, value = SGP_path .. "action.png"},
      menuTitle = "Menu Title"
    })
  :Do(function(_,data) self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {}) end)
  :ValidIf(function(_,data)
    if(data.params.menuIcon.value ~= nil) then
      if( (data.params.menuIcon.value == SGP_path .. "action.png") or (data.params.menuIcon.value == SGP_path1 .. "action.png") ) then
        return true
      else
        commonFunctions:printError("menuIcon.value is: " ..data.params.menuIcon.value ..". Expected: " .. SGP_path1 .. "action.png")
        return false
      end
    else
      commonFunctions:printError("menuIcon.value has a nil value")
      return false
    end
  end)

  EXPECT_HMICALL("TTS.SetGlobalProperties",{}):Times(0)
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
  EXPECT_NOTIFICATION("OnHashChange")
  :Do(function(_, data) self.currentHashID = data.payload.hashID end)

end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_menuIcon_absolute_path_menuTitle_INI_PrecSGP()
  local cid = self.mobileSession:SendRPC("ResetGlobalProperties",{ properties = { "MENUICON", "MENUNAME" }})

  EXPECT_HMICALL("UI.SetGlobalProperties",{
      menuIcon = {
        imageType = "DYNAMIC",
        value = icon_to_check
      },
      menuTitle = title_to_check
    })
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