---------------------------------------------------------------------------------------------
-- Requirement summary:
-- SDL must send WARNINGS (success:true) to mobile app in case HMI respond WARNINGS at least to one component of RPC
--
-- Description:
-- test is intended to check that SDL sends WARNINGS (success:true) to mobile app in case HMI respond WARNINGS to at least one HMI-portions
-- in this particular test it is checked case when UI.Alert gets WARNINGS and TTS.Speak gets SUCCESS from HMI 
-- 1. Used preconditions: App is registered and activated SUCCESSFULLY
-- 2. Performed steps: 
-- MOB -> SDL: sends Alert
-- SDL -> HMI: resends UI.Alert and TTS.Speak to HMI
-- HMI -> SDL: UI.Alert (WARNINGS),  TTS.Speak (SUCCESS)
--
-- Expected result:
-- SDL -> MOB: Alert(result code: WARNINGS, success: true)
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.SDLStoragePath = config.pathToSDL .. "storage/"
-- ToDo (vvvakulenko): remove after issue "ATF does not stop HB timers by closing session and connection" is resolved
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')

--[[ Local Variables ]]
local storagePath = config.SDLStoragePath..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"
--local ServerAddress = commonFunctions:read_parameter_from_smart_device_link_ini("ServerAddress") 

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_ActivationApp()
  local request_id = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
  EXPECT_HMIRESPONSE(request_id)
  :Do(function(_,data)
    if (data.result.isSDLAllowed ~= true) then
      local request_id1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
      EXPECT_HMIRESPONSE(request_id1)
      :Do(function(_,_)
      self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}}) 
      	--self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = ServerAddress}})
        EXPECT_HMICALL("BasicCommunication.ActivateApp")
        :Do(function(_,data1)
          self.hmiConnection:SendResponse(data1.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
        end)
      end)
    end
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"}) 
end

function Test.Precondition_PutFile()
  commonSteps:PutFile("Precondition_PutFile", "icon.png")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_Alert_UI_Alert_WARNINGS()
  local cor_id = self.mobileSession:SendRPC("Alert",
  {
    alertText1 = "alertText1",
    alertText2 = "alertText2",
    alertText3 = "alertText3",
    ttsChunks = {{text = "TTSChunk", type = "TEXT"}},
    duration = 3000,
    progressIndicator = true,
    softButtons =
      {{
        type = "BOTH",
        text = "Close",
        image =
        {
          value = "icon.png",
          imageType = "DYNAMIC",
        },
        isHighlighted = true,
        softButtonID = 3,
        systemAction = "DEFAULT_ACTION",
    }}
  })
 
  EXPECT_HMICALL("UI.Alert",
  {alertStrings =
    {
      {fieldName = "alertText1", fieldText = "alertText1"},
      {fieldName = "alertText2", fieldText = "alertText2"},
      {fieldName = "alertText3", fieldText = "alertText3"}
    },
    alertType = "BOTH",
    duration = 3000,
    progressIndicator = true,
    softButtons =
      {{
        type = "BOTH",
        text = "Close",
        image =
        {
          value = storagePath.."/icon.png",
          imageType = "DYNAMIC",
        },
        isHighlighted = true,
        softButtonID = 3,
        systemAction = "DEFAULT_ACTION",
      }},
    appID = self.applications["Test Application"]
  })
  :Do(function(_,data2) self.hmiConnection:SendResponse(data2.id, "UI.Alert", "WARNINGS", { })
  end)
 
  EXPECT_HMICALL("TTS.Speak",
  {ttsChunks =
      {{
        text = "TTSChunk",
        type = "TEXT"
    }},
    speakType = "ALERT",
    appID = self.applications["Test Application"]
  })
  :Do(function(_,data3) self.hmiConnection:SendResponse(data3.id, "TTS.Speak", "SUCCESS", { })
  end)

  EXPECT_RESPONSE(cor_id, { success = true, resultCode = "WARNINGS" })  
end
 
 --[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLStop()
  StopSDL()
end

return Test