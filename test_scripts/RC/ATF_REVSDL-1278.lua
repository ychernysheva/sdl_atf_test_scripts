local commonSteps = require("user_modules/shared_testcases/commonSteps")
commonSteps:DeleteLogsFileAndPolicyTable()

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

	
	
	
	

--======================================REVSDL-1278=========================================--
---------------------------------------------------------------------------------------------
------------REVSDL-1278: HMILevel change for rc-apps from passenger's device ----------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: 1. In case an application with AppHMIType "REMOTE_CONTROL" successfully registers from passenger's device at SDL and this application is not present in HMILevel resumption list, RSDL must notify this app via OnHMIStatus (NONE, params) about assigned NONE HMILevel.
	

	--Begin Test case CommonRequestCheck.1.1
	--Description: 	In case an application with AppHMIType "REMOTE_CONTROL" successfully registers from passenger's device at SDL and this application is not present in HMILevel resumption list, RSDL must notify this app via OnHMIStatus (NONE, params) about assigned NONE HMILevel.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1278
				--TC: REVSDL-1299, REVSDL-1337

		--Verification criteria: 
				--1. Assign NONE for passenger's rc-app - by RegisterAppInterface
				--2. Assign NONE for passenger's rc-app - by using 'exit' command from vehicle HMI

		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new app
				function Test:TC1_Precondition1()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.1.2
			--Description: Check that RSDL notified connected mobile app via OnHMIStatus (NONE, params) about assigned NONE HMILevel. 
				function Test:TC1_App1NONE()
					self.mobileSession1:StartService(7)
					:Do(function()
							local CorIdRegister = self.mobileSession1:SendRPC("RegisterAppInterface",
							{
							  syncMsgVersion =
							  {
								majorVersion = 3,
								minorVersion = 0
							  },
							  appName = "Test Application1",
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
								appName = "Test Application1"
							  }
							})
							:Do(function(_,data)
								self.applications["Test Application1"] = data.params.application.appID
								
								--RSDL sends BC.ActivateApp (level: NONE) to HMI
								EXPECT_HMICALL("BasicCommunication.ActivateApp", 
								{
								  appID = self.applications["Test Application1"],
								  level = "NONE",
								  priority = "NONE"
								})									
								
							end)
							
							--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
							self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
							
							--mobile side: Expect OnPermissionsChange notification for Passenger's device
							self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
							
							--check OnHMIStatus with deviceRank = "PASSENGER"
							self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
							:Timeout(5000)
							
						end)
					end
			--End Test case CommonRequestCheck.1.1.2
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.3
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (HMILevel=LIMITED)
				function Test:TC1_App1LIMITED()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession1:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application1"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = 1,
													levelspan = 1,
													level = 0
												},
												moduleType = "RADIO",
												buttonPressMode = "LONG",
												buttonName = "VOLUME_UP"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					--Mobile side: RSDL sends OnHMIStatus (LIMITED,params)
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE"})
					
					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.3
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.4
			--Description: 
							--1. HMI sends to RSDL: BasicCommunication.OnExitApplication(USER_EXIT, appID)
							--2. RSDL returns to App_1: OnHMIStatus(NONE) notification. 
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application1"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.1.1.4

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.1.1
	
--=================================================END TEST CASES 1==========================================================--	




