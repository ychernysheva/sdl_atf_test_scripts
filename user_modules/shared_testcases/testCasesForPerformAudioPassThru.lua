--This script contains common functions that are used in CRQs:
-- [GENIVI] PerformAudioPassThru: SDL must support new "audioPassThruIcon" parameter
--How to use:
--1. local testCasesForPerformAudioPassThru = require('user_modules/shared_testcases/testCasesForPerformAudioPassThru')

local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local applicationName = config.application1.registerAppInterfaceParams.appName
local SDLConfig = require ('user_modules/shared_testcases/SmartDeviceLinkConfigurations')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local config_path_sdl = commonPreconditions:GetPathToSDL()
local PathToAppFolder = config_path_sdl .. SDLConfig:GetValue("AppStorageFolder") .. "/" .. tostring(config.application1.registerAppInterfaceParams.appID .. "_" .. tostring(config.deviceMAC) .. "/")
local storagePath = config_path_sdl .."storage/"

local testCasesForPerformAudioPassThru = {}

--[[@Check_audioPassThruIcon_Existence: check that file icon exists in storage folder
--! @parameters: icon
--! defines file that should exist in app storage folder.
--]]
function testCasesForPerformAudioPassThru.Check_audioPassThruIcon_Existence(self, icon)
  local result = commonSteps:file_exists(PathToAppFolder .. icon)
  
  if(result == true) then
    print("The audioPassThruIcon:"..icon.." exists at application's sandbox")
  else
  	print("The audioPassThruIcon:"..icon.." doesn't exist at application's sandbox")  	
    self:FailTestCase ("The audioPassThruIcon:"..icon.." doesn't exist at application's sandbox")
  end
end

--[[@Check_ActivateAppDiffPolicyFlag: check that application is allowed by policy and activate it 
--! @parameters: 
--! app_name: name of application
--! device_ID - MAC address of device, usually config.deviceMAC 
--]]
function testCasesForPerformAudioPassThru:ActivateAppDiffPolicyFlag(self, app_name, device_ID)

  local ServerAddress = commonFunctions:read_parameter_from_smart_device_link_ini("ServerAddress")

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
        :Do(function(_,data1) self.hmiConnection:SendResponse(data1.id,"BasicCommunication.ActivateApp", "SUCCESS", {}) end)
      end

    end)

  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
end

