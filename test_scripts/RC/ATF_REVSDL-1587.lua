revsdl = require("user_modules/revsdl")

revsdl.AddUnknownFunctionIDs()
revsdl.SubscribeToRcInterface()

Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local config = require('config')
local module = require('testbase')

--List of resultscode
local RESULTS_CODE = {"SUCCESS", "WARNINGS", "RESUME_FAILED", "WRONG_LANGUAGE"}

--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice
--NonPrimaryNotification Group
local arrayGroups_nonPrimaryRCNotification = {
								permissionItem = {
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "OnHMIStatus"
									  },
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "OnPermissionsChange"
									  }
									 }
						}
--groups_PrimaryRC Group
local arrayGroups_PrimaryRC = {
							permissionItem = {
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED"},
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "AddCommand"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED"},
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "AddSubMenu"
								  },
								  {
									 hmiPermissions = {
										allowed = {"FULL", "LIMITED"},
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "Alert"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "ButtonPress"
								  },							  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "ChangeRegistration"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED"},
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "CreateInteractionChoiceSet"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED"},
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "DeleteCommand"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "DeleteFile"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED"},
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "DeleteInteractionChoiceSet"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED"},
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "DeleteSubMenu"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "EncodedSyncPData"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED"},
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "EndAudioPassThru"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED"},
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "GenericResponse"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "GetInteriorVehicleData"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "GetInteriorVehicleDataCapabilities"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "ListFiles"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnAppInterfaceUnregistered"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnAudioPassThru"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnButtonEvent"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnButtonPress"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnCommand"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnDriverDistraction"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnEncodedSyncPData"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnHMIStatus"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnHashChange"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnInteriorVehicleData"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnLanguageChange"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnPermissionsChange"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "OnSystemRequest"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "PerformAudioPassThru"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "PerformInteraction"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "PutFile"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "RegisterAppInterface"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "ResetGlobalProperties"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "FULL" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "ScrollableMessage"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "SetAppIcon"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "SetDisplayLayout"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "SetGlobalProperties"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "SetInteriorVehicleData"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "SetMediaClockTimer"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "Show"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "FULL" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "Slider"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "Speak"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "SubscribeButton"
								  },
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "SystemRequest"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "UnregisterAppInterface"
								  },								  
								  {
									 hmiPermissions = {
										allowed = { "BACKGROUND", "FULL", "LIMITED" },
										userDisallowed = {}
									 },
									 parameterPermissions = {
										allowed = {},
										userDisallowed = {}
									 },
									 rpcName = "UnsubscribeButton"
								  }
								}
						}
--groups_nonPrimaryRC Group
local arrayGroups_nonPrimaryRC = {
								permissionItem = {
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "ButtonPress"
									  },
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "GetInteriorVehicleData"
									  },
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "GetInteriorVehicleDataCapabilities"
									  },
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "OnHMIStatus"
									  },
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "OnInteriorVehicleData"
									  },
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "OnPermissionsChange"
									  },
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "OnSystemRequest"
									  },
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "SetInteriorVehicleData"
									  },
									  {
										 hmiPermissions = {
											allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
											userDisallowed = {}
										 },
										 parameterPermissions = {
											allowed = {},
											userDisallowed = {}
										 },
										 rpcName = "SystemRequest"
									  },									  
									 }
						}						
	
						

---------------------------------------------------------------------------------------------
-------------------------------------STARTING COMMON FUNCTIONS-------------------------------
---------------------------------------------------------------------------------------------

--Using for timeout
function sleep(iTimeout)
 os.execute("sleep "..tonumber(iTimeout))
end
--Using for Delaying event when AppRegistration
function DelayedExp()
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, 2000)
end

---------------------------------------------------------------------------------------------
----------------------------------------END COMMON FUNCTIONS---------------------------------
---------------------------------------------------------------------------------------------	

	
	
	
	

