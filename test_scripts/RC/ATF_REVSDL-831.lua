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


--Declaration connected devices.
--1. Device 2:
local device2 = "192.168.100.199"
local device2Port = 12345
--2. Device 3:
local device3 = "10.42.0.1"
local device3Port = 12345




--======================================REVSDL-831========================================--
---------------------------------------------------------------------------------------------
----------REVSDL-831: R-SDL must set first connected device as a "passenger's"---------------
------------one and change this setting upon user's choice delivered from HMI----------------
---------------------------------------------------------------------------------------------
--=========================================================================================--




---------------------------------------------------------------------------------------------
----------------------------------------END COMMON FUNCTIONS---------------------------------
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

---------------------------------------------------------------------------------------------
----------------------------------------END COMMON FUNCTIONS---------------------------------
---------------------------------------------------------------------------------------------	




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
--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1 (TCs: REVSDL-923 - [REVSDL-831]: TC_1. Any connected device should be treated as passenger's by RSDL.

	--Description: Rev-SDL must set any connected device independently on transport type as a "passenger's device".

		--Requirement/Diagrams id in jira: 
				--REVSDL-831
		--Verification criteria: 
				--Rev-SDL must set any connected device independently on transport type as a "passenger's device".
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.1.1
			--Description: Register new session for checking that app on device gets OnPermissionsChange with policies from "group_nonPrimaryRC"
				function Test:PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self.expectations_list,
						self.mobileConnection)
				end
			    
				function Test:TC_PassengerDevice_App1()
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
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
								--[[self.mobileSession1:ExpectNotification("OnPermissionsChange")
								:Do(function(_,data)
									table.print = print_r
									table.print( data.payload.permissionItem )
								end)]]
								
								--check OnHMIStatus with deviceRank = "PASSENGER"
								--self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								--:Timeout(3000)
								
							end)
						end
			--End Test case CommonRequestCheck.1.1
		-----------------------------------------------------------------------------------------
		--Begin Test case CommonRequestCheck.1.2
		--Description: Disconnect and then reconnect device to check that app on device gets OnPermissionsChange with policies from "group_nonPrimaryRC"
			--Disconnect device from RSDL by some ways: 
							--Send request from mobile UnregisterAppInterface.
							--"Exit" application from mobile.
							--IGNITION_OFF from HMI.
							--Disable Wifi.
							--Stop RSDL.
				function Test:UnregisterAppInterface_Success() 

				--mobile side: UnregisterAppInterface request 
				local CorIdURAI = self.mobileSession:SendRPC("UnregisterAppInterface", {})

				--hmi side: expected  BasicCommunication.OnAppUnregistered
				--EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.appID, unexpectedDisconnect = false})

				end
			--Re-connect by some ways: 
							--Send request RegisterAppInterface from mobile.
							--Launch application and add session again from mobile.
							--Enable Wifi.
							--Start RSDL again. 
				function Test:PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self.expectations_list,
						self.mobileConnection)
				end
			    
				function Test:TC_PassengerDevice_App2()
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
								self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
								
								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
								
								--check OnHMIStatus with deviceRank = "PASSENGER"
								--self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								--:Timeout(3000)
								
							end)
				end
			--End Test case CommonRequestCheck.1.2
						
		-----------------------------------------------------------------------------------------
	--End Test Case CommonRequestCheck.1
	--Note: Almost TCs of TRS REVSDL-831 are replaced by CRQ RESDLD-1577.
	
	
	
	
	
	
	
--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3 (multi devices - 3 devices)

	--Description: In case RSDL knows a device to be driver's and RC.OnSetDriversDevice for another device comes from HMI, RSDL must set the named device as driver's and set the previous one to passenger's.
	

	--Begin Test case CommonRequestCheck.3.1
	--Description: 	In case RSDL knows a device to be driver's and RC.OnSetDriversDevice for another device comes from HMI, RSDL must set the named device as driver's and set the previous one to passenger's.
					

		--Requirement/Diagrams id in jira: 
				--REVSDL-1213

		--Verification criteria: 
				--In case RSDL knows a device to be driver's and RC.OnSetDriversDevice for another device comes from HMI, RSDL must set the named device as driver's and set the previous one to passenger's.


		-----------------------------------------------------------------------------------------
			--Begin Test case CommonRequestCheck.3.1.1
			--Description: Connecting Device1 to RSDL
			function Test:ConnectDevice1()
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case CommonRequestCheck.3.1.1
	
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.3.1.2
			--Description: Connecting Device2 to RSDL
				function Test:ConnectDevice2()
					
					newConnectionDevice3(self, device3, device3Port)

				end
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case CommonRequestCheck.3.1.3
			--Description: Register new session for register new apps
				function Test:TC3_NewApps()
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
			--End Test case CommonRequestCheck.3.1.3
			
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.3.1.4
			--Description: Register App3 from Device2
			   function Test:TC3_App3Device2() 

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
			--End Test case CommonRequestCheck.3.1.4
			
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.3.1.5
			--Description: Register App4 from Device2
			   function Test:TC3_App4Device2() 

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
			--End Test case CommonRequestCheck.3.1.5
			
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.3.1.6
			--Description: Register App2 from Device1
			   function Test:TC3_App2Device1() 

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
			--End Test case CommonRequestCheck.3.1.6
    
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.3.1.7
			--Description: Register App5 from Device3
				--Device3
			   function Test:TC3_App5Device3() 

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
			--End Test case CommonRequestCheck.3.1.7
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.8
			--Description: Register App6 from Device3
			   function Test:TC3_App6Device3()

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
			--End Test case CommonRequestCheck.3.1.8
   
		-----------------------------------------------------------------------------------------   

			--Begin Test case CommonRequestCheck.3.1.9
			--Description: Set device2 to Driver's device from HMI.
				function Test:TC3_SetDevice2Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = device2, id = 2, isSDLAllowed = true}})
					
					--Device2: App3,4: gets OnPermissionsChange with policies from "groups_PrimaryRC"
					self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					self.mobileSession22:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
				
				end
			--End Test case CommonRequestCheck.3.1.9
	
		-----------------------------------------------------------------------------------------
   
 			--Begin Test case CommonRequestCheck.3.1.10
			--Description: Set device1 to Driver's device from HMI.
				function Test:TC3_SetDevice1Driver()

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
			--End Test case CommonRequestCheck.3.1.10
	
		-----------------------------------------------------------------------------------------   
   
 			--Begin Test case CommonRequestCheck.3.1.11
			--Description: Set device3 to Driver's device from HMI.
				function Test:TC3_SetDevice3Driver()

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
			--End Test case CommonRequestCheck.3.1.11
	
		-----------------------------------------------------------------------------------------    
	--End Test case CommonRequestCheck.3.1
	
--=================================================END TEST CASES 3==========================================================--
	

return Test	
