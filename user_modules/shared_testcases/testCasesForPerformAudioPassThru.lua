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
  local result1 = commonSteps:file_exists(PathToAppFolder .. string.rep ("a", 251).. ".png")
  local result2 = commonSteps:file_exists(PathToAppFolder .. "")
  if(result == true) then
    print("The audioPassThruIcon exists at application's sandbox")
  elseif (result1 == true) then
    print("The audioPassThruIcon exists at application's sandbox")
  elseif (result2 == true) then
    print("The audioPassThruIcon exists at application's sandbox")
  else
    self:FailTestCase ("The audioPassThruIcon does not exist at application's sandbox!")
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
      samplingRate = "16KHZ",
      maxDuration = 2000,
      bitsPerSample = "8_BIT",
      audioType = "PCM",
      muteAudio = true,
      audioPassThruIcon =
      { value = "icon.png",
        imageType = "STATIC"
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

function testCasesForPerformAudioPassThru:PerformAudioPassThru_AllParameters_Upper_SUCCESS(self)
  local CorIdPerformAudioPassThruAppParVD= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      initialPrompt =
      {
        {
          text = string.rep("a", 500),
          type = "TEXT",
        }
      },
      audioPassThruDisplayText1 = string.rep("a", 500),
      audioPassThruDisplayText2 = string.rep("a", 500),
      samplingRate = "44KHZ",
      maxDuration = 1000000,
      bitsPerSample = "16_BIT",
      audioType = "PCM",
      muteAudio = true,
      audioPassThruIcon =
      { value = string.rep ("a", 251).. ".png",
        imageType = "STATIC"
      }
    })

  -- hmi expects TTS.Speak request
  EXPECT_HMICALL("TTS.Speak",
    {
      speakType = "AUDIO_PASS_THRU",
      ttsChunks = { { text = string.rep("a", 500), type = "TEXT" } },
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
        {fieldName = "audioPassThruDisplayText1", fieldText = string.rep("a", 500)},
        {fieldName = "audioPassThruDisplayText2", fieldText = string.rep("a", 500)},
      },
      maxDuration = 1000000,
      muteAudio = true,
      audioPassThruIcon = { imageType = "STATIC", value = string.rep ("a", 251).. ".png"}

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

function testCasesForPerformAudioPassThru:PerformAudioPassThru_AllParameters_Lower_SUCCESS(self)
  local CorIdPerformAudioPassThruAppParVD= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      initialPrompt =
      {
        {
          text = "",
          type = "TEXT",
        },

      },
      audioPassThruDisplayText1 = "1",
      audioPassThruDisplayText2 = "2",
      samplingRate = "8KHZ",
      maxDuration = 1,
      bitsPerSample = "8_BIT",
      audioType = "PCM",
      muteAudio = true,
      audioPassThruIcon =
      { value = "",
        imageType = "STATIC"
      }
    })

  -- hmi expects TTS.Speak request
  EXPECT_HMICALL("TTS.Speak",
    {
      speakType = "AUDIO_PASS_THRU",
      ttsChunks = { { text = "", type = "TEXT" } },
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
        {fieldName = "audioPassThruDisplayText1", fieldText = "1"},
        {fieldName = "audioPassThruDisplayText2", fieldText = "2"},
      },
      maxDuration = 1,
      muteAudio = true,
      audioPassThruIcon = { imageType = "STATIC", value = ""}

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

function testCasesForPerformAudioPassThru:PerformAudioPassThru_MandatoryParameters_audioPassThruIcon_SUCCESS(self)
  local CorIdPerfAudioPassThruOnlyMandatoryVD= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      samplingRate = "22KHZ",
      maxDuration = 500500,
      bitsPerSample = "16_BIT",
      audioType = "PCM",
      audioPassThruIcon =
      { value = "icon.png",
        imageType = "STATIC"
      }
    })

  -- hmi expects UI.PerformAudioPassThru request
  EXPECT_HMICALL("UI.PerformAudioPassThru",
    {
      appID = self.applications[applicationName],
      audioPassThruDisplayTexts = {
        {fieldName = "audioPassThruDisplayText1", fieldText = ""},
        {fieldName = "audioPassThruDisplayText2", fieldText = ""},
      },
      maxDuration = 500500,
      muteAudio = true,
      audioPassThruIcon = { imageType = "STATIC", value = "icon.png"}

    })
  :Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
    end)

  self.mobileSession:ExpectResponse(CorIdPerfAudioPassThruOnlyMandatoryVD, { success = true, resultCode = "SUCCESS",
    })

