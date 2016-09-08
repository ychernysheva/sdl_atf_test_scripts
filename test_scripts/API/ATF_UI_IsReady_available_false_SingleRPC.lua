config.defaultProtocolVersion = 2
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.SDLStoragePath = config.pathToSDL .. "storage/"
---------------------------------------------------------------------------------------------
---------------------------- Required Shared libraries --------------------------------------
---------------------------------------------------------------------------------------------

	local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
	local commonSteps = require('user_modules/shared_testcases/commonSteps')
	local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
	local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

	APIName = "'..tested_method..'"
		
	DefaultTimeout = 3
	local iTimeout = 2000
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
	--Test = require('user_modules/connecttest_VR_Isready')
	--Test = require('user_modules/connecttest_UI_Isready')
	Test = require('connecttest')

	require('cardinalities')
	local events = require('events')  
	local mobile_session = require('mobile_session')
	require('user_modules/AppTypes')
	local interface = require('user_modules/Interfaces_RPC')

---------------------------------------------------------------------------------------------
-------------------------------------------Common variables-----------------------------------
---------------------------------------------------------------------------------------------
	--TestedInterface = "VR"
	TestedInterface = "UI"

	--RPCs that will be tested:

	--if RPC is applicable for this interface, then:
	--                                               in structure mobile_request add request[count_RPC];
	local mobile_request = {}
	--                                               in structure RPCs add RPC[count_RPC];
	local RPCs = {}
	local count_RPC = 1
	-- position of RCP in structure usedRPC{}
	local position_RPC = {}

	-- Interfaces that are not scope of testing
	local count_NotTestedInterface = 1
	local NotTestedInterfaces = {}

	for i = 1, #interface.RPC do
		if(interface.RPC[i].interface == TestedInterface) then
			print("====================== Tests are executed for "..TestedInterface.." interface. ====================================")
			for j = 1, #interface.RPC[i].usedRPC do
				
				if(interface.RPC[i].usedRPC[j].name ~= "Not applicable") then
				
					RPCs[count_RPC] = interface.RPC[i].usedRPC[j]
					position_RPC[count_RPC] = j
	   				
	 				--print("====================== "..RPCs[count_RPC].name)

					-- will be added request only applicable for this interface
					mobile_request[count_RPC] = interface.mobile_req[j]

					--print("mobile: "..mobile_request[count_RPC].name)
	 				count_RPC = count_RPC + 1
	 			end
	 		end
	 	else
			NotTestedInterfaces[count_NotTestedInterface] = interface.RPC[i]
			print("Not tested interface = "..NotTestedInterfaces[count_NotTestedInterface].interface)
			print("Not tested number RPCs = "..#NotTestedInterfaces[count_NotTestedInterface].usedRPC)
			count_NotTestedInterface = count_NotTestedInterface +1 
	  end
	end

	local params_RAI = {}
	for i = 1, #interface.RAI do
		if(interface.RAI[i].name == TestedInterface) then
			params_RAI = interface.RAI[i].params
		end
	end
	--print("params RAI info: ", params_RAI.info)

  
---------------------------------------------------------------------------------------------
-------------------------------------------Common function-----------------------------------
---------------------------------------------------------------------------------------------

	-- Cover 
	-- VR: APPLINK-25286: [HMI_API] '..tested_method..'
	-- UI:
	-- TTS:
	-- VehicleInfo: APPLINK-25305
	-- Navigation: APPLINK-25301

	function Test:initHMI_onReady_Interfaces_IsReady(case)
	  --critical(true)
	  local tested_method = (TestedInterface..".IsReady") 
	  
	  local function ExpectRequest(name, mandatory, params)
		

	    xmlReporter.AddMessage(debug.getinfo(1, "n").name, tostring(name))
	    local event = events.Event()
	    event.level = 2
	    event.matches = function(self, data) return data.method == name end
	    return
	      EXPECT_HMIEVENT(event, name)
	      :Times(mandatory and 1 or AnyNumber())
	      :Do(function(_, data)

			-- VR: APPLINK-25286: [HMI_API] '..tested_method..'
			-- UI:
			-- TTS:
			-- VehicleInfo: APPLINK-25305
			-- Navigation: APPLINK-25301

			if (name == tested_method) then
				--On the view of JSON message, Interface.IsReady response has colerationidID, code/resultCode, method and message parameters. Below are tests to verify all invalid cases of the response.
				
				--caseID 1-3: Check special cases
					--0. availabe_false
					--1. HMI_Does_Not_Repond
					--2. MissedAllParamaters
					--3. Invalid_Json

				if (case == 0) then -- responds {availabe = false}
					print("name = "..name)

					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {availabe = false}) 
					
				elseif (case == 1) then -- does not respond
					--self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", params) 
					
				elseif (case == 2) then --MissedAllParamaters
					self.hmiConnection:Send('{}')
					
				elseif (case == 3) then --Invalid_Json
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')	
					self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc";"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')	
				
				--*****************************************************************************************************************************
				
				--caseID 11-14 are used to checking "collerationID" parameter
					--11. collerationID_IsMissed
					--12. collerationID_IsNonexistent
					--13. collerationID_IsWrongType
					--14. collerationID_IsNegative 	
					
				elseif (case == 11) then --collerationID_IsMissed
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  
				elseif (case == 12) then --collerationID_IsNonexistent
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id + 10)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  
				elseif (case == 13) then --collerationID_IsWrongType
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":"'..tostring(data.id)..'","jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  
				elseif (case == 14) then --collerationID_IsNegative
					self.hmiConnection:Send('{"id":'..tostring(-1)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
				
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
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"code":0}}')

				elseif (case == 22) then --method_IsNotValid
					local method_IsNotValid = TestedInterface ..".IsRea"
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					 self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..method_IsNotValid..'", "code":0}}')				

				elseif (case == 23) then --method_IsOtherResponse
					local method_IsOtherResponse = NotTestedInterfaces[1].interface .. ".IsReady"
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					 self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..method_IsOtherResponse..'", "code":0}}')			

				elseif (case == 24) then --method_IsEmpty
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					 self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"", "code":0}}')							 
				
				elseif (case == 25) then --method_IsWrongType
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":123456789, "code":0}}')
				
				elseif (case == 26) then --method_IsInvalidCharacter_Newline
					local method_IsInvalidCharacter_Newline = TestedInterface ..".IsR\neady"
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..method_IsInvalidCharacter_Newline..'", "code":0}}')
				
				elseif (case == 27) then --method_IsInvalidCharacter_OnlySpaces
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"  ", "code":0}}')
				
				elseif (case == 28) then --method_IsInvalidCharacter_Tab
					local method_IsInvalidCharacter_Tab = TestedInterface ..".IsR\teady"
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..method_IsInvalidCharacter_Tab..'", "code":0}}')		
					  
				--*****************************************************************************************************************************
				
				--caseID 31-35 are used to checking "resultCode" parameter
					--31. resultCode_IsMissed
					--32. resultCode_IsNotExist
					--33. resultCode_IsWrongType
					--34. resultCode_INVALID_DATA (code = 11)
					--35. resultCode_DATA_NOT_AVAILABLE (code = 9)
					--36. resultCode_GENERIC_ERROR (code = 22)
					
				elseif (case == 31) then --resultCode_IsMissed
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'"}}')

				elseif (case == 32) then --resultCode_IsNotExist
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":123}}')

				elseif (case == 33) then --resultCode_IsWrongType
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":"0"}}')
				
				elseif (case == 34) then --resultCode_INVALID_DATA
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":11}}')
				
				elseif (case == 35) then --resultCode_DATA_NOT_AVAILABLE
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":9}}')
				
				elseif (case == 36) then --resultCode_GENERIC_ERROR
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":22}}')
				
				
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
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"The data sent is invalid","code":11}}')
					  
				elseif (case == 42) then --message_IsLowerBound
					local messageValue = "a"
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"' .. messageValue ..'","code":11}}')
								  
				elseif (case == 43) then --message_IsUpperBound
					local messageValue = string.rep("a", 1000)
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"' .. messageValue ..'","code":11}}')
				
				elseif (case == 44) then --message_IsOutUpperBound
					local messageValue = string.rep("a", 1001)
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"' .. messageValue ..'","code":11}}')

				elseif (case == 45) then --message_IsEmpty_IsOutLowerBound
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"","code":11}}')

				elseif (case == 46) then --message_IsWrongType
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":123,"code":11}}')
					  
				elseif (case == 47) then --message_IsInvalidCharacter_Tab
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"a\tb","code":11}}')

				elseif (case == 48) then --message_IsInvalidCharacter_OnlySpaces
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"  ","code":11}}')

				elseif (case == 49) then --message_IsInvalidCharacter_Newline
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"The data sent is invalid","code":11}}') --INVALID_DATA
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","error":{"data":{"method":"'..tested_method..'"}, "message":"a\n\b","code":11}}')

				--*****************************************************************************************************************************

				--caseID 51-55 are used to checking "available" parameter
					--51. available_IsMissed
					--52. available_IsWrongType

				elseif (case == 51) then --available_IsMissed
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"'..tested_method..'", "code":"0"}}')
		  
				elseif (case == 52) then --available_IsWrongType
					--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":true,"method":"'..tested_method..'", "code":0}}')
					  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"available":"true","method":"'..tested_method..'", "code":"0"}}')

				else
					print("***************************Error: "..tested_method..": Input value is not correct ***************************")
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
	    ----------------------------------------------------------------------------------------
	    -- Params for specific RPCs that are tested in scope of IsReady
		    local params_TTS_GetCapabilities = {
		    									speechCapabilities = { "TEXT", "PRE_RECORDED" },
										        prerecordedSpeechCapabilities =
										        {
										          "HELP_JINGLE",
										          "INITIAL_JINGLE",
										          "LISTEN_JINGLE",
										          "POSITIVE_JINGLE",
										          "NEGATIVE_JINGLE"
										        }
											}
			local params_UI_GetCapabilities = {  
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
										    	}

			local params_VR_GetCapabilities = {vrCapabilities = { "TEXT" }}

			local params_VehInfo_GetVehicleType = { vehicleType =
															        {
															          make = "Ford",
															          model = "Fiesta",
															          modelYear = "2013",
															          trim = "SE"
															        }}
		----------------------------------------------------------------------------------------

     	-- IsReady
	    ExpectRequest(tested_method, true, { available = true })

	    --VR: APPLINK-25100 / APPLINK-25099
	    --UI: 
	    --TTS: 
	    --VehicleInfo
	    --Navigation
	    if(case == 0) then -- available false
	    	
	    	ExpectRequest(TestedInterface ..".GetLanguage" , true, { language = "EN-US" })
	    	:Times(0)

	    	ExpectRequest(TestedInterface ..".GetSupportedLanguages" , true, { language = "EN-US" })
	    	:Times(0)

	    	ExpectRequest(TestedInterface ..".GetCapabilities", true, { vrCapabilities = { "TEXT" } })
			:Times(0)
		end
	    
	    if(case == 1) then -- don't send
	    	-- https://adc.luxoft.com/confluence/pages/viewpage.action?pageId=290334082&focusedCommentId=290338124#comment-290338124
	    	-- As result, in case HMI does NOT respond to Vehicle.IsReady -> SDL can send this request to HMI 
	    	if( TestedInterface == "VehicleInfo") then
				ExpectRequest("VehicleInfo.GetVehicleType", true, {params_VehInfo_GetVehicleType})
			end
		else
			ExpectRequest("VehicleInfo.GetVehicleType", true, {params_VehInfo_GetVehicleType})
			:Times(0)
		end
	    for i = 1, #NotTestedInterfaces do
	    	ExpectRequest(NotTestedInterfaces[i].interface ..".GetLanguage", true, { language = "EN-US" })
	    	ExpectRequest(NotTestedInterfaces[i].interface ..".GetSupportedLanguages", true, { languages =
																			        {
																			          "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU","TR-TR","PL-PL",
																			          "FR-FR","IT-IT","SV-SE","PT-PT","NL-NL","ZH-TW","JA-JP","AR-SA","KO-KR",
																			          "PT-BR","CS-CZ","DA-DK","NO-NO"
																			        } })	    	

			if    ( NotTestedInterfaces[i].interface == "UI") then 
				ExpectRequest("UI.GetCapabilities", true,  { params_UI_GetCapabilities })
			elseif( NotTestedInterfaces[i].interface == "TTS") then
				ExpectRequest("TTS.GetCapabilities", true, { params_TTS_GetCapabilities})
			elseif( NotTestedInterfaces[i].interface == "VR") then
				ExpectRequest("VR.GetCapabilities", true,  { params_VR_GetCapabilities })
			end
	    end
	    
	    ExpectRequest("UI.ChangeRegistration", false, { }):Pin()
	    ExpectRequest("TTS.SetGlobalProperties", false, { }):Pin()
	    ExpectRequest("BasicCommunication.UpdateDeviceList", false, { }):Pin()
	    ExpectRequest("VR.ChangeRegistration", false, { }):Pin()
		
	    ExpectRequest("TTS.ChangeRegistration", false, { }):Pin()
	    
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
	    
	    for i = 1, #NotTestedInterfaces do
	    	ExpectRequest(NotTestedInterfaces[i].interface ..".IsReady", true, { available = true })
	    end
	    --ExpectRequest("TTS.IsReady", true, { available = true })
	    --ExpectRequest("UI.IsReady", true, { available = true })
	    --Will be removed when Nav and VehInfo are also done.
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
 

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