--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2

	--Description: 2. --An application with AppHMILevel "BACKGROUND"
	

	--Begin Test case CommonRequestCheck.2.1
	--Description: 	--An application with AppHMIType "REMOTE_CONTROL" 
						--From passenger's device 
						--Of NONE HMILevel 
						--Sends a remote-control RPC 
						--And this RPC is allowed by app's assigned policies 
						--And this RPC is from "auto_allow" section (see REVSDL-966 for details), 
						--RSDL must notify this app via OnHMIStatus (BACKGROUND, params) about assigned BACKGROUND HMILevel.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1278
				--TC: REVSDL-1300, REVSDL-1336

		--Verification criteria: 
				--1. Assign BACKGROUND for passenger's rc-app - by sending RPC from "auto_allow"
				--2. Assign BACKGROUND for passenger's rc-app - by receiving phonecall or emergency occurence notified from HMI

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.1
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonPressMode = LONG (BACKGROUND)
				function Test:TC2_App1BACKGROUND()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
				--hmi side: expect Buttons.ButtonPress request
				EXPECT_HMICALL("Buttons.ButtonPress", 
								{ 
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									},
									moduleType = "RADIO",
									buttonPressMode = "LONG",
									buttonName = "VOLUME_UP"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					--Mobile side: RSDL sends OnHMIStatus (BACKGROUND,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.1
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.2
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (HMILevel=LIMITED)
				function Test:TC2_App1LIMITED()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = 1,
													levelspan = 1,
													level = 0
												},
												moduleType = "RADIO",
												buttonPressMode = "LONG",
												buttonName = "VOLUME_UP"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					--Mobile side: RSDL sends OnHMIStatus (LIMITED,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE"})
					
					self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.3
			--Description: (refer to defect: REVSDL-1541)
							--1. RSDL receives BC.OnPhoneCall(isActive:true) from HMI.
							--2. RSDL returns to mobile: OnHMIStatus(LIMITED, params) notification.
				function Test:TC2_OnPhoneCallLIMITED()

					--hmi side: HMI send BC.OnPhoneCall to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnPhoneCall", {isActive = true})
					
					--mobile side: Check that OnHMIStatus(BACKGROUND) sent by RSDL and received by App1
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.2.1.3

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.4
			--Description: 
							--1. HMI sends to RSDL: BasicCommunication.OnExitApplication(USER_EXIT, appID)
							--2. RSDL returns to App_1: OnHMIStatus(NONE) notification. 
				function Test:TC2_PreconditionNONE()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.2.1.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.5
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (set HMILevel=LIMITED again)
				function Test:TC2_PreconditionApp1LIMITED_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = 1,
													levelspan = 1,
													level = 0
												},
												moduleType = "RADIO",
												buttonPressMode = "LONG",
												buttonName = "VOLUME_UP"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					--Mobile side: RSDL sends OnHMIStatus (LIMITED,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE"})
					
					self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.5
			
		-----------------------------------------------------------------------------------------
		
			--[[Begin Test case CommonRequestCheck.2.1.6  : Removed this case due to defect: REVSDL-1378
			--Description: 
							--1. HMI sends to RSDL: OnEmergencyEvent(ON)
							--2. RSDL returns to mobile: OnHMIStatus(BACKGROUND, params) notification.
				function Test:TC2_OnEmergencyEventBACKGROUND()

					--hmi side: HMI send BC.OnPhoneCall to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnEmergencyEvent", {enabled = true})
					
					--mobile side: Check that OnHMIStatus(BACKGROUND) sent by RSDL and received by App1
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.2.1.6

		-----------------------------------------------------------------------------------------]]
		
	--End Test case CommonRequestCheck.2.1
--=================================================END TEST CASES 2==========================================================--




--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: 3. --An application with AppHMILevel "NONE" or "BACKGROUND"
	

	--Begin Test case CommonRequestCheck.3.1
	--Description: 	--An application with AppHMIType "REMOTE_CONTROL" 
						--An application with AppHMIType "REMOTE_CONTROL" 
						--From passenger's device 
						--Of NONE or BACKGROUND HMILevel sends an RPC 
						--And this RPC is allowed by app's assigned policies 
						--And this RPC is from "driver_allow" section (see REVSDL-966 for details) 
						--And the driver accepted the permission prompt 
						--RSDL must notify this app via OnHMIStatus (LIMITED, params) about assigned LIMITED HMILevel.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1278
				--TC: REVSDL-1328, REVSDL-1359

		--Verification criteria: 
				--1. Assign LIMITED for passenger's rc-app - from NONE
				--2. Assign LIMITED for passenger's rc-app - from BACKGROUND

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (NONE to LIMITED)
				function Test:TC2_NONEToLIMITED()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = 1,
													levelspan = 1,
													level = 0
												},
												moduleType = "RADIO",
												buttonPressMode = "LONG",
												buttonName = "VOLUME_UP"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					--Mobile side: RSDL sends OnHMIStatus (LIMITED,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE"})
					
					self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.2
			--Description: 
							--1. HMI sends to RSDL: BasicCommunication.OnExitApplication(USER_EXIT, appID)
							--2. RSDL returns to App_1: OnHMIStatus(NONE) notification. 
				function Test:TC2_PreconditionNONE()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.3
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonPressMode = LONG (BACKGROUND)
				function Test:TC2_App1BACKGROUND()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
				--hmi side: expect Buttons.ButtonPress request
				EXPECT_HMICALL("Buttons.ButtonPress", 
								{ 
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									},
									moduleType = "RADIO",
									buttonPressMode = "LONG",
									buttonName = "VOLUME_UP"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					--Mobile side: RSDL sends OnHMIStatus (BACKGROUND,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.3.1.4
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (set BACKGROUND to LIMITED)
				function Test:TC2_BACKGROUNDToLIMITED()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = 1,
													levelspan = 1,
													level = 0
												},
												moduleType = "RADIO",
												buttonPressMode = "LONG",
												buttonName = "VOLUME_UP"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					--Mobile side: RSDL sends OnHMIStatus (LIMITED,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE"})
					
					self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.1.4
			
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.3.1
--=================================================END TEST CASES 3==========================================================--






--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for Req.#4

	--Description: . --An application with AppHMILevel "NONE" or "BACKGROUND"
	

	--Begin Test case CommonRequestCheck.4.1
	--Description: 	--An application with AppHMIType "REMOTE_CONTROL" 
						--An application with AppHMIType "REMOTE_CONTROL" 
						--From passenger's device 
						--Of LIMITED HMILevel sends an RPC 
						--And this RPC is allowed by app's assigned policies 
						--And this RPC is from "auto_allow" section (see REVSDL-966 for details), 
						--RSDL must not change the HMILevel of this app.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1278
				--TC: REVSDL-1329

		--Verification criteria: 
				--1. Leave passenger's rc-app in LIMITED

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (NONE to LIMITED)
				function Test:TC4_NONEToLIMITED()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = 1,
													levelspan = 1,
													level = 0
												},
												moduleType = "RADIO",
												buttonPressMode = "LONG",
												buttonName = "VOLUME_UP"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					--Mobile side: RSDL sends OnHMIStatus (LIMITED,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE"})
					
					self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.1.2
			--Description: From App_1 mobile application, send an RPC which is allowed by App_1's assigned policies and this RPC is from "auto_allow" section. (zone=Driver)
				function Test:TC4_StillLIMITED()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
				--hmi side: expect Buttons.ButtonPress request
				EXPECT_HMICALL("Buttons.ButtonPress", 
								{ 
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									},
									moduleType = "RADIO",
									buttonPressMode = "LONG",
									buttonName = "VOLUME_UP"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					--Mobile side: RSDL doesn't sends OnHMIStatus (BACKGROUND,params)
					self.mobileSession:ExpectNotification("OnHMIStatus")
					:Times(0)
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.2
			
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.4.1
--=================================================END TEST CASES 4==========================================================--
		


		

--=================================================BEGIN TEST CASES 5==========================================================--
	--Begin Test suit CommonRequestCheck.5 for Req.#5

	--Description: . --An application with AppHMILevel "NONE" or "BACKGROUND"
	

	--Begin Test case CommonRequestCheck.5.1
	--Description: 	--An application with AppHMIType "REMOTE_CONTROL" 
						--An application with AppHMIType "REMOTE_CONTROL" 
						--From passenger's device 
						--Of LIMITED HMILevel sends an RPC 
						--And this RPC is allowed by app's assigned policies 
						--And this RPC is from "driver_allow" section (see REVSDL-966 for details) 
						--And the the permission prompt is either denied by the driver, timed out or unsuccessful 
						--RSDL must not change the HMILevel of this app.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1278
				--TC: REVSDL-1330, REVSDL-1358

		--Verification criteria: 
				--1. Leave passenger's rc-app in BACKGROUND/NONE - NONE case
				--2. Leave passenger's rc-app in BACKGROUND/NONE - BACKGROUND case

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (Driver denied permission)
				function Test:TC5_NONEDenied()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = 1,
													levelspan = 1,
													level = 0
												},
												moduleType = "RADIO",
												buttonPressMode = "LONG",
												buttonName = "VOLUME_UP"
							})
							:Times(0)
							:Do(function(_,data)
								--hmi side: sending Buttons.ButtonPress response
								self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
							end)
							
					end)

					--Check RSDL log: HMI sends RC.GetInteriorVehicleDataConsent(resultCode:SUCCESS, allowed:false) to RSDL and HMILevel of App_1 is not changed.
					self.mobileSession:ExpectNotification("OnHMIStatus")
					:Times(0)					
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.5.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.1.2
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (TIMEOUT 10s)
				function Test:TC5_NONETimeout10s()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)
							local function HMIResponse()						
								--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
								self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
								
								--hmi side: expect Buttons.ButtonPress request
								EXPECT_HMICALL("Buttons.ButtonPress", 
												{ 
													zone =
													{
														colspan = 2,
														row = 0,
														rowspan = 2,
														col = 1,
														levelspan = 1,
														level = 0
													},
													moduleType = "RADIO",
													buttonPressMode = "LONG",
													buttonName = "VOLUME_UP"
								})
								:Times(0)
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
							end

							RUN_AFTER(HMIResponse, 10000)							
					end)								
					
					--Check RSDL log: HMI sends RC.GetInteriorVehicleDataConsent(resultCode:SUCCESS, allowed:false) to RSDL and HMILevel of App_1 is not changed.
					self.mobileSession:ExpectNotification("OnHMIStatus")
					:Times(0)
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.5.1.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.5.1.3
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (Emulation HMI sending the erroneous response)
				function Test:TC5_NONEError()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", {"SUCCESS"}, {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = 1,
													levelspan = 1,
													level = 0
												},
												moduleType = "RADIO",
												buttonPressMode = "LONG",
												buttonName = "VOLUME_UP"
							})
							:Times(0)
							:Do(function(_,data)
								--hmi side: sending Buttons.ButtonPress response
								self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
							end)
							
					end)
					
					--Check RSDL log: HMI sends RC.GetInteriorVehicleDataConsent(resultCode:SUCCESS, allowed:false) to RSDL and HMILevel of App_1 is not changed.
					self.mobileSession:ExpectNotification("OnHMIStatus")
					:Times(0)					
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.5.1.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.1.4
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonPressMode = LONG (changing HMILevel to BACKGROUND)
				function Test:TC5_BACKGROUND()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
				--hmi side: expect Buttons.ButtonPress request
				EXPECT_HMICALL("Buttons.ButtonPress", 
								{ 
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									},
									moduleType = "RADIO",
									buttonPressMode = "LONG",
									buttonName = "VOLUME_UP"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					--Mobile side: RSDL sends OnHMIStatus (BACKGROUND,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.4
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.5.1.5
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (Driver denied permission)
				function Test:TC5_BACKGROUNDDenied()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = 1,
													levelspan = 1,
													level = 0
												},
												moduleType = "RADIO",
												buttonPressMode = "LONG",
												buttonName = "VOLUME_UP"
							})
							:Times(0)
							:Do(function(_,data)
								--hmi side: sending Buttons.ButtonPress response
								self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
							end)
							
					end)

					--Check RSDL log: HMI sends RC.GetInteriorVehicleDataConsent(resultCode:SUCCESS, allowed:false) to RSDL and HMILevel of App_1 is not changed.
					self.mobileSession:ExpectNotification("OnHMIStatus")
					:Times(0)					
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.5.1.5
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.1.6
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (TIMEOUT 10s)
				function Test:TC5_BACKGROUNDTimeout10s()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)
							local function HMIResponse()						
								--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
								self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
								
								--hmi side: expect Buttons.ButtonPress request
								EXPECT_HMICALL("Buttons.ButtonPress", 
												{ 
													zone =
													{
														colspan = 2,
														row = 0,
														rowspan = 2,
														col = 1,
														levelspan = 1,
														level = 0
													},
													moduleType = "RADIO",
													buttonPressMode = "LONG",
													buttonName = "VOLUME_UP"
								})
								:Times(0)
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
							end

							RUN_AFTER(HMIResponse, 10000)							
					end)								
					
					--Check RSDL log: HMI sends RC.GetInteriorVehicleDataConsent(resultCode:SUCCESS, allowed:false) to RSDL and HMILevel of App_1 is not changed.
					self.mobileSession:ExpectNotification("OnHMIStatus")
					:Times(0)
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.5.1.6
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.5.1.7
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (Emulation HMI sending the erroneous response)
				function Test:TC5_BACKGROUNDError()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 1,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "LONG",
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", {"SUCCESS"}, {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = 1,
													levelspan = 1,
													level = 0
												},
												moduleType = "RADIO",
												buttonPressMode = "LONG",
												buttonName = "VOLUME_UP"
							})
							:Times(0)
							:Do(function(_,data)
								--hmi side: sending Buttons.ButtonPress response
								self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
							end)
							
					end)
					
					--Check RSDL log: HMI sends RC.GetInteriorVehicleDataConsent(resultCode:SUCCESS, allowed:false) to RSDL and HMILevel of App_1 is not changed.
					self.mobileSession:ExpectNotification("OnHMIStatus")
					:Times(0)					
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.5.1.7
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.1
--=================================================END TEST CASES 5==========================================================--


		
return Test	