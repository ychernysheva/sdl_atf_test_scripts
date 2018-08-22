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
-- Perform resumption because of mobile disconnect->connect. => menuTitle is resumed
--
-- 2. Performed steps
-- ResetGlobalProperties(properties = "MENUNAME")
--
-- Expected result:
-- 1. UI.SetGlobalProperties(menuTitle = "MENU")
-- 2. TTS.SetGlobalProperties is not sent.
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--TODO(istoimenova): should be removed when "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonPreconditions = require ('user_modules/shared_testcases/commonPreconditions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require ('user_modules/shared_testcases/testCasesForPolicyTable')
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local testCasesForMenuIconMenuTitleParameters = require ('user_modules/shared_testcases/testCasesForMenuIconMenuTitleParameters')
local mobile_session = require('mobile_session')

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

function Test:Precondition_CloseConnection()
  self.mobileConnection:Close()
end

function Test:Precondition_ConnectMobile()
  self:connectMobile()
end

function Test:Precondition_StartSession()
  self.mobileSession = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application1.registerAppInterfaceParams)
end

function Test:Precondition_RegisterAppResumption()
  config.application1.registerAppInterfaceParams.hashID = self.currentHashID

  self.mobileSession:StartService(7)
  :Do(function()
    local CorIdRegister = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application1.registerAppInterfaceParams.appName }})
    :Do(function(_,data) self.applications[config.application1.registerAppInterfaceParams.appName] = data.params.application.appID end)

    EXPECT_HMICALL("BasicCommunication.ActivateApp")
    :Do(function(_,data) self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {}) end)

    self.mobileSession:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

    EXPECT_NOTIFICATION("OnHMIStatus",
        {hmiLevel = "NONE", systemContext = "MAIN"},
        {hmiLevel = "FULL", systemContext = "MAIN"})
    :Do(function(exp,_)
      if(exp.occurences == 2) then
        local TimeHMILevel = timestamp()
        print("HMI LEVEL is resumed")
        return TimeHMILevel
      end
    end)
    :Times(2)
  end)

  EXPECT_HMICALL("UI.SetGlobalProperties", { menuTitle = "Menu Title" })
  :Do(function(_,data) self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {}) end)

  EXPECT_HMICALL("TTS.SetGlobalProperties",{}):Times(0)

  EXPECT_NOTIFICATION("OnHashChange")
  :Do(function(_, data) self.currentHashID = data.payload.hashID end)

end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_menuTitle_INI_PrecSGP_MobileDisconnect()
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