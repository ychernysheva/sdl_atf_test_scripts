---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PerformAudioPassThru] "audioPassThruIcon" does NOT exist at 'AppStorageFolder'
-- [HMI API] UI.PerformAudioPassThru request/response
-- [HMI API] TTS.Speak request/response
-- [Mobile API] PerformAudioPassThru request/response
-- [HMI_API] [MOBILE_API] The "audioPassThruIcon" param at "ImageFieldName" struct
--
-- Description:
-- In case mobile app sends PerformAudioPassThru_request to SDL 
-- with valid <audioPassThruIcon> parameter
-- and the requested <audioPassThruIcon> does NOT exist at app`s sandbox
-- and with another related to request valid params
-- transfer UI.PerformAudioPassThru (<audioPassThruIcon>, other params)_request + Speak_request (depends on parameters provided by the app) to HMI
--respond with <resultCode_received_from_HMI> + <info> to mobile app (expected resultCode from HMI is "WARNINGS" and info: "Reference image(s) not found" 
-- as described in [F-S] Conditions for SDL to handle case when requested <Image> does not exist at "AppStorageFolder"
--
--1. Used preconditions
--1.1. audioPassThruIcon does not exist in created by app AppStorageFolder
--1.1. Request is sent with valid audioPassThruIcon parameter with type DYNAMIC, all other params used in PerformAudioPassThru_request are present and within bounds 
--2. Performed steps
-- Send PerformAudioPassThru (audioPassThruIcon, other params) from mobile to SDL and check:
--2.1 SDL sends UI.PerformAudioPassThru (audioPassThruIcon, other params) to HMI
--2.2 SDL sends TTS.Speak to HMI
--2.3 HMI sends UI.PerformAudioPassThru (WARNINGS) to SDL
--2.4 HMI sends TTS.Speak (SUCCESS) to SDL
-- Expected result:
-- SDL sends PerformAudioPassThru (WARNINGS, success:true, info:Reference image(s) not found) to mobile app

---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForPerformAudioPassThru = require('user_modules/shared_testcases/testCasesForPerformAudioPassThru')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable ()
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_Check_audioPassThruIcon_Existence()
  testCasesForPerformAudioPassThru:Check_audioPassThruIcon_Existence(self)
end

function Test:Precondition_ActivateApp()
  testCasesForPerformAudioPassThru:ActivateAppDiffPolicyFlag
  (self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_All_Params_Missing_audioPassThruIcon_DYNAMIC()
  local CorIdPerformAudioPassThruAppParVD= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      initialPrompt =
      {
        {
          text = "Makeyourchoice",
          type = "TEXT",
        },

      },
      audioPassThruDisplayText1 = "DisplayText1",
      audioPassThruDisplayText2 = "DisplayText2",
      samplingRate = "16KHZ",
      maxDuration = 2000,
      bitsPerSample = "8_BIT",
      audioType = "PCM",
      muteAudio = true, 
      audioPassThruIcon =
      { value = "icon.png",
        imageType = "DYNAMIC"
      }      
    })

  -- hmi expects TTS.Speak request
  EXPECT_HMICALL("TTS.Speak",
    {
      speakType = "AUDIO_PASS_THRU",
      ttsChunks = { { text = "Makeyourchoice", type = "TEXT" } },
      appID = self.applications[applicationName]
    })
  :Do(function(_,data)
      -- send notification to start TTS.Speak
      self.hmiConnection:SendNotification("TTS.Started",{ })

      -- HMI sends TTS.Speak SUCCESS
      local function ttsSpeakResponse()
        self.hmiConnection:SendResponse (data.id, data.method, "SUCCESS", {})

        -- HMI sends TTS.Stop
        self.hmiConnection:SendNotification("TTS.Stopped")
      end

      RUN_AFTER(ttsSpeakResponse, 1000)
    end)

  -- hmi expects UI.PerformAudioPassThru request
  EXPECT_HMICALL("UI.PerformAudioPassThru",
    {
      appID = self.applications[applicationName],
      audioPassThruDisplayTexts = {
        {fieldName = "audioPassThruDisplayText1", fieldText = "DisplayText1"},
        {fieldName = "audioPassThruDisplayText2", fieldText = "DisplayText2"},
      },
      maxDuration = 2000,
      muteAudio = true
    })
  :Do(function(_,data)
  	if data.params.audioPassThruIcon ~= nil then 
  		print (" \27[36m Unexpected parameter received \27[0m")
  		return false 
  	end
      local function UIPerformAoudioResponce()
        self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "WARNINGS", {})
      end

      RUN_AFTER(UIPerformAoudioResponce, 1500)
  end)

  if
  self.appHMITypes["NAVIGATION"] == true or
  self.appHMITypes["COMMUNICATION"] == true or
  self.isMediaApplication == true then
    --mobile side: expect OnHMIStatus notification
    EXPECT_NOTIFICATION("OnHMIStatus",
      {hmiLevel = "FULL", audioStreamingState = "ATTENUATED", systemContext = "MAIN"},
      {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
    :Times(2)
  else
    EXPECT_NOTIFICATION("OnHMIStatus")
    :Times(0)
  end

  self.mobileSession:ExpectResponse(CorIdPerformAudioPassThruAppParVD, 
    { success = true, 
      resultCode = "WARNINGS", 
      info = "Reference image(s) not found) to mobile app" ,
    })

  commonTestCases:DelayedExp(1500)

end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_Stop_SDL()
  StopSDL()
end

return Test
