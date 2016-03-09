Test = require('user_modules/connecttest_Button_Capabilities')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local config = require('config')
local module = require('testbase')

---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local policyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local integerParameter = require('user_modules/shared_testcases/testCasesForIntegerParameter')
local stringParameter = require('user_modules/shared_testcases/testCasesForStringParameter')
local arrayStringParameter = require('user_modules/shared_testcases/testCasesForArrayStringParameter')
local integerParameterInResponse = require('user_modules/shared_testcases/testCasesForIntegerParameterInResponse')
require('user_modules/AppTypes')



---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------
	
	--1. Activate application
	--commonSteps:ActivationApp()

	
	
local function button_capability(name, shortPressAvailable, longPressAvailable, upDownAvailable)

	--xmlReporter.AddMessage(debug.getinfo(1, "n").name, tostring(name))
	
	return
	{
		name = name,
		shortPressAvailable = shortPressAvailable == nil and true or shortPressAvailable,
		longPressAvailable = longPressAvailable == nil and true or longPressAvailable,
		upDownAvailable = upDownAvailable == nil and true or upDownAvailable
	}
end

local buttons_capabilities =
{
	capabilities =
		{
			--button_capability("PRESET_0"),
			--button_capability("PRESET_1"),
			--button_capability("PRESET_2"),
			button_capability("PRESET_3"),
			button_capability("PRESET_4"),
			button_capability("PRESET_5"),
			button_capability("PRESET_6"),
			button_capability("PRESET_7"),
			button_capability("PRESET_8"),
			button_capability("PRESET_9"),
			button_capability("OK", true, false, true),
			button_capability("SEEKLEFT"),
			button_capability("SEEKRIGHT"),
			button_capability("TUNEUP"),
			button_capability("TUNEDOWNxxxxxxxxxxxxxxxxxxxxxxx")
		},
	presetBankCapabilities = { onScreenPresetsAvailable = true }
}


