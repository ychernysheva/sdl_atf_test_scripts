-----------------------------------------------------------------------------------------------
---- – Scope: This script verifies below scenario:
	---- 1. HMI does not sends interface.IsReady() response or sends invalid response
	---- 2. Mobile -> SDL: A split request

	---- CASE 1
	---- 	1. SDL -> HMI(tested interface): request => Tested interface does not respond
	---- 	2. SDL -> HMI(other interface): request => SDL responds with different resultCode:
	---- 	3. SDL -> Mobile: "GENERIC_ERROR, success:false"

	---- CASE 2
	---- 	1. SDL -> HMI(tested interface): request => Tested interface responds with UNSUPPORTED_RESOURCE
	---- 	2. SDL -> HMI(other interface): request => SDL responds with different successfull resultCode
	---- 	3. SDL -> Mobile: "UNSUPPORTED_RESUORCE, success:true, info: "TestedInterface is not supported by system."

	---- CASE 3
	---- 	1. SDL -> HMI(tested interface): request => Tested interface responds with UNSUPPORTED_RESOURCE
	---- 	2. SDL -> HMI(other interface): request => SDL responds with different erroneous resultCode
	---- 	3. SDL -> Mobile: "UNSUPPORTED_RESUORCE, success:false, info: "TestedInterface is not supported by system."
-----------------------------------------------------------------------------------------------
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
		
	DefaultTimeout = 3
	local iTimeout = 2000
	local commonPreconditions = require ('/user_modules/shared_testcases/commonPreconditions')