--Not applicable

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK I----------------------------------------
--------------------------------Check normal cases of Mobile request---------------------------
-----------------------------------------------------------------------------------------------

-- Not applicable for '..tested_method..' HMI API.



----------------------------------------------------------------------------------------------
----------------------------------------TEST BLOCK II-----------------------------------------
-----------------------------Check special cases of Mobile request----------------------------
----------------------------------------------------------------------------------------------

-- Not applicable for '..tested_method..' HMI API.

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK III--------------------------------------
----------------------------------Check normal cases of HMI response---------------------------
-----------------------------------------------------------------------------------------------

--List of CRQs:
	--APPLINK-20918: [GENIVI] VR interface: SDL behavior in case HMI does not respond to IsReady_request or respond with "available" = false
		-- 1. HMI respond '..tested_method..' (false) -> SDL must return 'UNSUPPORTED_RESOURCE, success:false' to all single VR-related RPC
		-- 2. HMI respond '..tested_method..' (false) and app sends RPC that must be spitted -> SDL must NOT transfer VR portion of spitted RPC to HMI
		-- 3. HMI does NOT respond to '..tested_method..'_request -> SDL must transfer received RPC to HMI even to non-responded VR module

--List of parameters in '..tested_method..' response:
	--Parameter 1: correlationID: type=Integer, mandatory="true"
	--Parameter 2: method: type=String, mandatory="true" (method = "'..tested_method..'") 
	--Parameter 3: resultCode: type=String Enumeration(Integer), mandatory="true" 
	--Parameter 4: info/message: type=String, minlength="1" maxlength="10" mandatory="false" 
	--Parameter 5: available: type=Boolean, mandatory="true"