---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
	
	
	
 function Test:initHMI_onReady1(buttons_capabilities)
    critical(true)
    local function ExpectRequest(name, mandatory, params)
      xmlReporter.AddMessage(debug.getinfo(1, "n").name, tostring(name))
      local event = events.Event()
      event.level = 2
      event.matches = function(self, data) return data.method == name end
      return
      EXPECT_HMIEVENT(event, name)
      :Times(mandatory and 1 or AnyNumber())
      :Do(function(_, data)
          self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", params)
        end)
    end

    local function ExpectNotification(name, mandatory)
      xmlReporter.AddMessage(debug.getinfo(1, "n").name, tostring(name))
      local event = events.Event()
      event.level = 2
      event.matches = function(self, data) return data.method == name end
      return
      EXPECT_HMIEVENT(event, name)
      :Times(mandatory and 1 or AnyNumber())
    end

    ExpectRequest("BasicCommunication.MixingAudioSupported",
      true,
      { attenuatedSupported = true })
    ExpectRequest("BasicCommunication.GetSystemInfo", false,
      {
        ccpu_version = "ccpu_version",
        language = "EN-US",
        wersCountryCode = "wersCountryCode"
      })
    ExpectRequest("UI.GetLanguage", true, { language = "EN-US" })
    ExpectRequest("VR.GetLanguage", true, { language = "EN-US" })
    ExpectRequest("TTS.GetLanguage", true, { language = "EN-US" })
    ExpectRequest("UI.ChangeRegistration", false, { }):Pin()
    ExpectRequest("TTS.SetGlobalProperties", false, { }):Pin()
    ExpectRequest("BasicCommunication.UpdateDeviceList", false, { }):Pin()
    ExpectRequest("VR.ChangeRegistration", false, { }):Pin()
    ExpectRequest("TTS.ChangeRegistration", false, { }):Pin()
    ExpectRequest("VR.GetSupportedLanguages", true, {
        languages =
        {
          "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU","TR-TR","PL-PL",
          "FR-FR","IT-IT","SV-SE","PT-PT","NL-NL","ZH-TW","JA-JP","AR-SA","KO-KR",
          "PT-BR","CS-CZ","DA-DK","NO-NO"
        }
      })
    ExpectRequest("TTS.GetSupportedLanguages", true, {
        languages =
        {
          "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU","TR-TR","PL-PL",
          "FR-FR","IT-IT","SV-SE","PT-PT","NL-NL","ZH-TW","JA-JP","AR-SA","KO-KR",
          "PT-BR","CS-CZ","DA-DK","NO-NO"
        }
      })
    ExpectRequest("UI.GetSupportedLanguages", true, {
        languages =
        {
          "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU","TR-TR","PL-PL",
          "FR-FR","IT-IT","SV-SE","PT-PT","NL-NL","ZH-TW","JA-JP","AR-SA","KO-KR",
          "PT-BR","CS-CZ","DA-DK","NO-NO"
        }
      })
    ExpectRequest("VehicleInfo.GetVehicleType", true, {
        vehicleType =
        {
          make = "Ford",
          model = "Fiesta",
          modelYear = "2013",
          trim = "SE"
        }
      })
    ExpectRequest("VehicleInfo.GetVehicleData", true, { vin = "52-452-52-752" })

  
	ExpectRequest("Buttons.GetCapabilities", true, buttons_capabilities)
	
    ExpectRequest("VR.GetCapabilities", true, { vrCapabilities = { "TEXT" } })
    ExpectRequest("TTS.GetCapabilities", true, {
        speechCapabilities = { "TEXT", "PRE_RECORDED" },
        prerecordedSpeechCapabilities =
        {
          "HELP_JINGLE",
          "INITIAL_JINGLE",
          "LISTEN_JINGLE",
          "POSITIVE_JINGLE",
          "NEGATIVE_JINGLE"
        }
      })

    local function text_field(name, characterSet, width, rows)
      xmlReporter.AddMessage(debug.getinfo(1, "n").name, tostring(name))
      return
      {
        name = name,
        characterSet = characterSet or "TYPE2SET",
        width = width or 500,
        rows = rows or 1
      }
    end
    local function image_field(name, width, heigth)
      xmlReporter.AddMessage(debug.getinfo(1, "n").name, tostring(name))
      return
      {
        name = name,
        imageTypeSupported =
        {
          "GRAPHIC_BMP",
          "GRAPHIC_JPEG",
          "GRAPHIC_PNG"
        },
        imageResolution =
        {
          resolutionWidth = width or 64,
          resolutionHeight = height or 64
        }
      }

    end

    ExpectRequest("UI.GetCapabilities", true, {
        displayCapabilities =
        {
          displayType = "GEN2_8_DMA",
          textFields =
          {
            text_field("mainField1"),
            text_field("mainField2"),
            text_field("mainField3"),
            text_field("mainField4"),
            text_field("statusBar"),
            text_field("mediaClock"),
            text_field("mediaTrack"),
            text_field("alertText1"),
            text_field("alertText2"),
            text_field("alertText3"),
            text_field("scrollableMessageBody"),
            text_field("initialInteractionText"),
            text_field("navigationText1"),
            text_field("navigationText2"),
            text_field("ETA"),
            text_field("totalDistance"),
            text_field("navigationText"),
            text_field("audioPassThruDisplayText1"),
            text_field("audioPassThruDisplayText2"),
            text_field("sliderHeader"),
            text_field("sliderFooter"),
            text_field("notificationText"),
            text_field("menuName"),
            text_field("secondaryText"),
            text_field("tertiaryText"),
            text_field("timeToDestination"),
            text_field("turnText"),
            text_field("menuTitle")
          },
          imageFields =
          {
            image_field("softButtonImage"),
            image_field("choiceImage"),
            image_field("choiceSecondaryImage"),
            image_field("vrHelpItem"),
            image_field("turnIcon"),
            image_field("menuIcon"),
            image_field("cmdIcon"),
            image_field("showConstantTBTIcon"),
            image_field("showConstantTBTNextTurnIcon")
          },
          mediaClockFormats =
          {
            "CLOCK1",
            "CLOCK2",
            "CLOCK3",
            "CLOCKTEXT1",
            "CLOCKTEXT2",
            "CLOCKTEXT3",
            "CLOCKTEXT4"
          },
          graphicSupported = true,
          imageCapabilities = { "DYNAMIC", "STATIC" },
          templatesAvailable = { "TEMPLATE" },
          screenParams =
          {
            resolution = { resolutionWidth = 800, resolutionHeight = 480 },
            touchEventAvailable =
            {
              pressAvailable = true,
              multiTouchAvailable = true,
              doublePressAvailable = false
            }
          },
          numCustomPresetsAvailable = 10
        },
        audioPassThruCapabilities =
        {
          samplingRate = "44KHZ",
          bitsPerSample = "8_BIT",
          audioType = "PCM"
        },
        hmiZoneCapabilities = "FRONT",
        softButtonCapabilities =
        {
          shortPressAvailable = true,
          longPressAvailable = true,
          upDownAvailable = true,
          imageSupported = true
        }
      })

    ExpectRequest("VR.IsReady", true, { available = true })
    ExpectRequest("TTS.IsReady", true, { available = true })
    ExpectRequest("UI.IsReady", true, { available = true })
    ExpectRequest("Navigation.IsReady", true, { available = true })
    ExpectRequest("VehicleInfo.IsReady", true, { available = true })

    self.applications = { }
    ExpectRequest("BasicCommunication.UpdateAppList", false, { })
    :Pin()
    :Do(function(_, data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { })
        self.applications = { }
        for _, app in pairs(data.params.applications) do
          self.applications[app.appName] = app.appID
        end
      end)

    self.hmiConnection:SendNotification("BasicCommunication.OnReady")
  end
  


