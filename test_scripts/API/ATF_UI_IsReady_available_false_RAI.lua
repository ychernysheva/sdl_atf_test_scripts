print("\27[31m SDL crushes with DCHECK. Some tests are commented. After resolving uncomment tests!\27[0m")

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
-- Cases 1: HMI sends '..tested_method..' response (available = false)
-----------------------------------------------------------------------------------------------
	--List of CRQs:	
		--CRQ #1) APPLINK-25046: [RegisterAppInterface] SDL behavior in case <Interface> is not supported by system => omit <Interface>-related parameters from response to mobile app (meaning: SDL must NOT retrieve the default values from 'HMI_capabilities.json' file and provide via response to mobile app)		
		
	local function case1_IsReady_availabe_false()	
		local TestCaseName = TestedInterface .."_IsReady_response_availabe_false"
		
		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup(TestCaseName)
		
		local function StopStartSDL_HMI_MOBILE()
		
			--Stop SDL
			Test["Precondition_StopSDL_" ..tostring(TestCaseName)] = function(self)

				StopSDL()
			end
			
			--Start SDL
			Test["Precondition_StartSDL_" ..tostring(TestCaseName) ] = function(self)

				StartSDL(config.pathToSDL, config.ExitOnCrash)
			end
			
			--InitHMI
			Test["Precondition_InitHMI_" ..tostring(TestCaseName)] = function(self)

				self:initHMI()
			end
			
			
			--InitHMIonReady: 
			-- VR: APPLINK-25286: [HMI_API] '..tested_method..'
			-- UI: 
			-- TTS:
			-- VehicleInfo: APPLINK-25305
			-- Navigation: APPLINK-25301
			Test["Precondition_InitHMI_onReady_"..TestedInterface.."_IsReady_" ..tostring(TestCaseName)] = function(self)
				
				--self:initHMI_onReady_VR_IsReady(0)	--	availabe = false
				self:initHMI_onReady_Interfaces_IsReady(0)
			end

			
			--ConnectMobile
			Test["ConnectMobile_" ..tostring(TestCaseName)] = function(self)

				self:connectMobile()
			end
			
			--StartSession
			Test["StartSession_"..tostring(TestCaseName)] = function(self)

				self.mobileSession= mobile_session.MobileSession(self, self.mobileConnection)
				self.mobileSession:StartService(7)
			end
		end
		
		--ToDo: Due to problem with stop and start SDL (APPLINK-26394 (stop and start SDL again)), this step is skipped and 
		-- 		update user_modules/connecttest_VR_Isready.lua to send '..tested_method..'(available = false) response manually.
		
		StopStartSDL_HMI_MOBILE()
		
		-----------------------------------------------------------------------------------------------		
		--CRQ #1) APPLINK-25046: [RegisterAppInterface] SDL behavior in case <Interface> is not supported by system => omit <Interface>-related param from response to mobile app (meaning: SDL must NOT retrieve the default values from 'HMI_capabilities.json' file and provide via response to mobile app)
		-- Requirement it applicable for: VR; UI; TTS; VehicleInfo
		-- Requirement is NOT applicable for Navigation
		--Verification criteria:
			-- In case HMI respond <Interface>.IsReady (available=false) to SDL (<Interface>: VehicleInfo, TTS, UI, VR)
			-- and mobile app sends RegisterAppInterface_request to SDL
			-- and SDL successfully registers this application (see req-s # APPLINK-16420, APPLINK-16251, APPLINK-16250, APPLINK-16249, APPLINK-16320, APPLINK-15686, APPLINK-16307)
			-- SDL must omit <Interface>-related param from response to mobile app (meaning: SDL must NOT retrieve the default values from 'HMI_capabilities.json' file and provide via response to mobile app)		
		-----------------------------------------------------------------------------------------------		

		--local function RegisterApplication_Check_VR_Parameters_IsOmitted(TestCaseName)
		local function RegisterApplication_Check_Interfaces_Parameters_IsOmitted(TestCaseName)
		
			--List of resultCodes: APPLINK-16420 SUCCESS, APPLINK-16251 WRONG_LANGUAGE, APPLINK-16250 WRONG_LANGUAGE languageDesired, APPLINK-16249 WRONG_LANGUAGE hmiDisplayLanguageDesired, APPLINK-16320 UNSUPPORTED_RESOURCE unavailable/not supported component, APPLINK-15686 RESUME_FAILED, APPLINK-16307 WARNINGS, true

			-- APPLINK-16420 SUCCESS
			--Precondition: App has not been registered yet.			
			
			--Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_IsOmitted_resultCode_SUCCESS"] = function(self)
			Test["TC1_".."_Parameters_IsOmitted_resultCode_SUCCESS" ..TestCaseName .. "_RegisterApplication_Check_"..TestedInterface] = function(self)
			
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
					if(TestedInterface ~= "Navigation") then
						local errorMessage = ""

						------------------------------------------------------------------------------------------
						-- VR:
							if ( data.payload.vrCapabilities and (TestedInterface == "VR") )then
								errorMessage = errorMessage .. "SDL resends 'vrCapabilities' parameter to mobile app. "
							end
							if ( data.payload.language and (TestedInterface == "VR") )then
								errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
							end	
						------------------------------------------------------------------------------------------
						-- UI:
							if ( data.payload.hmiDisplayLanguage and (TestedInterface == "UI") )then
								errorMessage = errorMessage .. "SDL resends 'hmiDisplayLanguage' parameter to mobile app. "
							end
							if ( data.payload.displayCapabilities and (TestedInterface == "UI") )then
								errorMessage = errorMessage .. "SDL resends 'displayCapabilities' parameter to mobile app. "
							end
							if ( data.payload.audioPassThruCapabilities and (TestedInterface == "UI") )then
								errorMessage = errorMessage .. "SDL resends 'audioPassThruCapabilities' parameter to mobile app. "
							end
							if ( data.payload.hmiCapabilities and (TestedInterface == "UI") )then
								errorMessage = errorMessage .. "SDL resends 'hmiCapabilities' parameter to mobile app. "
							end						
						------------------------------------------------------------------------------------------
						-- TTS:
							if ( data.payload.language and (TestedInterface == "TTS") )then
								errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
							end	
							if ( data.payload.speechCapabilities and (TestedInterface == "TTS") )then
								errorMessage = errorMessage .. "SDL resends 'speechCapabilities' parameter to mobile app"
							end
							--TODO: Check parameter name prerecordedSpeech or prerecordedSpeechCapabilities
							if ( data.payload.prerecordedSpeech and (TestedInterface == "TTS") )then
								errorMessage = errorMessage .. "SDL resends 'prerecordedSpeech' parameter to mobile app"
							end
						------------------------------------------------------------------------------------------
						-- VehicleInfo:
							if ( data.payload.vehicleType and (TestedInterface == "VehicleInfo") )then
								errorMessage = errorMessage .. "SDL resends 'vehicleType' parameter to mobile app"
							end	
						------------------------------------------------------------------------------------------

						if errorMessage == "" then
							return true					
						else
							commonFunctions:printError(errorMessage)
							return false
						end

					end --if(TestedInterface ~= Navigation) then
				end)
				
				--mobile side: expect notification
				self.mobileSession:ExpectNotification("OnHMIStatus", { systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"})
			end	
				
			commonSteps:UnregisterApplication("Postcondition_UnregisterApplication_SUCCESS")
			
			-- APPLINK-16320 UNSUPPORTED_RESOURCE unavailable/not supported component: It is not applicable for RegisterAppInterface because RegisterAppInterface is not split able request
			
			-- APPLINK-16251 WRONG_LANGUAGE
			-- APPLINK-16250 WRONG_LANGUAGE languageDesired
			--[[TODO: Uncomment when DOUBLE check is resolved!!!!!
				Test["TC2_RegisterApplication_Check_VR_Parameters_IsOmitted_resultCode_WRONG_LANGUAGE"..TestCaseName ] = function(self)
					
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
						if(TestedInterface ~= "Navigation") then
							local errorMessage = ""
							------------------------------------------------------------------------------------------
							-- VR:
								if ( data.payload.vrCapabilities and (TestedInterface == "VR") )then
									errorMessage = errorMessage .. "SDL resends 'vrCapabilities' parameter to mobile app. "
								end
								if ( data.payload.language and (TestedInterface == "VR") )then
									errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
								end	
							------------------------------------------------------------------------------------------
							-- UI:
								if ( data.payload.hmiDisplayLanguage and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'hmiDisplayLanguage' parameter to mobile app. "
								end
								if ( data.payload.displayCapabilities and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'displayCapabilities' parameter to mobile app. "
								end
								if ( data.payload.audioPassThruCapabilities and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'audioPassThruCapabilities' parameter to mobile app. "
								end
								if ( data.payload.hmiCapabilities and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'hmiCapabilities' parameter to mobile app. "
								end						
							------------------------------------------------------------------------------------------
							-- TTS:
								if ( data.payload.language and (TestedInterface == "TTS") )then
									errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
								end	
								if ( data.payload.speechCapabilities and (TestedInterface == "TTS") )then
									errorMessage = errorMessage .. "SDL resends 'speechCapabilities' parameter to mobile app"
								end
								--TODO: Check parameter name prerecordedSpeech or prerecordedSpeechCapabilities
								if ( data.payload.prerecordedSpeech and (TestedInterface == "TTS") )then
									errorMessage = errorMessage .. "SDL resends 'prerecordedSpeech' parameter to mobile app"
								end
							------------------------------------------------------------------------------------------
							-- VehicleInfo:
								if ( data.payload.vehicleType and (TestedInterface == "VehicleInfo") )then
									errorMessage = errorMessage .. "SDL resends 'vehicleType' parameter to mobile app"
								end	
							------------------------------------------------------------------------------------------
						
							if errorMessage == "" then
								return true					
							else
								commonFunctions:printError(errorMessage)
								return false
							end
						end --if(TestedInterface ~= Navigation) then
					end)
					
					--mobile side: expect notification
					self.mobileSession:ExpectNotification("OnHMIStatus", { systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"})
				end	
			
				--APPLINK-16249 WRONG_LANGUAGE hmiDisplayLanguageDesired: It is for UI interface only.
		

			
				-- APPLINK-16307 WARNINGS, true
				commonSteps:UnregisterApplication("Precondition_UnregisterApplication_for_checking_WARNINGS_" ..TestCaseName)
				
				--Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_IsOmitted_resultCode_WARNINGS"] = function(self)
				Test["TC3_".."_Parameters_IsOmitted_resultCode_WARNINGS" ..TestCaseName .. "_RegisterApplication_Check_"..TestedInterface] = function(self)
					
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
						if(TestedInterface ~= "Navigation") then
							local errorMessage = ""
							------------------------------------------------------------------------------------------
							-- VR:
								if ( data.payload.vrCapabilities and (TestedInterface == "VR") )then
									errorMessage = errorMessage .. "SDL resends 'vrCapabilities' parameter to mobile app. "
								end
								if ( data.payload.language and (TestedInterface == "VR") )then
									errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
								end	
							------------------------------------------------------------------------------------------
							-- UI:
								if ( data.payload.hmiDisplayLanguage and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'hmiDisplayLanguage' parameter to mobile app. "
								end
								if ( data.payload.displayCapabilities and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'displayCapabilities' parameter to mobile app. "
								end
								if ( data.payload.audioPassThruCapabilities and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'audioPassThruCapabilities' parameter to mobile app. "
								end
								if ( data.payload.hmiCapabilities and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'hmiCapabilities' parameter to mobile app. "
								end						
							------------------------------------------------------------------------------------------
							-- TTS:
								if ( data.payload.language and (TestedInterface == "TTS") )then
									errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
								end	
								if ( data.payload.speechCapabilities and (TestedInterface == "TTS") )then
									errorMessage = errorMessage .. "SDL resends 'speechCapabilities' parameter to mobile app"
								end
								--TODO: Check parameter name prerecordedSpeech or prerecordedSpeechCapabilities
								if ( data.payload.prerecordedSpeech and (TestedInterface == "TTS") )then
									errorMessage = errorMessage .. "SDL resends 'prerecordedSpeech' parameter to mobile app"
								end
							------------------------------------------------------------------------------------------
							-- VehicleInfo:
								if ( data.payload.vehicleType and (TestedInterface == "VehicleInfo") )then
									errorMessage = errorMessage .. "SDL resends 'vehicleType' parameter to mobile app"
								end	
							------------------------------------------------------------------------------------------
						
							if errorMessage == "" then
								return true					
							else
								commonFunctions:printError(errorMessage)
								return false
							end
						end --if(TestedInterface ~= Navigation) then
					end)

					--mobile side: expect notification
					self.mobileSession:ExpectNotification("OnHMIStatus", { systemContext="MAIN", hmiLevel="NONE", audioStreamingState="NOT_AUDIBLE"})
				end	
			]]
			-- APPLINK-15686 RESUME_FAILED
			--////////////////////////////////////////////////////////////////////////////////////////////--
			-- Check absence of resumption in case HashID in RAI is not match
			--////////////////////////////////////////////////////////////////////////////////////////////--
			--TODO: Commented because script can't be debugged.
			--[[		if(TestedInterface ~= "NAVIGATION") then
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

				--Test[TestCaseName .. "_RegisterApplication_Check_VR_Parameters_IsOmitted_resultCode_RESUME_FAILED"] = function(self)
				Test["TC4_"..TestCaseName .. "_RegisterApplication_Check_"..TestedInterface.."_Parameters_IsOmitted_resultCode_RESUME_FAILED"] = function(self)
			
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
						if(TestedInterface ~= "Navigation") then
							local errorMessage = ""
							------------------------------------------------------------------------------------------
							-- VR:
								if ( data.payload.vrCapabilities and (TestedInterface == "VR") )then
									errorMessage = errorMessage .. "SDL resends 'vrCapabilities' parameter to mobile app. "
								end
								if ( data.payload.language and (TestedInterface == "VR") )then
									errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
								end	
							------------------------------------------------------------------------------------------
							-- UI:
								if ( data.payload.hmiDisplayLanguage and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'hmiDisplayLanguage' parameter to mobile app. "
								end
								if ( data.payload.displayCapabilities and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'displayCapabilities' parameter to mobile app. "
								end
								if ( data.payload.audioPassThruCapabilities and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'audioPassThruCapabilities' parameter to mobile app. "
								end
								if ( data.payload.hmiCapabilities and (TestedInterface == "UI") )then
									errorMessage = errorMessage .. "SDL resends 'hmiCapabilities' parameter to mobile app. "
								end						
							------------------------------------------------------------------------------------------
							-- TTS:
								if ( data.payload.language and (TestedInterface == "TTS") )then
									errorMessage = errorMessage .. "SDL resends 'language' parameter to mobile app"
								end	
								if ( data.payload.speechCapabilities and (TestedInterface == "TTS") )then
									errorMessage = errorMessage .. "SDL resends 'speechCapabilities' parameter to mobile app"
								end
								--TODO: Check parameter name prerecordedSpeech or prerecordedSpeechCapabilities
								if ( data.payload.prerecordedSpeech and (TestedInterface == "TTS") )then
									errorMessage = errorMessage .. "SDL resends 'prerecordedSpeech' parameter to mobile app"
								end
							------------------------------------------------------------------------------------------
							-- VehicleInfo:
								if ( data.payload.vehicleType and (TestedInterface == "VehicleInfo") )then
									errorMessage = errorMessage .. "SDL resends 'vehicleType' parameter to mobile app"
								end	
							------------------------------------------------------------------------------------------
						
							if errorMessage == "" then
								return true					
							else
								commonFunctions:printError(errorMessage)
								return false
							end
						end --if(TestedInterface ~= Navigation) then
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
			end --if(TestedInterface ~= "NAVIGATION") then ]]
		end

		RegisterApplication_Check_Interfaces_Parameters_IsOmitted(TestCaseName)

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