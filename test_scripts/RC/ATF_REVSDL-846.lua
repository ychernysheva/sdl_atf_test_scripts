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


--Declaration connected devices.
--1. Device 2:
local device2 = "192.168.100.199"
local device2Port = 12345
--2. Device 3:
local device3 = "10.42.0.1"
local device3Port = 12345


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

--New connection device2
function newConnectionDevice2(self, DeviceIP, Port)

  local tcpConnection = tcp.Connection(DeviceIP, Port)
  local fileConnection = file_connection.FileConnection("mobile2.out", tcpConnection)
  self.mobileConnection2 = mobile.MobileConnection(fileConnection)
  self.mobileSession21 = mobile_session.MobileSession(
		self.expectations_list,
		self.mobileConnection2,
		config.application1.registerAppInterfaceParams
	)
  event_dispatcher:AddConnection(self.mobileConnection2)
  self.mobileSession21:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection2:Connect()
end

--New connection device3
function newConnectionDevice3(self, DeviceIP1, Port)

  local tcpConnection = tcp.Connection(DeviceIP1, Port)
  local fileConnection = file_connection.FileConnection("mobile3.out", tcpConnection)
  self.mobileConnection3 = mobile.MobileConnection(fileConnection)
  self.mobileSession31 = mobile_session.MobileSession(
		self.expectations_list,
		self.mobileConnection3,
		config.application1.registerAppInterfaceParams
	)
  event_dispatcher:AddConnection(self.mobileConnection3)
  self.mobileSession31:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection3:Connect()
end


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

	
	
	
	

--======================================REVSDL-846=========================================--
---------------------------------------------------------------------------------------------
-------------------------REVSDL-846: R-SDL must inform the app when the ---------------------
---------------------"driver's"/"passenger's" state of the device is changed-----------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: 1. In case the device is set as 'driver's' (see REVSDL-831), R-SDL must assign "groups_primaryRC" permissions from appropriate policies to each remote-control app from this device.
	

	--Begin Test case CommonRequestCheck.1
	--Description: 	In case the device is set as 'driver's' (see REVSDL-831), R-SDL must assign "groups_primaryRC" permissions from appropriate policies to each remote-control app from this device.

		--Requirement/Diagrams id in jira: 
				--REVSDL-846
				--TC: REVSDL-970

		--Verification criteria: 
				--In case the device is set as 'driver's' (see REVSDL-831), R-SDL must assign "groups_primaryRC" permissions from appropriate policies to each remote-control app from this device.

		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.1.1
			--Description: Register new session for register new app
				function Test:TC1_PreconditionRegistrationApp()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.1.1
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.2
			--Description: check OnHMIStatus with "OnPermissionsChange" notification
					function Test:TC1_PassengerDevice()
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
								
								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.1.2

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.3
			--Description: Set device1 to Driver's device from HMI.
							--Cannot check policy.sql from RSDL folder.
				function Test:TC1_Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.1.3
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case Precondition.1.4
			--Description: Register new session for register new app
				function Test:TC1_PreconditionRegistrationApp()
				  self.mobileSession2 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.1.4
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.1.5
			--Description: Register another application from primary device and check  permissions assigned to mobile application registered from primary device.
					function Test:TC1_DriverDevice()
						self.mobileSession2:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession2:SendRPC("RegisterAppInterface",
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
								self.mobileSession2:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
								
								--mobile side: Expect OnPermissionsChange notification for Driver's device
								self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )								
								
								--check OnHMIStatus with deviceRank = "Driver"
								self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.1.5

		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.6
			--Description: Set device1 from Driver's to Passenger's device again from HMI.
				function Test:TC1_DriverToPassenger()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
				
				end
			--End Test case CommonRequestCheck.1.6
	
		-----------------------------------------------------------------------------------------	
	--End Test case CommonRequestCheck.1
	
--=================================================END TEST CASES 1==========================================================--	





