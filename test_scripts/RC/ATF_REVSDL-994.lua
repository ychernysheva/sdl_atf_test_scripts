Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local config = require('config')
local module = require('testbase')


--======================================REVSDL-994========================================--
---------------------------------------------------------------------------------------------
------------REVSDL-994: HMILevel change for rc-apps from driver's device---------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--

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
										allowed = { "BACKGROUND", "FULL", "LIMITED"},
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
locfal arrayGroups_nonPrimaryRC = {
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
						
--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: 1. In case an application with AppHMIType "REMOTE_CONTROL" successfully registers from driver's device at SDL and this application is not present in HMILevel resumption list, RSDL must notify this app via OnHMIStatus (NONE, params) about assigned NONE HMILevel.

		--Requirement/Diagrams id in jira: 
				--REVSDL-994
				--TC: REVSDL-1071
				
		--Verification criteria: 
				--RC-app from driver's device - assing NONE level - by sending RegisterAppInterface.
		
		-----------------------------------------------------------------------------------------	
				--Set device as driver's one
				function Test:TC1_OnDeviceRankChanged_Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					
					
				end
				
				function Test:TC1_PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self.expectations_list,
						self.mobileConnection)
						
					--New session2
					self.mobileSession2 = mobile_session.MobileSession(
						self.expectations_list,
						self.mobileConnection)

					--New session3
					self.mobileSession3 = mobile_session.MobileSession(
						self.expectations_list,
						self.mobileConnection)
										
				end
			    
				--Description: Register App1 for precondition
					function Test:TC1_DriverDevice_App1()
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
								end)
								
								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
								
								--mobile side: Expect OnPermissionsChange notification for DRIVER's device
								self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )								
								
								--check OnHMIStatus with deviceRank = "DRIVER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
								:Timeout(3000)
								
							end)
						end
			
			--Description: Register App2 for precondition
					function Test:TC1_DriverDevice_App2()
						self.mobileSession2:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession2:SendRPC("RegisterAppInterface",
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
								  appID = "2"
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
								
								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession2:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
								
								--mobile side: Expect OnPermissionsChange notification for DRIVER's device
								self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )								
								
								--check OnHMIStatus with deviceRank = "DRIVER"
								self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
								:Timeout(3000)
								
							end)
						end
			
			--Description: Register App3 for precondition
					function Test:TC1_DriverDevice_App3()
						self.mobileSession3:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession3:SendRPC("RegisterAppInterface",
								{
								  syncMsgVersion =
								  {
									majorVersion = 3,
									minorVersion = 0
								  },
								  appName = "Test Application3",
								  isMediaApplication = true,
								  languageDesired = 'EN-US',
								  hmiDisplayLanguageDesired = 'EN-US',
								  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
								  appID = "3"
								})

								EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
								{
								  application = 
								  {
									appName = "Test Application3"
								  }
								})
								:Do(function(_,data)
									self.applications["Test Application3"] = data.params.application.appID
								end)
								
								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession3:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
								
								--mobile side: Expect OnPermissionsChange notification for DRIVER's device
								self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )								
								
								--check OnHMIStatus with deviceRank = "DRIVER"
								self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
								:Timeout(3000)
								
							end)
						end
		
	--End Test Case CommonRequestCheck.1
