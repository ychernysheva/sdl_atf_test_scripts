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

	
	
	
	

--======================================REVSDL-1066=========================================--
---------------------------------------------------------------------------------------------
-----------REVSDL-1066: RSDL must inform HMILevel of a rc-application to HMI ----------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: 1. In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from driver's device is changed (see REVSDL-994 for details), RSDL must inform this event via BC.ActivateApp (level: <appropriate assigned HMILevel of the app>) to HMI. 
					  --Exception: FULL level (that is, RSDL must not notify HMI about the rc-app has transitioned to FULL).
	

	--Begin Test case CommonRequestCheck.1.1
	--Description: 	In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from driver's device is changed (see REVSDL-994 for details), RSDL must inform this event via BC.ActivateApp (level: <appropriate assigned HMILevel of the app>) to HMI. 

		--Requirement/Diagrams id in jira: 
				--REVSDL-1066
				--TC: REVSDL-1311

		--Verification criteria: 
				--In case the device is set as 'driver's' (see REVSDL-831), R-SDL must assign "groups_primaryRC" permissions from appropriate policies to each remote-control app from this device.

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
			
			--Begin Test case Precondition.1.1.2
			--Description: Set device1 to Driver's device from HMI.
				function Test:TC1_Precondition2()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.1.3
			--Description: RSDL sends BC.ActivateApp (level: NONE) to HMI
					function Test:TC1_Driver_LevelNONE()
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
								
								--mobile side: Expect OnPermissionsChange notification for Driver's device
								self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
								
								--check OnHMIStatus with deviceRank = "DRIVER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
								:Timeout(5000)
								
							end)
						end
			--End Test case CommonRequestCheck.1.1.3
		-----------------------------------------------------------------------------------------	
	--End Test case CommonRequestCheck.1.1
	
	
	
	--Begin Test case CommonRequestCheck.1.2
	--Description: 	In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from driver's device is changed (see REVSDL-994 for details), RSDL must inform this event via BC.ActivateApp (level: <appropriate assigned HMILevel of the app>) to HMI. 

		--Requirement/Diagrams id in jira: 
				--REVSDL-1066
				--TC: REVSDL-1312

		--Verification criteria: 
				--In case the device is set as 'driver's' (see REVSDL-831), R-SDL must assign "groups_primaryRC" permissions from appropriate policies to each remote-control app from this device.

		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.1.2.1
			--Description: Register new session for register new app
				function Test:TC2_Precondition1()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.1.2.1
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case Precondition.1.2.2
			--Description: Set device1 to Driver's device from HMI.
				function Test:TC2_Precondition2()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case Precondition.1.2.2
	
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.2.3
			--Description: activate App1 to FULL
				function Test:TC2_Precondition3()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.1.2.3
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.2.4
			--Description: Register App2 from Device1
				function Test:TC2_Precondition4()
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
									},
									{
									  appID = self.applications["Test Application"],
									  level = "LIMITED",
									  priority = "NONE"
									}
								)
								:Times(2)
								:Do(function(_,data)
									--Deactived App1 to LIMITED after register App2
									self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
								end)
								
							end)
							
							--App2 side: SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
							self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
							
							--App2 side: side: Expect OnPermissionsChange notification for Driver's device
							self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
							
							--App2 side: check OnHMIStatus with HMILEVEL NONE and deviceRank = "DRIVER"
							self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })							
							:Timeout(5000)
							
							--App1 side: changing HMILevel to LIMITED
							self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
							:Timeout(5000)
							
					end)
				end
			--End Test case CommonRequestCheck.1.2.4
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.1.2.5
			--Description: activate App2 to FULL
				function Test:TC2_ActivatedApp2_FULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application1"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)					
					
					--RSDL sends BC.ActivateApp to HMI for App1 and App2
					EXPECT_HMICALL("BasicCommunication.ActivateApp",
						{
						  appID = self.applications["Test Application"],
						  level = "BACKGROUND",
						  priority = "NONE"
						}
					)
					
					--App1 side: RSDL sends OnHMIStatus (BACKGROUND,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND"})
					
					--App2 side: RSDL sends OnHMIStatus (FULL,params)
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})					
					
				end
			--End Test case CommonRequestCheck.1.2.5
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.1.2


	--Begin Test case CommonRequestCheck.1.3
	--Description: 	In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from driver's device is changed (see REVSDL-994 for details), RSDL must inform this event via BC.ActivateApp (level: <appropriate assigned HMILevel of the app>) to HMI. 

		--Requirement/Diagrams id in jira: 
				--REVSDL-1066
				--TC: REVSDL-1313

		--Verification criteria: 
				--In case the device is set as 'driver's' (see REVSDL-831), R-SDL must assign "groups_primaryRC" permissions from appropriate policies to each remote-control app from this device.

		-----------------------------------------------------------------------------------------
			
			--Begin Test case Precondition.1.3.1
			--Description: Set device1 to Driver's device from HMI.
				function Test:TC3_Precondition1()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case Precondition.1.3.1
	
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.3.2
			--Description: activate App1 to FULL
				function Test:TC3_Precondition2()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.1.3.2
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.1.3.3
			--Description: activate App1 to LIMITED
				function Test:TC3_DeactivatedApp1_LIMITED()
				
					--hmi side: Go to "Application List" menu on HMI then deactivate App_1 to make HMILevel = LIMITED.
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
					
					--RSDL sends BC.ActivateApp (level: LIMITED) to HMI
					EXPECT_HMICALL("BasicCommunication.ActivateApp",
						{
						  appID = self.applications["Test Application"],
						  level = "LIMITED",
						  priority = "NONE"
						}
					)
					
					--Mobile side: RSDL sends OnHMIStatus (LIMITED,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
					
				end
			--End Test case CommonRequestCheck.1.3.3
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.1.3
	
	
	--Begin Test case CommonRequestCheck.1.4
	--Description: 	In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from driver's device is changed (see REVSDL-994 for details), RSDL must inform this event via BC.ActivateApp (level: <appropriate assigned HMILevel of the app>) to HMI. 

		--Requirement/Diagrams id in jira: 
				--REVSDL-1066
				--TC: REVSDL-1314

		--Verification criteria: 
				--In case the device is set as 'driver's' (see REVSDL-831), R-SDL must assign "groups_primaryRC" permissions from appropriate policies to each remote-control app from this device.

		-----------------------------------------------------------------------------------------
			
			--Begin Test case Precondition.1.4.1
			--Description: Set device1 to Driver's device from HMI.
				function Test:TC4_Precondition1()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case Precondition.1.4.1
	
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.4.2
			--Description: activate App1 from NONE to FULL
				function Test:TC4_NoneToFULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })
																
					--HMILevel of App_1 becomes FULL and RSDL doesn't send BC.ActivateApp to HMI. 
					EXPECT_HMICALL("BasicCommunication.ActivateApp",
						{
						  appID = self.applications["Test Application"],
						  level = "FULL",
						  priority = "NONE"
						}
					)
					:Times(0)

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					--Mobile side: RSDL sends OnHMIStatus (FULL,params) to mobile application.
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.1.4.2
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.1.4.3
			--Description: activate App1 to LIMITED
				function Test:TC4_DeactivatedApp1_LIMITED()
				
					--hmi side: Go to "Application List" menu on HMI then deactivate App_1 to make HMILevel = LIMITED.
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
					
					--RSDL sends BC.ActivateApp (level: LIMITED) to HMI
					EXPECT_HMICALL("BasicCommunication.ActivateApp",
						{
						  appID = self.applications["Test Application"],
						  level = "LIMITED",
						  priority = "NONE"
						}
					)
					
					--Mobile side: RSDL sends OnHMIStatus (BACKGROUND,params)
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
					
				end
			--End Test case CommonRequestCheck.1.4.3
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.4.4
			--Description: activate App1 from LIMITED to FULL
				function Test:TC4_LimitedToFULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })
																
					--HMILevel of App_1 becomes FULL and RSDL doesn't send BC.ActivateApp to HMI. 
					EXPECT_HMICALL("BasicCommunication.ActivateApp",
						{
						  appID = self.applications["Test Application"],
						  level = "FULL",
						  priority = "NONE"
						}
					)
					:Times(0)

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					--Mobile side: RSDL sends OnHMIStatus (FULL,params) to mobile application.
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.1.4.4
		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.1.4.5
			--Description: Register new session for register new app
				function Test:TC4_Precondition2()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.1.4.5
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.4.6
			--Description: Register App2 from Device1
				function Test:TC4_Precondition3()
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
									},
									{
									  appID = self.applications["Test Application"],
									  level = "LIMITED",
									  priority = "NONE"
									}
								)
								:Times(2)
								:Do(function(_,data)
									--Deactived App1 to LIMITED after register App2
									self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
								end)
								
							end)
							
							--App2 side: SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
							self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
							
							--App2 side: side: Expect OnPermissionsChange notification for Driver's device
							self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
							
							--App2 side: check OnHMIStatus with HMILEVEL NONE and deviceRank = "DRIVER"
							self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
							:Timeout(5000)
							
							--App1 side: changing HMILevel to LIMITED
							self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
							:Timeout(5000)
							
					end)
				end
			--End Test case Precondition.1.4.6
		-----------------------------------------------------------------------------------------		

			--Begin Test case Precondition.1.4.7
			--Description: activate App2 to FULL (App1 becomes BACKGROUND)
				function Test:TC4_Precondition4_App1LIMITED()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application1"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)					
					
					--RSDL sends BC.ActivateApp to HMI for App1 and App2
					EXPECT_HMICALL("BasicCommunication.ActivateApp",
						{
						  appID = self.applications["Test Application"],
						  level = "BACKGROUND",
						  priority = "NONE"
						}
					)
					
					--App1 side: RSDL sends OnHMIStatus (BACKGROUND,params)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND"})
					
					--App2 side: RSDL sends OnHMIStatus (FULL,params)
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})					
					
				end
			--End Test case Precondition.1.4.7
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.4.8
			--Description: activate App1 from BACKGROUND to FULL
				function Test:TC4_BackgroundToFULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })
																
					--HMILevel of App_1 becomes FULL and RSDL doesn't send BC.ActivateApp to HMI. (Only sends for App2 FULL -> LIMITED)
					EXPECT_HMICALL("BasicCommunication.ActivateApp",
						{
						  appID = self.applications["Test Application1"],
						  level = "LIMITED",
						  priority = "NONE"
						}
					)
					:Times(1)

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					--App1 side: RSDL sends OnHMIStatus (FULL,params) to mobile application.
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
					
					--App2 side: RSDL sends OnHMIStatus (LIMITED,params) to mobile application.
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"})
					
				end
			--End Test case CommonRequestCheck.1.4.8
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.1.4	
	