--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2

	--Description: 2. In case the device is set as 'passenger's' (see REVSDL-831), R-SDL must assign "groups_nonPrimaryRC" permissions from appropriate policies to each remote-control app from this device.
	

	--Begin Test case CommonRequestCheck.2
	--Description: 	In case the device is set as 'passenger's' (see REVSDL-831), R-SDL must assign "groups_nonPrimaryRC" permissions from appropriate policies to each remote-control app from this device.

		--Requirement/Diagrams id in jira: 
				--REVSDL-846
				--TC: REVSDL-971

		--Verification criteria: 
				--In case the device is set as 'passenger's' (see REVSDL-831), R-SDL must assign "groups_nonPrimaryRC" permissions from appropriate policies to each remote-control app from this device.

		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.2.1
			--Description: Register new session for register new app
				function Test:TC2_PreconditionRegistrationApp()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
				end
			--End Test case Precondition.2.1
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.2.2
			--Description: check OnHMIStatus with "OnPermissionsChange" notification
					function Test:TC2_PassengerDevice()
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
								
								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3
			--Description: From mobile app registered from non primary (passengers device) send disallowed in policy table (groups_NON_PrimaryRC) RPS with allowed seat position.
					function Test:TC2_PassengerDevice()

						local cid = self.mobileSession:SendRPC("ButtonPress",
						{
							zone =
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0
							},
							moduleType = "RADIO",
							buttonPressMode = "LONG",
							buttonName = "VOLUME_UP"						
						})
				
						
						EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED" })					
					
					end
			--End Test case CommonRequestCheck.2.3

		-----------------------------------------------------------------------------------------		
		

	--End Test case CommonRequestCheck.2
	
--=================================================END TEST CASES 2==========================================================--
		
		


--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: 3. In case the device's state is changed from "driver's" to "passenger's", RSDL must assign an HMILevel of "NONE" and send OnHMIStatus("NONE") to all remote-control applications from this device.
	

	--Begin Test case CommonRequestCheck.3
	--Description: 	In case the device's state is changed from "driver's" to "passenger's", RSDL must assign an HMILevel of "NONE" and send OnHMIStatus("NONE") to all remote-control applications from this device.

		--Requirement/Diagrams id in jira: 
				--REVSDL-846
				--TC: REVSDL-972

		--Verification criteria: 
				--In case the device's state is changed from "driver's" to "passenger's", RSDL must assign an HMILevel of "NONE" and send OnHMIStatus("NONE") to all remote-control applications from this device.

		-----------------------------------------------------------------------------------------
				
			--FROM BACKGROUND AND FULL to NONE HMILevel	
			--Begin Test case Precondition.3.1
			--Description: Register new session for register new apps
				function Test:TC3_Step1()
					
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
			--End Test case Precondition.3.1
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.3.2
			--Description: From mobile app send RegisterAppInteface (REMOTE_CONTROL, params) with AppId=1 to SDL.
					function Test:TC3_Step2_3_4()
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

								--SDL sends OnAppRegistered (appID_1, REMOTE_CONTROL, params).
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
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--SDL assign Level (NONE) and returns to mobile: OnHMIStatus (NONE, params)
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.3
			--Description: From mobile app send RegisterAppInteface (REMOTE_CONTROL, params) with AppId=2 to SDL.
					function Test:TC3_Step5()
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

								--SDL sends OnAppRegistered (appID_2, REMOTE_CONTROL, params).
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
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--SDL assign Level (NONE) and returns to mobile: OnHMIStatus (NONE, params)
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.4
			--Description: From mobile app send RegisterAppInteface (REMOTE_CONTROL, params) with AppId=3 to SDL.
					function Test:TC3_Step6()
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

								--SDL sends OnAppRegistered (appID_3, REMOTE_CONTROL, params).
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
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--SDL assign Level (NONE) and returns to mobile: OnHMIStatus (NONE, params)
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.3.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.5
			--Description: From appropriate HMI menu set connected device as Driver's device.
				function Test:TC3_Step7()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device for App1, App2, App3
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER" for App1, App2, App3
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.3.5
	
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.6
			--Description: From HMI set app1, app2 to Background.
				function Test:TC3_Step8()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application1"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
				
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				
				end
				function Test:TC3_Step9()

					--hmi side: sending SDL.ActivateApp request
					local rid2 = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application2"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid2)
				
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				
				end
				function Test:TC3_Step10()

					--hmi side: sending SDL.ActivateApp request
					local rid3 = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application3"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid3)
					
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})
					self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				
				end					
			--End Test case CommonRequestCheck.3.6
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.7
			--Description: From appropriate HMI menu set connected device as NON primary.
				function Test:TC3_Step11()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "AUDIBLE", deviceRank = "PASSENGER" })
				
				end
			--End Test case CommonRequestCheck.3.7
	
		-----------------------------------------------------------------------------------------

			--REPEAT STEPS FOR BACKGROUND AND LIMITED to NONE HMILevel
			--Begin Test case CommonRequestCheck.3.8
			--Description: From appropriate HMI menu set connected device as Driver's device.
				function Test:TC3_Step12_1()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device for App1, App2, App3
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER" for App1, App2, App3
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.3.8
	
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.9
			--Description: From HMI set app1, app2 to Background.
				function Test:TC3_Step12_2()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application1"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
				
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				
				end
				function Test:TC3_Step12_3()

					--hmi side: sending SDL.ActivateApp request
					local rid2 = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = self.applications["Test Application2"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid2)
				
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				
				end
				function Test:TC3_Step12_4()

					--hmi side: SDL send OnHMIStatus(NONE deviceRank:Driver OnSystemContext=) to mobile app. This notification can be observed on mobile app1.
					self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application2"], reason = "GENERAL"})
					
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"})
				
				end					
			--End Test case CommonRequestCheck.3.9
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.10
			--Description: From appropriate HMI menu set connected device as NON primary.
				function Test:TC3_Step12_5()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER" for App1, App2, App3
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", deviceRank = "PASSENGER" })
					self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "AUDIBLE", deviceRank = "PASSENGER" })
				
				end
			--End Test case CommonRequestCheck.3.10

		-----------------------------------------------------------------------------------------

	--End Test case CommonRequestCheck.3
	