-----------------------------------------------------------------------------------------------

	
	
-----------------------------------------------------------------------------------------------				
-- Cases 1: HMI sends '..tested_method..' response (available = false)
-----------------------------------------------------------------------------------------------
		
	local function case1_IsReady_availabe_false()	

		
		local TestCaseName = TestedInterface .."_IsReady_response_availabe_false"
		
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
			
			
			--InitHMIonReady: 
			-- VR: APPLINK-25286: [HMI_API] '..tested_method..'
			-- UI: 
			-- TTS:
			-- VehicleInfo: APPLINK-25305
			-- Navigation: APPLINK-25301
			Test[tostring(TestCaseName) .. "_initHMI_onReady_"..TestedInterface.."_IsReady_" .. tostring(description)] = function(self)
				
				--self:initHMI_onReady_VR_IsReady(0)	--	availabe = false
				self:initHMI_onReady_Interfaces_IsReady(0)
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
		
		
		--ToDo: Due to problem with stop and start SDL (APPLINK-26394 (stop and start SDL again)), this step is skipped and update user_modules/connecttest_VR_Isready.lua to send '..tested_method..'(available = false) response manually.
		StopStartSDL_HMI_MOBILE()
		
		-----------------------------------------------------------------------------------------------
		--CRQ #2) 
		-- VR:  APPLINK-20931: [VR Interface] Conditions for SDL to respond 'UNSUPPORTED_RESOURCE, success:false' to mobile app <= SDL receives '..tested_method..' (available=false) from HMI 
		-- UI:  APPLINK-25045
		-- TTS: APPLINK-25140
		-- VehicleInfo: APPLINK-25224
		-- Navigation:  APPLINK-25184
		--Verification criteria:
			-- In case SDL receives Interface (available=false) from HMI and mobile app sends any single VR-related RPC
			-- SDL must respond "UNSUPPORTED_RESOURCE, success=false, info: "Interface is not supported by system" to mobile app
			-- SDL must NOT transfer this Interface-related RPC to HMI
		-----------------------------------------------------------------------------------------------	
		commonSteps:RegisterAppInterface()
		
		-- Description: Activation app for precondition
		commonSteps:ActivationApp()

		local function Interface_IsReady_response_availabe_false_check_single_related_RPC(TestCaseName)
			--local function VR_IsReady_response_availabe_false_check_single_VR_related_RPC(TestCaseName)
			for count_RPC = 1, #RPCs do
				-- All applicable RPCs
				-- Test[TestCaseName .. "_AddCommand_VRCommandsOnly_UNSUPPORTED_RESOURCE_false"] = function(self)
				Test["TC5_".. RPCs[count_RPC].name .. "_UNSUPPORTED_RESOURCE_false" ..TestCaseName] = function(self)
					local menuparams = ""
					local vrCmd = ""
					--print("===================== Test: Interface_IsReady_response_availabe_false_check_single_related_RPC ==============================")
					print("=============== Test: "..TestedInterface.."."..RPCs[count_RPC].name)
					local mob_request = mobile_request[count_RPC]
					local hmi_call = RPCs[count_RPC]
					local hmi_method_call = TestedInterface.."."..hmi_call.name

					if ( hmi_call.params.appID ~= nil ) then hmi_call.params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end
					
					
					if ( TestedInterface == "VR") then 
						if (mob_request.params.menuParams ~= nil ) then 
							menuparams = mob_request.params.menuParams 
							mob_request.params.menuParams =  nil 
						end
					end
					if( TestedInterface == "UI") then
						if ( mob_request.params.vrCommands ~= nil ) then 
							vrCmd = mob_request.params.vrCommands
							mob_request.params.vrCommands = nil
						end
					end

					commonTestCases:DelayedExp(iTimeout)
			
					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC(mob_request.name, mob_request.params)
						
					--hmi side: expect Interface.RPC request
					EXPECT_HMICALL(hmi_method_call, {})
					:Times(0)
					
					--mobile side: expect AddCommand response
					if(mob_request.name ~= "DeleteCommand") then
						--mobile side: expect AddCommand response
						EXPECT_RESPONSE(cid, {success = false, resultCode = "UNSUPPORTED_RESOURCE", info =  TestedInterface .." is not supported by system"})
					else
						-- According to APPLINK-27079
						EXPECT_RESPONSE(cid, {success = false, resultCode = "INVALID_DATA"})
					end

					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)

					if(menuparams ~= "") then mob_request.params.menuParams = menuparams end
					if(vrCmd ~= "") 	 then mob_request.params.vrCommands = vrCmd end
				end			
			end -- for count_RPC = 1, #RPCs do
		end
		
		Interface_IsReady_response_availabe_false_check_single_related_RPC(TestedInterface .."_IsReady_response_availabe_false_single_"..TestedInterface.."_related_RPC")
		--VR_IsReady_response_availabe_false_check_single_VR_related_RPC("VR_IsReady_response_availabe_false_single_VR_related_RPC")
	
	end --local function case1_IsReady_availabe_false()

	--Precondition: Update connecttest_VR_Isready.lua responds '..tested_method..'(available = false). 
	--ToDo: After APPLINK-26394 (stop and start SDL again) is closed, remove this precondition.
	case1_IsReady_availabe_false()
	

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

-- Not applicable for '..tested_method..' HMI API.


----------------------------------------------------------------------------------------------
------------------------------------------Post-condition--------------------------------------
----------------------------------------------------------------------------------------------


	function Test:Postcondition_Preloadedfile()
	  print ("restoring sdl_preloaded_pt.json")
	  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
	end

return Test