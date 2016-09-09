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
			--print("Not tested interface = "..NotTestedInterfaces[count_NotTestedInterface].interface)
			--print("Not tested number RPCs = "..#NotTestedInterfaces[count_NotTestedInterface].usedRPC)
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
-- Cases 2: HMI does not sends '..tested_method..' response or send invalid response
-----------------------------------------------------------------------------------------------

	
	-----------------------------------------------------------------------------------------------
	--CRQ #3: 
	-- VR: APPLINK-25044 (split RPCs)
	-- UI: APPLINK-25099
	-- TTS: APPLINK-25139
	--Verification criteria:
		-- In case HMI does NOT respond to '..tested_method..'_request
		-- and mobile app sends RPC to SDL that must be split to
		-- -> tested interface RPC
		-- -> any other <Interface>.RPC (<Interface> - TTS, UI)
		-- SDL must:
		-- transfer both tested interface RPC and <Interface>.RPC to HMI (in case <Interface> is supported by system)
		-- respond with '<received_resultCode_from_HMI>' to mobile app (please see list with resultCodes below)	
	-----------------------------------------------------------------------------------------------
	--local function APPLINK_25044_split_RPCs(TestCaseName)
	local function Splitted_Interfaces_RPCs(TestCaseName, executeAppResults, executeAllRPCs)
		
		--3.1: Tested interface does not respond
		--local function checksplit_VR_RPCs_VR_does_not_Respond(TestCaseName)
		local function checksplit_Interfaces_RPCs_TestedInterface_does_not_Respond(TestCaseName)
			local TestData = {}
			if(executeAppResults == true) then
				TestData = {
				
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
			else
				TestData = { {success = true, resultCode = "SUCCESS", 				expected_resultCode = "SUCCESS"} }
			end
			
			local grammarID = 1
			-- All RPCs
			for i = 1, #TestData do
			--for i = 1, 1 do
				for count_RPC = 1, #RPCs do
					local mob_request = mobile_request[count_RPC]
					local hmi_call = RPCs[count_RPC]
					local other_interfaces_call = {}			
					local hmi_method_call = TestedInterface.."."..hmi_call.name

					if(mob_request.splitted == true) then
						-- Preconditions should be executed only once.
						if( i == 1) then
							--Precondition: for RPC DeleteCommand: AddCommand 1
							if(mob_request.name == "DeleteCommand") then
								Test["Precondition_AddCommand_1_"..TestCaseName] = function(self)
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
										grammarID = data.params.grammarID
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
							end						
						end --if( i == 1)

						--Precondition: for RPC PerformInteraction: CreateInteractionChoiceSet
						if(mob_request.name == "PerformInteraction") then
							Test["PerformInteraction_Precondition_CreateInteractionChoiceSet_" .. i.."_"..TestCaseName] = function(self)
								--mobile side: sending CreateInteractionChoiceSet request
								local cid = self.mobileSession:SendRPC("CreateInteractionChoiceSet",
																	{
																		interactionChoiceSetID = i + 1,
																		choiceSet = {{ 
																							choiceID = i + 1,
																							menuName ="Choice" .. tostring(i + 1),
																							vrCommands = 
																							{ 
																								"VrChoice" .. tostring(i + 1),
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
											cmdID = i + 1,
											type = "Choice",
											vrCommands = {"VrChoice"..tostring(i + 1) }
										})
								:Do(function(_,data)						
									--hmi side: sending VR.AddCommand response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
									grammarID = data.params.grammarID
								end)		
							
								--mobile side: expect CreateInteractionChoiceSet response
								EXPECT_RESPONSE(cid, { resultCode = "SUCCESS", success = true  })
							end
						end	-- if(mob_request.name == "PerformInteraction")					

						--Test[TestCaseName .. "_AddCommand_VR_does_not_respond_UI_responds_".. tostring(TestData[i].resultCode)] = function(self)
						Test["TC13_"..TestCaseName .. "_"..mob_request.name.."_"..TestedInterface.."_does_not_responds_OtherInterfaces_respond_".. tostring(TestData[i].resultCode)] = function(self)
					
							--======================================================================================================
							-- Update of used params
								if ( hmi_call.params.appID ~= nil ) then hmi_call.params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end

								if ( mob_request.params.cmdID      ~= nil ) then mob_request.params.cmdID = i end
								if ( mob_request.params.vrCommands ~= nil ) then mob_request.params.vrCommands =  {"vrCommands_" .. tostring(i)} end
								if ( mob_request.params.menuParams ~= nil ) then mob_request.params.menuParams =  {position = 1, menuName = "Command " .. tostring(i)} end
							--======================================================================================================
							commonTestCases:DelayedExp(iTimeout)
				
							--mobile side: sending RPC request
							local cid = self.mobileSession:SendRPC(mob_request.name, mob_request.params)
							
							--hmi side: expect OtherInterfaces.RPC request
							for cnt = 1, #NotTestedInterfaces do

								for cnt_rpc = 1, #NotTestedInterfaces[cnt].usedRPC do
									local local_interface = NotTestedInterfaces[cnt].interface
									local local_rpc = NotTestedInterfaces[cnt].usedRPC[cnt_rpc].name
									local local_params = NotTestedInterfaces[cnt].usedRPC[cnt_rpc].params
							 		
									if (local_rpc == hmi_call.name) then
										--======================================================================================================
										-- Update of verified params
											if ( local_params.cmdID ~= nil )      then local_params.cmdID = i end
											if ( local_params.menuParams ~= nil ) then local_params.menuParams =  {position = 1, menuName ="Command "..tostring(i)} end
			 								if ( local_params.appID ~= nil )      then local_params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end
			 								if ( hmi_call.params.grammarID ~= nil ) then 
										  		if (mob_request.name == "DeleteCommand") then
										  			hmi_call.params.grammarID =  grammarID  
												else
										  			hmi_call.params.grammarID[1] =  grammarID  
										  		end
										  	end
										--======================================================================================================
										EXPECT_HMICALL(local_interface.."."..local_rpc, local_params)
										:Do(function(_,data)
											--hmi side: sending NotTestedInterface.RPC response
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

									end -- if (local_rpc == hmi_call.name) then
								end --for cnt_rpc = 1, #NotTestedInterfaces[cnt].usedRPC do
							end --for cnt = 1, #NotTestedInterfaces do
							
							-- hmi side: sending tested interface response
							--======================================================================================================
							-- Update of verified params
								if ( hmi_call.params.cmdID ~= nil )      then hmi_call.params.cmdID = i end
								if ( hmi_call.params.type ~= nil ) 		   then hmi_call.params.type = "Command" end
								if ( hmi_call.params.vrCommands ~= nil ) then hmi_call.params.vrCommands = {"vrCommands_" .. tostring(i)} end
							--======================================================================================================
							EXPECT_HMICALL(hmi_method_call, hmi_call.params)
							:Do(function(_,data)
								if(mob_request.name == "AddCommand") then grammarID = data.params.grammarID end
								-- HMI does not respond							
							end)					
									
							--mobile side: expect AddCommand response
							EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
							:Timeout(12000)

							--mobile side: expect OnHashChange notification
							EXPECT_NOTIFICATION("OnHashChange")
							:Times(0)

							if(executeAllRPCs == false) then
								count_RPC = #RPCs
							end
						end
					end --if(mob_request.splitted == true) then

				end --for count_RPC = 1, #RPCs do
			end -- for i = 1, #TestData do
		end
			
		--checksplit_VR_RPCs_VR_does_not_Respond(TestCaseName)
		--Checked in 3.1
		--checksplit_Interfaces_RPCs_TestedInterface_does_not_Respond(TestCaseName)

		--3.2: Tested interface responds UNSUPPORTED_RESOURCE
		
		--3.2.1: Other interfaces respond successful resultCodes
		--local function checksplit_VR_RPCs_VR_Responds_UNSUPPORTED_RESOURCE_Others_respond_success_resultCodes(TestCaseName)
		local function checksplit_TestedInterface_RPCs_Responds_UNSUPPORTED_RESOURCE_Others_respond_success_resultCodes(TestCaseName)
			local TestData = {}
			if(executeAppResults == true) then
				TestData = {
					{resultCode = "SUCCESS"},
					{resultCode = "WARNINGS"},
					{resultCode = "WRONG_LANGUAGE"},
					{resultCode = "RETRY"},
					{resultCode = "SAVED"}
				}
			else
				TestData = { {resultCode = "SUCCESS"} }
			end
				
			-- 1. All RPCs
			for i = 1, #TestData do
			--for i = 1, 1 do
				for count_RPC = 1, #RPCs do
					local mob_request = mobile_request[count_RPC]
					local hmi_call = RPCs[count_RPC]
					local other_interfaces_call = {}			
					local hmi_method_call = TestedInterface.."."..hmi_call.name

					-- Preconditions should be executed only once.
					if( i == 1) then
						--Precondition: for RPC DeleteCommand: AddCommand 1
						if(mob_request.name == "DeleteCommand") then

							Test[TestCaseName .. "_Precondition_AddCommand_101"] = function(self)

								--mobile side: sending AddCommand request
								local cid = self.mobileSession:SendRPC("AddCommand",
								{
									cmdID = 101,
									vrCommands = {"vrCommands_101"},
									menuParams = {position = 1, menuName = "Command 101"}
								})
									
								--hmi side: expect VR.AddCommand request
								EXPECT_HMICALL("VR.AddCommand", 
								{ 
									cmdID = 101,
									type = "Command",
									vrCommands = {"vrCommands_101"}
								})
								:Do(function(_,data)
									--hmi side: sending VR.AddCommand response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})						
								end)
								
								--hmi side: expect UI.AddCommand request 
								EXPECT_HMICALL("UI.AddCommand", 
								{ 
									cmdID = 1,		
									menuParams = {position = 1, menuName ="Command 101"}
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
						end
					end -- if( i == 1) then
					--Precondition: for RPC PerformInteraction: CreateInteractionChoiceSet
					if(mob_request.name == "PerformInteraction") then
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
					
					
					--Test[TestCaseName .. "_AddCommand_VR_responds_UNSUPPORTED_RESOURCE_UI_responds_".. tostring(TestData[i].resultCode)] = function(self)
					Test["TC14_"..TestCaseName .. "_"..mob_request.name.."_"..TestedInterface.."_responds_UNSUPPORTED_RESOURCE_OtherInterfaces_respond_".. tostring(TestData[i].resultCode)] = function(self)

						commonTestCases:DelayedExp(iTimeout)
						--======================================================================================================
						-- Update of used params
						if ( hmi_call.params.appID ~= nil )      then hmi_call.params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end
						

						if ( mob_request.params.appName ~= nil )    then mob_request.params.appName = config.application1.registerAppInterfaceParams.appName end
						if ( mob_request.params.cmdID ~= nil )      then mob_request.params.cmdID = 100+i end
			 			if ( mob_request.params.menuParams ~= nil ) then mob_request.params.menuParams = {position = 1, menuName ="Command ".. tostring(100+i)} end
			 			
			 			if ( mob_request.params.vrCommands ~= nil ) then	mob_request.params.vrCommands = {"vrCommands_" .. tostring(100+i)}	end
			 			if ( mob_request.params.appID ~= nil ) then mob_request.params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end

						
						--======================================================================================================
						--mobile side: sending AddCommand request
						local cid = self.mobileSession:SendRPC(mob_request.name, mob_request.params)
							
						--hmi side: expect VR.AddCommand request
						for cnt = 1, #NotTestedInterfaces do
							for cnt_rpc = 1, #NotTestedInterfaces[cnt].usedRPC do
								
						 		local local_interface = NotTestedInterfaces[cnt].interface
						 		local local_rpc = NotTestedInterfaces[cnt].usedRPC[cnt_rpc].name
						 		local local_params = NotTestedInterfaces[cnt].usedRPC[cnt_rpc].params
							 		
						 		if (local_rpc == hmi_call.name) then
						 			--======================================================================================================
									-- Update of verified params
										if ( local_params.cmdID ~= nil )      then local_params.cmdID = 100+i end
										if ( local_params.menuParams ~= nil ) then local_params.menuParams =  {position = 1, menuName ="Command "..tostring(100+i)} end
			 							if ( local_params.appID ~= nil )      then local_params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end
			 							if ( local_params.appHMIType ~= nil ) then local_params.appHMIType = config.application1.registerAppInterfaceParams.appHMIType end
			 							if ( local_params.appName ~= nil )    then local_params.appName = config.application1.registerAppInterfaceParams.appName end
									--======================================================================================================
									
									EXPECT_HMICALL(local_interface.."."..local_rpc, local_params)
									:Do(function(_,data)
										--hmi side: sending NotTestedInterface.RPC response
										self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
									end)
						 		end --if (local_rpc == hmi_call.name) then
						 	end --for cnt_rpc = 1, #NotTestedInterfaces[cnt].usedRPC do
						end --for cnt = 1, #NotTestedInterfaces do
						

						-- hmi side: sending tested interface response
						--======================================================================================================
						-- Update of verified params
							if ( hmi_call.params.cmdID ~= nil ) 		 then hmi_call.params.cmdID = 100+i end
							if ( hmi_call.params.type ~= nil ) 			 then hmi_call.params.type = "Command" end
							if ( hmi_call.params.vrCommands ~= nil ) then hmi_call.params.vrCommands = {"vrCommands_" .. tostring(100+i)} end
						--======================================================================================================
						EXPECT_HMICALL(hmi_method_call, hmi_call.params)
						:Do(function(_,data)
							--hmi side: sending VR.AddCommand response
							self.hmiConnection:SendError(data.id, data.method, "UNSUPPORTED_RESOURCE", "error message")					
						end)		
						
						--mobile side: expect AddCommand response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "UNSUPPORTED_RESOURCE", info = "VR is not supported by system"})

						--mobile side: expect OnHashChange notification
						EXPECT_NOTIFICATION("OnHashChange")
						
						if(executeAllRPCs == false) then
							count_RPC = #RPCs
						end
					end
				end -- for count_RPC = 1, #RPCs do
			end -- for i = 1, #TestData do
		end
		
		--checksplit_VR_RPCs_VR_Responds_UNSUPPORTED_RESOURCE_Others_respond_success_resultCodes(TestCaseName)
		checksplit_TestedInterface_RPCs_Responds_UNSUPPORTED_RESOURCE_Others_respond_success_resultCodes(TestCaseName)

		
		--3.2.2: Other interfaces respond unsuccessful resultCodes
		local function checksplit_Interface_RPCs_Responds_UNSUPPORTED_RESOURCE_Others_respond_unsuccess_resultCodes(TestCaseName)
			--local function checksplit_VR_RPCs_VR_Responds_UNSUPPORTED_RESOURCE_Others_respond_unsuccess_resultCodes(TestCaseName)
		

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
			local grammarID = 1							
			-- 1. All RPCs
			for i = 1, #TestData do
			--for i = 1, 1 do
				for count_RPC = 1, #RPCs do
					local mob_request = mobile_request[count_RPC]
					local hmi_call = RPCs[count_RPC]
					local other_interfaces_call = {}			
					local hmi_method_call = TestedInterface.."."..hmi_call.name

					-- Preconditions should be executed only once.
					if( i == 1) then
						--Precondition: for RPC DeleteCommand: AddCommand 1
						if(mob_request.name == "DeleteCommand") then
							Test[TestCaseName .. "_Precondition_AddCommand_201"] = function(self)
								--mobile side: sending AddCommand request
								local cid = self.mobileSession:SendRPC("AddCommand",
								{
									cmdID = 201,
									vrCommands = {"vrCommands_201"},
									menuParams = {position = 1, menuName = "Command 201"}
								})
									
								--hmi side: expect VR.AddCommand request
								EXPECT_HMICALL("VR.AddCommand", 
								{ 
									cmdID = 201,
									type = "Command",
									vrCommands = {"vrCommands_201"}
								})
								:Do(function(_,data)
									--hmi side: sending VR.AddCommand response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})						
									grammarID = data.params.grammarID
								end)
								
								--hmi side: expect UI.AddCommand request 
								EXPECT_HMICALL("UI.AddCommand", 
								{ 
									cmdID = 201,		
									menuParams = {position = 1, menuName ="Command 201"}
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
						end
					end -- if( i == 1) then

					--Precondition: for RPC PerformInteraction: CreateInteractionChoiceSet
					if(mob_request.name == "PerformInteraction") then
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
																						} 
																						--image =
																						--{ 
																							--value ="icon.png",
																							--imageType ="STATIC",
																						--}
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
									grammarID = data.params.grammarID
							end)		
									
							--mobile side: expect CreateInteractionChoiceSet response
							EXPECT_RESPONSE(cid, { resultCode = "SUCCESS", success = true  })
									
						end
					end --if(mob_request.name == "PerformInteraction") then
					
					
					--Test[TestCaseName .. "_AddCommand_VR_responds_UNSUPPORTED_RESOURCE_UI_responds_".. tostring(TestData[i].resultCode)] = function(self)
					Test["TC15_"..TestCaseName .. "_"..mob_request.name.."_"..TestedInterface.."_responds_UNSUPPORTED_RESOURCE_OtherInterfaces_respond_".. tostring(TestData[i].resultCode)] = function(self)
						print("======================================================================================================")
						print("Splitted 3 RPC: "..mob_request.name)
						--======================================================================================================
						-- Update of used params
							if ( hmi_call.params.appID ~= nil )         then hmi_call.params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end
							if ( mob_request.params.cmdID ~= nil )      then mob_request.params.cmdID = (200+i) end
				 			if ( mob_request.params.menuParams ~= nil ) then mob_request.params.menuParams =  {position = 1, menuName ="Command "..tostring(200+i)} end
				 			if ( mob_request.params.vrCommands ~= nil ) then mob_request.params.vrCommands = {"vrCommands_" .. tostring(200+i)} end
						--======================================================================================================
				
						commonTestCases:DelayedExp(iTimeout)
			
						--mobile side: sending RPC request
						local cid = self.mobileSession:SendRPC(mob_request.name, mob_request.params)
							
						--======================================================================================================
						-- Update of verified params
						if( hmi_call.params.cmdID ~= nil )      then hmi_call.params.cmdID = (200+i) end
						if( hmi_call.params.type ~= nil )       then hmi_call.params.type = "Command" end
						if( hmi_call.params.vrCommands ~= nil ) then hmi_call.params.vrCommands = {"vrCommands_" .. tostring(200 + i)} end
						if ( hmi_call.params.grammarID ~= nil ) then 
					  		if (mob_request.name == "DeleteCommand") then
					  			hmi_call.params.grammarID =  grammarID  
							else
					  			hmi_call.params.grammarID[1] =  grammarID  
					  		end
					  	end
						-- Update of verified params
						--======================================================================================================

						--hmi side: expect VR.AddCommand request
						EXPECT_HMICALL(hmi_method_call, hmi_call.params)
						:Do(function(_,data)
							--hmi side: sending VR.AddCommand response
							self.hmiConnection:SendError(data.id, data.method, "UNSUPPORTED_RESOURCE", "error message")					
							if(mob_request.name == "AddCommand") then grammarID = data.params.grammarID end
						end)
						

						for cnt = 1, #NotTestedInterfaces do
							for cnt_rpc = 1, #NotTestedInterfaces[cnt].usedRPC do
						 		local local_interface = NotTestedInterfaces[cnt].interface
						 		local local_rpc = NotTestedInterfaces[cnt].usedRPC[cnt_rpc].name
						 		local local_params = NotTestedInterfaces[cnt].usedRPC[cnt_rpc].params
						 		
						 		if (local_rpc == hmi_call.name) then
						 			--======================================================================================================
									-- Update of verified params
							 			if ( local_params.cmdID ~= nil ) then local_params.cmdID = 200+i end
							 			if ( local_params.menuParams ~= nil ) then local_params.menuParams =  {position = 1, menuName ="Command "..tostring(200+i)} end
							 			if ( local_params.appID ~= nil ) then local_params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end
									--======================================================================================================
									
									--hmi side: expect OtherInterfaces.RPC request 
									EXPECT_HMICALL(local_interface.."."..local_rpc, local_params)
									:Do(function(_,data)
										--hmi side: sending UI.AddCommand response
										self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "error message 2")
									end)
						 		end -- if (local_rpc == hmi_call.name) then
						 	end --for cnt_rpc = 1, #NotTestedInterfaces[cnt].usedRPC do
						end --for cnt = 1, #NotTestedInterfaces do
						
						--mobile side: expect AddCommand response
						EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE", info = "VR is not supported by system"})

						--mobile side: expect OnHashChange notification
						EXPECT_NOTIFICATION("OnHashChange")
						:Times(0)

						if(executeAllRPCs == false) then
							count_RPC = #RPCs
						end
					end
				end --for count_RPC = 1, #RPCs do
			end -- for i = 1, #TestData do
		end
		
		--checksplit_VR_RPCs_VR_Responds_UNSUPPORTED_RESOURCE_Others_respond_unsuccess_resultCodes(TestCaseName)
		--Checked in 3.3
		--checksplit_Interface_RPCs_Responds_UNSUPPORTED_RESOURCE_Others_respond_unsuccess_resultCodes(TestCaseName)

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

	
	--ToDo: Defect APPLINK-26394 Due to problem when stop and start SDL, script is debugged by updating user_modules/connecttest_VR_Isready.lua
	for i=1, #TestData do
		--for i=1, 1 do
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
			Test["InitHMI_onReady_VR_InReady_" .. tostring(TestCaseName)] = function(self)
							
				--self:initHMI_onReady_VR_IsReady(case)
				self:initHMI_onReady_Interfaces_IsReady(case)
				
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

			commonSteps:RegisterAppInterface()
			commonSteps:ActivationApp()
			
		end
	
		--TODO: Test is executed on parts
		--ToDo: Due to problem when stop and start SDL (APPLINK-26394 (stop and start SDL again)), script is debugged by updating user_modules/connecttest_VR_Isready.lua
		StopStartSDL_HMI_MOBILE(TestData[i].caseID, TestCaseName)
		
		--APPLINK_25044_split_RPCs(TestCaseName)
		if( i == 1) then
			Splitted_Interfaces_RPCs(TestCaseName, true, true)
		else
			Splitted_Interfaces_RPCs(TestCaseName, false, false)
		end
		
	
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

-- Not applicable for '..tested_method..' HMI API.


----------------------------------------------------------------------------------------------
------------------------------------------Post-condition--------------------------------------
----------------------------------------------------------------------------------------------


	function Test:Postcondition_Preloadedfile()
	  print ("restoring sdl_preloaded_pt.json")
	  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
	end

return Test