--======================================REVSDL-1587========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1587: Send OnHMIStatus("deviceRank") when the device status-------------
---------------------------changes between "driver's" and "passenger's"----------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: Check OnHMIStatus("deviceRank": <appropriate_value>, params) after RegisterAppInterface_response successfully
	

	--Begin Test case CommonRequestCheck.1
	--Description: 	Scenario 1:
				--Device1 is set as passenger's before app_1 registration with SDL
					

		--Requirement/Diagrams id in jira: 
				--REVSDL-1587
				--https://adc.luxoft.com/jira/secure/attachment/121961/121961_Req_1_of_REVSDL-1587.png

		--Verification criteria: 
				--RSDL must send OnHMIStatus("deviceRank": <appropriate_value>, params) notification to application registered with REMOTE_CONTROL appHMIType after this application successfully registers (after SDL sends RegisterAppInterface_response (<resultCode>, success:true) to such application.

		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.1.1
			--Description: Register new session for check OnHMIStatus with deviceRank = "PASSENGER"
				function Test:PreconditionRegistrationApp_Passenger()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.1.1
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.1
			--Description: check OnHMIStatus with deviceRank = "PASSENGER"
					function Test:OnHMIStatus_PassengerDevice()
						self.mobileSession1:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession1:SendRPC("RegisterAppInterface",
								{
								  syncMsgVersion =
								  {
									majorVersion = 3,
									minorVersion = 0
								  },
								  appName = "Test Application2",
								  isMediaApplication = true,
								  languageDesired = 'EN-US',
								  hmiDisplayLanguageDesired = 'EN-US',
								  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
								  appID = "1"
								})

								EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
								{
								  application = 
								  {
									appName = "Test Application2"
								  }
								})
								:Do(function(_,data)
									self.applications["Test Application2"] = data.params.application.appID
								end)
								
								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: 
									--> SUCCESS 
									--> WARNINGS 
									--> RESUME_FAILED 
									--> WRONG_LANGUAGE
								self.mobileSession1:ExpectResponse(CorIdRegister, { success = true })
								:ValidIf (function(_,data)
									local bSuccess = false
									for i = 1, #RESULTS_CODE do
										if data.payload.resultCode == RESULTS_CODE[i] then 
											bSuccess = true
											break 
										end
									end
									if bSuccess then
										return bSuccess
									else
										print( "Actual resultCode: ".. data.payload.resultCode ..". SDL sends RegisterAppInterface_response (success:true) with resultCodes not in {SUCCESS, WARNINGS, RESUME_FAILED, WRONG_LANGUAGE}")
										return bSuccess
									end
									
								end)
								
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.1.1

		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.1.2
			--Description: Register new session for check OnHMIStatus with deviceRank = "PASSENGER"
				function Test:PreconditionRegistrationApp_Passenger()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.1.2
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.2
			--Description: check OnHMIStatus with deviceRank = "PASSENGER", RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
					function Test:OnHMIStatus_PassengerDevice_SUCCESS()
						self.mobileSession1:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession1:SendRPC("RegisterAppInterface",
																{
																	syncMsgVersion = 
																	{ 
																		majorVersion = 2,
																		minorVersion = 2,
																	}, 
																	appName ="SyncProxyTester",
																	ttsName = 
																	{ 
																		 
																		{ 
																			text ="SyncProxyTester",
																			type ="TEXT",
																		}, 
																	}, 
																	ngnMediaScreenAppName ="SPT",
																	vrSynonyms = 
																	{ 
																		"VRSyncProxyTester",
																	}, 
																	isMediaApplication = true,
																	languageDesired ="EN-US",
																	hmiDisplayLanguageDesired ="EN-US",
																	appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
																	appID ="123456",
																	deviceInfo = 
																	{
																		hardware = "hardware",
																		firmwareRev = "firmwareRev",
																		os = "os",
																		osVersion = "osVersion",
																		carrier = "carrier",
																		maxNumberRFCOMMPorts = 5
																	}
																
																})
					

							--hmi side: expected  BasicCommunication.OnAppRegistered
							EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
						            {
						              	application = 
						              	{
						                	appName = "SyncProxyTester",
						                	ngnMediaScreenAppName ="SPT",
						                	deviceInfo = 
											{
												hardware = "hardware",
												firmwareRev = "firmwareRev",
												os = "os",
												osVersion = "osVersion",
												carrier = "carrier",
												maxNumberRFCOMMPorts = 5
											},
											policyAppID = "123456",
											hmiDisplayLanguageDesired ="EN-US",
											isMediaApplication = true,
											appHMIType = 
											{ 
												"NAVIGATION", "REMOTE_CONTROL"
											}
						              	},
						              	ttsName = 
										{ 
											 
											{ 
												text ="SyncProxyTester",
												type ="TEXT"
											}
										},
										vrSynonyms = 
										{ 
											"VRSyncProxyTester"
										}
						            })
								:Do(function(_,data)
									self.applications["Test Application2"] = data.params.application.appID
								end)
								
								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: 
									--> SUCCESS
								self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS"})
								
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.1.2

		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.1.3
			--Description: Register new session for check OnHMIStatus with deviceRank = "PASSENGER"
				function Test:PreconditionRegistrationApp_Passenger()
				  self.mobileSession2 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.1.3
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.3
			--Description: check OnHMIStatus with deviceRank = "PASSENGER", RegisterAppInterface_response (success:true) with the following resultCodes: RESUME_FAILED
					function Test:OnHMIStatus_PassengerDevice_RESUME_FAILED()
						self.mobileSession2:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession2:SendRPC("RegisterAppInterface",
																{
																  	 
																	syncMsgVersion = 
																	{ 
																		majorVersion = 2,
																		minorVersion = 2,
																	}, 
																	appName ="SyncProxyTester2",
																	isMediaApplication = true,
																	languageDesired ="EN-US",
																	hmiDisplayLanguageDesired ="EN-US",
																	appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
																	appID ="1234567",
																	hashID = "hashID"
																})

						--hmi side: expected  BasicCommunication.OnAppRegistered
						EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
						            {
						              	application = 
						              	{
						                	appName = "SyncProxyTester2",
											appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
											policyAppID = "1234567",
											hmiDisplayLanguageDesired ="EN-US",
											isMediaApplication = true
						              	}
						            })
								:Do(function(_,data)
									self.applications["SyncProxyTester2"] = data.params.application.appID
								end)
								
								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: 
									--> RESUME_FAILED
								self.mobileSession2:ExpectResponse(CorIdRegister, { success = true, resultCode = "RESUME_FAILED"})
								
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.1.3

		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.1.4
			--Description: Register new session for check OnHMIStatus with deviceRank = "PASSENGER"
				function Test:PreconditionRegistrationApp_Passenger()
				  self.mobileSession3 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.1.4
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.4
			--Description: check OnHMIStatus with deviceRank = "PASSENGER", RegisterAppInterface_response (success:true) with the following resultCodes: WRONG_LANGUAGE
					function Test:OnHMIStatus_PassengerDevice_WRONG_LANGUAGE()
						self.mobileSession3:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession3:SendRPC("RegisterAppInterface",
															{
																syncMsgVersion = 
																{ 
																	majorVersion = 2,
																	minorVersion = 2,
																}, 
																appName ="SyncProxyTester3",
																isMediaApplication = true,
																languageDesired = "DE-DE",
																hmiDisplayLanguageDesired ="EN-US",
																appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
																appID ="1234569",
															}) 
	 
			 		--hmi side: expected  BasicCommunication.OnAppRegistered
					EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
								            {
								              	application = 
								              	{
								                	appName = "SyncProxyTester3",
													appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
													policyAppID = "1234569",
													hmiDisplayLanguageDesired ="EN-US",
													isMediaApplication = true
								              	}
								            })
								:Do(function(_,data)
									self.applications["SyncProxyTester3"] = data.params.application.appID
								end)
								
								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: 
									--> WRONG_LANGUAGE
								self.mobileSession3:ExpectResponse(CorIdRegister, { success = true, resultCode = "WRONG_LANGUAGE"})
								
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.1.4

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.1.1
		

		

	--Begin Test case CommonRequestCheck.2
	--Description: 	Scenario 2:
				--Device1 is set as driver's before app_1 registration with SDL
					

		--Requirement/Diagrams id in jira: 
				--REVSDL-1360
				--https://adc.luxoft.com/jira/secure/attachment/121961/121961_Req_1_of_REVSDL-1587.png

		--Verification criteria: 
				--RSDL must send OnHMIStatus("deviceRank": <appropriate_value>, params) notification to application registered with REMOTE_CONTROL appHMIType after this application successfully registers (after SDL sends RegisterAppInterface_response (<resultCode>, success:true) to such application.

		-----------------------------------------------------------------------------------------				
				
			--Begin Test case Precondition.2.1.1
			--Description: Set device1 to Driver's device
				function Test:OnHMIStatus_SetDriverDevice()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
				
				end
			--End Test case Precondition.2.1.1
			
		-----------------------------------------------------------------------------------------	
				
			--Begin Test case Precondition.2.1.2
			--Description: Register new session for check OnHMIStatus with deviceRank = "DRIVER"
				function Test:PreconditionRegistrationApp_Driver()
				  self.mobileSession4 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.2.1.2
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.2.1
			--Description: check OnHMIStatus with deviceRank = "DRIVER"
					function Test:OnHMIStatus_DriverDevice()
						self.mobileSession4:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession4:SendRPC("RegisterAppInterface",
								{
								  syncMsgVersion =
								  {
									majorVersion = 3,
									minorVersion = 0
								  },
								  appName = "Test Application4",
								  isMediaApplication = true,
								  languageDesired = 'EN-US',
								  hmiDisplayLanguageDesired = 'EN-US',
								  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
								  appID = "4"
								})

								EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
								{
								  application = 
								  {
									appName = "Test Application4"
								  }
								})
								:Do(function(_,data)
									self.applications["Test Application4"] = data.params.application.appID
								end)
								
								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: 
									--> SUCCESS 
									--> WARNINGS 
									--> RESUME_FAILED 
									--> WRONG_LANGUAGE
								self.mobileSession4:ExpectResponse(CorIdRegister, { success = true })
								:ValidIf (function(_,data)
									local bSuccess = false
									for i = 1, #RESULTS_CODE do
										if data.payload.resultCode == RESULTS_CODE[i] then 
											bSuccess = true
											break 
										end
									end
									if bSuccess then
										return bSuccess
									else
										print( "Actual resultCode: ".. data.payload.resultCode ..". SDL sends RegisterAppInterface_response (success:true) with resultCodes not in {SUCCESS, WARNINGS, RESUME_FAILED, WRONG_LANGUAGE}")
										return bSuccess
									end
									
								end)
								
								--check OnHMIStatus with deviceRank = "DRIVER"
								self.mobileSession4:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.2.1
	
		-----------------------------------------------------------------------------------------	
	
	--End Test case CommonRequestCheck.1.2
	
