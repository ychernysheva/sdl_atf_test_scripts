config.defaultProtocolVersion = 2


---------------------------------------------------------------------------------------------
---------------------------- Required Shared libraries --------------------------------------
---------------------------------------------------------------------------------------------

local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

APIName = "VR.IsReady"
	
DefaultTimeout = 3
local iTimeout = 10000
local commonPreconditions = require ('/user_modules/shared_testcases/commonPreconditions')


---------------------------------------------------------------------------------------------
------------------------- General Precondition before ATF start -----------------------------
---------------------------------------------------------------------------------------------
--make backup copy of file sdl_preloaded_pt.json
commonPreconditions:BackupFile("sdl_preloaded_pt.json")
-- TODO: Remove after implementation policy update

-- TODO: Remove after implementation policy update
-- Precondition: replace preloaded file with new one
os.execute('cp ./files/ptu_general.json ' .. tostring(config.pathToSDL) .. "sdl_preloaded_pt.json")

-- Precondition for APPLINK-16307 WARNINGS, true: appID is assigned none empty appHMIType = { "NAVIGATION" }
local function update_sdl_preloaded_pt_json()
	pathToFile = config.pathToSDL .. 'sdl_preloaded_pt.json'
	local file  = io.open(pathToFile, "r")
	local json_data = file:read("*all") -- may be abbreviated to "*a";
	file:close()

	local json = require("modules/json")
	 
	local data = json.decode(json_data)
	for k,v in pairs(data.policy_table.functional_groupings) do
		if (data.policy_table.functional_groupings[k].rpcs == nil) then
			--do
			data.policy_table.functional_groupings[k] = nil
		else
			--do
			local count = 0
			for _ in pairs(data.policy_table.functional_groupings[k].rpcs) do count = count + 1 end
			if (count < 30) then
				--do
				data.policy_table.functional_groupings[k] = nil
			end
		end
	end

	data.policy_table.app_policies["0000001"].AppHMIType = {"NAVIGATION"}
	data = json.encode(data)
	file = io.open(pathToFile, "w")
	file:write(data)
	file:close()
end

--update_sdl_preloaded_pt_json()	
--Add AppHMIType = {"NAVIGATION"} for app "0000001"
--config.application1.registerAppInterfaceParams.AppHMIType = {"NAVIGATION"}


		
		

-- Precondition: remove policy table and log files
commonSteps:DeleteLogsFileAndPolicyTable()


---------------------------------------------------------------------------------------------
---------------------------- General Settings for configuration----------------------------
---------------------------------------------------------------------------------------------
Test = require('user_modules/connecttest_VR_Isready')

require('cardinalities')
local events = require('events')  
local mobile_session = require('mobile_session')
require('user_modules/AppTypes')


  
---------------------------------------------------------------------------------------------
-------------------------------------------Common function-----------------------------------
---------------------------------------------------------------------------------------------

--Cover APPLINK-25286: [HMI_API] VR.IsReady
function Test:initHMI_onReady_VR_IsReady(case)
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

		--APPLINK-25286: [HMI_API] VR.IsReady
		if (name == "VR.IsReady") then
	
			--On the view of JSON message, VR.IsReady response has colerationidID, code/resultCode, method and message parameters. Below are tests to verify all invalid cases of the response.
			
			--caseID 1-3: Check special cases
				--0. availabe_false
				--1. HMI_Does_Not_Repond
				--2. MissedAllParamaters
				--3. Invalid_Json

			if (case == 0) then -- responds {availabe = false}
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {availabe = false}) 
				
			elseif (case == 1) then -- does not respond
				--self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", params) 
				
			elseif (case == 2) then --MissedAllParamaters
				self.hmiConnection:Send('{}')
				
			elseif (case == 3) then --Invalid_Json
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')	
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc";"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')	
			
			--*****************************************************************************************************************************
			
			--caseID 11-14 are used to checking "collerationID" parameter
				--11. collerationID_IsMissed
				--12. collerationID_IsNonexistent
				--13. collerationID_IsWrongType
				--14. collerationID_IsNegative 	
				
			elseif (case == 11) then --collerationID_IsMissed
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  
			elseif (case == 12) then --collerationID_IsNonexistent
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id + 10)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  
			elseif (case == 13) then --collerationID_IsWrongType
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":"'..tostring(data.id)..'","jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  
			elseif (case == 14) then --collerationID_IsNegative
				self.hmiConnection:Send('{"id":'..tostring(-1)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
			
			--*****************************************************************************************************************************
			
			--caseID 21-27 are used to checking "method" parameter
				--21. method_IsMissed
				--22. method_IsNotValid
				--23. method_IsOtherResponse
				--24. method_IsEmpty
				--25. method_IsWrongType
				--26. method_IsInvalidCharacter_Newline
				--27. method_IsInvalidCharacter_OnlySpaces
				--28. method_IsInvalidCharacter_Tab
				
			elseif (case == 21) then --method_IsMissed
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"code":0}}')

			elseif (case == 22) then --method_IsNotValid
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				 self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsRea", "code":0}}')				

			elseif (case == 23) then --method_IsOtherResponse
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				 self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"UI.IsReady", "code":0}}')			

			elseif (case == 24) then --method_IsEmpty
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				 self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"", "code":0}}')							 
			
			elseif (case == 25) then --method_IsWrongType
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":123456789, "code":0}}')
			
			elseif (case == 26) then --method_IsInvalidCharacter_Newline
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsR\neady", "code":0}}')
			
			elseif (case == 27) then --method_IsInvalidCharacter_OnlySpaces
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"  ", "code":0}}')
			
			elseif (case == 28) then --method_IsInvalidCharacter_Tab
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsRe\tady", "code":0}}')		
				  
			--*****************************************************************************************************************************
			
			--caseID 31-35 are used to checking "resultCode" parameter
				--31. resultCode_IsMissed
				--32. resultCode_IsNotExist
				--33. resultCode_IsWrongType
				--34. resultCode_INVALID_DATA (code = 11)
				--35. resultCode_DATA_NOT_AVAILABLE (code = 9)
				--36. resultCode_GENERIC_ERROR (code = 22)
				
			elseif (case == 31) then --resultCode_IsMissed
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady"}}')

			elseif (case == 32) then --resultCode_IsNotExist
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":123}}')

			elseif (case == 33) then --resultCode_IsWrongType
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":"0"}}')
			
			elseif (case == 34) then --resultCode_INVALID_DATA
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":11}}')
			
			elseif (case == 35) then --resultCode_DATA_NOT_AVAILABLE
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":9}}')
			
			elseif (case == 36) then --resultCode_GENERIC_ERROR
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":22}}')
			
			
			--*****************************************************************************************************************************
			
			--caseID 41-45 are used to checking "message" parameter
				--41. message_IsMissed
				--42. message_IsLowerBound
				--43. message_IsUpperBound
				--44. message_IsOutUpperBound
				--45. message_IsEmpty_IsOutLowerBound
				--46. message_IsWrongType
				--47. message_IsInvalidCharacter_Tab
				--48. message_IsInvalidCharacter_OnlySpaces
				--49. message_IsInvalidCharacter_Newline

			elseif (case == 41) then --message_IsMissed
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"The data sent is invalid","code":11}}')
				  
			elseif (case == 42) then --message_IsLowerBound
				local messageValue = "a"
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"' .. messageValue ..'","code":11}}')
							  
			elseif (case == 43) then --message_IsUpperBound
				local messageValue = string.rep("a", 1000)
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"' .. messageValue ..'","code":11}}')
			
			elseif (case == 44) then --message_IsOutUpperBound
				local messageValue = string.rep("a", 1001)
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"' .. messageValue ..'","code":11}}')

			elseif (case == 45) then --message_IsEmpty_IsOutLowerBound
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"","code":11}}')

			elseif (case == 46) then --message_IsWrongType
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":123,"code":11}}')
				  
			elseif (case == 47) then --message_IsInvalidCharacter_Tab
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"a\tb","code":11}}')

			elseif (case == 48) then --message_IsInvalidCharacter_OnlySpaces
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"  ","code":11}}')

			elseif (case == 49) then --message_IsInvalidCharacter_Newline
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"VR.IsReady"}, "message":"a\n\b","code":11}}')

			--*****************************************************************************************************************************

			--caseID 51-55 are used to checking "available" parameter
				--51. available_IsMissed
				--52. available_IsWrongType

			elseif (case == 51) then --available_IsMissed
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"VR.IsReady", "code":"0"}}')
	  
			elseif (case == 52) then --available_IsWrongType
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"VR.IsReady", "code":0}}')
				  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":"true","method":"VR.IsReady", "code":"0"}}')

			else
				print("***************************Error: VR.IsReady: Input value is not correct ***************************")
			end

		
		else
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", params) 			
		end

		
		
      end)
	  
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
	:Times(0)
	
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
	:Times(0)
	
    ExpectRequest("TTS.GetSupportedLanguages", true, {
        languages =
        {
          "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU","TR-TR","PL-PL",
          "FR-FR","IT-IT","SV-SE","PT-PT","NL-NL","ZH-TW","JA-JP","AR-SA","KO-KR",
          "PT-BR","CS-CZ","DA-DK","NO-NO"
        }
      })
	  --:Times(0)
    ExpectRequest("UI.GetSupportedLanguages", true, {
        languages =
        {
          "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU","TR-TR","PL-PL",
          "FR-FR","IT-IT","SV-SE","PT-PT","NL-NL","ZH-TW","JA-JP","AR-SA","KO-KR",
          "PT-BR","CS-CZ","DA-DK","NO-NO"
        }
      })
	  --:Times(0)
    ExpectRequest("VehicleInfo.GetVehicleType", true, {
        vehicleType =
        {
          make = "Ford",
          model = "Fiesta",
          modelYear = "2013",
          trim = "SE"
        }
     })
	 :Times(0) 
    ExpectRequest("VehicleInfo.GetVehicleData", true, { vin = "52-452-52-752" })
	:Times(0)

    local function button_capability(name, shortPressAvailable, longPressAvailable, upDownAvailable)
      xmlReporter.AddMessage(debug.getinfo(1, "n").name, tostring(name))
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
        button_capability("PRESET_0"),
        button_capability("PRESET_1"),
        button_capability("PRESET_2"),
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
        button_capability("TUNEDOWN")
      },
      presetBankCapabilities = { onScreenPresetsAvailable = true }
    }
    ExpectRequest("Buttons.GetCapabilities", true, buttons_capabilities)
    ExpectRequest("VR.GetCapabilities", true, { vrCapabilities = { "TEXT" } })
	:Times(0)
	
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
	  --:Times(0)

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
	  --:Times(0)

    ExpectRequest("VR.IsReady", true, { available = true })
    ExpectRequest("TTS.IsReady", true, { available = true })
    ExpectRequest("UI.IsReady", true, { available = true })
    ExpectRequest("Navigation.IsReady", true, { available = true })
	ExpectRequest("VehicleInfo.IsReady", true, params1)

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
 


---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

--Not applicable

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK I----------------------------------------
--------------------------------Check normal cases of Mobile request---------------------------
-----------------------------------------------------------------------------------------------

-- Not applicable for VR.IsReady HMI API.



----------------------------------------------------------------------------------------------
----------------------------------------TEST BLOCK II-----------------------------------------
-----------------------------Check special cases of Mobile request----------------------------
----------------------------------------------------------------------------------------------

-- Not applicable for VR.IsReady HMI API.

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK III--------------------------------------
----------------------------------Check normal cases of HMI response---------------------------
-----------------------------------------------------------------------------------------------

--List of CRQs:
	--APPLINK-20918: [GENIVI] VR interface: SDL behavior in case HMI does not respond to IsReady_request or respond with "available" = false
		-- 1. HMI respond VR.IsReady (false) -> SDL must return 'UNSUPPORTED_RESOURCE, success:false' to all single VR-related RPC
		-- 2. HMI respond VR.IsReady (false) and app sends RPC that must be spitted -> SDL must NOT transfer VR portion of spitted RPC to HMI
		-- 3. HMI does NOT respond to VR.IsReady_request -> SDL must transfer received RPC to HMI even to non-responded VR module

--List of parameters in VR.IsReady response:
	--Parameter 1: correlationID: type=Integer, mandatory="true"
	--Parameter 2: method: type=String, mandatory="true" (method = "VR.IsReady") 
	--Parameter 3: resultCode: type=String Enumeration(Integer), mandatory="true" 
	--Parameter 4: info/message: type=String, minlength="1" maxlength="10" mandatory="false" 
	--Parameter 5: available: type=Boolean, mandatory="true"
-----------------------------------------------------------------------------------------------

	
	
