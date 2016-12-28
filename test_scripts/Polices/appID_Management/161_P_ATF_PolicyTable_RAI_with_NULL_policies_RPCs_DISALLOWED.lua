---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [GeneralResultCode] DISALLOWED. A request comes with appID which has "null" permissions in Policy Table
-- [RegisterAppInterface] Allow only RegisterAppInterface for the application with NULL policies
--
-- Description:
-- In case PolicyTable has "<appID>": "null" in the Local PolicyTable for the specified application with appID,
-- PoliciesManager must return DISALLOWED resultCode and success:"false" to any RPC requested by such <appID> app.
-- Performed steps
-- Pre_step. Add in sdl_preloaded_pt application id with NULL policy
-- 1. MOB-SDL - Open new session and register application in this session
-- 2. MOB-SDL - send the list of RPCs
-- 3. SDL responce, success = false, resultCode = "DISALLOWED"
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
require('user_modules/AppTypes')
local mobile_session = require("mobile_session")

--[[ General configuration parameters ]]
config.defaultProtocolVersion = 2
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local Preconditions = require('user_modules/shared_testcases/commonPreconditions')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:Pecondition_Add_App()
  commonTestCases:DelayedExp(3000)
  self:connectMobile()
  commonTestCases:DelayedExp(3000)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
  :Do(function(_,data)
  self.HMIAppID = data.params.application.appID
  end)
  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
  self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
  end)
end

function Test:Consent_Device()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID })
  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,data)
  if data.result.isSDLAllowed ~= true then
    local RequestIdGetMes = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
    {language = "EN-US", messageCodes = {"DataConsent"}})
    EXPECT_HMIRESPONSE(RequestIdGetMes)
    :Do(function()
    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
    {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
    EXPECT_HMICALL("BasicCommunication.ActivateApp")
    :Do(function()
    self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
    end)
    :Times(AtLeast(1))
    end)
  end
  end)
end

function Test:Precondition_CloseConnection()
  self.mobileConnection:Close()
  commonTestCases:DelayedExp(3000)
end

function Test.Precondition_SetNullPermissionsToApp()
  Preconditions:BackupFile("sdl_preloaded_pt.json")
  testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/jsons/Policies/appID_Management/ptu_23511.json")
end

function Test:Precondition_ConnectDevice()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
end

function Test:Pecondition_StartNewSession()
  self.mobileSession2 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartService(7)
end

function Test:Pecondition_RegisterNewApp()
  config.application2.registerAppInterfaceParams.appName = "App_test"
  config.application2.registerAppInterfaceParams.appID = "123abc"
  local correlationId = self.mobileSession2:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
  :Do(function(_,data)
  HMIAppID = data.params.application.appID
  self.applications[config.application2.registerAppInterfaceParams.appName] = data.params.application.appID
  end)
  self.mobileSession2:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE" })
  self.mobileSession2:ExpectResponse(correlationId, { success = true })
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
local RPC_Base4_EmptyParams = {"Alert", "EndAudioPassThru", "Show"}
for i = 1, #RPC_Base4_EmptyParams do
  function Test:RPCsNoParams_DISALLOWED()
    print(RPC_Base4_EmptyParams[i].."_DISALLOWED")
    local correlationId = self.mobileSession2:SendRPC(RPC_Base4_EmptyParams[i], {})
    self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
  end
end

function Test:AddCommand_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "AddCommand",
  {
    cmdID = 1,
    vrCommands = { "vrCommands_12" },
    menuParams = {position = 1, menuName ="Command 1"}
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:DeleteCommand_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "DeleteCommand",
  {
    cmdID = 1
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:Slider_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "Slider",
  {
    numTicks = 3,
    position = 2,
    sliderHeader ="sliderHeader",
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:ScrollableMessage_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "ScrollableMessage",
  {
    scrollableMessageBody = "abc"
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:PerformAudioPassThru_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "PerformAudioPassThru",
  {
    samplingRate ="8KHZ",
    maxDuration = 2000,
    bitsPerSample ="8_BIT",
    audioType ="PCM",
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:Speak_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "Speak",
  {
    ttsChunks = {
      {
        text ="a",
        type ="TEXT"
      }
    }
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:SubscribeButton_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "SubscribeButton",
  {
    buttonName = "PRESET_0"
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:PerformInteraction_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "PerformInteraction",
  {
    initialText = "StartPerformInteraction", 
    initialPrompt = {
      {
        text = "Makeyourchoice", 
        type = "TEXT", 
      }
    },
    interactionMode = "BOTH", 
    interactionChoiceSetIDList = {2}, 
    helpPrompt = {
    {
      text = "Choosethevarianton", 
      type = "TEXT", 
    }
  },
  interactionLayout = "ICON_ONLY"
})
self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:CreateInteractionChoiceSet_DISALLOWED()
local correlationId = self.mobileSession2:SendRPC( "CreateInteractionChoiceSet",
{
  interactionChoiceSetID = 1002,
  choiceSet =
  {

    {
      choiceID = 1002,
      menuName ="Choice1002",
      vrCommands =
      {
        "Choice1002",
      }
    }
  }
})
self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:DeleteInteractionChoiceSet_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "DeleteInteractionChoiceSet",
  {
    interactionChoiceSetID = 1002
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:AddSubMenu_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "AddSubMenu",
  {
    menuID = 1000,
    menuName = "SubMenupositive"
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:DeleteSubMenu_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "DeleteSubMenu",
  {
    menuID = 1000
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:SetMediaClockTimer_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "SetMediaClockTimer",
  {
    updateMode = "COUNTDOWN"

  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:PutFile_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "PutFile",
  {
    syncFileName = "icon.png",
    fileType  = "GRAPHIC_PNG",
    persistentFile = false,
    systemFile = false
  }, "files/icon.png"  )
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:ListFiles_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "ListFiles", {})
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end


function Test:ChangeRegistration_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "ChangeRegistration",
  {
    language = "EN-US",
    hmiDisplayLanguage ="EN-US"
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:SetAppIcon_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "SetAppIcon",
  {
    syncFileName = "icon.png"
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:DeleteFile_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "DeleteFile",
  {
    syncFileName ="icon.png"
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:SetGlobalProperties_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "SetGlobalProperties",
  {
    menuTitle = "Menu Title"
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:ResetGlobalProperties_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "ResetGlobalProperties",

  {
    properties =
    {
      "VRHELPTITLE",
      "MENUNAME",
      "MENUICON",
      "KEYBOARDPROPERTIES",
      "VRHELPITEMS",
      "HELPPROMPT",
      "TIMEOUTPROMPT"
    }
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:SetDisplayLayout_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "SetDisplayLayout",
  {
    displayLayout = "ONSCREEN_PRESETS"
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:SystemRequest_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC( "SystemRequest",
  {
    requestType = "NAVIGATION",
    fileName = "icon.png"
  })
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

function Test:UnregisterAppInterface_DISALLOWED()
  local correlationId = self.mobileSession2:SendRPC("UnregisterAppInterface", {})
  self.mobileSession2:ExpectResponse(correlationId, { success = false, resultCode = "DISALLOWED" })
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_StopSDL()
  StopSDL()
end

function Test.Postcondition_RestorePreloadedPT()
  testCasesForPolicyTable:Restore_preloaded_pt()
end