--=================================================END TEST CASES 3==========================================================--
		
		
		
		
--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for Req.#4

	--Description: 4. In case the device's state is changed from "passenger's" to "driver's", RSDL must leave all remote-control applications from this device in the same HMILevel as they were (that is, not send OnHMIStatus notification).
	

	--Begin Test case CommonRequestCheck.4
	--Description: 	In case the device's state is changed from "passenger's" to "driver's", RSDL must leave all remote-control applications from this device in the same HMILevel as they were (that is, not send OnHMIStatus notification).

		--Requirement/Diagrams id in jira: 
				--REVSDL-846
				--TC: REVSDL-1215

		--Verification criteria: 
				--4. In case the device's state is changed from "passenger's" to "driver's", RSDL must leave all remote-control applications from this device in the same HMILevel as they were (that is, not send OnHMIStatus notification).

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.4.1
			--Description: Register new session for register new apps
				function Test:TC4_Step1_1()
					
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
			--End Test case Precondition.4.1
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.4.2
			--Description: From mobile app send RegisterAppInteface (REMOTE_CONTROL, params) with AppId=1 to SDL.
					function Test:TC4_Step1_2()
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

								--SDL sends OnAppRegistered (appID_1, REMOTE_CONTROL, params).
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
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--SDL assign Level (NONE) and returns to mobile: OnHMIStatus (NONE, params)
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

								
							end)
						end
			--End Test case CommonRequestCheck.4.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3
			--Description: From mobile app send RegisterAppInteface (REMOTE_CONTROL, params) with AppId=2 to SDL.
					function Test:TC4_Step1_3()
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

								--SDL sends OnAppRegistered (appID_2, REMOTE_CONTROL, params).
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
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--SDL assign Level (NONE) and returns to mobile: OnHMIStatus (NONE, params)
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								
							end)
						end
			--End Test case CommonRequestCheck.4.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.4
			--Description: From mobile app send RegisterAppInteface (REMOTE_CONTROL, params) with AppId=3 to SDL.
					function Test:TC4_Step1_4()
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

								--SDL sends OnAppRegistered (appID_3, REMOTE_CONTROL, params).
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
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--SDL assign Level (NONE) and returns to mobile: OnHMIStatus (NONE, params)
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

								
							end)
						end
			--End Test case CommonRequestCheck.4.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.5
			--Description: App2 (LIMITED)
					function Test:TC4_Step1_5()

							local cid = self.mobileSession2:SendRPC("ButtonPress",
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
						
							--hmi side: expect RC.GetInteriorVehicleDataConsent request
							EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
										{ 
											appID = self.applications["Test Application2"],
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
								--hmi side: sending RC.GetInteriorVehicleDataConsent response
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
							
							--mobile side: SDL sends (success:true) with the following resultCodes: SUCCESS
							self.mobileSession2:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
							
							--SDL assign Level (LIMITED) and returns to mobile: OnHMIStatus (LIMITED, params)
							self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE" })
				
					end
			--End Test case CommonRequestCheck.4.5

		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.6
			--Description: App3 (BACKGROUND)
					function Test:TC4_Step1_6()

							local cid = self.mobileSession3:SendRPC("ButtonPress",
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
												col = 0,
												levelspan = 1,
												level = 0
											},
											moduleType = "CLIMATE",
											buttonPressMode = "LONG",
											buttonName = "AC_MAX"
										})
							:Do(function(_,data)
								--hmi side: sending Buttons.ButtonPress response
								self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
							end)					
							
							self.mobileSession3:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
							
							--SDL assign Level (BACKGROUND) and returns to mobile: OnHMIStatus (BACKGROUND, params)
							self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE" })
				
					end
			--End Test case CommonRequestCheck.4.6

		-----------------------------------------------------------------------------------------	
		
			--Begin Test case CommonRequestCheck.4.7
			--Description: From appropriate HMI menu set connected device as Driver's device.
				function Test:TC4_Step2()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device for App1, App2, App3
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER" for App1, App2, App3
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.4.7
	
		-----------------------------------------------------------------------------------------

	--End Test case CommonRequestCheck.4