-----------------------------------------------------------------------------------------------				
-- Cases 1: HMI sends VR.IsReady response (available = false)
-----------------------------------------------------------------------------------------------
	--List of CRQs:	
		--CRQ #1) APPLINK-25046: [RegisterAppInterface] SDL behavior in case <Interface> is not supported by system => omit <Interface>-related parameters from response to mobile app (meaning: SDL must NOT retrieve the default values from 'HMI_capabilities.json' file and provide via response to mobile app)		
		--CRQ #2) APPLINK-20931: [VR Interface] Conditions for SDL to respond 'UNSUPPORTED_RESOURCE, success:false' to mobile app (single VR-related RPC)
		--CRQ #3) APPLINK-25042: [VR Interface] VR.IsReady(false) -> HMI respond with successful resultCode to spitted RPC
		--CRQ #4) APPLINK-25043: [VR Interface] VR.IsReady(false) -> HMI respond with errorCode to spitted RPC
		
	local function case1_IsReady_availabe_false()	

		
		local TestCaseName = "VR_IsReady_response_availabe_false"
		
		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup(TestCaseName)
		
		local function StopStartSDL_HMI_MOBILE()
		
			--Stop SDL
			Test[tostring(TestCaseName) .. "_Precondition_StopSDL"] = function(self)
				StopSDL()
			end
			
			--Start SDL
			Test[tostring(TestCaseName) .. "_Precondition_StartSDL"] = function(self)
				StartSDL(config.pathToSDL, config.ExitOnCrash)
			end
			
			--InitHMI
			Test[tostring(TestCaseName) .. "_Precondition_InitHMI"] = function(self)
				self:initHMI()
			end
			
			
			--InitHMIonReady: Cover APPLINK-25286: [HMI_API] VR.IsReady
			Test[tostring(TestCaseName) .. "_initHMI_onReady_VR_IsReady_" .. tostring(description)] = function(self)
				
				self:initHMI_onReady_VR_IsReady(0)	--	availabe = false
			end

			
			--ConnectMobile
			Test[tostring(TestCaseName) .. "_ConnectMobile"] = function(self)
				self:connectMobile()
			end
			
			--StartSession
			Test[tostring(TestCaseName) .. "_StartSession"] = function(self)
				self.mobileSession= mobile_session.MobileSession(self, self.mobileConnection)
				self.mobileSession:StartService(7)
			end

		end
		
		
		--ToDo: Due to problem with stop and start SDL (APPLINK-25898), this step is skipped and update user_modules/connecttest_VR_Isready.lua to send VR.IsReady(available = false) response manually.
		StopStartSDL_HMI_MOBILE()
		
		-----------------------------------------------------------------------------------------------		
		--CRQ #1) APPLINK-25046: [RegisterAppInterface] SDL behavior in case <Interface> is not supported by system => omit <Interface>-related param from response to mobile app (meaning: SDL must NOT retrieve the default values from 'HMI_capabilities.json' file and provide via response to mobile app)
		--Verification criteria:
			-- In case HMI respond <Interface>.IsReady (available=false) to SDL (<Interface>: VehicleInfo, TTS, UI, VR)
			-- and mobile app sends RegisterAppInterface_request to SDL
			-- and SDL successfully registers this application (see req-s # APPLINK-16420, APPLINK-16251, APPLINK-16250, APPLINK-16249, APPLINK-16320, APPLINK-15686, APPLINK-16307)
			-- SDL must omit <Interface>-related param from response to mobile app (meaning: SDL must NOT retrieve the default values from 'HMI_capabilities.json' file and provide via response to mobile app)		
		-----------------------------------------------------------------------------------------------		
		

		local function RegisterApplication_Check_VR_Parameters_IsOmitted(TestCaseName)
		
			--List of resultCodes: APPLINK-16420 SUCCESS, APPLINK-16251 WRONG_LANGUAGE, APPLINK-16250 WRONG_LANGUAGE languageDesired, APPLINK-16249 WRONG_LANGUAGE hmiDisplayLanguageDesired, APPLINK-16320 UNSUPPORTED_RESOURCE unavailable/not supported component, APPLINK-15686 RESUME_FAILED, APPLINK-16307 WARNINGS, true

			
			-- APPLINK-16420 SUCCESS
			--Precondition: App has not been registered yet.			
			
			Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_IsOmitted_resultCode_SUCCESS"] = function(self)
			
				commonTestCases:DelayedExp(iTimeout)
				
				--mobile side: RegisterAppInterface request
				local CorIdRegister=self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

				--hmi side: expect BasicCommunication.OnAppRegistered request
				EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
				{
					application=
					{
						appName=config.application1.registerAppInterfaceParams.appName
					}
				})
				:Do(function(_,data)
					self.appName=data.params.application.appName
					self.applications[config.application1.registerAppInterfaceParams.appName]=data.params.application.appID
				end)
				
				
				--mobile side: expect response
				-- SDL does not send VR-related param to mobile app	
				self.mobileSession:ExpectResponse(CorIdRegister, {success=true,resultCode="SUCCESS"})
				:ValidIf (function(_,data)
					local errorMessage = ""
					if data.payload.vrCapabilities then
						errorMessage = errorMessage .. "SDL resends 'vrCapabilities' parameter to mobile app. "
					end
					if data.payload.language then
						errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
					end	
					
					if errorMessage == "" then
						return true					
					else
						commonFunctions:printError(errorMessage)
						return false
					end
				end)
				
				--mobile side: expect notification
				self.mobileSession:ExpectNotification("OnHMIStatus", { systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"})
		 
			end	
				
			commonSteps:UnregisterApplication("Postcondition_UnregisterApplication_SUCCESS")
			
			-- APPLINK-16320 UNSUPPORTED_RESOURCE unavailable/not supported component: It is not applicable for RegisterAppInterface because RegisterAppInterface is not split able request
			
			-- APPLINK-16251 WRONG_LANGUAGE
			-- APPLINK-16250 WRONG_LANGUAGE languageDesired
			Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_IsOmitted_resultCode_WRONG_LANGUAGE"] = function(self)
				
				commonTestCases:DelayedExp(iTimeout)
				
				--Set language  = "RU-RU"
				local parameters = commonFunctions:cloneTable(config.application1.registerAppInterfaceParams)
				parameters.languageDesired = "RU-RU"
		
				--mobile side: RegisterAppInterface request
				local CorIdRegister=self.mobileSession:SendRPC("RegisterAppInterface", parameters)

				--hmi side: expect BasicCommunication.OnAppRegistered request
				EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
				{
					application=
					{
						appName=config.application1.registerAppInterfaceParams.appName
					}
				})
				:Do(function(_,data)
					self.appName=data.params.application.appName
					self.applications[config.application1.registerAppInterfaceParams.appName]=data.params.application.appID
				end)
				
				

				--mobile side: expect response
				-- SDL does not send VR-related param to mobile app	
				self.mobileSession:ExpectResponse(CorIdRegister, {success=true,resultCode="WRONG_LANGUAGE"})
				:ValidIf (function(_,data)
					local errorMessage = ""
					if data.payload.vrCapabilities then
						errorMessage = errorMessage .. "SDL resends 'vrCapabilities' parameter to mobile app. "
					end
					if data.payload.language then
						errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
					end	
					
					if errorMessage == "" then
						return true					
					else
						commonFunctions:printError(errorMessage)
						return false
					end
				end)
				
				--mobile side: expect notification
				self.mobileSession:ExpectNotification("OnHMIStatus", { systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"})
		 
			end	
		
			
			
			--APPLINK-16249 WRONG_LANGUAGE hmiDisplayLanguageDesired: It is for UI interface only.
			
			
			-- APPLINK-16307 WARNINGS, true
			commonSteps:UnregisterApplication(TestCaseName .. "_Precondition_UnregisterApplication_for_checking_WARNINGS")
			
			Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_IsOmitted_resultCode_WARNINGS"] = function(self)
				
				commonTestCases:DelayedExp(iTimeout)
				
				local parameters = commonFunctions:cloneTable(config.application1.registerAppInterfaceParams)
				parameters.appHMIType = {"MEDIA"}
		
				--mobile side: RegisterAppInterface request
				local CorIdRegister=self.mobileSession:SendRPC("RegisterAppInterface", parameters)

				--hmi side: expect BasicCommunication.OnAppRegistered request
				EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
				{
					application=
					{
						appName=config.application1.registerAppInterfaceParams.appName
					}
				})
				:Do(function(_,data)
					self.appName=data.params.application.appName
					self.applications[config.application1.registerAppInterfaceParams.appName]=data.params.application.appID
				end)
				
				
				--mobile side: expect response
				-- SDL does not send VR-related param to mobile app	
				self.mobileSession:ExpectResponse(CorIdRegister, {success=true,resultCode="WARNINGS"})
				:ValidIf (function(_,data)
					local errorMessage = ""
					if data.payload.vrCapabilities then
						errorMessage = errorMessage .. "SDL resends 'vrCapabilities' parameter to mobile app. "
					end
					if data.payload.language then
						errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
					end	
					
					if errorMessage == "" then
						return true					
					else
						commonFunctions:printError(errorMessage)
						return false
					end
				end)

				--mobile side: expect notification
				self.mobileSession:ExpectNotification("OnHMIStatus", { systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"})
		 
			end	
		

			
			-- APPLINK-15686 RESUME_FAILED
			--////////////////////////////////////////////////////////////////////////////////////////////--
			-- Check absence of resumption in case HashID in RAI is not match
			--////////////////////////////////////////////////////////////////////////////////////////////--

			--Precondition:
			commonSteps:UnregisterApplication(TestCaseName .. "_Precondition_for_checking_RESUME_FAILED_UnregisterApp")
			commonSteps:RegisterAppInterface(TestCaseName .. "_Precondition_for_checking_RESUME_FAILED_RegisterApp")
			commonSteps:ActivationApp(_, TestCaseName .. "_Precondition_for_checking_RESUME_FAILED_ActivateApp")	


			function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_AddCommand()
				
				--mobile side: sending AddCommand request
				local cid = self.mobileSession:SendRPC("AddCommand",
				{
					cmdID = 1,
					menuParams = 	
					{
						position = 0,
						menuName ="Command 1"
					}, 
					vrCommands = {"VRCommand 1"}
				})
			
				--hmi side: expect UI.AddCommand request 
				EXPECT_HMICALL("UI.AddCommand", 
				{ 
					cmdID = icmdID,		
					menuParams = 
					{
						position = 0,
						menuName ="Command 1"
					}
				})
				:Do(function(_,data)
					--hmi side: sending UI.AddCommand response 
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)

				--hmi side: expect VR.AddCommand request 
				EXPECT_HMICALL("VR.AddCommand", 
				{ 
					cmdID = 1,							
					type = "Command",
					vrCommands = 
					{
						"VRCommand 1"
					}
				})
				:Do(function(_,data)
					--hmi side: sending VR.AddCommand response 
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)	
			
				
				--mobile side: expect AddCommand response 
				EXPECT_RESPONSE(cid, {  success = true, resultCode = "SUCCESS"  })
				:Do(function()
					--mobile side: expect OnHashChange notification
					--Requirement id in JAMA/or Jira ID: APPLINK-15682
					--[Data Resumption]: OnHashChange
					EXPECT_NOTIFICATION("OnHashChange")
						:Do(function(_, data)
							self.currentHashID = data.payload.hashID
						end)
				end)
				
			end

			function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_CreateInteractionChoiceSet()
				--mobile side: sending CreateInteractionChoiceSet request
				local cid = self.mobileSession:SendRPC("CreateInteractionChoiceSet",
													{
														interactionChoiceSetID = 1,
														choiceSet = 
														{ 
															
															{ 
																choiceID = 1,
																menuName = "Choice 1",
																vrCommands = 
																{ 
																	"VrChoice 1",
																}
															}
														}
													})
			
				
				--hmi side: expect VR.AddCommand request
				EXPECT_HMICALL("VR.AddCommand", 
							{ 
								cmdID = 1,
								appID = self.applications[config.application1.registerAppInterfaceParams.appName],
								type = "Choice",
								vrCommands = {"VrChoice 1"}
							})
				:Do(function(_,data)
					--hmi side: sending VR.AddCommand response
					grammarIDValue = data.params.grammarID
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
			
				--mobile side: expect CreateInteractionChoiceSet response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				:Do(function(_,data)
					
					--mobile side: expect OnHashChange notification
					--Requirement id in JAMA/or Jira ID: APPLINK-15682
					--[Data Resumption]: OnHashChange
					EXPECT_NOTIFICATION("OnHashChange")
					:Do(function(_, data)
						self.currentHashID = data.payload.hashID
					end)
				end)
			end

			function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_AddSubMenu()
				
				--mobile side: sending AddSubMenu request
				local cid = self.mobileSession:SendRPC("AddSubMenu",
													{
														menuID = 1,
														position = 500,
														menuName = "SubMenupositive 1"
													})

				--hmi side: expect UI.AddSubMenu request
				EXPECT_HMICALL("UI.AddSubMenu", 
							{ 
								menuID = 1,
								menuParams = {
									position = 500,
									menuName = "SubMenupositive 1"
								}
							})
				:Do(function(_,data)
					--hmi side: sending UI.AddSubMenu response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
				
				--mobile side: expect AddSubMenu response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				:Do(function()
					--mobile side: expect OnHashChange notification
					
					--Requirement id in JAMA/or Jira ID: APPLINK-15682
					--[Data Resumption]: OnHashChange
					EXPECT_NOTIFICATION("OnHashChange")
						:Do(function(_, data)
							self.currentHashID = data.payload.hashID
						end)
				end)
			end

			function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_SetGlobalProperites()
			
				--mobile side: sending SetGlobalProperties request
				local cid = self.mobileSession:SendRPC("SetGlobalProperties",
													{
														menuTitle = "Menu Title",
														timeoutPrompt = 
														{
															{
																text = "Timeout prompt",
																type = "TEXT"
															}
														},
														vrHelp = 
														{
															{
																position = 1,
																text = "VR help item"
															}
														},
														helpPrompt = 
														{
															{
																text = "Help prompt",
																type = "TEXT"
															}
														},
														vrHelpTitle = "VR help title",
													})


				--hmi side: expect TTS.SetGlobalProperties request
				EXPECT_HMICALL("TTS.SetGlobalProperties",
							{
								timeoutPrompt = 
								{
									{
										text = "Timeout prompt",
										type = "TEXT"
									}
								},
								helpPrompt = 
								{
									{
										text = "Help prompt",
										type = "TEXT"
									}
								}
							})
					:Do(function(_,data)
						--hmi side: sending UI.SetGlobalProperties response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)

				--hmi side: expect UI.SetGlobalProperties request
				EXPECT_HMICALL("UI.SetGlobalProperties",
							{
								menuTitle = "Menu Title",
								vrHelp = 
								{
									{
										position = 1,
										text = "VR help item"
									}
								},
								vrHelpTitle = "VR help title"
							})
				:Do(function(_,data)
					--hmi side: sending UI.SetGlobalProperties response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)


				--mobile side: expect SetGlobalProperties response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				:Do(function(_,data)

					--Requirement id in JAMA/or Jira ID: APPLINK-15682
					--[Data Resumption]: OnHashChange
					EXPECT_NOTIFICATION("OnHashChange")
					:Do(function(_, data)
						self.currentHashID = data.payload.hashID
					end)
				end)
			end

			

			function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_SubscribeButton()
			
				--mobile side: sending SubscribeButton request
				local cid = self.mobileSession:SendRPC("SubscribeButton", {buttonName = "PRESET_0"})

				--expect Buttons.OnButtonSubscription
				EXPECT_HMINOTIFICATION("Buttons.OnButtonSubscription", 
				{
					appID = self.applications[config.application1.registerAppInterfaceParams.appName], 
					isSubscribed = true, 
					name = "PRESET_0"
				})

				--mobile side: expect SubscribeButton response
				EXPECT_RESPONSE(cid, {success = true, resultCode = "SUCCESS"})
				:Do(function(_,data)
					
					--Requirement id in JAMA/or Jira ID: APPLINK-15682
					--[Data Resumption]: OnHashChange
					EXPECT_NOTIFICATION("OnHashChange")
					:Do(function(_, data)
						self.currentHashID = data.payload.hashID
					end)
				end)
			end
		 
			function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_SubscribeVehicleData()
			
				--mobile side: sending SubscribeVehicleData request
				local cid = self.mobileSession:SendRPC("SubscribeVehicleData",{gps = true})
			
				--hmi side: expect SubscribeVehicleData request
				EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData",{gps = true})
				:Do(function(_,data)
					--hmi side: sending VehicleInfo.SubscribeVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { gps = { resultCode = "SUCCESS", dataType = "VEHICLEDATA_GPS"}})	
				end)
			
				--mobile side: expect SubscribeVehicleData response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				:Do(function(_,data)
					
					--mobile side: expect OnHashChange notification
					--Requirement id in JAMA/or Jira ID: APPLINK-15682
					--[Data Resumption]: OnHashChange
					EXPECT_NOTIFICATION("OnHashChange")
					:Do(function(_, data)
						self.currentHashID = data.payload.hashID
					end)
				end)
			end

			function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_SubscribeWayPoints()
				
				local cid = self.mobileSession:SendRPC("SubscribeWayPoints", {})

				--hmi side: expected SubscribeWayPoints request
				EXPECT_HMICALL("Navigation.SubscribeWayPoints")
				:Do(function(_,data)
					--hmi side: sending Navigation.SubscribeWayPoints response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
				
				--mobile side: SubscribeWayPoints response
				EXPECT_RESPONSE(cid, {success = true , resultCode = "SUCCESS"})
				:Do(function(_,data)
					--Requirement id in JAMA/or Jira ID: APPLINK-15682
					--[Data Resumption]: OnHashChange

					--userPrint(31,"DEFECT ID: APPLINK-25808")
					EXPECT_NOTIFICATION("OnHashChange")
					:Do(function(_, data)
						self.currentHashID = data.payload.hashID
					end)
				end)
			end
			
			function Test:Precondition_for_checking_RESUME_FAILED_CloseConnection()
				self.mobileConnection:Close() 
			end

			function Test:Precondition_for_checking_RESUME_FAILED_ConnectMobile()
				self:connectMobile()
			end

			function Test:Precondition_for_checking_RESUME_FAILED_StartSession()
			   self.mobileSession = mobile_session.MobileSession(
				  self,
				  self.mobileConnection,
				  config.application1.registerAppInterfaceParams)

				self.mobileSession:StartService(7)
			end

			Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_IsOmitted_resultCode_RESUME_FAILED"] = function(self)
			
				commonTestCases:DelayedExp(iTimeout)
				
				local parameters = commonFunctions:cloneTable(config.application1.registerAppInterfaceParams)
				parameters.hashID = "sdfgTYWRTdfhsdfgh"

				--mobile side: RegisterAppInterface request
				local CorIdRegister=self.mobileSession:SendRPC("RegisterAppInterface", parameters)

				--hmi side: expect BasicCommunication.OnAppRegistered request
				EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
				{
					application=
					{
						appName=config.application1.registerAppInterfaceParams.appName
					}
				})
				:Do(function(_,data)
					self.appName=data.params.application.appName
					self.applications[config.application1.registerAppInterfaceParams.appName]=data.params.application.appID
				end)
				
				
				--mobile side: expect response
				-- SDL does not send VR-related param to mobile app	
				self.mobileSession:ExpectResponse(CorIdRegister, {success=true,resultCode="RESUME_FAILED"})
				:ValidIf (function(_,data)
					local errorMessage = ""
					if data.payload.vrCapabilities then
						errorMessage = errorMessage .. "SDL resends 'vrCapabilities' parameter to mobile app. "
					end
					if data.payload.language then
						errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
					end	
					
					if errorMessage == "" then
						return true					
					else
						commonFunctions:printError(errorMessage)
						return false
					end
				end)

				
				--mobile side: expect notification
				self.mobileSession:ExpectNotification("OnHMIStatus", 
							{systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"}, 
							{systemContext="MAIN", hmiLevel="FULL", audioStreamingState="AUDIBLE"}
				)
				:Times(2)
				
				EXPECT_HMICALL("UI.AddCommand")
				:Times(0)

				EXPECT_HMICALL("VR.AddCommand")
				:Times(0)

				EXPECT_HMICALL("UI.AddSubMenu")
				:Times(0)

				--APPLINK-9532: Sending TTS.SetGlobalProperties to VCA in case no obtained from mobile app
				--Description: When registering the app as soon as the app gets HMI Level NONE, SDL sends TTS.SetGlobalProperties(helpPrompt[]) with an empty array of helpPrompts (just helpPrompts, no timeoutPrompt).
				--hmi side: expect TTS.SetGlobalProperties request
				EXPECT_HMICALL("TTS.SetGlobalProperties")
				:Do(function(_,data)
					--hmi side: sending UI.SetGlobalProperties response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
				:ValidIf(function(_,data)
					if data.params.timeoutPrompt then
						commonFunctions:printError("TTS.SetGlobalProperties request came with unexpected timeoutPrompt parameter.")
						return false
					elseif data.params.helpPrompt and #data.params.helpPrompt == 0 then
						return true
					elseif data.params.helpPrompt == nil then
						commonFunctions:printError("UI.SetGlobalProperties request came without helpPrompt")
						return false
					else 
						commonFunctions:printError("UI.SetGlobalProperties request came with some unexpected values of helpPrompt, array length is " .. tostring(#data.params.helpPrompt))
						return false
					end
				end)


				EXPECT_HMICALL("UI.SetGlobalProperties")
				:Times(0)

				--mobile side: expect OnHashChange notification
				EXPECT_NOTIFICATION("OnHashChange")
				:Times(0)

			end	


		end
			
		RegisterApplication_Check_VR_Parameters_IsOmitted(TestCaseName)

		-- Description: Activation app for precondition
		commonSteps:ActivationApp()

		
		-----------------------------------------------------------------------------------------------
		--CRQ #2) APPLINK-20931: [VR Interface] Conditions for SDL to respond 'UNSUPPORTED_RESOURCE, success:false' to mobile app <= SDL receives VR.IsReady (available=false) from HMI 
		--Verification criteria:
			-- In case SDL receives VR.IsReady (available=false) from HMI and mobile app sends any single VR-related RPC
			-- SDL must respond "UNSUPPORTED_RESOURCE, success=false, info: "VR is not supported by system" to mobile app
			-- SDL must NOT transfer this VR-related RPC to HMI
		-----------------------------------------------------------------------------------------------	

		local function VR_IsReady_response_availabe_false_check_single_VR_related_RPC(TestCaseName)
		
				-- 1. Add.Command		
				Test[TestCaseName .. "_AddCommand_VRCommandsOnly_UNSUPPORTED_RESOURCE_false"] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
			
					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC("AddCommand",
					{
						cmdID = 1,
						vrCommands = { "vrCommands_1" }
					})
						
					--hmi side: expect VR.AddCommand request
					EXPECT_HMICALL("VR.AddCommand", {})
					:Times(0)
					
					--mobile side: expect AddCommand response
					EXPECT_RESPONSE(cid, {success = false, resultCode = "UNSUPPORTED_RESOURCE", info =  "VR is not supported by system"})

					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)

				end
			
				-- 2. DeleteCommand
				--ToDo: Should update according to answer on question APPLINK-27079
				Test[TestCaseName .. "_DeleteCommand_VRCommandsOnly_UNSUPPORTED_RESOURCE_false"] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
					
					--mobile side: sending DeleteCommand request
					local cid = self.mobileSession:SendRPC("DeleteCommand", {cmdID = 1})
					
					--hmi side: expect VR.DeleteCommand request
					EXPECT_HMICALL("VR.DeleteCommand", {})
					:Times(0)
					
					--mobile side: expect DeleteCommand response 
					--EXPECT_RESPONSE(cid, {success = false, resultCode = "UNSUPPORTED_RESOURCE", info =  "VR is not supported by system"})
					--ResultCode INVALID_ID is applicable because we cannot create command so that the command is not exist for deleting.
					EXPECT_RESPONSE(cid, {success = false, resultCode = "INVALID_ID"})

					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)
					
				end		
			
				-- 3. CreateInteractionChoiceSet
				Test[TestCaseName .. "_CreateInteractionChoiceSet_1"] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
					
					--mobile side: sending CreateInteractionChoiceSet request
					local cid = self.mobileSession:SendRPC("CreateInteractionChoiceSet",
															{
																interactionChoiceSetID = 1,
																choiceSet = {{ 
																					choiceID = 1,
																					menuName ="Choice 1",
																					vrCommands = {"VrChoice 1"}, 
																					image =
																					{ 
																						value ="icon.png",
																						imageType ="STATIC",
																					}
																			}}
															})
					
					--hmi side: expect there is no VR.AddCommand
					EXPECT_HMICALL("VR.AddCommand", {})
					:Times(0)
					
					--mobile side: expect CreateInteractionChoiceSet response
					EXPECT_RESPONSE(cid, {success = false, resultCode = "UNSUPPORTED_RESOURCE", info =  "VR is not supported by system"})
					
					--mobile side: expect there is no OnHashChange
					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)
					
				end
			
		end
		
		VR_IsReady_response_availabe_false_check_single_VR_related_RPC("VR_IsReady_response_availabe_false_single_VR_related_RPC")
			

			
		-----------------------------------------------------------------------------------------------
		--CRQ #3) APPLINK-25042: [VR Interface] VR.IsReady(false) -> HMI respond with successful resultCode to split RPC
		--Verification criteria:
			-- In case SDL receives VR.IsReady (available=false) from HMI
			-- and mobile app sends RPC to SDL that must be split to:
			-- -> VR RPC
			-- -> any other <Interface>.RPC (<Interface> - TTS, UI)
			-- SDL must:
			-- transfer only <Interface>.RPC to HMI (in case <Interface> is supported by system)
			-- respond with 'UNSUPPORTED_RESOURCE, success:true,' + 'info: VR is not supported by system' to mobile app IN CASE <Interface>.RPC was successfully processed by HMI (please see list with resultCodes below)
		
		-----------------------------------------------------------------------------------------------	

		local function VR_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_SUCCESS(TestCaseName)

			-- List of successful resultCodes (success:true)
			local TestData = {
								{resultCode = "SUCCESS", 		info = "VR is not supported by system"},
								{resultCode = "WARNINGS", 		info = "VR is not supported by system"},
								{resultCode = "WRONG_LANGUAGE", info = "VR is not supported by system"},
								{resultCode = "RETRY", 			info = "VR is not supported by system"},
								{resultCode = "SAVED", 			info = "VR is not supported by system"},
							}

			-- AddCommand		
			for i = 1, #TestData do
				Test[TestCaseName .. "_AddCommand_UNSUPPORTED_RESOURCE_true_Incase_UI_responds_" .. TestData[i].resultCode] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
			
					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC("AddCommand",
					{
						cmdID = i,
						vrCommands = { "vrCommands_" .. tostring(i) },
						menuParams = {position = 1, menuName = "Command " .. tostring(i)}
					})
						
					--hmi side: expect UI.AddCommand request 
					EXPECT_HMICALL("UI.AddCommand", 
					{ 
						cmdID = i,		
						menuParams = {position = 1, menuName ="Command "..tostring(i)}
					})
					:Do(function(_,data)
						--hmi side: sending UI.AddCommand response 
						self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
					end)	
					
					--hmi side: expect VR.AddCommand request
					EXPECT_HMICALL("VR.AddCommand", {})
					:Times(0)
					
					--mobile side: expect AddCommand response
					EXPECT_RESPONSE(cid, {success = true, resultCode = "UNSUPPORTED_RESOURCE", info = TestData[i].info})
					:Timeout(iTimeout)

					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Timeout(iTimeout)

				end
			end
			
			-- DeleteCommand	
			for i = 1, #TestData do
				Test[TestCaseName .. "_DeleteCommand_UNSUPPORTED_RESOURCE_true_Incase_UI_responds_" .. TestData[i].resultCode] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
					
					--mobile side: sending DeleteCommand request
					local cid = self.mobileSession:SendRPC("DeleteCommand", {cmdID = i})
					
					--hmi side: expect UI.DeleteCommand request
					EXPECT_HMICALL("UI.DeleteCommand", {cmdID = i})
					:Do(function(_,data)
						--hmi side: sending UI.DeleteCommand response
						self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
					end)
					
					
					--hmi side: expect VR.DeleteCommand request
					EXPECT_HMICALL("VR.DeleteCommand", {})
					:Times(0)
					
					--mobile side: expect DeleteCommand response 
					EXPECT_RESPONSE(cid, {success = true, resultCode = "UNSUPPORTED_RESOURCE", info = TestData[i].info})
					:Timeout(iTimeout)

					EXPECT_NOTIFICATION("OnHashChange")
					:Timeout(iTimeout)
					
				end		
				
			end
					
			-- PerformInteraction: We cannot check {success = true, resultCode = "UNSUPPORTED_RESOURCE"} because SDL does not allow to create choiceset. So there is no choiceset for PerformInteraction request	
			
			-- ChangeRegistration
			for i = 1, #TestData do
				Test[TestCaseName .. "_ChangeRegistration_UNSUPPORTED_RESOURCE_true_Incase_UI_responds_" .. TestData[i].resultCode] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
					
					local request = {	language ="EN-US",
										hmiDisplayLanguage ="EN-US",
										appName ="SyncProxyTester_" .. tostring(i),
										ttsName = {{text ="SyncProxyTester", type ="TEXT"}},
										ngnMediaScreenAppName ="SPT",
										vrSynonyms = {"VRSyncProxyTester"}}

					--mobile side: send ChangeRegistration request
					local cid = self.mobileSession:SendRPC("ChangeRegistration", request)

					--hmi side: expect UI.ChangeRegistration request
					EXPECT_HMICALL("UI.ChangeRegistration",
					{
						appName = request.appName,
						language = request.hmiDisplayLanguage,
						ngnMediaScreenAppName = request.ngnMediaScreenAppName
					})
					:Do(function(_,data)
						--hmi side: send UI.ChangeRegistration response
						self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
					end)

					--hmi side: expect there is no VR.ChangeRegistration request
					EXPECT_HMICALL("VR.ChangeRegistration", {})
					:Times(0)

					--hmi side: expect TTS.ChangeRegistration request
					EXPECT_HMICALL("TTS.ChangeRegistration",
					{
						language = request.language,
						ttsName = request.ttsName
					})
					:Do(function(_,data)
						--hmi side: send TTS.ChangeRegistration response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS",{})
					end)

					--mobile side: expect ChangeRegistration response					
					EXPECT_RESPONSE(cid, {success = true, resultCode = "UNSUPPORTED_RESOURCE", info = TestData[i].info})
					:Timeout(iTimeout)
					
					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Timeout(iTimeout)

				end
			end
			
			
			
		end
		
		VR_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_SUCCESS("VR_IsReady_availabe_false_split_RPC_SUCCESS")
		
		
		
		
		-----------------------------------------------------------------------------------------------	
		--CRQ #4) APPLINK-25043: [VR Interface] VR.IsReady(false) -> HMI respond with errorCode to split RPC
		--Verification criteria:
			-- In case SDL receives VR.IsReady (available=false) from HMI
			-- and mobile app sends RPC to SDL that must be split to:
			-- -> VR RPC
			-- -> any other <Interface>.RPC (<Interface> - TTS, UI)
			-- SDL must:
			-- transfer only <Interface>.RPC to HMI (in case <Interface> is supported by system)
			-- respond with '<received_errorCode_from_HMI>' to mobile app IN CASE <Interface>.RPC got any erroneous resultCode from HMI (please see list with resultCodes below)
		-----------------------------------------------------------------------------------------------	
		--ToDo: Update according to question APPLINK-26900
			
		local function VR_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_Error(TestCaseName)

			-- List of erroneous resultCodes (success:false)
			local TestData = {
			
								{resultCode = "UNSUPPORTED_REQUEST", 		info = "VR is not supported by system"},
								{resultCode = "DISALLOWED", 				info = "VR is not supported by system"},
								{resultCode = "USER_DISALLOWED", 			info = "VR is not supported by system"},
								{resultCode = "REJECTED", 					info = "VR is not supported by system"},
								{resultCode = "ABORTED", 					info = "VR is not supported by system"},
								{resultCode = "IGNORED", 					info = "VR is not supported by system"},
								{resultCode = "IN_USE", 					info = "VR is not supported by system"},
								{resultCode = "VEHICLE_DATA_NOT_AVAILABLE", info = "VR is not supported by system"},
								{resultCode = "TIMED_OUT", 					info = "VR is not supported by system"},
								{resultCode = "INVALID_DATA", 				info = "VR is not supported by system"},
								{resultCode = "CHAR_LIMIT_EXCEEDED", 		info = "VR is not supported by system"},
								{resultCode = "INVALID_ID", 				info = "VR is not supported by system"},
								{resultCode = "DUPLICATE_NAME", 			info = "VR is not supported by system"},
								{resultCode = "APPLICATION_NOT_REGISTERED", info = "VR is not supported by system"},
								{resultCode = "OUT_OF_MEMORY", 				info = "VR is not supported by system"},
								{resultCode = "TOO_MANY_PENDING_REQUESTS", 	info = "VR is not supported by system"},
								{resultCode = "GENERIC_ERROR", 				info = "VR is not supported by system"},
								{resultCode = "TRUNCATED_DATA", 			info = "VR is not supported by system"},
								{resultCode = "UNSUPPORTED_RESOURCE", 		info = "VR is not supported by system"},
								{resultCode = "NOT_RESPOND", 				info = "VR is not supported by system"},
							}
			
		
			-- AddCommand		
			for i = 1, #TestData do
				Test[TestCaseName .. "_AddCommand_UNSUPPORTED_RESOURCE_true_Incase_UI_responds_" .. TestData[i].resultCode] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
			
					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC("AddCommand",
					{
						cmdID = i,
						vrCommands = { "vrCommands_" .. tostring(i) },
						menuParams = {position = 1, menuName = "Command " .. tostring(i)}
					})
						
					--hmi side: expect UI.AddCommand request 
					EXPECT_HMICALL("UI.AddCommand", 
					{ 
						cmdID = i,		
						menuParams = {position = 1, menuName ="Command "..tostring(i)}
					})
					:Do(function(_,data)
						--hmi side: sending UI.AddCommand response 
						if TestData[i].resultCode == "NOT_RESPOND" then
							--UI does not respond
						else
							self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "Error Messages")
						end
					end)	
					
					--hmi side: expect VR.AddCommand request
					EXPECT_HMICALL("VR.AddCommand", {})
					:Times(0)
					
					--mobile side: expect AddCommand response
					if TestData[i].resultCode == "NOT_RESPOND" then
						EXPECT_RESPONSE(cid, {success = false, resultCode = "GENERIC_ERROR"})
						:Timeout(12000)
					else
						EXPECT_RESPONSE(cid, {success = false, resultCode = "UNSUPPORTED_RESOURCE", info = TestData[i].info})
					end
					
					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)

				end
			end
			
			-- DeleteCommand	
			for i = 1, #TestData do
				Test[TestCaseName .. "_DeleteCommand_UNSUPPORTED_RESOURCE_true_Incase_UI_responds_" .. TestData[i].resultCode] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
					
					--mobile side: sending DeleteCommand request
					local cid = self.mobileSession:SendRPC("DeleteCommand", {cmdID = i})
					
					--hmi side: expect UI.DeleteCommand request
					EXPECT_HMICALL("UI.DeleteCommand", {cmdID = i})
					:Do(function(_,data)
						--hmi side: sending UI.DeleteCommand response
						if TestData[i].resultCode == "NOT_RESPOND" then
							--UI does not respond
						else
							self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "Error Messages")
						end
					end)
					
					
					--hmi side: expect VR.DeleteCommand request
					EXPECT_HMICALL("VR.DeleteCommand", {})
					:Times(0)
					
					--mobile side: expect DeleteCommand response 
					if TestData[i].resultCode == "NOT_RESPOND" then
						EXPECT_RESPONSE(cid, {success = false, resultCode = "GENERIC_ERROR"})
						:Timeout(12000)
					else
						EXPECT_RESPONSE(cid, {success = false, resultCode = "UNSUPPORTED_RESOURCE", info = TestData[i].info})
					end

					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)
					
				end		
				
			end
			
			-- CreateInteractionChoiceSet: It can be removed due to not applicable
			-- 3. PerformInteraction => It is not applicable. We cannot check {success = true, resultCode = "UNSUPPORTED_RESOURCE"} because SDL does not allow to create choiceset. So there is no choiceset for PerformInteraction request. And answer on question APPLINK-27079. If we send PerformInteraction, SDL always responds INVALID_DATA. This case is covered by ATF_PerformInteraction.lua
			-- 4. ChangeRegistration => It is covered by RegisterApplication_Check_VR_Parameters_IsOmitted
			-- 5. GetSupportedLanguages => It is not sent from SDL to HMI in case VR_IsReady_response_availabe_false according to APPLINK-25042 "transfer only <Interface>.RPC to HMI (in case <Interface> is supported by system)"
			-- 6. GetLanguage => The same as GetSupportedLanguages
			-- 7. GetCapabilities => The same as GetSupportedLanguages
		
		end
		
		VR_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_Error("VR_IsReady_availabe_false_split_RPC_Unsuccess")
		
	end
		
	--Precondition: Update connecttest_VR_Isready.lua responds VR.IsReady(available = false). 
	--ToDo: After APPLINK-25898 is closed, remove this precondition.
	case1_IsReady_availabe_false()



	
-----------------------------------------------------------------------------------------------				
-- Cases 2: HMI does not sends VR.IsReady response or send invalid response
-----------------------------------------------------------------------------------------------

	--List of CRQs:	
		--CRQ #1: APPLINK-25064: [RegisterAppInterface] SDL behavior in case HMI does NOT respond to IsReady request
		--CRQ #2: APPLINK-20932: [VR Interface] SDL behavior in case HMI does not respond to VR.IsReady_request (any single VR-related RPC)
		--CRQ #3: APPLINK-25044: [VR Interface] HMI does NOT respond to IsReady and mobile app sends RPC that must be split

	-----------------------------------------------------------------------------------------------
	--CRQ #1: APPLINK-25064: [RegisterAppInterface] SDL behavior in case HMI does NOT respond to IsReady request
	--Verification criteria:	
		-- In case HMI does NOT respond to <Interface>.IsReady_request to SDL (<Interface>: VehicleInfo, TTS, UI, VR)
		-- and mobile app sends RegisterAppInterface_request to SDL
		-- and SDL successfully registers this application (see req-s # APPLINK-16420, APPLINK-16251, APPLINK-16250, APPLINK-16249, APPLINK-16320, APPLINK-15686, APPLINK-16307)
		-- SDL must:
		-- provide the value of <Interface>-related params:
		-- a. either received from HMI via <Interface>.GetCapabilities response (please see APPLINK-24325, APPLINK-24102, APPLINK-24100, APPLINK-23626)
		-- b. either retrieved from 'HMI_capabilities.json' file
	-----------------------------------------------------------------------------------------------
	local function RegisterApplication_Check_VR_Parameters_From_HMI_capabilities_json(TestCaseName)
	
		--List of resultCodes: APPLINK-16420 SUCCESS, APPLINK-16251 WRONG_LANGUAGE, APPLINK-16250 WRONG_LANGUAGE languageDesired, APPLINK-16249 WRONG_LANGUAGE hmiDisplayLanguageDesired, APPLINK-16320 UNSUPPORTED_RESOURCE unavailable/not supported component, APPLINK-15686 RESUME_FAILED, APPLINK-16307 WARNINGS, true

		
		-- APPLINK-16420 SUCCESS
		--Precondition: Unregister app
		commonSteps:UnregisterApplication(TestCaseName .. "_Precondition_UnregisterApplication_SUCCESS")
		
		Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_From_HMI_capabilities_json_resultCode_SUCCESS"] = function(self)
		
			commonTestCases:DelayedExp(iTimeout)
			
			--mobile side: RegisterAppInterface request
			local CorIdRegister=self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

			--hmi side: expect BasicCommunication.OnAppRegistered request
			EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
			{
				application=
				{
					appName=config.application1.registerAppInterfaceParams.appName
				}
			})
			:Do(function(_,data)
				self.appName=data.params.application.appName
				self.applications[config.application1.registerAppInterfaceParams.appName]=data.params.application.appID
			end)
			
			
			-- Read VR parameters from hmi_capabilities.json
			local HmiCapabilities_file = config.pathToSDL .. "hmi_capabilities.json"
			f = assert(io.open(HmiCapabilities_file, "r"))
			fileContent = f:read("*all")
			f:close()
			
			local json = require("modules/json")
			local HmiCapabilities = json.decode(fileContent)

			--mobile side: expect response
			-- SDL sends VR-related parameters to mobile app with value from HMI_capabilities_json
			self.mobileSession:ExpectResponse(CorIdRegister, 
				{
					success = true, 
					resultCode = resultCode,
					info = info,
					vrCapabilities = HmiCapabilities.VR.capabilities,
					language = HmiCapabilities.VR.language
				}
			)
			
			--mobile side: expect notification
			self.mobileSession:ExpectNotification("OnHMIStatus", { systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"})
	 
		end	
			
		commonSteps:UnregisterApplication("Postcondition_UnregisterApplication_SUCCESS")
		
		-- APPLINK-16320 UNSUPPORTED_RESOURCE unavailable/not supported component: It is not applicable for RegisterAppInterface because RegisterAppInterface is not split able request
		
		-- APPLINK-16251 WRONG_LANGUAGE
		-- APPLINK-16250 WRONG_LANGUAGE languageDesired
		Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_From_HMI_capabilities_json_resultCode_WRONG_LANGUAGE"] = function(self)
			
			commonTestCases:DelayedExp(iTimeout)
			
			--Set language  = "RU-RU"
			local parameters = commonFunctions:cloneTable(config.application1.registerAppInterfaceParams)
			parameters.languageDesired = "RU-RU"
	
			--mobile side: RegisterAppInterface request
			local CorIdRegister=self.mobileSession:SendRPC("RegisterAppInterface", parameters)

			--hmi side: expect BasicCommunication.OnAppRegistered request
			EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
			{
				application=
				{
					appName=config.application1.registerAppInterfaceParams.appName
				}
			})
			:Do(function(_,data)
				self.appName=data.params.application.appName
				self.applications[config.application1.registerAppInterfaceParams.appName]=data.params.application.appID
			end)
			
			
			-- Read VR parameters from hmi_capabilities.json
			local HmiCapabilities_file = config.pathToSDL .. "hmi_capabilities.json"
			f = assert(io.open(HmiCapabilities_file, "r"))
			fileContent = f:read("*all")
			f:close()
			
			local json = require("modules/json")
			local HmiCapabilities = json.decode(fileContent)

			--mobile side: expect response
			-- SDL sends VR-related parameters to mobile app with value from HMI_capabilities_json
			self.mobileSession:ExpectResponse(CorIdRegister, 
				{
					success = true, 
					resultCode = "WRONG_LANGUAGE",
					vrCapabilities = HmiCapabilities.VR.capabilities,
					language = HmiCapabilities.VR.language
				}
			)
			
			--mobile side: expect notification
			self.mobileSession:ExpectNotification("OnHMIStatus", { systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"})
	 
		end	
	
		
		
		--APPLINK-16249 WRONG_LANGUAGE hmiDisplayLanguageDesired: It is for UI interface only.
		
		
		-- APPLINK-16307 WARNINGS, true
		commonSteps:UnregisterApplication(TestCaseName .. "_Precondition_UnregisterApplication_for_checking_WARNINGS")
		
		Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_From_HMI_capabilities_json_resultCode_WARNINGS"] = function(self)
			
			commonTestCases:DelayedExp(iTimeout)
			
			local parameters = commonFunctions:cloneTable(config.application1.registerAppInterfaceParams)
			parameters.appHMIType = {"MEDIA"}
	
			--mobile side: RegisterAppInterface request
			local CorIdRegister=self.mobileSession:SendRPC("RegisterAppInterface", parameters)

			--hmi side: expect BasicCommunication.OnAppRegistered request
			EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
			{
				application=
				{
					appName=config.application1.registerAppInterfaceParams.appName
				}
			})
			:Do(function(_,data)
				self.appName=data.params.application.appName
				self.applications[config.application1.registerAppInterfaceParams.appName]=data.params.application.appID
			end)
			
			
			-- Read VR parameters from hmi_capabilities.json
			local HmiCapabilities_file = config.pathToSDL .. "hmi_capabilities.json"
			f = assert(io.open(HmiCapabilities_file, "r"))
			fileContent = f:read("*all")
			f:close()
			
			local json = require("modules/json")
			local HmiCapabilities = json.decode(fileContent)

			--mobile side: expect response
			-- SDL sends VR-related parameters to mobile app with value from HMI_capabilities_json
			self.mobileSession:ExpectResponse(CorIdRegister, 
				{
					success = true, 
					resultCode = "WARNINGS",
					vrCapabilities = HmiCapabilities.VR.capabilities,
					language = HmiCapabilities.VR.language
				}
			)
			
			--mobile side: expect notification
			self.mobileSession:ExpectNotification("OnHMIStatus", { systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"})
	 
		end	
	

		
		-- APPLINK-15686 RESUME_FAILED
		--////////////////////////////////////////////////////////////////////////////////////////////--
		-- Check absence of resumption in case HashID in RAI is not match
		--////////////////////////////////////////////////////////////////////////////////////////////--

		--Precondition:
		commonSteps:UnregisterApplication(TestCaseName .. "_Precondition_for_checking_RESUME_FAILED_UnregisterApp")
		commonSteps:RegisterAppInterface(TestCaseName .. "_Precondition_for_checking_RESUME_FAILED_RegisterApp")
		commonSteps:ActivationApp(_, TestCaseName .. "_Precondition_for_checking_RESUME_FAILED_ActivateApp")	


		function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_AddCommand()
			
			--mobile side: sending AddCommand request
			local cid = self.mobileSession:SendRPC("AddCommand",
			{
				cmdID = 1,
				menuParams = 	
				{
					position = 0,
					menuName ="Command 1"
				}, 
				vrCommands = {"VRCommand 1"}
			})
		
			--hmi side: expect UI.AddCommand request 
			EXPECT_HMICALL("UI.AddCommand", 
			{ 
				cmdID = icmdID,		
				menuParams = 
				{
					position = 0,
					menuName ="Command 1"
				}
			})
			:Do(function(_,data)
				--hmi side: sending UI.AddCommand response 
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)

			--hmi side: expect VR.AddCommand request 
			EXPECT_HMICALL("VR.AddCommand", 
			{ 
				cmdID = 1,							
				type = "Command",
				vrCommands = 
				{
					"VRCommand 1"
				}
			})
			:Do(function(_,data)
				--hmi side: sending VR.AddCommand response 
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)	
		
			
			--mobile side: expect AddCommand response 
			EXPECT_RESPONSE(cid, {  success = true, resultCode = "SUCCESS"  })
			:Do(function()
				--mobile side: expect OnHashChange notification
				--Requirement id in JAMA/or Jira ID: APPLINK-15682
				--[Data Resumption]: OnHashChange
				EXPECT_NOTIFICATION("OnHashChange")
					:Do(function(_, data)
						self.currentHashID = data.payload.hashID
					end)
			end)
			
		end

		function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_CreateInteractionChoiceSet()
			--mobile side: sending CreateInteractionChoiceSet request
			local cid = self.mobileSession:SendRPC("CreateInteractionChoiceSet",
												{
													interactionChoiceSetID = 1,
													choiceSet = 
													{ 
														
														{ 
															choiceID = 1,
															menuName = "Choice 1",
															vrCommands = 
															{ 
																"VrChoice 1",
															}
														}
													}
												})
		
			
			--hmi side: expect VR.AddCommand request
			EXPECT_HMICALL("VR.AddCommand", 
						{ 
							cmdID = 1,
							appID = self.applications[config.application1.registerAppInterfaceParams.appName],
							type = "Choice",
							vrCommands = {"VrChoice 1"}
						})
			:Do(function(_,data)
				--hmi side: sending VR.AddCommand response
				grammarIDValue = data.params.grammarID
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
		
			--mobile side: expect CreateInteractionChoiceSet response
			EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
			:Do(function(_,data)
				
				--mobile side: expect OnHashChange notification
				--Requirement id in JAMA/or Jira ID: APPLINK-15682
				--[Data Resumption]: OnHashChange
				EXPECT_NOTIFICATION("OnHashChange")
				:Do(function(_, data)
					self.currentHashID = data.payload.hashID
				end)
			end)
		end

		function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_AddSubMenu()
			
			--mobile side: sending AddSubMenu request
			local cid = self.mobileSession:SendRPC("AddSubMenu",
												{
													menuID = 1,
													position = 500,
													menuName = "SubMenupositive 1"
												})

			--hmi side: expect UI.AddSubMenu request
			EXPECT_HMICALL("UI.AddSubMenu", 
						{ 
							menuID = 1,
							menuParams = {
								position = 500,
								menuName = "SubMenupositive 1"
							}
						})
			:Do(function(_,data)
				--hmi side: sending UI.AddSubMenu response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
			
			--mobile side: expect AddSubMenu response
			EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
			:Do(function()
				--mobile side: expect OnHashChange notification
				
				--Requirement id in JAMA/or Jira ID: APPLINK-15682
				--[Data Resumption]: OnHashChange
				EXPECT_NOTIFICATION("OnHashChange")
					:Do(function(_, data)
						self.currentHashID = data.payload.hashID
					end)
			end)
		end

		function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_SetGlobalProperites()
		
			--mobile side: sending SetGlobalProperties request
			local cid = self.mobileSession:SendRPC("SetGlobalProperties",
												{
													menuTitle = "Menu Title",
													timeoutPrompt = 
													{
														{
															text = "Timeout prompt",
															type = "TEXT"
														}
													},
													vrHelp = 
													{
														{
															position = 1,
															text = "VR help item"
														}
													},
													helpPrompt = 
													{
														{
															text = "Help prompt",
															type = "TEXT"
														}
													},
													vrHelpTitle = "VR help title",
												})


			--hmi side: expect TTS.SetGlobalProperties request
			EXPECT_HMICALL("TTS.SetGlobalProperties",
						{
							timeoutPrompt = 
							{
								{
									text = "Timeout prompt",
									type = "TEXT"
								}
							},
							helpPrompt = 
							{
								{
									text = "Help prompt",
									type = "TEXT"
								}
							}
						})
				:Do(function(_,data)
					--hmi side: sending UI.SetGlobalProperties response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)

			--hmi side: expect UI.SetGlobalProperties request
			EXPECT_HMICALL("UI.SetGlobalProperties",
						{
							menuTitle = "Menu Title",
							vrHelp = 
							{
								{
									position = 1,
									text = "VR help item"
								}
							},
							vrHelpTitle = "VR help title"
						})
			:Do(function(_,data)
				--hmi side: sending UI.SetGlobalProperties response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)


			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
			:Do(function(_,data)

				--Requirement id in JAMA/or Jira ID: APPLINK-15682
				--[Data Resumption]: OnHashChange
				EXPECT_NOTIFICATION("OnHashChange")
				:Do(function(_, data)
					self.currentHashID = data.payload.hashID
				end)
			end)
		end

		

		function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_SubscribeButton()
		
			--mobile side: sending SubscribeButton request
			local cid = self.mobileSession:SendRPC("SubscribeButton", {buttonName = "PRESET_0"})

			--expect Buttons.OnButtonSubscription
			EXPECT_HMINOTIFICATION("Buttons.OnButtonSubscription", 
			{
				appID = self.applications[config.application1.registerAppInterfaceParams.appName], 
				isSubscribed = true, 
				name = "PRESET_0"
			})

			--mobile side: expect SubscribeButton response
			EXPECT_RESPONSE(cid, {success = true, resultCode = "SUCCESS"})
			:Do(function(_,data)
				
				--Requirement id in JAMA/or Jira ID: APPLINK-15682
				--[Data Resumption]: OnHashChange
				EXPECT_NOTIFICATION("OnHashChange")
				:Do(function(_, data)
					self.currentHashID = data.payload.hashID
				end)
			end)
		end
	 
		function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_SubscribeVehicleData()
		
			--mobile side: sending SubscribeVehicleData request
			local cid = self.mobileSession:SendRPC("SubscribeVehicleData",{gps = true})
		
			--hmi side: expect SubscribeVehicleData request
			EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData",{gps = true})
			:Do(function(_,data)
				--hmi side: sending VehicleInfo.SubscribeVehicleData response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { gps = { resultCode = "SUCCESS", dataType = "VEHICLEDATA_GPS"}})	
			end)
		
			--mobile side: expect SubscribeVehicleData response
			EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
			:Do(function(_,data)
				
				--mobile side: expect OnHashChange notification
				--Requirement id in JAMA/or Jira ID: APPLINK-15682
				--[Data Resumption]: OnHashChange
				EXPECT_NOTIFICATION("OnHashChange")
				:Do(function(_, data)
					self.currentHashID = data.payload.hashID
				end)
			end)
		end

		function Test:Precondition_for_checking_RESUME_FAILED_AddResumptionData_SubscribeWayPoints()
			
			local cid = self.mobileSession:SendRPC("SubscribeWayPoints", {})

			--hmi side: expected SubscribeWayPoints request
			EXPECT_HMICALL("Navigation.SubscribeWayPoints")
			:Do(function(_,data)
				--hmi side: sending Navigation.SubscribeWayPoints response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
			
			--mobile side: SubscribeWayPoints response
			EXPECT_RESPONSE(cid, {success = true , resultCode = "SUCCESS"})
			:Do(function(_,data)
				--Requirement id in JAMA/or Jira ID: APPLINK-15682
				--[Data Resumption]: OnHashChange

				--userPrint(31,"DEFECT ID: APPLINK-25808")
				EXPECT_NOTIFICATION("OnHashChange")
				:Do(function(_, data)
					self.currentHashID = data.payload.hashID
				end)
			end)
		end
		
		function Test:Precondition_for_checking_RESUME_FAILED_CloseConnection()
			self.mobileConnection:Close() 
		end

		function Test:Precondition_for_checking_RESUME_FAILED_ConnectMobile()
			self:connectMobile()
		end

		function Test:Precondition_for_checking_RESUME_FAILED_StartSession()
		   self.mobileSession = mobile_session.MobileSession(
			  self,
			  self.mobileConnection,
			  config.application1.registerAppInterfaceParams)

			self.mobileSession:StartService(7)
		end

		Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_From_HMI_capabilities_json_resultCode_RESUME_FAILED"] = function(self)
		
			commonTestCases:DelayedExp(iTimeout)
			
			local parameters = commonFunctions:cloneTable(config.application1.registerAppInterfaceParams)
			parameters.hashID = "sdfgTYWRTdfhsdfgh"

			--mobile side: RegisterAppInterface request
			local CorIdRegister=self.mobileSession:SendRPC("RegisterAppInterface", parameters)

			--hmi side: expect BasicCommunication.OnAppRegistered request
			EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
			{
				application=
				{
					appName=config.application1.registerAppInterfaceParams.appName
				}
			})
			:Do(function(_,data)
				self.appName=data.params.application.appName
				self.applications[config.application1.registerAppInterfaceParams.appName]=data.params.application.appID
			end)
			
			
			-- Read VR parameters from hmi_capabilities.json
			local HmiCapabilities_file = config.pathToSDL .. "hmi_capabilities.json"
			f = assert(io.open(HmiCapabilities_file, "r"))
			fileContent = f:read("*all")
			f:close()
			
			local json = require("modules/json")
			local HmiCapabilities = json.decode(fileContent)

			--mobile side: expect response
			-- SDL sends VR-related parameters to mobile app with value from HMI_capabilities_json
			self.mobileSession:ExpectResponse(CorIdRegister, 
				{
					success = true, 
					resultCode = "RESUME_FAILED",
					vrCapabilities = HmiCapabilities.VR.capabilities,
					language = HmiCapabilities.VR.language
				}
			)
			
			--mobile side: expect notification
			self.mobileSession:ExpectNotification("OnHMIStatus", 
						{systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"}, 
						{systemContext="MAIN", hmiLevel="FULL", audioStreamingState="AUDIBLE"}
			)
			:Times(2)
			
			EXPECT_HMICALL("UI.AddCommand")
			:Times(0)

			EXPECT_HMICALL("VR.AddCommand")
			:Times(0)

			EXPECT_HMICALL("UI.AddSubMenu")
			:Times(0)

			--APPLINK-9532: Sending TTS.SetGlobalProperties to VCA in case no obtained from mobile app
			--Description: When registering the app as soon as the app gets HMI Level NONE, SDL sends TTS.SetGlobalProperties(helpPrompt[]) with an empty array of helpPrompts (just helpPrompts, no timeoutPrompt).
			--hmi side: expect TTS.SetGlobalProperties request
			EXPECT_HMICALL("TTS.SetGlobalProperties")
			:Do(function(_,data)
				--hmi side: sending UI.SetGlobalProperties response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
			:ValidIf(function(_,data)
				if data.params.timeoutPrompt then
					commonFunctions:printError("TTS.SetGlobalProperties request came with unexpected timeoutPrompt parameter.")
					return false
				elseif data.params.helpPrompt and #data.params.helpPrompt == 0 then
					return true
				elseif data.params.helpPrompt == nil then
					commonFunctions:printError("UI.SetGlobalProperties request came without helpPrompt")
					return false
				else 
					commonFunctions:printError("UI.SetGlobalProperties request came with some unexpected values of helpPrompt, array length is " .. tostring(#data.params.helpPrompt))
					return false
				end
			end)


			EXPECT_HMICALL("UI.SetGlobalProperties")
			:Times(0)

			--mobile side: expect OnHashChange notification
			EXPECT_NOTIFICATION("OnHashChange")
			:Times(0)

		end	


	end
	
	-----------------------------------------------------------------------------------------------
	--CRQ #2: APPLINK-20932 (single VR)
	--Verification criteria:	
		-- In case SDL does NOT receive VR.IsReady_response during <DefaultTimeout> from HMI
		-- and mobile app sends any single VR-related RPC
		-- SDL must:
		-- transfer this VR-related RPC to HMI
		-- respond with <received_resultCode_from_HMI> to mobile app	
	-----------------------------------------------------------------------------------------------
	local function APPLINK_20932_single_VR_RPCs(TestCaseName)

		-- List of all resultCodes
		local TestData = {
		
				{success = true, resultCode = "SUCCESS", 			expected_resultCode = "SUCCESS"},
				{success = true, resultCode = "WARNINGS", 			expected_resultCode = "WARNINGS"},
				{success = true, resultCode = "WRONG_LANGUAGE", 		expected_resultCode = "WRONG_LANGUAGE"},
				{success = true, resultCode = "RETRY", 				expected_resultCode = "RETRY"},
				{success = true, resultCode = "SAVED", 				expected_resultCode = "SAVED"},
								
				{success = false, resultCode = "", 		expected_resultCode = "GENERIC_ERROR"}, --not respond
				{success = false, resultCode = "ABC", 	expected_resultCode = "INVALID_DATA"},
				
				{success = false, resultCode = "UNSUPPORTED_REQUEST", 	expected_resultCode = "UNSUPPORTED_REQUEST"},
				{success = false, resultCode = "DISALLOWED", 			expected_resultCode = "DISALLOWED"},
				{success = false, resultCode = "USER_DISALLOWED", 		expected_resultCode = "USER_DISALLOWED"},
				{success = false, resultCode = "REJECTED", 				expected_resultCode = "REJECTED"},
				{success = false, resultCode = "ABORTED", 				expected_resultCode = "ABORTED"},
				{success = false, resultCode = "IGNORED", 				expected_resultCode = "IGNORED"},
				{success = false, resultCode = "IN_USE", 				expected_resultCode = "IN_USE"},
				{success = false, resultCode = "VEHICLE_DATA_NOT_AVAILABLE", expected_resultCode = "VEHICLE_DATA_NOT_AVAILABLE"},
				{success = false, resultCode = "TIMED_OUT", 					expected_resultCode = "TIMED_OUT"},
				{success = false, resultCode = "INVALID_DATA", 				expected_resultCode = "INVALID_DATA"},
				{success = false, resultCode = "CHAR_LIMIT_EXCEEDED", 		expected_resultCode = "CHAR_LIMIT_EXCEEDED"},
				{success = false, resultCode = "INVALID_ID", 				expected_resultCode = "INVALID_ID"},
				{success = false, resultCode = "DUPLICATE_NAME", 			expected_resultCode = "DUPLICATE_NAME"},
				{success = false, resultCode = "APPLICATION_NOT_REGISTERED", expected_resultCode = "APPLICATION_NOT_REGISTERED"},
				{success = false, resultCode = "OUT_OF_MEMORY", 				expected_resultCode = "OUT_OF_MEMORY"},
				{success = false, resultCode = "TOO_MANY_PENDING_REQUESTS", 	expected_resultCode = "TOO_MANY_PENDING_REQUESTS"},
				{success = false, resultCode = "GENERIC_ERROR", 				expected_resultCode = "GENERIC_ERROR"},
				{success = false, resultCode = "TRUNCATED_DATA", 			expected_resultCode = "TRUNCATED_DATA"}
			}
			
			
		-- 1. Add.Command
		for i = 1, #TestData do
			
			Test[TestCaseName .. "_AddCommand_VRCommandsOnly_".. tostring(TestData[i].resultCode)] = function(self)
			
				commonTestCases:DelayedExp(iTimeout)
		
				--mobile side: sending AddCommand request
				local cid = self.mobileSession:SendRPC("AddCommand",
				{
					cmdID = i,
					vrCommands = {"vrCommands_" .. tostring(i)}
				})
					
				--hmi side: expect VR.AddCommand request
				EXPECT_HMICALL("VR.AddCommand", 
				{ 
					cmdID = i,
					type = "Command",
					vrCommands = {"vrCommands_" .. tostring(i)}
				})
				:Do(function(_,data)
					--hmi side: sending response
					if (TestData[i].resultCode == "") then
						-- HMI does not respond					
					else
						if TestData[i].success == true then 
							self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
						else
							self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "error message")
						end						
					end
					
				end)
				
				--mobile side: expect AddCommand response and OnHashChange notification
				if TestData[i].success == true then 
					
					EXPECT_RESPONSE(cid, { success = TestData[i].success , resultCode = TestData[i].expected_resultCode })
					
					EXPECT_NOTIFICATION("OnHashChange")
					:Timeout(iTimeout)
					
				else
					
					EXPECT_RESPONSE(cid, { success = TestData[i].success , resultCode = TestData[i].expected_resultCode, info = "error message"})
					
					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)
					
				end

			end
		
		end
		
		-- 2. DeleteCommand
		for i = 1, #TestData do

			Test[TestCaseName .. "_DeleteCommand_VRCommandsOnly_".. tostring(TestData[i].resultCode)] = function(self)
			
				commonTestCases:DelayedExp(iTimeout)
				
				--mobile side: sending DeleteCommand request
				local cid = self.mobileSession:SendRPC("DeleteCommand", {cmdID = i})
				
				--hmi side: expect VR.DeleteCommand request
				EXPECT_HMICALL("VR.DeleteCommand", {cmdID = commandID})
				:Do(function(_,data)
					--hmi side: sending VR.DeleteCommand response
					if (TestData[i].resultCode == "") then
						-- HMI does not respond							
					else
						if TestData[i].success == true then 
							self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
						else
							self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "error message")
						end
					end						
				end)

				
				--mobile side: expect DeleteCommand response and OnHashChange notification
				if TestData[i].success == true then 
					
					EXPECT_RESPONSE(cid, { success = TestData[i].success , resultCode = TestData[i].expected_resultCode })
					
					EXPECT_NOTIFICATION("OnHashChange")
					:Timeout(iTimeout)
					
				else
					EXPECT_RESPONSE(cid, { success = TestData[i].success , resultCode = TestData[i].expected_resultCode, info = "error message"})
					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)
				end
				
			end		
		
		end
		

	end

	-----------------------------------------------------------------------------------------------
	--CRQ #3: APPLINK-25044 (split RPCs)
	--Verification criteria:
		-- In case HMI does NOT respond to VR.IsReady_request
		-- and mobile app sends RPC to SDL that must be split to
		-- -> VR RPC
		-- -> any other <Interface>.RPC (<Interface> - TTS, UI)
		-- SDL must:
		-- transfer both VR RPC and <Interface>.RPC to HMI (in case <Interface> is supported by system)
		-- respond with '<received_resultCode_from_HMI>' to mobile app (please see list with resultCodes below)	
	-----------------------------------------------------------------------------------------------
	local function APPLINK_25044_split_RPCs(TestCaseName)
		--3.1: VR does not respond
		local function checksplit_VR_RPCs_VR_does_not_Respond(TestCaseName)
		
		local TestData = {
			
					{success = true, resultCode = "SUCCESS", 				expected_resultCode = "SUCCESS"},
					{success = true, resultCode = "WARNINGS", 				expected_resultCode = "WARNINGS"},
					{success = true, resultCode = "WRONG_LANGUAGE", 		expected_resultCode = "WRONG_LANGUAGE"},
					{success = true, resultCode = "RETRY", 				expected_resultCode = "RETRY"},
					{success = true, resultCode = "SAVED", 				expected_resultCode = "SAVED"},
							
					{success = false, resultCode = "", 	expected_resultCode = "GENERIC_ERROR"},
					{success = false, resultCode = "ABC", expected_resultCode = "INVALID_DATA"},
					
					{success = false, resultCode = "UNSUPPORTED_REQUEST", expected_resultCode = "UNSUPPORTED_REQUEST"},
					{success = false, resultCode = "DISALLOWED", expected_resultCode = "DISALLOWED"},
					{success = false, resultCode = "USER_DISALLOWED", expected_resultCode = "USER_DISALLOWED"},
					{success = false, resultCode = "REJECTED", expected_resultCode = "REJECTED"},
					{success = false, resultCode = "ABORTED", expected_resultCode = "ABORTED"},
					{success = false, resultCode = "IGNORED", expected_resultCode = "IGNORED"},
					{success = false, resultCode = "IN_USE", 	expected_resultCode = "IN_USE"},
					{success = false, resultCode = "VEHICLE_DATA_NOT_AVAILABLE", expected_resultCode = "VEHICLE_DATA_NOT_AVAILABLE"},
					{success = false, resultCode = "TIMED_OUT", expected_resultCode = "TIMED_OUT"},
					{success = false, resultCode = "INVALID_DATA", expected_resultCode = "INVALID_DATA"},
					{success = false, resultCode = "CHAR_LIMIT_EXCEEDED", expected_resultCode = "CHAR_LIMIT_EXCEEDED"},
					{success = false, resultCode = "INVALID_ID", 	expected_resultCode = "INVALID_ID"},
					{success = false, resultCode = "DUPLICATE_NAME", expected_resultCode = "DUPLICATE_NAME"},
					{success = false, resultCode = "APPLICATION_NOT_REGISTERED", expected_resultCode = "APPLICATION_NOT_REGISTERED"},
					{success = false, resultCode = "OUT_OF_MEMORY", expected_resultCode = "OUT_OF_MEMORY"},
					{success = false, resultCode = "TOO_MANY_PENDING_REQUESTS", expected_resultCode = "TOO_MANY_PENDING_REQUESTS"},
					{success = false, resultCode = "GENERIC_ERROR", expected_resultCode = "GENERIC_ERROR"},
					{success = false, resultCode = "TRUNCATED_DATA", expected_resultCode = "TRUNCATED_DATA"},

				}
				
			-- 1. Add.Command
			for i = 1, #TestData do
				
				Test[TestCaseName .. "_AddCommand_VR_does_not_respond_UI_responds_".. tostring(TestData[i].resultCode)] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
			
					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC("AddCommand",
					{
						cmdID = i,
						vrCommands = {"vrCommands_" .. tostring(i)},
						menuParams = {position = 1, menuName = "Command " .. tostring(i)}
					})
						
					--hmi side: expect VR.AddCommand request
					EXPECT_HMICALL("VR.AddCommand", 
					{ 
						cmdID = i,
						type = "Command",
						vrCommands = {"vrCommands_" .. tostring(i)}
					})
					:Do(function(_,data)
						-- HMI does not respond							
					end)
					
					--hmi side: expect UI.AddCommand request 
					EXPECT_HMICALL("UI.AddCommand", 
					{ 
						cmdID = i,		
						menuParams = {position = 1, menuName ="Command "..tostring(i)}
					})
					:Do(function(_,data)
						--hmi side: sending UI.AddCommand response
						if (TestData[i].resultCode == "") then
							-- HMI does not respond					
						else
							if TestData[i].success == true then 
								self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
							else
								self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "error message")
							end						
						end
					end)
					
					
					--mobile side: expect AddCommand response
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
					:Timeout(12000)

					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)

				end
			
			end
			
			-- 2. DeleteCommand
				--Precondition: AddCommand 1
				Test[TestCaseName .. "_Precondition_AddCommand_1"] = function(self)
				

					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC("AddCommand",
					{
						cmdID = 1,
						vrCommands = {"vrCommands_1"},
						menuParams = {position = 1, menuName = "Command 1"}
					})
						
					--hmi side: expect VR.AddCommand request
					EXPECT_HMICALL("VR.AddCommand", 
					{ 
						cmdID = 1,
						type = "Command",
						vrCommands = {"vrCommands_1"}
					})
					:Do(function(_,data)
						--hmi side: sending VR.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})						
					end)
					
					--hmi side: expect UI.AddCommand request 
					EXPECT_HMICALL("UI.AddCommand", 
					{ 
						cmdID = 1,		
						menuParams = {position = 1, menuName ="Command 1"}
					})
					:Do(function(_,data)
						--hmi side: sending UI.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
					end)
					
					
					--mobile side: expect AddCommand response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")

				end
			
			
			for i = 1, #TestData do
									
				Test[TestCaseName .. "_DeleteCommand_VR_does_not_respond_UI_responds_".. tostring(TestData[i].resultCode)] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
					
					--mobile side: sending DeleteCommand request
					local cid = self.mobileSession:SendRPC("DeleteCommand", {cmdID = 1})
					
					--hmi side: expect VR.DeleteCommand request
					EXPECT_HMICALL("VR.DeleteCommand", {cmdID = 1})
					:Do(function(_,data)
						-- HMI does not respond											
					end)

					--hmi side: expect UI.DeleteCommand request
					EXPECT_HMICALL("UI.DeleteCommand", {cmdID = 1})
					:Do(function(_,data)
						--hmi side: sending UI.DeleteCommand response
						if (TestData[i].resultCode == "") then
							-- HMI does not respond					
						else
							if TestData[i].success == true then
								self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
							else
								self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "error message")
							end						
						end
						
					end)
					
					
					--mobile side: expect DeleteCommand response 
					EXPECT_RESPONSE(cid, {success = false , resultCode = "GENERIC_ERROR"})
					:Timeout(12000)

					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)
				end		
			
			end
			
			
		
			-- 3. PerformInteraction: Precondition: CreateInteractionChoiceSet
			for i = 1, #TestData do
			

				Test[TestCaseName .. "_PerformInteraction_Precondition_CreateInteractionChoiceSet_" .. i] = function(self)
						--mobile side: sending CreateInteractionChoiceSet request
					local cid = self.mobileSession:SendRPC("CreateInteractionChoiceSet",
															{
																interactionChoiceSetID = i,
																choiceSet = {{ 
																					choiceID = i,
																					menuName ="Choice" .. tostring(i),
																					vrCommands = 
																					{ 
																						"VrChoice" .. tostring(i),
																					}, 
																					image =
																					{ 
																						value ="icon.png",
																						imageType ="STATIC",
																					}
																			}}
															})
					
					--hmi side: expect VR.AddCommand
					EXPECT_HMICALL("VR.AddCommand", 
								{ 
									cmdID = i,
									type = "Choice",
									vrCommands = {"VrChoice"..tostring(i) }
								})
					:Do(function(_,data)						
						--hmi side: sending VR.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		
					
					--mobile side: expect CreateInteractionChoiceSet response
					EXPECT_RESPONSE(cid, { resultCode = "SUCCESS", success = true  })
					
				end

			end
			
			-- 3. PerformInteraction 
			--ToDo: Due to defect APPLINK-26882, current script just execute case HMI responds PerformInteraction_VR_ONLY success.
			--for i = 1, #TestData do					
			for i = 1, 1 do					
				
				Test[TestCaseName .. "_PerformInteraction_VR_does_not_respond_UI_responds_" .. tostring(TestData[i].resultCode)] = function(self)

					local params = 
						{		       
							initialText = "StartPerformInteraction",
							initialPrompt = { 
								{ 
									text = "Makeyourchoice",
									type = "TEXT"
								}
							}, 
							interactionMode = "VR_ONLY",
							interactionChoiceSetIDList = {i},
							helpPrompt = { 
								{ 
									text = "Selectthevariant",
									type = "TEXT"
								}
							}, 
							timeoutPrompt = { 
								{ 
									text = "TimeoutPrompt",
									type = "TEXT"
								}
							}, 
							timeout = 5000,
							vrHelp = {
										{ 
											text = "New  VRHelp",
											position = 1,	
											image = {
														value = "icon.png",
														imageType = "STATIC",
													} 
										}
									} 
						}
						
					
					--mobile side: sending PerformInteraction request
					local cid = self.mobileSession:SendRPC("PerformInteraction", params)
					
					--hmi side: expect VR.PerformInteraction request 
					EXPECT_HMICALL("VR.PerformInteraction", 
					{	
						helpPrompt = params.helpPrompt,
						initialPrompt = params.initialPrompt,
						timeout = params.timeout,
						timeoutPrompt = params.timeoutPrompt
					})
					:Do(function(_,data)
						--Send notification to start TTS & VR						
						self.hmiConnection:SendNotification("TTS.Started")
						self.hmiConnection:SendNotification("VR.Started")
						self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = self.applications[ config.application1.registerAppInterfaceParams.appName], systemContext = "VRSESSION" })

						
						local function vrResponse()
						
							--Send VR.PerformInteraction response 
							--self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {choiceID = i})
							
							--Send notification to stop TTS & VR
							self.hmiConnection:SendNotification("TTS.Stopped")
							self.hmiConnection:SendNotification("VR.Stopped")		
							
							self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = self.applications[ config.application1.registerAppInterfaceParams.appName], systemContext = "MAIN" })							
							
						end
						
						RUN_AFTER(vrResponse, 10)
						
					end)
					
					--hmi side: expect UI.PerformInteraction request 
					EXPECT_HMICALL("UI.PerformInteraction", 
					{
						timeout = params.timeout,
						--Updated: Lines are commented due to APPLINK-16052, please uncomment once resolved
						--vrHelp = params.vrHelp,
						--vrHelpTitle = params.initialText,
					})
					:Do(function(_,data)
						local function uiResponse()
							
							if (TestData[i].resultCode == "") then
								-- HMI does not respond					
							else
								if TestData[i].success == true then
									self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
								else
									self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "error message")
								end						
							end
							
						end
						RUN_AFTER(uiResponse, 10)
					end)
					
					--mobile side: OnHMIStatus notifications
					EXPECT_NOTIFICATION("OnHMIStatus",
							{ systemContext = "MAIN", 		hmiLevel = "FULL", audioStreamingState = "ATTENUATED"  },
							{ systemContext = "MAIN", 		hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE" },
							{ systemContext = "VRSESSION",  hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE" },
							{ systemContext = "VRSESSION",  hmiLevel = "FULL", audioStreamingState = "AUDIBLE"    },
							{ systemContext = "MAIN",  		hmiLevel = "FULL", audioStreamingState = "AUDIBLE"    })
						:Times(5)

					
					--mobile side: expect PerformInteraction response
					EXPECT_RESPONSE(cid, {success = false, resultCode = "GENERIC_ERROR"})
					:Timeout(12000)
				end
			
			end
			
			--4. ChangeRegistration
			for i = 1, #TestData do
				Test[TestCaseName .. "_ChangeRegistration_VR_does_not_respond_UI_responds_" .. TestData[i].resultCode] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
					
					local request = {	language ="EN-US",
										hmiDisplayLanguage ="EN-US",
										appName ="SyncProxyTester_" .. tostring(i),
										ttsName = {{text ="SyncProxyTester", type ="TEXT"}},
										ngnMediaScreenAppName ="SPT",
										vrSynonyms = {"VRSyncProxyTester"}}

					--mobile side: send ChangeRegistration request
					local cid = self.mobileSession:SendRPC("ChangeRegistration", request)

					--hmi side: expect UI.ChangeRegistration request
					EXPECT_HMICALL("UI.ChangeRegistration",
					{
						appName = request.appName,
						language = request.hmiDisplayLanguage,
						ngnMediaScreenAppName = request.ngnMediaScreenAppName
					})
					:Do(function(_,data)
						--hmi side: send UI.ChangeRegistration response
						self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
					end)

					--hmi side: expect VR.ChangeRegistration request
					EXPECT_HMICALL("VR.ChangeRegistration", {language = request.language, vrSynonyms = request.vrSynonyms})
					:Do(function(_,data)						
						--HMI does not send VR.ChangeRegistration response 
					end)

					--hmi side: expect TTS.ChangeRegistration request
					EXPECT_HMICALL("TTS.ChangeRegistration",
					{
						language = request.language,
						ttsName = request.ttsName
					})
					:Do(function(_,data)
						--hmi side: send TTS.ChangeRegistration response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS",{})
					end)

					--mobile side: expect PerformInteraction response
					EXPECT_RESPONSE(cid, {success = false, resultCode = "GENERIC_ERROR"})
					:Timeout(12000)
					
					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Timeout(12000)
					:Times(0)

				end
			end
			
			
		end
			
		checksplit_VR_RPCs_VR_does_not_Respond(TestCaseName)


		--3.2: VR responds UNSUPPORTED_RESOURCE
		
		--3.2.1: Other interfaces respond successful resultCodes
		local function checksplit_VR_RPCs_VR_Responds_UNSUPPORTED_RESOURCE_Others_respond_success_resultCodes(TestCaseName)
		
		local TestData = {
					{resultCode = "SUCCESS"},
					{resultCode = "WARNINGS"},
					{resultCode = "WRONG_LANGUAGE"},
					{resultCode = "RETRY"},
					{resultCode = "SAVED"}
				}
				
			-- 1. Add.Command
			for i = 1, #TestData do
				
				Test[TestCaseName .. "_AddCommand_VR_responds_UNSUPPORTED_RESOURCE_UI_responds_".. tostring(TestData[i].resultCode)] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
			
					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC("AddCommand",
					{
						cmdID = i,
						vrCommands = {"vrCommands_" .. tostring(i)},
						menuParams = {position = 1, menuName = "Command " .. tostring(i)}
					})
						
					--hmi side: expect VR.AddCommand request
					EXPECT_HMICALL("VR.AddCommand", 
					{ 
						cmdID = i,
						type = "Command",
						vrCommands = {"vrCommands_" .. tostring(i)}
					})
					:Do(function(_,data)
						--hmi side: sending VR.AddCommand response
						self.hmiConnection:SendError(data.id, data.method, "UNSUPPORTED_RESOURCE", "error message")					
					end)
					
					--hmi side: expect UI.AddCommand request 
					EXPECT_HMICALL("UI.AddCommand", 
					{ 
						cmdID = i,		
						menuParams = {position = 1, menuName ="Command "..tostring(i)}
					})
					:Do(function(_,data)
						--hmi side: sending UI.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
					end)
					
					
					--mobile side: expect AddCommand response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "UNSUPPORTED_RESOURCE", info = "VR is not supported by system"})

					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
				end
			
			end
			
			-- 2. DeleteCommand
				--Precondition: AddCommand 1
				Test[TestCaseName .. "_Precondition_AddCommand_1"] = function(self)
				

					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC("AddCommand",
					{
						cmdID = 1,
						vrCommands = {"vrCommands_1"},
						menuParams = {position = 1, menuName = "Command 1"}
					})
						
					--hmi side: expect VR.AddCommand request
					EXPECT_HMICALL("VR.AddCommand", 
					{ 
						cmdID = 1,
						type = "Command",
						vrCommands = {"vrCommands_1"}
					})
					:Do(function(_,data)
						--hmi side: sending VR.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})						
					end)
					
					--hmi side: expect UI.AddCommand request 
					EXPECT_HMICALL("UI.AddCommand", 
					{ 
						cmdID = 1,		
						menuParams = {position = 1, menuName ="Command 1"}
					})
					:Do(function(_,data)
						--hmi side: sending UI.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)
					
					
					--mobile side: expect AddCommand response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")

				end
			
			
			for i = 1, #TestData do
									
				Test[TestCaseName .. "_DeleteCommand_VR_responds_UNSUPPORTED_RESOURCE_UI_responds_".. tostring(TestData[i].resultCode)] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
					
					--mobile side: sending DeleteCommand request
					local cid = self.mobileSession:SendRPC("DeleteCommand", {cmdID = 1})
					
					--hmi side: expect VR.DeleteCommand request
					EXPECT_HMICALL("VR.DeleteCommand", {cmdID = 1})
					:Do(function(_,data)
						--hmi side: sending VR.DeleteCommand response
						self.hmiConnection:SendError(data.id, data.method, "UNSUPPORTED_RESOURCE", "error message")												
					end)

					--hmi side: expect UI.DeleteCommand request
					EXPECT_HMICALL("UI.DeleteCommand", {cmdID = 1})
					:Do(function(_,data)
						--hmi side: sending UI.DeleteCommand response
						self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
					end)
					
					
					--mobile side: expect DeleteCommand response 
					EXPECT_RESPONSE(cid, {success = true , resultCode = "UNSUPPORTED_RESOURCE", info = "VR is not supported by system"})

					EXPECT_NOTIFICATION("OnHashChange")
				end		
			
			end
			
			
		
			-- 3. PerformInteraction: Precondition: CreateInteractionChoiceSet
			for i = 1, #TestData do
			

				Test[TestCaseName .. "_PerformInteraction_Precondition_CreateInteractionChoiceSet_" .. i] = function(self)
						--mobile side: sending CreateInteractionChoiceSet request
					local cid = self.mobileSession:SendRPC("CreateInteractionChoiceSet",
															{
																interactionChoiceSetID = i,
																choiceSet = {{ 
																					choiceID = i,
																					menuName ="Choice" .. tostring(i),
																					vrCommands = 
																					{ 
																						"VrChoice" .. tostring(i),
																					}, 
																					image =
																					{ 
																						value ="icon.png",
																						imageType ="STATIC",
																					}
																			}}
															})
					
					--hmi side: expect VR.AddCommand
					EXPECT_HMICALL("VR.AddCommand", 
								{ 
									cmdID = i,
									type = "Choice",
									vrCommands = {"VrChoice"..tostring(i) }
								})
					:Do(function(_,data)						
						--hmi side: sending VR.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		
					
					--mobile side: expect CreateInteractionChoiceSet response
					EXPECT_RESPONSE(cid, { resultCode = "SUCCESS", success = true  })
					
				end

			end
			
			-- 3. PerformInteraction
			--ToDo: Due to defect APPLINK-26882, current script just execute case HMI responds PerformInteraction success.
			--for i = 1, #TestData do					
			for i = 1, 1 do					
				
				Test[TestCaseName .. "_PerformInteraction_VR_responds_UNSUPPORTED_RESOURCE_UI_responds_" .. tostring(TestData[i].resultCode)] = function(self)

					local params = 
						{		       
							initialText = "StartPerformInteraction",
							initialPrompt = { 
								{ 
									text = "Makeyourchoice",
									type = "TEXT"
								}
							}, 
							interactionMode = "VR_ONLY",
							interactionChoiceSetIDList = {i},
							helpPrompt = { 
								{ 
									text = "Selectthevariant",
									type = "TEXT"
								}
							}, 
							timeoutPrompt = { 
								{ 
									text = "TimeoutPrompt",
									type = "TEXT"
								}
							}, 
							timeout = 5000,
							vrHelp = {
										{ 
											text = "New  VRHelp",
											position = 1,	
											image = {
														value = "icon.png",
														imageType = "STATIC",
													} 
										}
									} 
						}
						
					
					--mobile side: sending PerformInteraction request
					local cid = self.mobileSession:SendRPC("PerformInteraction", params)
					
					--hmi side: expect VR.PerformInteraction request 
					EXPECT_HMICALL("VR.PerformInteraction", 
					{	
						helpPrompt = params.helpPrompt,
						initialPrompt = params.initialPrompt,
						timeout = params.timeout,
						timeoutPrompt = params.timeoutPrompt
					})
					:Do(function(_,data)

						--Send VR.PerformInteraction response 
						self.hmiConnection:SendError(data.id, data.method, "UNSUPPORTED_RESOURCE", "error message")			
						
					end)
					
					--hmi side: expect UI.PerformInteraction request 
					EXPECT_HMICALL("UI.PerformInteraction", 
					{
						timeout = params.timeout,
						vrHelp = params.vrHelp,
						vrHelpTitle = params.initialText,
					})
					:Do(function(_,data)
						--HMI sends UI.PerformInteraction response 
						self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
					end)
					
					--mobile side: OnHMIStatus notifications
					EXPECT_NOTIFICATION("OnHMIStatus",{})
					:Times(0)

					
					--mobile side: expect PerformInteraction response
					EXPECT_RESPONSE(cid, {success = true, resultCode = "UNSUPPORTED_RESOURCE", info = "VR is not supported by system"})

				end
			
			end
			
			--4. ChangeRegistration
			for i = 1, #TestData do
				Test[TestCaseName .. "_ChangeRegistration_VR_responds_UNSUPPORTED_RESOURCE_UI_responds_" .. TestData[i].resultCode] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
					
					local request = {	language ="EN-US",
										hmiDisplayLanguage ="EN-US",
										appName ="SyncProxyTester_" .. tostring(i),
										ttsName = {{text ="SyncProxyTester", type ="TEXT"}},
										ngnMediaScreenAppName ="SPT",
										vrSynonyms = {"VRSyncProxyTester"}}

					--mobile side: send ChangeRegistration request
					local cid = self.mobileSession:SendRPC("ChangeRegistration", request)

					--hmi side: expect UI.ChangeRegistration request
					EXPECT_HMICALL("UI.ChangeRegistration",
					{
						appName = request.appName,
						language = request.hmiDisplayLanguage,
						ngnMediaScreenAppName = request.ngnMediaScreenAppName
					})
					:Do(function(_,data)
						--hmi side: send UI.ChangeRegistration response
						self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
					end)

					--hmi side: expect VR.ChangeRegistration request
					EXPECT_HMICALL("VR.ChangeRegistration", {language = request.language, vrSynonyms = request.vrSynonyms})
					:Do(function(_,data)						
						--hmi side: send VR.ChangeRegistration response
						self.hmiConnection:SendError(data.id, data.method, "UNSUPPORTED_RESOURCE", "error message")
						
					end)

					--hmi side: expect TTS.ChangeRegistration request
					EXPECT_HMICALL("TTS.ChangeRegistration",
					{
						language = request.language,
						ttsName = request.ttsName
					})
					:Do(function(_,data)
						--hmi side: send TTS.ChangeRegistration response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS",{})
					end)

					--mobile side: expect response
					EXPECT_RESPONSE(cid, {success = true, resultCode = "UNSUPPORTED_RESOURCE", info = "VR is not supported by system"})
					
					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")

				end
			end
			
		end
		
		checksplit_VR_RPCs_VR_Responds_UNSUPPORTED_RESOURCE_Others_respond_success_resultCodes(TestCaseName)

		
		--3.2.2: Other interfaces respond unsuccessful resultCodes
		local function checksplit_VR_RPCs_VR_Responds_UNSUPPORTED_RESOURCE_Others_respond_unsuccess_resultCodes(TestCaseName)
		

			-- List of erroneous resultCodes (success:false)
			local TestData = {
			
								{resultCode = "UNSUPPORTED_REQUEST"			},
								{resultCode = "DISALLOWED", 				},
								{resultCode = "USER_DISALLOWED", 			},
								{resultCode = "REJECTED", 					},
								{resultCode = "ABORTED", 					},
								{resultCode = "IGNORED", 					},
								{resultCode = "IN_USE", 					},
								{resultCode = "VEHICLE_DATA_NOT_AVAILABLE", },
								{resultCode = "TIMED_OUT", 					},
								{resultCode = "INVALID_DATA", 				},
								{resultCode = "CHAR_LIMIT_EXCEEDED", 		},
								{resultCode = "INVALID_ID", 				},
								{resultCode = "DUPLICATE_NAME", 			},
								{resultCode = "APPLICATION_NOT_REGISTERED", },
								{resultCode = "OUT_OF_MEMORY", 				},
								{resultCode = "TOO_MANY_PENDING_REQUESTS", 	},
								{resultCode = "GENERIC_ERROR", 				},
								{resultCode = "TRUNCATED_DATA", 			},
								{resultCode = "UNSUPPORTED_RESOURCE", 		}
							}
							
			-- 1. Add.Command
			for i = 1, #TestData do
				
				Test[TestCaseName .. "_AddCommand_VR_responds_UNSUPPORTED_RESOURCE_UI_responds_".. tostring(TestData[i].resultCode)] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
			
					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC("AddCommand",
					{
						cmdID = i,
						vrCommands = {"vrCommands_" .. tostring(i)},
						menuParams = {position = 1, menuName = "Command " .. tostring(i)}
					})
						
					--hmi side: expect VR.AddCommand request
					EXPECT_HMICALL("VR.AddCommand", 
					{ 
						cmdID = i,
						type = "Command",
						vrCommands = {"vrCommands_" .. tostring(i)}
					})
					:Do(function(_,data)
						--hmi side: sending VR.AddCommand response
						self.hmiConnection:SendError(data.id, data.method, "UNSUPPORTED_RESOURCE", "error message")					
					end)
					
					--hmi side: expect UI.AddCommand request 
					EXPECT_HMICALL("UI.AddCommand", 
					{ 
						cmdID = i,		
						menuParams = {position = 1, menuName ="Command "..tostring(i)}
					})
					:Do(function(_,data)
						--hmi side: sending UI.AddCommand response
						self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "error message 2")
					end)
					
					
					--mobile side: expect AddCommand response
					EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE", info = "VR is not supported by system"})

					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)
				end
			
			end
			
			-- 2. DeleteCommand
				--Precondition: AddCommand 1
				Test[TestCaseName .. "_Precondition_AddCommand_1"] = function(self)
				

					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC("AddCommand",
					{
						cmdID = 1,
						vrCommands = {"vrCommands_1"},
						menuParams = {position = 1, menuName = "Command 1"}
					})
						
					--hmi side: expect VR.AddCommand request
					EXPECT_HMICALL("VR.AddCommand", 
					{ 
						cmdID = 1,
						type = "Command",
						vrCommands = {"vrCommands_1"}
					})
					:Do(function(_,data)
						--hmi side: sending VR.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})						
					end)
					
					--hmi side: expect UI.AddCommand request 
					EXPECT_HMICALL("UI.AddCommand", 
					{ 
						cmdID = 1,		
						menuParams = {position = 1, menuName ="Command 1"}
					})
					:Do(function(_,data)
						--hmi side: sending UI.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
					end)
					
					
					--mobile side: expect AddCommand response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")

				end
			
			
			for i = 1, #TestData do
									
				Test[TestCaseName .. "_DeleteCommand_VR_responds_UNSUPPORTED_RESOURCE_UI_responds_".. tostring(TestData[i].resultCode)] = function(self)
				
					commonTestCases:DelayedExp(iTimeout)
					
					--mobile side: sending DeleteCommand request
					local cid = self.mobileSession:SendRPC("DeleteCommand", {cmdID = 1})
					
					--hmi side: expect VR.DeleteCommand request
					EXPECT_HMICALL("VR.DeleteCommand", {cmdID = 1})
					:Do(function(_,data)
						--hmi side: sending VR.DeleteCommand response
						self.hmiConnection:SendError(data.id, data.method, "UNSUPPORTED_RESOURCE", "error message")												
					end)

					--hmi side: expect UI.DeleteCommand request
					EXPECT_HMICALL("UI.DeleteCommand", {cmdID = 1})
					:Do(function(_,data)
						--hmi side: sending UI.DeleteCommand response
						self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "error message 2")
					end)
					
					
					--mobile side: expect DeleteCommand response 
					EXPECT_RESPONSE(cid, {success = false , resultCode = "UNSUPPORTED_RESOURCE"})

					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)
				end		
			
			end
			
			
		
			-- 3. PerformInteraction: Precondition: CreateInteractionChoiceSet
			for i = 1, #TestData do
			

				Test[TestCaseName .. "_PerformInteraction_Precondition_CreateInteractionChoiceSet_" .. i] = function(self)
						--mobile side: sending CreateInteractionChoiceSet request
					local cid = self.mobileSession:SendRPC("CreateInteractionChoiceSet",
															{
																interactionChoiceSetID = i,
																choiceSet = {{ 
																					choiceID = i,
																					menuName ="Choice" .. tostring(i),
																					vrCommands = 
																					{ 
																						"VrChoice" .. tostring(i),
																					}, 
																					image =
																					{ 
																						value ="icon.png",
																						imageType ="STATIC",
																					}
																			}}
															})
					
					--hmi side: expect VR.AddCommand
					EXPECT_HMICALL("VR.AddCommand", 
								{ 
									cmdID = i,
									type = "Choice",
									vrCommands = {"VrChoice"..tostring(i) }
								})
					:Do(function(_,data)						
						--hmi side: sending VR.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		
					
					--mobile side: expect CreateInteractionChoiceSet response
					EXPECT_RESPONSE(cid, { resultCode = "SUCCESS", success = true  })
					
				end

			end
			
			-- 3. PerformInteraction
			--ToDo: Due to defect APPLINK-26882, current script just execute case HMI responds PerformInteraction_VR_ONLY success.
			--for i = 1, #TestData do					
			for i = 1, 1 do					
				
				Test[TestCaseName .. "_PerformInteraction_VR_responds_UNSUPPORTED_RESOURCE_UI_responds_" .. tostring(TestData[i].resultCode)] = function(self)

					local params = 
						{		       
							initialText = "StartPerformInteraction",
							initialPrompt = { 
								{ 
									text = "Makeyourchoice",
									type = "TEXT"
								}
							}, 
							interactionMode = "VR_ONLY",
							interactionChoiceSetIDList = {i},
							helpPrompt = { 
								{ 
									text = "Selectthevariant",
									type = "TEXT"
								}
							}, 
							timeoutPrompt = { 
								{ 
									text = "TimeoutPrompt",
									type = "TEXT"
								}
							}, 
							timeout = 5000,
							vrHelp = {
										{ 
											text = "New  VRHelp",
											position = 1,	
											image = {
														value = "icon.png",
														imageType = "STATIC",
													} 
										}
									} 
						}
						
					
					--mobile side: sending PerformInteraction request
					local cid = self.mobileSession:SendRPC("PerformInteraction", params)
					
					--hmi side: expect VR.PerformInteraction request 
					EXPECT_HMICALL("VR.PerformInteraction", 
					{	
						helpPrompt = params.helpPrompt,
						initialPrompt = params.initialPrompt,
						timeout = params.timeout,
						timeoutPrompt = params.timeoutPrompt
					})
					:Do(function(_,data)

						--Send VR.PerformInteraction response 
						self.hmiConnection:SendError(data.id, data.method, "UNSUPPORTED_RESOURCE", "error message")			
						
					end)
					
					--hmi side: expect UI.PerformInteraction request 
					EXPECT_HMICALL("UI.PerformInteraction", 
					{
						timeout = params.timeout,
						--Updated: Lines are commented due to APPLINK-16052, please uncomment once resolved
						--vrHelp = params.vrHelp,
						--vrHelpTitle = params.initialText,
					})
					:Do(function(_,data)
						--HMI sends UI.PerformInteraction response 
						self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "error message 2")
					end)
					
					--mobile side: OnHMIStatus notifications
					EXPECT_NOTIFICATION("OnHMIStatus",{})
					:Times(0)

					
					--mobile side: expect PerformInteraction response
					EXPECT_RESPONSE(cid, {success = false, resultCode = "UNSUPPORTED_RESOURCE"})

				end
			
			end
			
			
		end
		
		checksplit_VR_RPCs_VR_Responds_UNSUPPORTED_RESOURCE_Others_respond_unsuccess_resultCodes(TestCaseName)

	end

	
	local TestData = {

	--caseID 1-3 are used to checking special cases
	{caseID = 1, description = "HMI_Does_Not_Repond"},
	{caseID = 2, description = "MissedAllParamaters"},
	{caseID = 3, description = "Invalid_Json"},

			
	--caseID 11-14 are used to checking "collerationID" parameter
		--11. IsMissed
		--12. IsNonexistent
		--13. IsWrongType
		--14. IsNegative 	
	{caseID = 11, description = "collerationID_IsMissed"},
	{caseID = 12, description = "collerationID_IsNonexistent"},
	{caseID = 13, description = "collerationID_IsWrongType"},
	{caseID = 14, description = "collerationID_IsNegative"},

	--caseID 21-27 are used to checking "method" parameter
		--21. IsMissed
		--22. IsNotValid
		--23. IsOtherResponse
		--24. IsEmpty
		--25. IsWrongType
		--26. IsInvalidCharacter - \n, \t, only spaces
	{caseID = 21, description = "method_IsMissed"},
	{caseID = 22, description = "method_IsNotValid"},
	{caseID = 23, description = "method_IsOtherResponse"},
	{caseID = 24, description = "method_IsEmpty"},
	{caseID = 25, description = "method_IsWrongType"},
	{caseID = 26, description = "method_IsInvalidCharacter_Splace"},
	{caseID = 26, description = "method_IsInvalidCharacter_Tab"},
	{caseID = 26, description = "method_IsInvalidCharacter_NewLine"},

		-- --caseID 31-35 are used to checking "resultCode" parameter
			-- --31. IsMissed
			-- --32. IsNotExist
			-- --33. IsEmpty
			-- --34. IsWrongType
	{caseID = 31,  description = "resultCode_IsMissed"},
	{caseID = 32,  description = "resultCode_IsNotExist"},
	{caseID = 33,  description = "resultCode_IsWrongType"},
	{caseID = 34,  description = "resultCode_INVALID_DATA"},
	{caseID = 35,  description = "resultCode_DATA_NOT_AVAILABLE"},
	{caseID = 36,  description = "resultCode_GENERIC_ERROR"},
	

		--caseID 41-45 are used to checking "message" parameter
			--41. IsMissed
			--42. IsLowerBound
			--43. IsUpperBound
			--44. IsOutUpperBound
			--45. IsEmpty/IsOutLowerBound
			--46. IsWrongType
			--47. IsInvalidCharacter - \n, \t, only spaces
	{caseID = 41,  description = "message_IsMissed"},
	{caseID = 42,  description = "message_IsLowerBound"},
	{caseID = 43,  description = "message_IsUpperBound"},
	{caseID = 44,  description = "message_IsOutUpperBound"},
	{caseID = 45,  description = "message_IsEmpty_IsOutLowerBound"},
	{caseID = 46,  description = "message_IsWrongType"},
	{caseID = 47,  description = "message_IsInvalidCharacter_Tab"},
	{caseID = 48,  description = "message_IsInvalidCharacter_OnlySpaces"},
	{caseID = 49,  description = "message_IsInvalidCharacter_Newline"},
	

	--caseID 51-55 are used to checking "available" parameter
		--51. IsMissed
		--52. IsWrongType
	{caseID = 51,  description = "available_IsMissed"},
	{caseID = 52,  description = "available_IsWrongType"},
				
}

	
	--ToDo: Defect APPLINK-25898 Due to problem when stop and start SDL, script is debugged by updating user_modules/connecttest_VR_Isready.lua
	--for i=1, #TestData do
	for i=1, 1 do

	
		local TestCaseName = "Case_" .. TestData[i].caseID .. "_IsReady_" ..TestData[i].description

				
		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup(TestCaseName)
		
		local function StopStartSDL_HMI_MOBILE(case, TestCaseName)
		
			--Stop SDL
			Test[tostring(TestCaseName) .. "_Precondition_StopSDL"] = function(self)
				StopSDL()
			end
			
			--Start SDL
			Test[tostring(TestCaseName) .. "_Precondition_StartSDL"] = function(self)
				StartSDL(config.pathToSDL, config.ExitOnCrash)
			end
			
			--InitHMI
			Test[tostring(TestCaseName) .. "_Precondition_InitHMI"] = function(self)
				self:initHMI()
			end
			
			
			--InitHMIonReady
			Test[tostring(TestCaseName) .. "_initHMI_onReady_VR_InReady_" .. tostring(description)] = function(self)
							
				self:initHMI_onReady_VR_IsReady(case)
				
			end

			
			--ConnectMobile
			Test[tostring(TestCaseName) .. "_ConnectMobile"] = function(self)
				self:connectMobile()
			end
			
			--StartSession
			Test[tostring(TestCaseName) .. "_StartSession"] = function(self)
				self.mobileSession= mobile_session.MobileSession(self, self.mobileConnection)
				self.mobileSession:StartService(7)
			end
			
		end
	

		--ToDo: Due to problem when stop and start SDL (APPLINK-25898), script is debugged by updating user_modules/connecttest_VR_Isready.lua
		--StopStartSDL_HMI_MOBILE(TestData[i].caseID, TestCaseName)

		
		RegisterApplication_Check_VR_Parameters_From_HMI_capabilities_json(TestCaseName)

		APPLINK_20932_single_VR_RPCs(TestCaseName)
		
		APPLINK_25044_split_RPCs(TestCaseName)
		
	
	end


----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK IV----------------------------------------
------------------------------Check special cases of HMI response-----------------------------
----------------------------------------------------------------------------------------------

-- These cases are merged into TEST BLOCK III


	
-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Not applicable



----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VI----------------------------------------
-------------------------Sequence with emulating of user's action(s)--------------------------
----------------------------------------------------------------------------------------------

--Not applicable



----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VII---------------------------------------
--------------------------------------Different HMIStatus-------------------------------------
----------------------------------------------------------------------------------------------

-- Not applicable for VR.IsReady HMI API.


----------------------------------------------------------------------------------------------
------------------------------------------Post-condition--------------------------------------
----------------------------------------------------------------------------------------------


	function Test:Postcondition_Preloadedfile()
	  print ("restoring sdl_preloaded_pt.json")
	  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
	end

return Test