--=================================================END TEST CASES 1==========================================================--





--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2

	--Description: Check OnHMIStatus("deviceRank": <appropriate_value>, params) after RegisterAppInterface_response successfully
	

	--Begin Test case CommonRequestCheck.2
	--Description: 	--RSDL must send OnHMIStatus("deviceRank: DRIVER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device 
							--in case RSDL has treated <deviceID> as passenger's 
							--AND RSDL gets OnDeviceRankChanged ("DRIVER", <deviceID>) notification from HMI 
							--(meaning, in case the device the rc-apps are running from is set as driver's)
					

		--Requirement/Diagrams id in jira: 
				--REVSDL-1587
				--https://adc.luxoft.com/jira/secure/attachment/121953/121953_Req_2_of_REVSDL-1587.png

		--Verification criteria: 
				--RSDL must send OnHMIStatus("deviceRank: DRIVER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device 
							--in case RSDL has treated <deviceID> as passenger's 
							--AND RSDL gets OnDeviceRankChanged ("DRIVER", <deviceID>) notification from HMI 
							--(meaning, in case the device the rc-apps are running from is set as driver's)
	
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.2.1
			--Description: Set device1 to Driver's device
				function Test:OnHMIStatus_OnDeviceRankChanged()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })					
				
				end
			--End Test case CommonRequestCheck.2.1
	
		-----------------------------------------------------------------------------------------	
	
	--End Test case CommonRequestCheck.2
	
--=================================================END TEST CASES 2==========================================================--	




--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device 
	

	--Begin Test case CommonRequestCheck.3
	--Description: 	--RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device 
							--in case RSDL has treated <deviceID> as driver's 
							--AND RSDL gets OnDeviceRankChanged ("PASSENGER", <deviceID>) notification from HMI (meaning, in case the device the rc-apps are running from is set as passenger's)
					

		--Requirement/Diagrams id in jira: 
				--REVSDL-1587
				--https://adc.luxoft.com/jira/secure/attachment/121954/121954_Req_3_of_REVSDL-1587.png

		--Verification criteria: 
				--RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device 
							--in case RSDL has treated <deviceID> as driver's 
							--AND RSDL gets OnDeviceRankChanged ("PASSENGER", <deviceID>) notification from HMI (meaning, in case the device the rc-apps are running from is set as passenger's)

		-----------------------------------------------------------------------------------------
							
			--Begin Test case Precondition.3
			--Description: Set device1 to Driver's device
				function Test:OnHMIStatus_SetDriverDevice()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
					{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })					
				
				end
			--End Test case Precondition.3
	
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.3.1
			--Description: Set device1 from Driver's to passenger's device
				function Test:OnHMIStatus_SetDriverToPassenger()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
					{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })					
				
				end
			--End Test case CommonRequestCheck.3.1	
	
		-----------------------------------------------------------------------------------------	
	
	--End Test case CommonRequestCheck.3
	
--=================================================END TEST CASES 3==========================================================--	




--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for Req.#4

	--Description: RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device 
	

	--Begin Test case CommonRequestCheck.4
	--Description: 	--RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device 
							--in case RSDL has treated <deviceID> as driver's 
							--AND RSDL gets OnDeviceRankChanged ("DRIVER", <deviceID_2>) notification from HMI (meaning, in case the device the rc-apps are running from is set as passenger's because of another device is chosen as driver's)
					

		--Requirement/Diagrams id in jira: 
				--REVSDL-1587
				--https://adc.luxoft.com/jira/secure/attachment/121955/121955_Req_4_of_REVSDL-1587.png

		--Verification criteria: 
				--RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device 
							--in case RSDL has treated <deviceID> as driver's 
							--AND RSDL gets OnDeviceRankChanged ("DRIVER", <deviceID_2>) notification from HMI (meaning, in case the device the rc-apps are running from is set as passenger's because of another device is chosen as driver's)
	
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case Precondition.4
			--Description: Set device1 to Driver's device
				function Test:OnHMIStatus_SetDriverDevice()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
					{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })					
				
				end
			--End Test case Precondition.4
	
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.4.1
			--Description: Set device2 to Driver's device. After that Device1 become passenger's device
				function Test:OnHMIStatus_SetAnotherDeviceToDriver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
					{deviceRank = "DRIVER", device = {name = "127.0.0.2", id = 2, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.4.1	
	
		-----------------------------------------------------------------------------------------	
	
	--End Test case CommonRequestCheck.4
	
--=================================================END TEST CASES 4==========================================================--	





--=================================================BEGIN TEST CASES 5==========================================================--

--[[p.5 is removed - per implementation issues (this requirement impacts SDL implementation hardly, while RSDL must be developed without any impact on SDL).
	--Begin Test suit CommonRequestCheck.5 for Req.#5

	--Description: RSDL must always include "deviceRank": <appropriate_value> parameter to OnHMIStatus in case RSDL is triggered to send OnHMIStatus notification to the application of REMOTE_CONTROL appHMIType because of HMILevel or systemContext or audioStreamingState change.
	

	--Begin Test case CommonRequestCheck.5.1
	--Description: 	Scenario 1: From HMI trigger HMILevel to change. Press EXIT_Application button.
					--RSDL must always include "deviceRank": <appropriate_value> parameter to OnHMIStatus in case RSDL is triggered to send OnHMIStatus notification to the application of REMOTE_CONTROL appHMIType because of HMILevel or systemContext or audioStreamingState change.
					

		--Requirement/Diagrams id in jira: 
				--REVSDL-1587
				--https://adc.luxoft.com/jira/secure/attachment/121956/121956_Req_5_of_REVSDL-1587.png

		--Verification criteria: 
				--RSDL must always include "deviceRank": <appropriate_value> parameter to OnHMIStatus in case RSDL is triggered to send OnHMIStatus notification to the application of REMOTE_CONTROL appHMIType because of HMILevel or systemContext or audioStreamingState change.
	
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case Precondition.5.1.1
			--Description: Set device1 to Driver's device
				function Test:OnHMIStatus_SetDriverDevice()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
					{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })					
				
				end
			--End Test case Precondition.5.1.1
	
		-----------------------------------------------------------------------------------------
	
			--Begin Test case Precondition.5.1.2
			--Description: Activation App from device1 to FULL level
				function Test:OnHMIStatus_ActivationApp()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)

				
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				
				end
			--End Test case Precondition.5.1.2

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.1.3
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button.
				function Test:OnHMIStatus_CheckOnHMIStatus()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.5.1.3

		-----------------------------------------------------------------------------------------

		
	--Begin Test case CommonRequestCheck.5.2
	--Description: 	Scenario 2: HMI sends OnSystemContext() to SDL
					--RSDL must always include "deviceRank": <appropriate_value> parameter to OnHMIStatus in case RSDL is triggered to send OnHMIStatus notification to the application of REMOTE_CONTROL appHMIType because of HMILevel or systemContext or audioStreamingState change.
					

		--Requirement/Diagrams id in jira: 
				--REVSDL-1587
				--https://adc.luxoft.com/jira/secure/attachment/121956/121956_Req_5_of_REVSDL-1587.png

		--Verification criteria: 
				--RSDL must always include "deviceRank": <appropriate_value> parameter to OnHMIStatus in case RSDL is triggered to send OnHMIStatus notification to the application of REMOTE_CONTROL appHMIType because of HMILevel or systemContext or audioStreamingState change.
	
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case Precondition.5.2.1
			--Description: Set device1 to Driver's device
				function Test:OnHMIStatus_SetDriverDevice()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
					{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })					
				
				end
			--End Test case Precondition.5.2.1
	
		-----------------------------------------------------------------------------------------
	
			--Begin Test case Precondition.5.2.2
			--Description: Activation App from device1 to FULL level
				function Test:OnHMIStatus_ActivationApp()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)

				
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				
				end
			--End Test case Precondition.5.2.2

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.2.3
			--Description: HMI sends OnSystemContext() to SDL
				function Test:OnHMIStatus_CheckOnHMIStatus()

					--hmi side: HMI sends OnSystemContext() to SDL
					self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = self.applications["Test Application"], systemContext = "MENU" })
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MENU", hmiLevel = "FULL", audioStreamingState = "AUDIBLE", deviceRank = "DRIVER" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.5.2.3

		-----------------------------------------------------------------------------------------

	--Begin Test case CommonRequestCheck.5.3
	--Description: 	Scenario 3: SDL send OnHMIStatus(NONE deviceRank:Driver OnSystemContext=) to mobile app. This notification can be observed on mobile app1.
					--RSDL must always include "deviceRank": <appropriate_value> parameter to OnHMIStatus in case RSDL is triggered to send OnHMIStatus notification to the application of REMOTE_CONTROL appHMIType because of HMILevel or systemContext or audioStreamingState change.
					

		--Requirement/Diagrams id in jira: 
				--REVSDL-1587
				--https://adc.luxoft.com/jira/secure/attachment/121956/121956_Req_5_of_REVSDL-1587.png

		--Verification criteria: 
				--RSDL must always include "deviceRank": <appropriate_value> parameter to OnHMIStatus in case RSDL is triggered to send OnHMIStatus notification to the application of REMOTE_CONTROL appHMIType because of HMILevel or systemContext or audioStreamingState change.
	
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case Precondition.5.3.1
			--Description: Set device1 to Driver's device
				function Test:OnHMIStatus_SetDriverDevice()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
					{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })					
				
				end
			--End Test case Precondition.5.3.1
	
		-----------------------------------------------------------------------------------------
	
			--Begin Test case Precondition.5.3.2
			--Description: Activation App from device1 to FULL level
				function Test:OnHMIStatus_ActivationApp()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)

				
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				
				end
			--End Test case Precondition.5.3.2

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.3.3
			--Description: SDL send OnHMIStatus(NONE deviceRank:Driver OnSystemContext=) to mobile app. This notification can be observed on mobile app1.
				function Test:OnHMIStatus_CheckOnHMIStatus()

					--hmi side: SDL send OnHMIStatus(NONE deviceRank:Driver OnSystemContext=) to mobile app. This notification can be observed on mobile app1.
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", deviceRank = "DRIVER" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.5.3.3

		-----------------------------------------------------------------------------------------
	
	--End Test case CommonRequestCheck.5
]]	
--=================================================END TEST CASES 5==========================================================--	



		
	
return Test	