--===================================================END TEST CASES 1==========================================================--




	
--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2

	--Description: 2. In case an application_1 with AppHMIType "REMOTE_CONTROL" from driver's device is in HMILevel of LIMITED and the vehicle HMI User activates another remote-control application_2 from driver's device, RSDL must assign BACKGROUND HMILevel to this application_1 and send it OnHMIStatus (BACKGROUND, params) notification.
	

	--Begin Test case CommonRequestCheck.2.1
	--Description: 	--1. FULL -> BACKGROUND
					--2. LIMITED -> BACKGROUND

		--Requirement/Diagrams id in jira: 
				--REVSDL-994
				--TC: REVSDL-1335

		--Verification criteria: 
				--In case an application_1 with AppHMIType "REMOTE_CONTROL" from driver's device is in HMILevel of LIMITED and the vehicle HMI User activates another remote-control application_2 from driver's device, RSDL must assign BACKGROUND HMILevel to this application_1 and send it OnHMIStatus (BACKGROUND, params) notification.

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.2.1.2
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
			--End Test case Precondition.2.1.2
	
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.3
			--Description: activate App1 to FULL
				function Test:TC2_Precondition3()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL" })
				end
			--End Test case CommonRequestCheck.2.1.3
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.2.1.4
			--Description: 
							--1. RSDL receives BC.OnPhoneCall(isActive:true) from HMI.
							--2. RSDL returns to mobile: OnHMIStatus(BACKGROUND, params) notification.
				function Test:TC2_OnPhoneCallFULLToBACKGROUND()

					--hmi side: HMI send BC.OnPhoneCall to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnPhoneCall", {isActive = true})
					
					--mobile side: Check that OnHMIStatus(BACKGROUND) sent by RSDL and received by App1
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.2.1.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.5
			--Description: activate App1 to FULL again
				function Test:TC2_Precondition4()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL" })
				end
			--End Test case CommonRequestCheck.2.1.5
		-----------------------------------------------------------------------------------------			
		
			--REMOVED THIS TESTCASE DUE TO DEFECT: REVSDL-1378
			--Begin Test case CommonRequestCheck.2.1.6
			--[[Description: 
							--1. HMI sends to RSDL: OnEmergencyEvent(ON)
							--2. RSDL returns to mobile: OnHMIStatus(BACKGROUND, params) notification.
				function Test:TC2_OnEmergencyEventFULLToBACKGROUND()

					--hmi side: HMI send BC.OnPhoneCall to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnEmergencyEvent", {enabled = true})
					
					--mobile side: Check that OnHMIStatus(BACKGROUND) sent by RSDL and received by App1
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.2.1.6]]

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.1		
		
		
		-----------------------------------------------------------------------------------------		
	--Begin Test case CommonRequestCheck.2.2 (must run CommonRequestCheck.2.1 before for precondition)
	--Description: 	--1. FULL -> BACKGROUND
					--2. LIMITED -> BACKGROUND

		--Requirement/Diagrams id in jira: 
				--REVSDL-994
				--TC: REVSDL-1072
				
		--Verification criteria: 
				--In case an application_1 with AppHMIType "REMOTE_CONTROL" from driver's device is in HMILevel of LIMITED and the vehicle HMI User activates another remote-control application_2 from driver's device, RSDL must assign BACKGROUND HMILevel to this application_1 and send it OnHMIStatus (BACKGROUND, params) notification.

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.2.1.1
			--Description: Register new session for register new app
				function Test:TC2_Precondition1()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.2.1.1
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.2.2.1
			--Description: Register App2, App2=NONE for precondition
				function Test:TC2_App2NONE()
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
							
							--mobile side: Expect OnPermissionsChange notification for DRIVER's device
							self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )								
							
							--mobile side:RSDL sends OnHMIStatus (NONE,params) to mobile application.
							self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
							
						end)
					end
			--End Test case CommonRequestCheck.2.2.1
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.2.2
			--Description: activate App1 to FULL
				function Test:TC2_Precondition4()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application1"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				end
			--End Test case CommonRequestCheck.2.2.2
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.2.2.3
			--Description: Go to "Application List" menu on HMI then deactivate App_1.
				function Test:TC2_DeactivateApp1()

					--Deactived App1 via go to "Application List" menu on HMI
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application1"], reason = "GENERAL"})
					
					--App2 side: changing HMILevel to LIMITED
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"})
					:Timeout(5000)
						
				end
			--End Test case CommonRequestCheck.2.2.3
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.3
			--Description: On HMI, activate App_2
							--1. App1: SDL returns to mobile: OnHMIStatus (BACKGROUND, params).
							--2. App2: SDL returns to mobile: OnHMIStatus (FULL, params).
				function Test:TC2_ActivateApp2()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					--App1: SDL returns to mobile: OnHMIStatus (BACKGROUND, params).
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "AUDIBLE"})
					
					--App2 side: changing HMILevel to FULL
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
					:Timeout(5000)
						
				end
			--End Test case CommonRequestCheck.2.2.3
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.2

