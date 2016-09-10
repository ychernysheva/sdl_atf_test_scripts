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
	-- Precondition: remove policy table and log files
	commonSteps:DeleteLogsFileAndPolicyTable()


---------------------------------------------------------------------------------------------
---------------------------- General Settings for configuration----------------------------
---------------------------------------------------------------------------------------------
	Test = require('connecttest')

	require('cardinalities')
	local events = require('events')  
	local mobile_session = require('mobile_session')
	require('user_modules/AppTypes')
	local isReady = require('user_modules/isReady')

---------------------------------------------------------------------------------------------
------------------------------------ Common variables ---------------------------------------
---------------------------------------------------------------------------------------------
	local RPCs = commonFunctions:cloneTable(isReady.RPCs)
	local mobile_request = commonFunctions:cloneTable(isReady.mobile_request)
	local NotTestedInterfaces = commonFunctions:cloneTable(isReady.NotTestedInterfaces)
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
	-- VR:          APPLINK-20918: [GENIVI] VR interface: SDL behavior in case HMI does not respond to IsReady_request or respond with "available" = false
	-- UI:          APPLINK-25085: [GENIVI] UI interface: SDL behavior in case HMI does not respond to IsReady_request or respond with "available" = false
	-- TTS:         APPLINK-25117: [GENIVI] TTS interface: SDL behavior in case HMI does not respond to IsReady_request or respond with "available" = false
	-- Navigation:  APPLINK-25169: [GENIVI] Navigation interface: SDL behavior in case HMI does not respond to IsReady_request or respond with "available" = false
	-- VehicleInfo: APPLINK-25200: [GENIVI] VehicleInfo interface: SDL behavior in case HMI does not respond to IsReady_request or respond with "available" = false