--=================================================END TEST CASES 4==========================================================--

		



--=================================================BEGIN TEST CASES 5==========================================================--
	--Begin Test suit CommonRequestCheck.5.1 for Req.#5

	--Description: 5. In case the device's "driver's"/"passenger's" state is either changed from one to another or initially set, Rev-SDL must notify each app registered from such device via OnPermissionsChange notification about changed policy permission.
	

	--Begin Test case CommonRequestCheck.5.1
	--Description: 	In case the device's "driver's"/"passenger's" state is either changed from one to another or initially set, Rev-SDL must notify each app registered from such device via OnPermissionsChange notification about changed policy permission.

		--Requirement/Diagrams id in jira: 
				--REVSDL-846
				--TC: REVSDL-973 (SKIP STEP4 BECAUSE OF CONNECTING TWO DEVICES)

		--Verification criteria: 
				--5. In case the device's "driver's"/"passenger's" state is either changed from one to another or initially set, Rev-SDL must notify each app registered from such device via OnPermissionsChange notification about changed policy permission.

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.5.1
			--Description: Register new session for register new apps
				function Test:TC5_Step1_1()
					
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
			--End Test case Precondition.5.1
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case CommonRequestCheck.5.1.2
			--Description: From mobile app send RegisterAppInteface (REMOTE_CONTROL, params) with AppId=1 to SDL.
					function Test:TC5_Step1_2()
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

								--SDL sends OnAppRegistered (appID_1, REMOTE_CONTROL, params).
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
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--SDL assign Level (NONE) and returns to mobile: OnHMIStatus (NONE, params)
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

								
							end)
						end
			--End Test case CommonRequestCheck.5.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.3
			--Description: From mobile app send RegisterAppInteface (REMOTE_CONTROL, params) with AppId=2 to SDL.
					function Test:TC5_Step1_3()
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

								--SDL sends OnAppRegistered (appID_2, REMOTE_CONTROL, params).
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
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--SDL assign Level (NONE) and returns to mobile: OnHMIStatus (NONE, params)
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								
							end)
						end
			--End Test case CommonRequestCheck.5.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.4
			--Description: From mobile app send RegisterAppInteface (REMOTE_CONTROL, params) with AppId=3 to SDL.
					function Test:TC5_Step1_4()
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

								--SDL sends OnAppRegistered (appID_3, REMOTE_CONTROL, params).
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
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )								
								
								--SDL assign Level (NONE) and returns to mobile: OnHMIStatus (NONE, params)
								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

								
							end)
						end
			--End Test case CommonRequestCheck.5.1.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.1.5
			--Description: From appropriate HMI menu set connected device as Driver's device.
							-- Rev-SDL must notify each app registered from such device via OnPermissionsChange(List of assigned permissions)
				function Test:TC5_Step2()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device for App1, App2, App3
								-- Rev-SDL must notify each app registered from such device via OnPermissionsChange(List of assigned permissions)
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER" for App1, App2, App3
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.5.1.5
	
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.6
			--Description: From appropriate HMI menu set connected device as Passenger's device.
							-- Rev-SDL must notify each app registered from such device via OnPermissionsChange(List of assigned permissions)
				function Test:TC5_Step3()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for PASSENGER's device for App1, App2, App3
								-- Rev-SDL must notify each app registered from such device via OnPermissionsChange(List of assigned permissions)
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER" for App1, App2, App3
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
				
				end
			--End Test case CommonRequestCheck.5.1.6
	
		-----------------------------------------------------------------------------------------

			--REPEAT STEP2, STEP3 ONE MORE TIME:
			--Begin Test case CommonRequestCheck.5.1.7
			--Description: From appropriate HMI menu set connected device as Driver's device.
							-- Rev-SDL must notify each app registered from such device via OnPermissionsChange(List of assigned permissions)
				function Test:TC5_Step3_RepeatStep2()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device for App1, App2, App3
								-- Rev-SDL must notify each app registered from such device via OnPermissionsChange(List of assigned permissions)
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER" for App1, App2, App3
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
					self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.5.1.7
	
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.8
			--Description: From appropriate HMI menu set connected device as Passenger's device.
							-- Rev-SDL must notify each app registered from such device via OnPermissionsChange(List of assigned permissions)
				function Test:TC5_Step3_RepeatStep3()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for PASSENGER's device for App1, App2, App3
								-- Rev-SDL must notify each app registered from such device via OnPermissionsChange(List of assigned permissions)
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER" for App1, App2, App3
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
					self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
				
				end
			--End Test case CommonRequestCheck.5.1.8
	
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.1
	
	
	--Begin Test case CommonRequestCheck.5.2
	--Description: 	In case the device's "driver's"/"passenger's" state is either changed from one to another or initially set, Rev-SDL must notify each app registered from such device via OnPermissionsChange notification about changed policy permission.
					

		--Requirement/Diagrams id in jira: 
				--REVSDL-973

		--Verification criteria: 
				--In case the device's "driver's"/"passenger's" state is either changed from one to another or initially set, Rev-SDL must notify each app registered from such device via OnPermissionsChange notification about changed policy permission.

		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.5.2.1
			--Description: Set device1 to Driver's device from HMI
				function Test:TC5_Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })					
				
				end
			--End Test case CommonRequestCheck.5.2.1
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.2.2
			--Description: Set device1 to Passenger's device from HMI
				function Test:TC5_Passenger()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })					
				
				end
			--End Test case CommonRequestCheck.5.2.1
				
		-----------------------------------------------------------------------------------------
			--Begin Test case CommonRequestCheck.5.2.3
			--Description: Connecting Device1 to RSDL
			function Test:TC5_ConnectDevice1()
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case CommonRequestCheck.5.2.3
	
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.5.2.4
			--Description: Connecting Device2 to RSDL
				function Test:TC5_ConnectDevice2()
					
					newConnectionDevice3(self, device3, device3Port)

				end
			--End Test case CommonRequestCheck.5.2.4

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case CommonRequestCheck.5.2.5
			--Description: Register new session for register new apps
				function Test:TC5_NewApps()
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
					
				  self.mobileSession22 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection2)

				  self.mobileSession32 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection3)
					
				end
			--End Test case CommonRequestCheck.5.2.5
			
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.5.2.6
			--Description: Register App3 from Device2
			   function Test:TC5_App3Device2() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession21:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession21:SendRPC("RegisterAppInterface",
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
							  text ="4005",
							  type ="PRE_RECORDED",
							 }, 
							}, 
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="123456",
						   
						   })

				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				  end)    

			   end
			--End Test case CommonRequestCheck.5.2.6
			
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.5.2.7
			--Description: Register App4 from Device2
			   function Test:TC5_App4Device2() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession22:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession22:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="SyncProxyTester2",
							ttsName = 
							{ 
							  
							 { 
							  text ="4005",
							  type ="PRE_RECORDED",
							 }, 
							}, 
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1234567",
						   
						   })

				   --mobile side: RegisterAppInterface response 
				   self.mobileSession22:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				  end)    

			   end
			--End Test case CommonRequestCheck.5.2.7
			
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.5.2.8
			--Description: Register App2 from Device1
			   function Test:TC5_App2Device1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession1:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession1:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="SyncProxyTester App1",
							ttsName = 
							{ 
							  
							 { 
							  text ="4005",
							  type ="PRE_RECORDED",
							 }, 
							}, 
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1234568",
						   
						   })

				   --mobile side: RegisterAppInterface response 
				   self.mobileSession1:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				  end)    

			   end
			--End Test case CommonRequestCheck.5.2.8
    
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.5.2.9
			--Description: Register App5 from Device3
				--Device3
			   function Test:TC5_App5Device3() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession31:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession31:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="SyncProxyTester31",
							ttsName = 
							{ 
							  
							 { 
							  text ="4005",
							  type ="PRE_RECORDED",
							 }, 
							}, 
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="8888",
						   
						   })

				   --mobile side: RegisterAppInterface response 
				   self.mobileSession31:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				  end)    

			   end
			--End Test case CommonRequestCheck.5.2.9
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.10
			--Description: Register App6 from Device3
			   function Test:TC5_App6Device3()

				--mobile side: RegisterAppInterface request
				  self.mobileSession32:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession32:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="SyncProxyTester32",
							ttsName = 
							{ 
							  
							 { 
							  text ="4005",
							  type ="PRE_RECORDED",
							 }, 
							}, 
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="9999",
						   
						   })

				   --mobile side: RegisterAppInterface response 
				   self.mobileSession32:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				  end)    

			   end
			--End Test case CommonRequestCheck.5.2.10
   
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.5.2.11
			--Description: Set device2 to Driver's device from HMI.
				function Test:TC5_SetDevice2Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = device2, id = 2, isSDLAllowed = true}})
					
					--Device2: App3,4: gets OnPermissionsChange with policies from "groups_PrimaryRC"
					self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession22:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
				
				end
			--End Test case CommonRequestCheck.5.2.11
	
		-----------------------------------------------------------------------------------------
   
 			--Begin Test case CommonRequestCheck.5.2.12
			--Description: Set device1 to Driver's device from HMI.
				function Test:TC5_SetDevice1Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--Device1: (App1, App2)
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--Device2: (App3, App4)
					self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession22:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				
				end
			--End Test case CommonRequestCheck.5.2.12
	
		-----------------------------------------------------------------------------------------   
   
 			--Begin Test case CommonRequestCheck.5.2.13
			--Description: Set device3 to Driver's device from HMI.
				function Test:TC5_SetDevice3Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = device3, id = 3, isSDLAllowed = true}})
					
					--Device1: (App1, App2)
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--Device3: (App5, App6)
					self.mobileSession31:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession32:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
				
				end
			--End Test case CommonRequestCheck.5.2.13
	
		-----------------------------------------------------------------------------------------    
	--End Test case CommonRequestCheck.5.2
--=================================================END TEST CASES 5==========================================================--


		
	
return Test	