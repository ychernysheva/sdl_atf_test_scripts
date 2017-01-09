--This script contains common functions that are used in CRQs:
-- [GENIVI] PerformAudioPassThru: SDL must support new "audioPassThruIcon" parameter
--How to use:
--1. local testCasesForPerformAudioPassThru = require('user_modules/shared_testcases/testCasesForPerformAudioPassThru')

local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local applicationName = config.application1.registerAppInterfaceParams.appName
local SDLConfig = require ('user_modules/shared_testcases/SmartDeviceLinkConfigurations')
local PathToAppFolder = config.pathToSDL .. SDLConfig:GetValue("AppStorageFolder") .. "/" .. tostring(config.application1.registerAppInterfaceParams.appID .. "_" .. tostring(config.deviceMAC) .. "/")

local testCasesForPerformAudioPassThru = {}

function testCasesForPerformAudioPassThru:Check_audioPassThruIcon_Existence(self)
  --print("PathToAppFolder = "..PathToAppFolder)
  local result = commonSteps:file_exists(PathToAppFolder .. "icon.png")
  if(result == true) then
    print("audioPassThruIcon exists at application's sandbox")
  else
    self:FailTestCase ("audioPassThruIcon does not exist at application's sandbox!")
  end
end

function testCasesForPerformAudioPassThru:ActivateAppDiffPolicyFlag(self, app_name, device_ID)

  local ServerAddress = "127.0.0.1"--commonSteps:get_data_from_SDL_ini("ServerAddress")

  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp",
    { appID = self.applications[app_name]})

  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,data)
      if(data.result.isSDLAllowed == false) then
        local RequestId1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
        --hmi side: expect SDL.GetUserFriendlyMessage message response
        EXPECT_HMIRESPONSE( RequestId1, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
        :Do(function(_,_)
            self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
              {allowed = true, source = "GUI", device = {id = device_ID, name = ServerAddress, isSDLAllowed = true}})
          end)
        EXPECT_HMICALL("BasicCommunication.ActivateApp")
        :Do(function() self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {}) end)
      end

    end)

  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
end

function testCasesForPerformAudioPassThru:PerformAudioPassThru_AllParameters_SUCCESS(self)
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
      samplingRate = "8KHZ",
      maxDuration = 2000,
      bitsPerSample = "8_BIT",
      audioType = "PCM",
      muteAudio = true,
      audioPassThruIcon =
      {
        { value = "icon.png",
          imageType = "STATIC"
        }

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
      muteAudio = true,
      audioPassThruIcon = { imageType = "STATIC", value = "icon.png"}

    })
  :Do(function(_,data)
      local function UIPerformAoudioResponce()
        self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
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

  self.mobileSession:ExpectResponse(CorIdPerformAudioPassThruAppParVD, { success = true, resultCode = "SUCCESS",
    })

  commonTestCases:DelayedExp(1500)

end

return testCasesForPerformAudioPassThru