--[[@Check_PerformAudioPassThru_AllParameters_SUCCESS: check that result code SUCCESS is returned when all RPC parameters are sent and within bounds 
--! @parameters: NO
--]]
function testCasesForPerformAudioPassThru:PerformAudioPassThru_AllParameters_SUCCESS(self)
  local CorIdPerformAudioPassThruAppParVD= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      initialPrompt = {{text = "Makeyourchoice",type = "TEXT"}},
      audioPassThruDisplayText1 = "DisplayText1",
      audioPassThruDisplayText2 = "DisplayText2",
      samplingRate = "16KHZ",
      maxDuration = 2000,
      bitsPerSample = "8_BIT",
      audioType = "PCM",
      muteAudio = true,
      audioPassThruIcon =
	    { 
	      value = "icon.png",
	      imageType = "STATIC"
	    }
    })

  EXPECT_HMICALL("TTS.Speak",
    {
      speakType = "AUDIO_PASS_THRU",
      ttsChunks = {{text = "Makeyourchoice", type = "TEXT"}},
      appID = self.applications[config.application1.registerAppInterfaceParams.appName]
    })
  :Do(function(_,data)
      self.hmiConnection:SendNotification("TTS.Started",{})
      
      local function ttsSpeakResponse()
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
        self.hmiConnection:SendNotification("TTS.Stopped")
      end
      RUN_AFTER(ttsSpeakResponse, 1000)
  end)

  EXPECT_HMICALL("UI.PerformAudioPassThru",
    {
      appID = self.applications[config.application1.registerAppInterfaceParams.appName],
      audioPassThruDisplayTexts = {
        {fieldName = "audioPassThruDisplayText1", fieldText = "DisplayText1"},
        {fieldName = "audioPassThruDisplayText2", fieldText = "DisplayText2"},
      },
      maxDuration = 2000,
      muteAudio = true,
      audioPassThruIcon = 
      { 
        imageType = "STATIC", 
        value = "icon.png"
      }
    })
  :Do(function(_,data)
      
      local function UIPerformAudioResponse()
        self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
      end
      RUN_AFTER(UIPerformAudioResponse, 1500)
  end)
  
  if
	  (self.appHMITypes["NAVIGATION"] == true) or
	  (self.appHMITypes["COMMUNICATION"] == true) or
	  (self.isMediaApplication == true) then

	  EXPECT_NOTIFICATION("OnHMIStatus",
      {hmiLevel = "FULL", audioStreamingState = "ATTENUATED", systemContext = "MAIN"},
      {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
    :Times(2)
  else
    EXPECT_NOTIFICATION("OnHMIStatus"):Times(0)
  end

  self.mobileSession:ExpectResponse(CorIdPerformAudioPassThruAppParVD, {success = true, resultCode = "SUCCESS"})
  EXPECT_NOTIFICATION("OnHashChange"):Times(0)

  commonTestCases:DelayedExp(1500)
end

--[[@Check_PerformAudioPassThru_AllParameters_Upper_SUCCESS: check that result code SUCCESS is returned when all RPC parameters are sent and within upper bound
--! @parameters: NO
--]]
function testCasesForPerformAudioPassThru:PerformAudioPassThru_AllParameters_Upper_SUCCESS(self)
  local CorIdPerformAudioPassThruAppUpperParVD= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      initialPrompt = {{text = string.rep("a", 500), type = "TEXT"}},
      audioPassThruDisplayText1 = string.rep("a", 500),
      audioPassThruDisplayText2 = string.rep("a", 500),
      samplingRate = "44KHZ",
      maxDuration = 1000000,
      bitsPerSample = "16_BIT",
      audioType = "PCM",
      muteAudio = true,
      audioPassThruIcon =
      { 
        value = string.rep ("a", 251).. ".png",
        imageType = "STATIC"
      }
    })

  EXPECT_HMICALL("TTS.Speak",
    {
      speakType = "AUDIO_PASS_THRU",
      ttsChunks = {{text = string.rep("a", 500), type = "TEXT"}},
      appID = self.applications[config.application1.registerAppInterfaceParams.appName]
    })
  :Do(function(_,data)
      self.hmiConnection:SendNotification("TTS.Started",{})

      local function ttsSpeakResponse()
        self.hmiConnection:SendResponse (data.id, data.method, "SUCCESS", {})
        self.hmiConnection:SendNotification("TTS.Stopped")
      end
      RUN_AFTER(ttsSpeakResponse, 1000)
   end)

  EXPECT_HMICALL("UI.PerformAudioPassThru",
    {
      appID = self.applications[config.application1.registerAppInterfaceParams.appName],
      audioPassThruDisplayTexts = {
        {fieldName = "audioPassThruDisplayText1", fieldText = string.rep("a", 500)},
        {fieldName = "audioPassThruDisplayText2", fieldText = string.rep("a", 500)},
      },
      maxDuration = 1000000,
      muteAudio = true,
      audioPassThruIcon = 
      { 
        imageType = "STATIC", 
        value = string.rep ("a", 251).. ".png"
  	  }
    })
  :Do(function(_,data)

      local function UIPerformAudioResponse()
        self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
      end
      RUN_AFTER(UIPerformAudioResponse, 1500)
  end)

  if
  (self.appHMITypes["NAVIGATION"] == true) or
  (self.appHMITypes["COMMUNICATION"] == true) or
  (self.isMediaApplication == true) then

    EXPECT_NOTIFICATION("OnHMIStatus",
      {hmiLevel = "FULL", audioStreamingState = "ATTENUATED", systemContext = "MAIN"},
      {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
    :Times(2)
  else
    EXPECT_NOTIFICATION("OnHMIStatus"):Times(0)
  end

  self.mobileSession:ExpectResponse(CorIdPerformAudioPassThruAppUpperParVD, {success = true, resultCode = "SUCCESS"})
  EXPECT_NOTIFICATION("OnHashChange"):Times(0)

  commonTestCases:DelayedExp(1500)

end

--[[@Check_PerformAudioPassThru_AllParameters_Lower_SUCCESS: check that result code SUCCESS is returned when all RPC parameters are sent and within lower bound
--! @parameters: NO
--]]
function testCasesForPerformAudioPassThru:PerformAudioPassThru_AllParameters_Lower_SUCCESS(self)
  local CorIdPerformAudioPassThruAppLowerPar= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      initialPrompt = {{text = "A", type = "TEXT"}},
      audioPassThruDisplayText1 = "1",
      audioPassThruDisplayText2 = "2",
      samplingRate = "8KHZ",
      maxDuration = 1,
      bitsPerSample = "8_BIT",
      audioType = "PCM",
      muteAudio = true,
      audioPassThruIcon =
      { value = "1",
        imageType = "STATIC"
      }
    })

  EXPECT_HMICALL("TTS.Speak",
    {
      speakType = "AUDIO_PASS_THRU",
      ttsChunks = {{text = "A", type = "TEXT"}},
      appID = self.applications[config.application1.registerAppInterfaceParams.appName]
    })
  :Do(function(_,data)
      self.hmiConnection:SendNotification("TTS.Started",{})

      local function ttsSpeakResponse()
        self.hmiConnection:SendResponse (data.id, data.method, "SUCCESS", {})
        self.hmiConnection:SendNotification("TTS.Stopped")
      end
      RUN_AFTER(ttsSpeakResponse, 1000)
  end)

  EXPECT_HMICALL("UI.PerformAudioPassThru",
    {
      appID = self.applications[config.application1.registerAppInterfaceParams.appName],
      audioPassThruDisplayTexts = {
        {fieldName = "audioPassThruDisplayText1", fieldText = "1"},
        {fieldName = "audioPassThruDisplayText2", fieldText = "2"},
      },
      maxDuration = 1,
      muteAudio = true,
      audioPassThruIcon = 
      { 
        imageType = "STATIC", 
        value = "1"
      }
    })
  :Do(function(_,data)
      
      local function UIPerformAudioResponse()
        self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
      end
      RUN_AFTER(UIPerformAudioResponse, 1500)
    end)

  if
  (self.appHMITypes["NAVIGATION"] == true) or
  (self.appHMITypes["COMMUNICATION"] == true) or
  (self.isMediaApplication == true) then

    EXPECT_NOTIFICATION("OnHMIStatus",
      {hmiLevel = "FULL", audioStreamingState = "ATTENUATED", systemContext = "MAIN"},
      {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
    :Times(2)
  else
    EXPECT_NOTIFICATION("OnHMIStatus"):Times(0)
  end

  self.mobileSession:ExpectResponse(CorIdPerformAudioPassThruAppLowerPar, {success = true, resultCode = "SUCCESS"})
  EXPECT_NOTIFICATION("OnHashChange"):Times(0)

  commonTestCases:DelayedExp(1500)
end

--[[@Check_PerformAudioPassThru_MandatoryParameters_audioPassThruIcon_SUCCESS: check that result code SUCCESS is returned when mandatory RPC parameters are sent and within bounds together with audioPassThruIcon
--! @parameters: NO
--]]
function testCasesForPerformAudioPassThru:PerformAudioPassThru_MandatoryParameters_audioPassThruIcon_SUCCESS(self)
  local CorIdPerfAudioPassThruOnlyMandatoryVD= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      samplingRate = "22KHZ",
      maxDuration = 500500,
      bitsPerSample = "16_BIT",
      audioType = "PCM",
      audioPassThruIcon =
      { 
        value = "icon.png",
        imageType = "STATIC"
      }
    })

  EXPECT_HMICALL("UI.PerformAudioPassThru",
    {
      appID = self.applications[config.application1.registerAppInterfaceParams.appName],
      maxDuration = 500500,
      muteAudio = true,
      audioPassThruIcon = 
      { 
        value = "icon.png",
        imageType = "STATIC"      
  	  }
    })
  :Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
    end)

  EXPECT_HMICALL("TTS.Speak"):Times(0)
  self.mobileSession:ExpectResponse(CorIdPerfAudioPassThruOnlyMandatoryVD, {success = true, resultCode = "SUCCESS"})
	EXPECT_NOTIFICATION("OnHashChange"):Times(0)