-----------------------------------------------------------------------------------------------

	--List of CRQs:	
		--CRQ #1) 
			-- VR:  APPLINK-25042: [VR Interface] VR.IsReady(false) -> HMI respond with successfull resultCode to splitted RPC
			-- UI:  APPLINK-25102: [UI Interface] UI.IsReady(false) -> HMI respond with successfull resultCode to splitted RPC
			-- TTS: APPLINK-25133: [TTS Interface] TTS.IsReady(false) -> HMI respond with successfull resultCode to splitted RPC
			-- VehicleInfo: Not applicable
			-- Navigation: Not applicable
		--CRQ #2) 
			-- VR:  APPLINK-25043: [VR Interface] VR.IsReady(false) -> HMI respond with errorCode to splitted RPC
			-- UI:  APPLINK-25100: [UI Interface] UI.IsReady(false) -> HMI respond with errorCode to splitted RPC
			-- TTS: APPLINK-25134: [TTS Interface] TTS.IsReady(false) -> HMI respond with errorCode to splitted RPC
			-- VehicleInfo: Not applicable
			-- Navigation:  Not applicable
		
		

		
	local TestCaseName = TestedInterface .."_IsReady_response_availabe_false"
		
	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(TestCaseName)
		
	isReady:StopStartSDL_HMI_MOBILE(self, 0, TestCaseName)
		
			
	-----------------------------------------------------------------------------------------------
	--CRQ #1) 
			-- VR:  APPLINK-25042: [VR Interface] VR.IsReady(false) -> HMI respond with successfull resultCode to splitted RPC
			-- UI:  APPLINK-25102: [UI Interface] UI.IsReady(false) -> HMI respond with successfull resultCode to splitted RPC
			-- TTS: APPLINK-25133: [TTS Interface] TTS.IsReady(false) -> HMI respond with successfull resultCode to splitted RPC
			-- VehicleInfo: Not applicable
			-- Navigation: Not applicable
	-- Verification criteria:
		-- In case SDL receives TestedInterface.IsReady (available=false) from HMI
		-- and mobile app sends RPC to SDL that must be split to:
		-- -> TestedInterface RPC
		-- -> any other <Interface>.RPC
		-- SDL must:
		-- transfer only <Interface>.RPC to HMI (in case <Interface> is supported by system)
		-- respond with 'UNSUPPORTED_RESOURCE, success:true,' + 'info: TestedInterface is not supported by system' to mobile app IN CASE <Interface>.RPC was successfully processed by HMI (please see list with resultCodes below)
	
	-----------------------------------------------------------------------------------------------	
	commonSteps:RegisterAppInterface("Precondition_RegisterAppInterface_"..TestCaseName)
		
	-- Description: Activation app for precondition
	commonSteps:ActivationApp( nil, "Precondition_ActivationApp_"..TestCaseName)

	-- For VehicleInfo and Navigation specified requirements are not applicable.
	if( (TestedInterface ~= "VehicleInfo") and (TestedInterface~="Navigation") ) then
		--local function VR_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_SUCCESS(TestCaseName)
		local function Interface_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_SUCCESS(TestCaseName)

			-- List of successful resultCodes (success:true)
			local TestData = {
								{resultCode = "SUCCESS", 		info = "VR is not supported by system"},
								{resultCode = "WARNINGS", 		info = "VR is not supported by system"},
								{resultCode = "WRONG_LANGUAGE", info = "VR is not supported by system"},
								{resultCode = "RETRY", 			info = "VR is not supported by system"},
								{resultCode = "SAVED", 			info = "VR is not supported by system"},
							}

			-- All applicable RPCs
			for i = 1, #TestData do
			--for i = 1, 1 do
					for count_RPC = 1, #RPCs do
						local mob_request = mobile_request[count_RPC]
						local hmi_call = RPCs[count_RPC]
						local other_interfaces_call = {}			
						local hmi_method_call = TestedInterface.."."..hmi_call.name
						local vrCmd = ""
						local local_menuparams = ""

						Test["TC01_"..TestCaseName .. "_"..mob_request.name.."_UNSUPPORTED_RESOURCE_true_Incase_OtherInterfaces_responds_" .. TestData[i].resultCode] = function(self)
					
							--======================================================================================================
							-- Update of used params
								if ( hmi_call.params.appID ~= nil ) then hmi_call.params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end
								if ( mob_request.params.cmdID ~= nil ) then mob_request.params.cmdID = i end
				 				if ( mob_request.params.menuParams ~= nil ) then mob_request.params.menuParams =  {position = 1, menuName ="Command "..tostring(i)} end
				 				if ( mob_request.params.appID ~= nil ) then mob_request.params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end
							--======================================================================================================
							commonTestCases:DelayedExp(iTimeout)
					
							--mobile side: sending RPC request
							local cid = self.mobileSession:SendRPC(mob_request.name, mob_request.params)
								
							--hmi side: expect Interface.RPC request 	
							for cnt = 1, #NotTestedInterfaces do
								for cnt_rpc = 1, #NotTestedInterfaces[cnt].usedRPC do
							
						 			local local_interface = NotTestedInterfaces[cnt].interface
						 			local local_rpc = NotTestedInterfaces[cnt].usedRPC[cnt_rpc].name
						 			local local_params = NotTestedInterfaces[cnt].usedRPC[cnt_rpc].params
						 		
						 			if (local_rpc == hmi_call.name) then
										
										--======================================================================================================
										-- Update of verified params
						 					if ( local_params.cmdID ~= nil ) then local_params.cmdID = i end
						 					if ( local_params.menuParams ~= nil ) then local_params.menuParams =  {position = 1, menuName ="Command "..tostring(i)} end
						 					if ( local_params.appID ~= nil ) then local_params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end
						 				--======================================================================================================
						 				--print("TC01_ Waiting RPC: "..local_interface.."."..local_rpc)

						 				EXPECT_HMICALL(local_interface.."."..local_rpc, local_params)
										:Do(function(_,data)
											--hmi side: sending Interface.RPC response 
											self.hmiConnection:SendResponse(data.id, data.method, TestData[i].resultCode, {})
										end)	
						 			end --if (local_rpc == hmi_call.name) then
						 		end--for cnt_rpc = 1, #NotTestedInterfaces[cnt].usedRPC do
							end--for cnt = 1, #NotTestedInterfaces do
							
							--hmi side: expect there is no request is sent to the testing interface.
							EXPECT_HMICALL(hmi_method_call, {})
							:Times(0)
							
							--mobile side: expect RPC response
							EXPECT_RESPONSE(cid, {success = true, resultCode = "UNSUPPORTED_RESOURCE", info = TestData[i].info})
							:Timeout(iTimeout)

							--mobile side: expect OnHashChange notification
							if(mob_request.hashChange == true) then
								EXPECT_NOTIFICATION("OnHashChange")
								:Timeout(iTimeout)
							else
								EXPECT_NOTIFICATION("OnHashChange")
								:Times(0)
							end
						end
					end --for count_RPC = 1, #RPCs do
			end --for i = 1, #TestData do
		end

		--VR_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_SUCCESS("VR_IsReady_availabe_false_split_RPC_SUCCESS")
		Interface_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_SUCCESS(TestedInterface .."_IsReady_availabe_false_split_RPC_SUCCESS")
	else
		print("\27[31m This case is not applicable for "..TestedInterface .." \27[0m")
	end -- if( (TestedInterface ~= "VehicleInfo") and (TestedInterface~="Navigation") ) then
		
		
	-----------------------------------------------------------------------------------------------	
	--CRQ #2) 
			-- VR:  APPLINK-25043: [VR Interface] VR.IsReady(false) -> HMI respond with errorCode to splitted RPC
			-- UI:  APPLINK-25100: [UI Interface] UI.IsReady(false) -> HMI respond with errorCode to splitted RPC
			-- TTS: APPLINK-25134: [TTS Interface] TTS.IsReady(false) -> HMI respond with errorCode to splitted RPC
			-- VehicleInfo: Not applicable
			-- Navigation:  Not applicable
	--Verification criteria:
		-- In case SDL receives TestedInterface.IsReady (available=false) from HMI
		-- and mobile app sends RPC to SDL that must be split to:
		-- -> TestedInterface RPC
		-- -> any other <Interface>.RPC 
		-- SDL must:
		-- transfer only <Interface>.RPC to HMI (in case <Interface> is supported by system)
		-- respond with '<received_errorCode_from_HMI>' to mobile app IN CASE <Interface>.RPC got any erroneous resultCode from HMI (please see list with resultCodes below)
	-----------------------------------------------------------------------------------------------	
	--ToDo: Update according to question APPLINK-26900
	-- For VehicleInfo and Navigation specified requirements are not applicable.
	if( (TestedInterface ~= "VehicleInfo") and (TestedInterface~="Navigation") ) then	

			--local function VR_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_Error(TestCaseName)
			local function Interface_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_Error(TestCaseName)
				
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
			
				-- All RPCs		
				for i = 1, #TestData do
				--for i = 1, 1 do
					for count_RPC = 1, #RPCs do
						local mob_request = mobile_request[count_RPC]
						local hmi_call = RPCs[count_RPC]
						local other_interfaces_call = {}			
						local hmi_method_call = TestedInterface.."."..hmi_call.name
					
						Test["TC02_"..TestCaseName .. "_"..mob_request.name.."_UNSUPPORTED_RESOURCE_true_Incase_UI_responds_" .. TestData[i].resultCode] = function(self)
							--Test[TestCaseName .. "_AddCommand_UNSUPPORTED_RESOURCE_true_Incase_UI_responds_" .. TestData[i].resultCode] = function(self)
							--======================================================================================================
							-- Update of used params
								if ( hmi_call.params.appID ~= nil ) then hmi_call.params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end

								if ( mob_request.params.cmdID      ~= nil ) then mob_request.params.cmdID = i end
								if ( mob_request.params.vrCommands ~= nil ) then mob_request.params.vrCommands = { "vrCommands_" .. tostring(i) } end
								if ( mob_request.params.menuParams ~= nil ) then mob_request.params.menuParams = {position = 1, menuName = "Command " .. tostring(i)} end
							--======================================================================================================
							
							commonTestCases:DelayedExp(iTimeout)
					
							--mobile side: sending RPC request
							local cid = self.mobileSession:SendRPC(mob_request.name, mob_request.params)
								
							--hmi side: expect UI.AddCommand request 
							for cnt = 1, #NotTestedInterfaces do
								
								for cnt_rpc = 1, #NotTestedInterfaces[cnt].usedRPC do
							 		local local_interface = NotTestedInterfaces[cnt].interface
							 		local local_rpc = NotTestedInterfaces[cnt].usedRPC[cnt_rpc].name
							 		local local_params = NotTestedInterfaces[cnt].usedRPC[cnt_rpc].params
							 		
							 		if (local_rpc == hmi_call.name) then
							 			EXPECT_HMICALL(local_interface.."."..local_rpc, local_params)
										:Do(function(_,data)
											--hmi side: sending Interface.RPC response 
											if TestData[i].resultCode == "NOT_RESPOND" then
												--HMI does not respond
											else
												self.hmiConnection:SendError(data.id, data.method, TestData[i].resultCode, "Error Messages")
											end
										end)	
							 		end
							 	end --for cnt_rpc = 1, #NotTestedInterfaces[cnt].usedRPC do
							end --for cnt = 1, #NotTestedInterfaces do
							
							
							--hmi side: expect Interface.RPC request
							EXPECT_HMICALL(hmi_method_call, {})
							:Times(0)
							
							--mobile side: expect RPC response
							if TestData[i].resultCode == "NOT_RESPOND" then
								EXPECT_RESPONSE(cid, {success = false, resultCode = "GENERIC_ERROR"})
								:Timeout(12000)
							else
								EXPECT_RESPONSE(cid, {success = false, resultCode = TestData[i].resultCode, info = TestData[i].info})
							end
							
							--mobile side: expect OnHashChange notification
							EXPECT_NOTIFICATION("OnHashChange")
							:Times(0)
						end
					end --for count_RPC = 1, #RPCs do
				end -- for i = 1, #TestData do
			end
			
			--VR_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_Error("VR_IsReady_availabe_false_split_RPC_Unsuccess")
			Interface_IsReady_response_availabe_false_check_split_RPC_Other_Interfaces_Responds_Error(TestedInterface .."_IsReady_availabe_false_split_RPC_Unsuccess")
			--end
	else
		print("\27[31m This case is not applicable for "..TestedInterface .." \27[0m")
	end --if( (TestedInterface ~= "VehicleInfo") and (TestedInterface~="Navigation") ) then	
	


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

return Test