function Test:startMobile()
  return self:StartService(7)
  :Do(function()
      -- Heartbeat
      if self.version > 2 then
        local event = events.Event()
        event.matches = function(s, data)
          return data.frameType == constants.FRAME_TYPE.CONTROL_FRAME and
          data.serviceType == constants.SERVICE_TYPE.CONTROL and
          data.frameInfo == constants.FRAME_INFO.HEARTBEAT and
          self.sessionId == data.sessionId
        end
        self:ExpectEvent(event, "Heartbeat")
        :Pin()
        :Times(AnyNumber())
        :Do(function(data)
            if self.heartbeatEnabled and self.answerHeartbeatFromSDL then
              self:Send( { frameType = constants.FRAME_TYPE.CONTROL_FRAME,
                  serviceType = constants.SERVICE_TYPE.CONTROL,
                  frameInfo = constants.FRAME_INFO.HEARTBEAT_ACK } )
            end
          end)

        local d = qt.dynamic()
        self.heartbeatToSDLTimer = timers.Timer()
        self.heartbeatFromSDLTimer = timers.Timer()

        function d.SendHeartbeat()
          if self.heartbeatEnabled and self.sendHeartbeatToSDL then
            self:Send( { frameType = constants.FRAME_TYPE.CONTROL_FRAME,
                serviceType = constants.SERVICE_TYPE.CONTROL,
                frameInfo = constants.FRAME_INFO.HEARTBEAT } )
            self.heartbeatFromSDLTimer:reset()
          end
        end

        function d.CloseSession()
          if self.heartbeatEnabled then
            self:StopService(7)
            self.test:FailTestCase("SDL didn't send anything for " .. self.heartbeatFromSDLTimer:interval()
              .. " msecs. Closing session # " .. self.sessionId)
          end
        end

        self.connection:OnInputData(function(_, msg)
            if self.sessionId ~= msg.sessionId then return end
            xmlReporter:LOG("SDLtoMOB", msg)
            if self.heartbeatEnabled then
                if msg.frameType == constants.FRAME_TYPE.CONTROL_FRAME and
                   msg.frameInfo == constants.FRAME_INFO.HEARTBEAT_ACK and
                   self.ignoreHeartBeatAck then
                    return
                end
                self.heartbeatFromSDLTimer:reset()
            end
          end)
        self.connection:OnMessageSent(function(sessionId)
            if self.heartbeatEnabled and self.sessionId == sessionId then
              self.heartbeatToSDLTimer:reset()
            end
          end)
        qt.connect(self.heartbeatToSDLTimer, "timeout()", d, "SendHeartbeat()")
        qt.connect(self.heartbeatFromSDLTimer, "timeout()", d, "CloseSession()")
        self:StartHeartbeat()
      end

      local correlationId = self:SendRPC("RegisterAppInterface", self.regAppParams)
      self:ExpectResponse(correlationId, { success = true })
    end)
end



function module:registerApp()
 
	commonFunctions:printTable(config.application1.registerAppInterfaceParams)
	
    local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
	EXPECT_RESPONSE(correlationId, { success = true })
	:Do(function(_,data)
			commonFunctions:printTable(data)
		end)	
 end
 
 
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------








 
function Test:InitHMI_onReady_Step2_HMISend_buttons_capabilities()
	
	--commonFunctions:printTable(buttons_capabilities)
	self:initHMI_onReady1(buttons_capabilities)
end


function Test:ConnectMobile_Step3()
  self:connectMobile()
end

function Test:StartSession_Step4_Mobile_start_Session()
  --self:startSession()
module:startSession_s1()


end


function Test:MobileRegisterApp()

	module:registerApp()	
end

function Test:HMI_UpdateAppList()

	module:basicCommunication_UpdateAppList()	
end