end

--[[@Check_PerformAudioPassThru_Diff_Speech_Capabilities: check that result code WARNINGS is returned when RPC parameters are sent and within bounds but ttsChunksType is not TEXT
--! @parameters: NO
--]]
function testCasesForPerformAudioPassThru:PerformAudioPassThru_Diff_Speech_Capabilities(self, ttsChunksType_value)
  local ttsChunksType_array = {
    {text = "4025",type = "PRE_RECORDED"},
    {text = "Sapi",type = "SAPI_PHONEMES"},
    {text = "LHplus", type = "LHPLUS_PHONEMES"},
    {text = "Silence", type = "SILENCE"}
  }
  local ttsChunksType = {}
	
	for i = 1, #ttsChunksType_array do
	    if(ttsChunksType_array[i].type == ttsChunksType_value) then
	      ttsChunksType = ttsChunksType_array[i]
	    end
	  end
  
  if ( 
        (ttsChunksType.type == "PRE_RECORDED") or
        (ttsChunksType.type == "SAPI_PHONEMES") or
        (ttsChunksType.type == "LHPLUS_PHONEMES") or
        (ttsChunksType.type == "SILENCE")
     )
  then
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

    EXPECT_HMICALL("UI.PerformAudioPassThru",
      {
        appID = self.applications[applicationName],
        audioPassThruDisplayTexts = {
          {fieldName = "audioPassThruDisplayText1", fieldText = "DisplayText1"},
          {fieldName = "audioPassThruDisplayText2", fieldText = "DisplayText2"},
        },
        maxDuration = 2000,
        muteAudio = true,
        audioPassThruIcon = {imageType = "STATIC", value = "icon.png"}
      })
    :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
      end)

    self.mobileSession:ExpectResponse(CorIdPerformAudioPassThruSpeechCap, { success = true, resultCode = "WARNINGS"})
  else 
  	print ("Unexpected TTS.Chunks type")
  end
  EXPECT_NOTIFICATION("OnHashChange"):Times(0)