---------------------------------------------------------------------------------------------
------------------------- General Precondition before ATF start -----------------------------
---------------------------------------------------------------------------------------------
	-- Precondition: remove policy table and log files
	commonSteps:DeleteLogsFileAndPolicyTable()

	local print_msg = ""

	if(Tested_resultCode ~= nil) then
		print_msg = "Test will be executed for resultCode = " .. Tested_resultCode .. "; "
	else
		Tested_resultCode = "AllTested"
		print_msg = "Test will be executed for all resultCodes; "
	end

	if(Tested_wrongJSON == nil) then
		Tested_wrongJSON = true
		print_msg = print_msg .. "All wrong JSON formats will be tested."
	else
		print_msg = print_msg .. "Wrong JSON formats won't be tested."
	end

	print("====================== ".. print_msg .. " ======================")
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
-------------------------------------------Common variables-----------------------------------
---------------------------------------------------------------------------------------------
	local RPCs           	  = commonFunctions:cloneTable(isReady.RPCs)
	local mobile_request 	  = commonFunctions:cloneTable(isReady.mobile_request)
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
	-----------------------------------------------------------------------------------------------
	--CRQ #1: 
	-- VR:  APPLINK-25044: [VR Interface] HMI does NOT respond to IsReady and mobile app sends RPC that must be splitted
	-- UI:  APPLINK-25099: [UI Interface] HMI does NOT respond to IsReady and mobile app sends RPC that must be splitted
	-- TTS: APPLINK-25139: [TTS Interface] HMI does NOT respond to IsReady and mobile app sends RPC that must be splitted
	-- VehicleInfo: Not applicable
	-- Navigation:  Not applicable
	-- Verification criteria:
		-- In case HMI does NOT respond to TestedInterface.IsReady_request
		-- and mobile app sends RPC to SDL that must be split to
		-- -> tested interface RPC
		-- -> any other <Interface>.RPC
		-- SDL must:
		-- transfer both tested interface RPC and <Interface>.RPC to HMI (in case <Interface> is supported by system)
		-- respond with '<received_resultCode_from_HMI>' to mobile app (please see list with resultCodes below)	
	-----------------------------------------------------------------------------------------------
	-- IsExecutedAllResultCodes:
	 							-- false: Test will be executed only for result code SUCCESS
	 							-- true:  Test will be executed for all possible result codes defined in structure TestData
	-- IsExecutedAllRelatedRPCs:
								-- false: Test will be executed only for first RPC
								-- true:  Test will be executed for all defined RPCs in structure RPCs
	local function Splitted_Interfaces_RPCs(TestCaseName, IsExecutedAllResultCodes, IsExecutedAllRelatedRPCs)
		
		--CASE 1: Tested interface does not respond
		local function checksplit_Interfaces_RPCs_TestedInterface_does_not_Respond(TestCaseName)
			local TestData = {}
			if(IsExecutedAllResultCodes == true) then
				TestData = {
				
						{success = true, resultCode = "SUCCESS", 					 expected_resultCode = "SUCCESS"},
						{success = true, resultCode = "WARNINGS", 					 expected_resultCode = "WARNINGS"},
						{success = true, resultCode = "WRONG_LANGUAGE", 			 expected_resultCode = "WRONG_LANGUAGE"},
						{success = true, resultCode = "RETRY", 						 expected_resultCode = "RETRY"},
						{success = true, resultCode = "SAVED", 						 expected_resultCode = "SAVED"},
								
						{success = false, resultCode = "", 							 expected_resultCode = "GENERIC_ERROR"},
						{success = false, resultCode = "ABC", 						 expected_resultCode = "INVALID_DATA"},
						
						{success = false, resultCode = "UNSUPPORTED_REQUEST", 		 expected_resultCode = "UNSUPPORTED_REQUEST"},
						{success = false, resultCode = "DISALLOWED", 				 expected_resultCode = "DISALLOWED"},
						{success = false, resultCode = "USER_DISALLOWED", 			 expected_resultCode = "USER_DISALLOWED"},
						{success = false, resultCode = "REJECTED", 					 expected_resultCode = "REJECTED"},
						{success = false, resultCode = "ABORTED", 					 expected_resultCode = "ABORTED"},
						{success = false, resultCode = "IGNORED", 					 expected_resultCode = "IGNORED"},
						{success = false, resultCode = "IN_USE", 					 expected_resultCode = "IN_USE"},
						{success = false, resultCode = "VEHICLE_DATA_NOT_AVAILABLE", expected_resultCode = "VEHICLE_DATA_NOT_AVAILABLE"},
						{success = false, resultCode = "TIMED_OUT", 				 expected_resultCode = "TIMED_OUT"},
						{success = false, resultCode = "INVALID_DATA", 				 expected_resultCode = "INVALID_DATA"},
						{success = false, resultCode = "CHAR_LIMIT_EXCEEDED", 		 expected_resultCode = "CHAR_LIMIT_EXCEEDED"},
						{success = false, resultCode = "INVALID_ID", 				 expected_resultCode = "INVALID_ID"},
						{success = false, resultCode = "DUPLICATE_NAME", 		     expected_resultCode = "DUPLICATE_NAME"},
						{success = false, resultCode = "APPLICATION_NOT_REGISTERED", expected_resultCode = "APPLICATION_NOT_REGISTERED"},
						{success = false, resultCode = "OUT_OF_MEMORY", 			 expected_resultCode = "OUT_OF_MEMORY"},
						{success = false, resultCode = "TOO_MANY_PENDING_REQUESTS",  expected_resultCode = "TOO_MANY_PENDING_REQUESTS"},
						{success = false, resultCode = "GENERIC_ERROR", 			 expected_resultCode = "GENERIC_ERROR"},
						{success = false, resultCode = "TRUNCATED_DATA", 			 expected_resultCode = "TRUNCATED_DATA"},
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
							Test["Precondition_PerformInteraction_CreateInteractionChoiceSet_" .. i.."_"..TestCaseName] = function(self)
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

						
						if( ( Tested_resultCode == "AllTested" ) or (Tested_resultCode == TestData[i].resultCode) ) then
							Test["TC01_"..TestCaseName .. "_"..mob_request.name.."_"..TestedInterface.."_does_not_responds_OtherInterfaces_respond_".. tostring(TestData[i].resultCode)] = function(self)
						
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
				 								if ( local_params.grammarID ~= nil ) then 
											  		if (mob_request.name == "DeleteCommand") then
											  			local_params.grammarID =  grammarID  
													else
											  			local_params.grammarID[1] =  grammarID  
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
							end

							if(IsExecutedAllRelatedRPCs == false) then
								break --use break to exit the second for loop "for count_RPC = 1, #RPCs do"
							end
						end --if( ( Tested_resultCode == "AllTested" ) or (Tested_resultCode == TestData[i].resultCode) ) then

					end --if(mob_request.splitted == true) then
				end --for count_RPC = 1, #RPCs do
			end -- for i = 1, #TestData do
		end
			
		checksplit_Interfaces_RPCs_TestedInterface_does_not_Respond(TestCaseName)

		--CASE 2: Other interfaces respond successful resultCodes. Tested interface responds UNSUPPORTED_RESOURCE
		--local function checksplit_VR_RPCs_VR_Responds_UNSUPPORTED_RESOURCE_Others_respond_success_resultCodes(TestCaseName)
		local function checksplit_TestedInterface_RPCs_Responds_UNSUPPORTED_RESOURCE_Others_respond_success_resultCodes(TestCaseName)
			local TestData = {}
			if(IsExecutedAllResultCodes == true) then
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
									cmdID = 101,		
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
							Test["Precondition_PerformInteraction_Precondition_CreateInteractionChoiceSet_" .. i ..TestCaseName] = function(self)
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
					
					if( ( Tested_resultCode == "AllTested" ) or (Tested_resultCode == TestData[i].resultCode) ) then
					
						Test["TC02_"..TestCaseName .. "_"..mob_request.name.."_"..TestedInterface.."_responds_UNSUPPORTED_RESOURCE_OtherInterfaces_respond_".. tostring(TestData[i].resultCode)] = function(self)

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
							if(mob_request.hashChange == true) then
								EXPECT_NOTIFICATION("OnHashChange")
								:Timeout(iTimeout)
							else
								EXPECT_NOTIFICATION("OnHashChange")
								:Times(0)
							end
																
						end

						if(IsExecutedAllRelatedRPCs == false) then
							break --use break to exit the second for loop "for count_RPC = 1, #RPCs do"
						end
					end -- if( ( Tested_resultCode == "AllTested" ) or (Tested_resultCode == TestData[i].resultCode) ) then
				end -- for count_RPC = 1, #RPCs do
			end -- for i = 1, #TestData do
		end
		
		checksplit_TestedInterface_RPCs_Responds_UNSUPPORTED_RESOURCE_Others_respond_success_resultCodes(TestCaseName)

		
		--CASE 3: Other interfaces respond unsuccessful resultCodes. Tested interface responds UNSUPPORTED_RESOURCE
		local function checksplit_Interface_RPCs_Responds_UNSUPPORTED_RESOURCE_Others_respond_unsuccess_resultCodes(TestCaseName)

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
							Test["Precondition_AddCommand_201" ..TestCaseName] = function(self)
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
						Test["Precondition_PerformInteraction_CreateInteractionChoiceSet_" .. i ..TestCaseName] = function(self)
								
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
					
					if( ( Tested_resultCode == "AllTested" ) or (Tested_resultCode == TestData[i].resultCode) ) then
					
						Test["TC03_"..TestCaseName .. "_"..mob_request.name.."_"..TestedInterface.."_responds_UNSUPPORTED_RESOURCE_OtherInterfaces_respond_".. tostring(TestData[i].resultCode)] = function(self)
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

							if(IsExecutedAllRelatedRPCs == false) then
								count_RPC = #RPCs
							end
						end

						if(IsExecutedAllRelatedRPCs == false) then
							break --use break to exit the second for loop "for count_RPC = 1, #RPCs do"
						end
					end --if( ( Tested_resultCode == "AllTested" ) or (Tested_resultCode == TestData[i].resultCode) ) then
				end --for count_RPC = 1, #RPCs do
			end -- for i = 1, #TestData do
		end
		
		checksplit_Interface_RPCs_Responds_UNSUPPORTED_RESOURCE_Others_respond_unsuccess_resultCodes(TestCaseName)

	end

	--ToDo: Defect APPLINK-26394 Due to problem when stop and start SDL, script is debugged by updating user_modules/connecttest_VR_Isready.lua
	for i=1, #TestData do
		--for i=1, 1 do
		local TestCaseName = "Case_" .. TestData[i].caseID .. "_IsReady_" ..TestData[i].description
				
		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup(TestCaseName)
		
		isReady:StopStartSDL_HMI_MOBILE(self, TestData[i].caseID, TestCaseName)

		-- Description: Register app for precondition
		commonSteps:RegisterAppInterface("Precondition_RegisterAppInterface_" .. TestCaseName)
		
		-- Description: Activation app for precondition
		commonSteps:ActivationApp(nil, "Precondition_ActivationApp_" .. TestCaseName)
		
		if( i == 1) then
			-- execute test for all resultCodes and all related RPCs of the testing interface
			Splitted_Interfaces_RPCs(TestCaseName, true, true)
		else
			-- Tested_wrongJSON is defined in general lua script for execution
			-- if Tested_wrongJSON is not defined by default will be set to true. Test will be executed.
			if(Tested_wrongJSON == true) then
				-- execute test for only one resultCode (SUCCESS) and the first related RPC of the testing interface
				Splitted_Interfaces_RPCs(TestCaseName, false, false)
			end
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

return Test