--=================================================END TEST CASES 1==========================================================--	





--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2

	--Description: 2. In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from passenger's device is changed (see REVSDL-1278 for details), RSDL must inform this event via BC.ActivateApp (level: <appropriate assigned HMILevel of the app>) to HMI. 
					  --Exception: FULL level (that is, RSDL must not notify HMI about the rc-app has transitioned to FULL).
	

	--Begin Test case CommonRequestCheck.2.1
	--Description: 	In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from passenger's device is changed (see REVSDL-1278 for details), RSDL must inform this event via BC.ActivateApp (level: <appropriate assigned HMILevel of the app>) to HMI. 

		--Requirement/Diagrams id in jira: 
				--REVSDL-1066
				--TC: REVSDL-1315

		--Verification criteria: 
				--In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from passenger's device is changed to NONE, RSDL must inform this event via BC.ActivateApp (level: NONE) to HMI.

		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.2.1.1
			--Description: Register new session for register new app
				function Test:TC1_Precondition1()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.2.1.1
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.2.1.2
			--Description: RSDL sends BC.ActivateApp (level: NONE) to HMI
					function Test:TC1_Driver_LevelNONE()
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
									
									--RSDL sends BC.ActivateApp (level: NONE) to HMI.
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
								
								--mobile side:RSDL sends OnHMIStatus (NONE,params) to mobile application.
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								
							end)
						end
			--End Test case CommonRequestCheck.2.1.2
		-----------------------------------------------------------------------------------------	
	--End Test case CommonRequestCheck.2.1

	--Begin Test case CommonRequestCheck.2.2
	--Description: 	In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from passenger's device is changed to BACKGROUND, RSDL must inform this event via BC.ActivateApp (level: BACKGROUND) to HMI.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1066
				--TC: REVSDL-1317

		--Verification criteria: 
				--In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from passenger's device is changed to BACKGROUND, RSDL must inform this event via BC.ActivateApp (level: BACKGROUND) to HMI.

		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.2.2.1
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE to get HMILevel = BACKGROUND
				function Test:TC2_PassengerBACKGROUND()
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
						moduleType = "CLIMATE",
						buttonPressMode = "LONG",
						buttonName = "AC_MAX"						
					})
					
					
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
											moduleType = "CLIMATE",
											buttonPressMode = "LONG",
											buttonName = "AC_MAX"
										})
							:Do(function(_,data)
							
								--RSDL sends BC.ActivateApp (level: BACKGROUND) to HMI.
								EXPECT_HMICALL("BasicCommunication.ActivateApp", 
								{
								  appID = self.applications["Test Application1"],
								  level = "BACKGROUND",
								  priority = "NONE"
								})
								--hmi side: sending Buttons.ButtonPress response
								self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
							end)
					
					
					--SDL sends (success:true) with the following resultCodes: SUCCESS
					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
					
					--mobile side:RSDL sends OnHMIStatus (NONE,params) to mobile application.
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE" })
					
				end
			--End Test case CommonRequestCheck.2.2.1
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.2
	

	--Begin Test case CommonRequestCheck.2.3
	--Description: 	In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from passenger's device is changed to LIMITED, RSDL must inform this event via BC.ActivateApp (level: LIMITED) to HMI.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1066
				--TC: REVSDL-1316

		--Verification criteria: 
				--In case the HMILevel of the application registered with "REMOTE_CONTROL" appHMIType from passenger's device is changed to LIMITED, RSDL must inform this event via BC.ActivateApp (level: LIMITED) to HMI.

		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.2.3.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:TC3_PassengerLIMITED()
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
							
							
							--RSDL sends BC.ActivateApp (level: LIMITED) to HMI.
							EXPECT_HMICALL("BasicCommunication.ActivateApp", 
							{
							  appID = self.applications["Test Application1"],
							  level = "LIMITED",
							  priority = "NONE"
							})
							:Do(function(_,data)							
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
					end)								
					
					--SDL sends (success:true) with the following resultCodes: SUCCESS
					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
					
					--mobile side:RSDL sends OnHMIStatus (NONE,params) to mobile application.
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE" })
				end
			--End Test case CommonRequestCheck.2.3.1
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.3	

--=================================================END TEST CASES 2==========================================================--

		
	
return Test	