end

--[[@Check_PerformAudioPassThru_DYNAMIC_image_SUCCESS_all: check that result code SUCCESS is returned when all RPC parameters are sent and within bounds and image type = DYNAMIC
--! @parameters: ttsChunksType_value
--]]
function testCasesForPerformAudioPassThru:PerformAudioPassThru_DYNAMIC_image_SUCCESS_all(self)
  local CorIdPerformAudioPassThruAppParALLDynamic= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      initialPrompt = {{text = "Makeyourchoice",type = "TEXT"}},
      audioPassThruDisplayText1 = "DisplayText1",
      audioPassThruDisplayText2 = "DisplayText2",
      samplingRate = "16KHZ",
      maxDuration = 2000,
      bitsPerSample = "8_BIT",
      audioType = "PCM",
      muteAudio = true,
      audioPassThruIcon =
      { 
        value = "icon.png",
        imageType = "DYNAMIC"
      }
    })

  EXPECT_HMICALL("TTS.Speak",
    {
      speakType = "AUDIO_PASS_THRU",
      ttsChunks = {{ text = "Makeyourchoice", type = "TEXT"}},
      appID = self.applications[config.application1.registerAppInterfaceParams.appName]
    })
  :Do(function(_,data)
      self.hmiConnection:SendNotification("TTS.Started",{})
      local function ttsSpeakResponse()
        self.hmiConnection:SendResponse (data.id, data.method, "SUCCESS", {})
        self.hmiConnection:SendNotification("TTS.Stopped")
      end
      RUN_AFTER(ttsSpeakResponse, 1000)
    end)

  EXPECT_HMICALL("UI.PerformAudioPassThru",
    {
      appID = self.applications[config.application1.registerAppInterfaceParams.appName],
      audioPassThruDisplayTexts = {
        {fieldName = "audioPassThruDisplayText1", fieldText = "DisplayText1"},
        {fieldName = "audioPassThruDisplayText2", fieldText = "DisplayText2"},
      },
      maxDuration = 2000,
      muteAudio = true
    })
  :Do(function(_,data)
      local function UIPerformAudioResponse()
        self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
      end
      RUN_AFTER(UIPerformAudioResponse, 1500)
    end)
   :ValidIf (function(_,data2)
    	if(data2.params.audioPassThruIcon ~= nil) then
		  	if (string.match(data2.params.audioPassThruIcon.value, "%S*" .. "("..string.sub(storagePath, 2).."icon.png)" .. "$") == nil ) then
					print("\27[31m Invalid path to DYNAMIC image\27[0m")
					return false 
				else 
					return true
				end
			else
				print("\27[31m The audioPassThruIcon is nil \27[0m")
				return false 
			end
		end)
  if
  (self.appHMITypes["NAVIGATION"]) == true or
  (self.appHMITypes["COMMUNICATION"]) == true or
  (self.isMediaApplication) == true then

    EXPECT_NOTIFICATION("OnHMIStatus",
      {hmiLevel = "FULL", audioStreamingState = "ATTENUATED", systemContext = "MAIN"},
      {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
    :Times(2)
  else
    EXPECT_NOTIFICATION("OnHMIStatus"):Times(0)
  end

  self.mobileSession:ExpectResponse(CorIdPerformAudioPassThruAppParALLDynamic, { success = true, resultCode = "SUCCESS"})
  EXPECT_NOTIFICATION("OnHashChange"):Times(0)

  commonTestCases:DelayedExp(1500)
end

--[[@Check_PerformAudioPassThru_MandatoryParameters_audioPassThruIcon_SUCCESS: check that result code SUCCESS is returned when mandatory RPC parameters are sent and within bounds together with audioPassThruIcon with image type = DYNAMIC
--! @parameters: NO
--]]
function testCasesForPerformAudioPassThru:PerformAudioPassThru_DYNAMIC_image_MandatoryParameters_audioPassThruIcon_SUCCESS(self)
  local CorIdPerfAudioPassThruOnlyMandatoryDYNAMIC= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      samplingRate = "22KHZ",
      maxDuration = 500500,
      bitsPerSample = "16_BIT",
      audioType = "PCM",
      audioPassThruIcon =
      { 
        value = "icon.png",
        imageType = "DYNAMIC"
      }
    })

  EXPECT_HMICALL("UI.PerformAudioPassThru",
    {
      appID = self.applications[config.application1.registerAppInterfaceParams.appName],
      maxDuration = 500500,
      muteAudio = true,
    })
  :Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, "UI.PerformAudioPassThru", "SUCCESS", {})
    end)
   :ValidIf (function(_,data3)
      if(data3.params.audioPassThruIcon ~= nil) then
        if (string.match(data3.params.audioPassThruIcon.value, "%S*" .. "("..string.sub(storagePath, 2).."icon.png)" .. "$") == nil ) then
          print("\27[31m Invalid path to DYNAMIC image\27[0m")
          return false 
        else 
          return true
        end
      else
        print("\27[31m The audioPassThruIcon is nil \27[0m")
        return false 
      end
    end)

  EXPECT_HMICALL("TTS.Speak"):Times(0)
  self.mobileSession:ExpectResponse(CorIdPerfAudioPassThruOnlyMandatoryDYNAMIC, {success = true, resultCode = "SUCCESS"})
	EXPECT_NOTIFICATION("OnHashChange"):Times(0)
end

return testCasesForPerformAudioPassThru