--=================================================END TEST CASES 2==========================================================--
	
	

	
	
--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: 3. In case an application with AppHMIType "REMOTE_CONTROL" from driver's device is in HMILevel of LIMITED and the vehicle HMI User activates another non-remote-control application_2, RSDL must leave application_1 in LIMITED HMILevel.
	

	--Begin Test case CommonRequestCheck.3.1
	--Description: 	--1. App1: remoteControl -> (LIMITED)
					--2. App2: non-remoteControl -> (NONE)

		--Requirement/Diagrams id in jira: 
				--REVSDL-994
				--TC: REVSDL-1073

		--Verification criteria: 
				--In case an application with AppHMIType "REMOTE_CONTROL" from driver's device is in HMILevel of LIMITED and the vehicle HMI User activates another non-remote-control application_2, RSDL must leave application_1 in LIMITED HMILevel.

		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.3.1.1
			--Description: Register new session for register new app
				function Test:TC3_Precondition1()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				
				  self.mobileSession2 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)				
					
				end
			--End Test case Precondition.3.1.1
			
		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.3.1.2
			--Description: Set device1 to Driver's device from HMI.
				function Test:TC3_Precondition2()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case Precondition.3.1.2
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.3.1.3
			--Description: Register App1 (non-remoteControl), App1=NONE for precondition
				function Test:TC3_App1NoneRemoteControl()
					self.mobileSession1:StartService(7)
					:Do(function()
							local CorIdRegister = self.mobileSession1:SendRPC("RegisterAppInterface",
							{
							  syncMsgVersion =
							  {
								majorVersion = 3,
								minorVersion = 0
							  },
							  appName = "App1",
							  isMediaApplication = false,
							  languageDesired = 'EN-US',
							  hmiDisplayLanguageDesired = 'EN-US',
							  appID = "1"
							})

							EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
							{
							  application = 
							  {
								appName = "App1"
							  }
							})
							:Do(function(_,data)
							
								self.applications["App1"] = data.params.application.appID								
								
							end)
							
							--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
							self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })								
							
							--mobile side:RSDL sends OnHMIStatus (NONE,params) to mobile application.
							self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
							
						end)
					end
					
					
				function Test:TC3_App2RemoteControl()
					self.mobileSession2:StartService(7)
					:Do(function()
							local CorIdRegister = self.mobileSession2:SendRPC("RegisterAppInterface",
							{
							  syncMsgVersion =
							  {
								majorVersion = 3,
								minorVersion = 0
							  },
							  appName = "App2",
							  isMediaApplication = false,
							  languageDesired = 'EN-US',
							  hmiDisplayLanguageDesired = 'EN-US',
							  appHMIType = { "REMOTE_CONTROL" },
							  appID = "2"
							})

							EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
							{
							  application = 
							  {
								appName = "App2"
							  }
							})
							:Do(function(_,data)
							
								self.applications["App2"] = data.params.application.appID								
								
							end)
							
							--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
							self.mobileSession2:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })								
							
							--mobile side:RSDL sends OnHMIStatus (NONE,params) to mobile application.
							self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
							
						end)
					end					
			--End Test case CommonRequestCheck.3.1.3
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.4
			--Description: activate App2 to FULL
				function Test:TC3_Precondition4()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["App2"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE"})
				end
			--End Test case CommonRequestCheck.3.1.4
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.3.1.5
			--Description: Go to "Application List" menu on HMI then deactivate App_2
				function Test:TC3_DeactivateApp2()

					--Deactived App1 via go to "Application List" menu on HMI
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["App2"], reason = "GENERAL"})
					
					--App1 side: changing HMILevel to LIMITED
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE"})
					:Timeout(5000)
						
				end
			--End Test case CommonRequestCheck.3.1.5
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.6
			--Description: On HMI, activate App_1
							--1. App1: HMIStatus of App_1 is not changed, still keeps LIMITED HMILevel
							--2. App2: SDL returns to mobile: OnHMIStatus (FULL, params)
				function Test:TC3_ActivateApp1()

					--hmi side: On HMI, activate App_1
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["App1"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					--App2 side: SDL returns to mobile: OnHMIStatus (FULL, params)
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE"})
					
					--App1 side: HMIStatus of App_1 is not changed, still keeps LIMITED HMILevel
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE"})
					:Times(0)
						
				end
			--End Test case CommonRequestCheck.3.1.6
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.1

--=================================================END TEST CASES 3==========================================================--


	
	
--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for Req.#4

	--Description: 4. In case an application with AppHMIType "REMOTE_CONTROL" from driver's device is in HMILevel of FULL and RSDL gets BC.OnAppDeactivated (<any reason>) for this application (= the vehicle HMI User goes either to media embedded HMI screen, or to embedded navigation screen, or to settings menu, or to phonemenu, or to any other non-application HMI menu), RSDL must assign LIMITED HMILevel to this application and send it OnHMIStatus (LIMITED, params) notification.
	

	--Begin Test case CommonRequestCheck.4.1
	--Description: 	--FULL to LIMITED with any reason

		--Requirement/Diagrams id in jira: 
				--REVSDL-994
				--TC: REVSDL-1074

		--Verification criteria: 
				--In case an application with AppHMIType "REMOTE_CONTROL" from driver's device is in HMILevel of FULL and RSDL gets BC.OnAppDeactivated (<any reason>)

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.4.1.1
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
			--End Test case Precondition.4.1.1
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.1.2
			--Description: activate App1 to FULL
				function Test:TC4_App1FULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.4.1.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.3
			--Description: HMI sends to SDL: OnAppDeactivated (appID_1, *AUDIO*).
				function Test:TC4_DeactivateAUDIO()

					--HMI sends to SDL: OnAppDeactivated (appID_1, *AUDIO*).
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "AUDIO"})
					
					--App1 side: changing HMILevel to LIMITED
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
					:Timeout(5000)
						
				end
			--End Test case CommonRequestCheck.4.1.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.1.4
			--Description: activate App1 to FULL
				function Test:TC4_App1FULL1()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.4.1.4
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.5
			--Description: HMI sends to SDL: OnAppDeactivated (appID_1, *PHONECALL*).
				function Test:TC4_DeactivatePHONECALL()

					--HMI sends to SDL: OnAppDeactivated (appID_1, *PHONECALL*).
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "PHONECALL"})
					
					--App1 side: changing HMILevel to LIMITED
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
					:Timeout(5000)
						
				end
			--End Test case CommonRequestCheck.4.1.5
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.6
			--Description: activate App1 to FULL
				function Test:TC4_App1FULL2()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.4.1.6
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.7
			--Description: HMI sends to SDL: OnAppDeactivated (appID_1, *NAVIGATIONMAP*).
				function Test:TC4_DeactivateNAVIGATIONMAP()

					--HMI sends to SDL: OnAppDeactivated (appID_1, *NAVIGATIONMAP*).
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "NAVIGATIONMAP"})
					
					--App1 side: changing HMILevel to LIMITED
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
					:Timeout(5000)
						
				end
			--End Test case CommonRequestCheck.4.1.7
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case CommonRequestCheck.4.1.8
			--Description: activate App1 to FULL
				function Test:TC4_App1FULL3()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.4.1.8
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.9
			--Description: HMI sends to SDL: OnAppDeactivated (appID_1, *PHONEMENU*).
				function Test:TC4_DeactivatePHONEMENU()

					--HMI sends to SDL: OnAppDeactivated (appID_1, *PHONEMENU*).
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "PHONEMENU"})
					
					--App1 side: changing HMILevel to LIMITED
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
					:Timeout(5000)
						
				end
			--End Test case CommonRequestCheck.4.1.9
			
		-----------------------------------------------------------------------------------------	
		
			--Begin Test case CommonRequestCheck.4.1.10
			--Description: activate App1 to FULL
				function Test:TC4_App1FULL4()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.4.1.10
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.11
			--Description: HMI sends to SDL: OnAppDeactivated (appID_1, *SYNCSETTINGS*).
				function Test:TC4_DeactivateSYNCSETTINGS()

					--HMI sends to SDL: OnAppDeactivated (appID_1, *SYNCSETTINGS*).
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "SYNCSETTINGS"})
					
					--App1 side: changing HMILevel to LIMITED
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
					:Timeout(5000)
						
				end
			--End Test case CommonRequestCheck.4.1.11
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.12
			--Description: activate App1 to FULL
				function Test:TC4_App1FULL5()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.4.1.12
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.13
			--Description: HMI sends to SDL: OnAppDeactivated (appID_1, *GENERAL*).
				function Test:TC4_DeactivateGENERAL()

					--HMI sends to SDL: OnAppDeactivated (appID_1, *GENERAL*).
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
					
					--App1 side: changing HMILevel to LIMITED
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
					:Timeout(5000)
						
				end
			--End Test case CommonRequestCheck.4.1.13
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.4.1