end

function testCasesForPerformAudioPassThru:PerformAudioPassThru_Diff_Speech_Capabilities(self, ttsChunksType_value)
  local ttsChunksType_array = {
    {text = "4025",type = "PRE_RECORDED"},
    {text = "Sapi",type = "SAPI_PHONEMES"},
    {text = "LHplus", type = "LHPLUS_PHONEMES"},
    {text = "Silence", type = "SILENCE"}
  }
  local ttsChunksType = {}
	
	for i = 1, #ttsChunksType_array do
	    -- print (ttsChunksType_array[i].type)
	    if(ttsChunksType_array[i].type == ttsChunksType_value) then
	      --print("IN"..i)
	      ttsChunksType = ttsChunksType_array[i]
	    end
	  end
  
  --print(ttsChunksType.type, ttsChunksType.text)

  if ( (ttsChunksType.type == "PRE_RECORDED") or
    (ttsChunksType.type == "SAPI_PHONEMES") or
    (ttsChunksType.type == "LHPLUS_PHONEMES") or
    (ttsChunksType.type == "SILENCE")
  )
  then
  --print ("IN")
    local CorIdPerformAudioPassThruSpeechCap = self.mobileSession:SendRPC("PerformAudioPassThru",
      {
        initialPrompt = {
				          {
				            text = ttsChunksType.text,
				            type = ttsChunksType.type
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
	        { value = "icon.png",
	          imageType = "STATIC"
	        }

      })

    --hmi side: expect for TTS.Speak
    EXPECT_HMICALL("TTS.Speak",
      {
        ttsChunks =
        {

          {
            text = ttsChunksType.text,
            type = ttsChunksType.type
          },
        }

      })
    :Do(function(_,data)

        self.hmiConnection:SendResponse(data.id, "TTS.Speak", "UNSUPPORTED_RESOURCE", { })

      end)

    --hmi side: expect for UI.PerformAudioPassThru
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
        self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
      end)

    self.mobileSession:ExpectResponse(CorIdPerformAudioPassThruSpeechCap, { success = true, resultCode = "WARNINGS"})
  else 
  	print ("Unexpected TTS.Chunks type")
  end
end

function testCasesForPerformAudioPassThru:PerformAudioPassThru_DYNAMIC_image_SUCCESS_all(self)
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
      muteAudio = true,
      audioPassThruIcon = { imageType = "DYNAMIC", value = PathToAppFolder .."icon.png"}

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

function testCasesForPerformAudioPassThru:PerformAudioPassThru_DYNAMIC_image_MandatoryParameters_audioPassThruIcon_SUCCESS(self)
  local CorIdPerfAudioPassThruOnlyMandatoryVD= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      samplingRate = "22KHZ",
      maxDuration = 500500,
      bitsPerSample = "16_BIT",
      audioType = "PCM",
      audioPassThruIcon =
      { value = "icon.png",
        imageType = "DYNAMIC"
      }
    })

  -- hmi expects UI.PerformAudioPassThru request
  EXPECT_HMICALL("UI.PerformAudioPassThru",
    {
      appID = self.applications[applicationName],
      audioPassThruDisplayTexts = {
        {fieldName = "audioPassThruDisplayText1", fieldText = ""},
        {fieldName = "audioPassThruDisplayText2", fieldText = ""},
      },
      maxDuration = 500500,
      muteAudio = true,
      audioPassThruIcon = { imageType = "DYNAMIC",value = PathToAppFolder .."icon.png"}

    })
  :Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
    end)

  self.mobileSession:ExpectResponse(CorIdPerfAudioPassThruOnlyMandatoryVD, { success = true, resultCode = "SUCCESS",
    })

end
return testCasesForPerformAudioPassThru