--=================================================END TEST CASES 4==========================================================--



--=================================================BEGIN TEST CASES 5==========================================================--
	--Begin Test suit CommonRequestCheck.5 for Req.#5

	--Description: 5. In case an application with AppHMIType "REMOTE_CONTROL" from driver's device is in any of NONE, BACKGROUND or LIMITED HMILevel and RSDL receives SDL.ActivateApp for this application (= the vehicle HMI User activates this application from the HMI), RSDL must assign FULL HMILevel to this application and send it OnHMIStatus (FULL, params) notification
	

	--Begin Test case CommonRequestCheck.5.1
	--Description: 	In case an application with AppHMIType "REMOTE_CONTROL" from driver's device is in any of NONE, BACKGROUND or LIMITED HMILevel and RSDL receives SDL.ActivateApp for this application (= the vehicle HMI User activates this application from the HMI), RSDL must assign FULL HMILevel to this application and send it OnHMIStatus (FULL, params) notification

		--Requirement/Diagrams id in jira: 
				--REVSDL-994
				--TC: REVSDL-1076

		--Verification criteria: 
				--NONE to FULL

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.5.1.1
			--Description: Set device1 to Driver's device from HMI.
				function Test:TC5_Precondition1()

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
		
			--Begin Test case CommonRequestCheck.5.1.2
			--Description: activate App1 from NONE to FULL
				function Test:TC5_App1NONEToFULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.5.1.2
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.1.3
			--Description: Set HMILevel App1 to LIMITED
				function Test:TC5_Precondition2()

					--HMI sends to SDL: OnAppDeactivated (appID_1, *GENERAL*).
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
					
					--App1 side: changing HMILevel to LIMITED
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED"})
					:Timeout(5000)
						
				end
			--End Test case CommonRequestCheck.5.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.5.1.4
			--Description: activate App1 from LIMITED to FULL
				function Test:TC5_App1LIMITEDToFULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.5.1.4
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.5.1.5
			--Description: Set device1 from Driver's to passenger's device (precondition for setting to HMILevel BACKGROUND)
				function Test:TC5_Precondition3()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
					{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })					
				
				end
			--End Test case CommonRequestCheck.5.1.5
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case CommonRequestCheck.5.1.6
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonPressMode = LONG (BACKGROUND)
				function Test:TC5_Precondition4()
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
			--End Test case CommonRequestCheck.5.1.6
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case Precondition.5.1.7
			--Description: Set device1 to Driver's device from HMI.
				function Test:TC5_Precondition5()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case Precondition.5.1.7
	
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.8
			--Description: activate App1 from BACKGROUND to FULL
				function Test:TC5_App1BACKGROUNDToFULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.5.1.8
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.1

--=================================================END TEST CASES 5==========================================================--	

	
	
return Test	
