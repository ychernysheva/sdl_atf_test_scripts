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
local device2 = "172.30.192.146"
local device2Port = 12345
--2. Device 3:
local device3 = "192.168.101.199"
local device3Port = 12345




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
		config.application51.registerAppInterfaceParams
	)
  event_dispatcher:AddConnection(self.mobileConnection2)
  self.mobileSession21:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection2:Connect()
end

--New connection device3
function newConnectionDevice3(self, DeviceIP1, Port1)

  local tcpConnection = tcp.Connection(DeviceIP1, Port1)
  local fileConnection = file_connection.FileConnection("mobile3.out", tcpConnection)
  self.mobileConnection3 = mobile.MobileConnection(fileConnection)
  self.mobileSession31 = mobile_session.MobileSession(
		self.expectations_list,
		self.mobileConnection3,
		config.application52.registerAppInterfaceParams
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

	
	
	


--======================================REVSDL-1702========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1702: SetInteriorVehicleData: conditions to return----------------------
----------------------------------READ_ONLY resultCode---------------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--




--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: In case: application sends valid SetInteriorVehicleData with just read-only parameters in "radioControlData" struct, for muduleType: RADIO, RSDL must 
						--respond with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.
	

	--Begin Test case CommonRequestCheck.1.1
	--Description: 	--PASSENGER's Device
					--RSDL responds with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For PASSENGER'S Device
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.1.1.1
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:PASSENGER_READONLY()
					
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
				
				--mobile side: respond with "resultCode: READ_ONLY, success:false"
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.1.1.1
			
		-----------------------------------------------------------------------------------------	
	
	--End Test case CommonRequestCheck.1.1
	
	
	--Begin Test case CommonRequestCheck.1.2
	--Description: 	--DRIVER's Device
					--RSDL responds with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For DRIVER'S Device
				
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.1.2.1
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:SetPASSENGERToDRIVER()
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.1.2.1
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.1.2.2
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:DRIVER_READONLY()
					
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
				
				--mobile side: respond with "resultCode: READ_ONLY, success:false"
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.1.2.2
			
		-----------------------------------------------------------------------------------------	
	
	--End Test case CommonRequestCheck.1.2
	
--=================================================END TEST CASES 1==========================================================--




--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2

	--Description: In case: application sends valid SetInteriorVehicleData with just read-only parameters in "climateControlData" struct, for muduleType: CLIMATE, RSDL must 
						--respond with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.
	

	--Begin Test case CommonRequestCheck.2.1
	--Description: 	--PASSENGER's Device
					--RSDL responds with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For PASSENGER'S Device
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.2.1.1
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:PASSENGER_READONLY()
					
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters in "radioControlData" struct, for muduleType: CLIMATE
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30
							}
						}						
					})
				
				--mobile side: respond with "resultCode: READ_ONLY, success:false"
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.2.1.1
			
		-----------------------------------------------------------------------------------------	
	
	--End Test case CommonRequestCheck.2.1
	
	
	--Begin Test case CommonRequestCheck.2.2
	--Description: 	--DRIVER's Device
					--RSDL responds with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For DRIVER'S Device
				
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.2.2.1
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:SetPASSENGERToDRIVER()
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.2.2.1
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.2.2.2
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:DRIVER_READONLY()
					
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters in "radioControlData" struct, for muduleType: CLIMATE
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30
							}
						}						
					})
				
				--mobile side: respond with "resultCode: READ_ONLY, success:false"
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.2.2.2
			
		-----------------------------------------------------------------------------------------	
	
	--End Test case CommonRequestCheck.2.2
	
--=================================================END TEST CASES 2==========================================================--





--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: In case: application sends valid SetInteriorVehicleData with read-only parameters and one or more settable parameters in "radioControlData" struct, for muduleType: RADIO, RSDL must 
						--cut the read-only parameters off and process this RPC as assigned (that is, check policies, send to HMI, and etc. per existing requirements)
	

	--Begin Test case CommonRequestCheck.3.1
	--Description: 	--PASSENGER's Device
					--RSDL cut the read-only parameters off and process this RPC as assigned.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For PASSENGER'S Device
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.3.1.1
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and frequencyInteger parameter
				function Test:PASSENGER_SETTABLE_frequencyInteger()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyInteger = 105,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyInteger = 105
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData =
													{
														radioControlData = 
														{
															frequencyInteger = 105
														},
														moduleType = "RADIO",
														moduleZone = 
														{
															colspan = 2,
															row = 0,
															rowspan = 2,
															col = 0,
															levelspan = 1,
															level = 0
														}
													}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.3.1.1
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.3.1.2
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and frequencyFraction parameter
				function Test:PASSENGER_SETTABLE_frequencyFraction()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyFraction = 3,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyFraction = 3
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData =
													{
														radioControlData = 
														{
															frequencyFraction = 3
														},
														moduleType = "RADIO",
														moduleZone = 
														{
															colspan = 2,
															row = 0,
															rowspan = 2,
															col = 0,
															levelspan = 1,
															level = 0
														}
													}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.3.1.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.3
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and band parameter
				function Test:PASSENGER_SETTABLE_band()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								band = "AM",
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								band = "AM"
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData =
													{
														radioControlData = 
														{
															band = "AM"
														},
														moduleType = "RADIO",
														moduleZone = 
														{
															colspan = 2,
															row = 0,
															rowspan = 2,
															col = 0,
															levelspan = 1,
															level = 0
														}
													}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.3.1.3
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.4
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and hdChannel parameter
				function Test:PASSENGER_SETTABLE_hdChannel()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								hdChannel = 1,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								hdChannel = 1
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData =
													{
														radioControlData = 
														{
															hdChannel = 1
														},
														moduleType = "RADIO",
														moduleZone = 
														{
															colspan = 2,
															row = 0,
															rowspan = 2,
															col = 0,
															levelspan = 1,
															level = 0
														}
													}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.3.1.4
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.5
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and all parameters
				function Test:PASSENGER_SETTABLE_AllParams()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData =
													{
														radioControlData = 
														{
															frequencyInteger = 105,
															frequencyFraction = 3,
															band = "AM",
															hdChannel = 1
														},
														moduleType = "RADIO",
														moduleZone = 
														{
															colspan = 2,
															row = 0,
															rowspan = 2,
															col = 0,
															levelspan = 1,
															level = 0
														}
													}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.3.1.5
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.1


	--Begin Test case CommonRequestCheck.3.2
	--Description: 	--DRIVER's Device
					--RSDL cut the read-only parameters off and process this RPC as assigned.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For DRIVER'S Device

			--Begin Test case CommonRequestCheck.3.2.0
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:SetPASSENGERToDRIVER()
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.3.2.0
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.3.2.1
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and frequencyInteger parameter
				function Test:DRIVER_SETTABLE_frequencyInteger()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyInteger = 105,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyInteger = 105
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData =
													{
														radioControlData = 
														{
															frequencyInteger = 105
														},
														moduleType = "RADIO",
														moduleZone = 
														{
															colspan = 2,
															row = 0,
															rowspan = 2,
															col = 0,
															levelspan = 1,
															level = 0
														}
													}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.3.2.1
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.3.2.2
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and frequencyFraction parameter
				function Test:DRIVER_SETTABLE_frequencyFraction()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyFraction = 3,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyFraction = 3
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData =
													{
														radioControlData = 
														{
															frequencyFraction = 3
														},
														moduleType = "RADIO",
														moduleZone = 
														{
															colspan = 2,
															row = 0,
															rowspan = 2,
															col = 0,
															levelspan = 1,
															level = 0
														}
													}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.3.2.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.3
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and band parameter
				function Test:DRIVER_SETTABLE_band()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								band = "AM",
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								band = "AM"
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData =
													{
														radioControlData = 
														{
															band = "AM"
														},
														moduleType = "RADIO",
														moduleZone = 
														{
															colspan = 2,
															row = 0,
															rowspan = 2,
															col = 0,
															levelspan = 1,
															level = 0
														}
													}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.3.2.3
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.4
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and hdChannel parameter
				function Test:DRIVER_SETTABLE_hdChannel()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								hdChannel = 1,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								hdChannel = 1
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData =
													{
														radioControlData = 
														{
															hdChannel = 1
														},
														moduleType = "RADIO",
														moduleZone = 
														{
															colspan = 2,
															row = 0,
															rowspan = 2,
															col = 0,
															levelspan = 1,
															level = 0
														}
													}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.3.2.4
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.5
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and all parameters
				function Test:DRIVER_SETTABLE_AllParams()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData =
													{
														radioControlData = 
														{
															frequencyInteger = 105,
															frequencyFraction = 3,
															band = "AM",
															hdChannel = 1
														},
														moduleType = "RADIO",
														moduleZone = 
														{
															colspan = 2,
															row = 0,
															rowspan = 2,
															col = 0,
															levelspan = 1,
															level = 0
														}
													}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.3.2.5
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.2
	
--=================================================END TEST CASES 3==========================================================--

	


--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for Req.#4

	--Description: In case: application sends valid SetInteriorVehicleData with read-only parameters and one or more settable parameters in "climateControlData" struct, for muduleType: CLIMATE, RSDL must 
						--cut the read-only parameters off and process this RPC as assigned (that is, check policies, send to HMI, and etc. per existing requirements)
	

	--Begin Test case CommonRequestCheck.4.1
	--Description: 	--PASSENGER's Device
					--RSDL cut the read-only parameters off and process this RPC as assigned.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For PASSENGER'S Device
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.4.1.1
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and all parameter
				function Test:PASSENGER_SETTABLE_AllParams()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.1.2
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and fanSpeed parameter
				function Test:PASSENGER_SETTABLE_fanSpeed()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.1.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.3
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and circulateAirEnable parameter
				function Test:PASSENGER_SETTABLE_circulateAirEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.1.3
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.4.1.4
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and dualModeEnable parameter
				function Test:PASSENGER_SETTABLE_dualModeEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								dualModeEnable = true,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								dualModeEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								dualModeEnable = true
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.1.4
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.5
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and defrostZone parameter
				function Test:PASSENGER_SETTABLE_defrostZone()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								defrostZone = "FRONT"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								defrostZone = "FRONT"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								defrostZone = "FRONT"
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.1.5
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.1.6
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and acEnable parameter
				function Test:PASSENGER_SETTABLE_acEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								acEnable = true
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								acEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								acEnable = true
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.1.6
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.7
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and desiredTemp parameter
				function Test:PASSENGER_SETTABLE_desiredTemp()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								desiredTemp = 24
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								desiredTemp = 24
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								desiredTemp = 24
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.1.7
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.4.1.8
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and autoModeEnable parameter
				function Test:PASSENGER_SETTABLE_autoModeEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								autoModeEnable = true
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								autoModeEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								autoModeEnable = true
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.1.8
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.4.1.9
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and temperatureUnit parameter
				function Test:PASSENGER_SETTABLE_temperatureUnit()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								temperatureUnit = "CELSIUS"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								temperatureUnit = "CELSIUS"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								temperatureUnit = "CELSIUS"
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.1.9
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.4.1
	
	
	--Begin Test case CommonRequestCheck.4.2
	--Description: 	--DRIVER's Device
					--RSDL responds with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For DRIVER'S Device
				
		-----------------------------------------------------------------------------------------				
				
			--Begin Test case CommonRequestCheck.4.2.0
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:SetPASSENGERToDRIVER()
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.4.2.0
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.4.2.1
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and all parameter
				function Test:DRIVER_SETTABLE_AllParams()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.2.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.2.2
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and fanSpeed parameter
				function Test:DRIVER_SETTABLE_fanSpeed()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.2.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.2.3
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and circulateAirEnable parameter
				function Test:DRIVER_SETTABLE_circulateAirEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.2.3
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.4.2.4
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and dualModeEnable parameter
				function Test:DRIVER_SETTABLE_dualModeEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								dualModeEnable = true,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								dualModeEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								dualModeEnable = true
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.2.4
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.2.5
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and defrostZone parameter
				function Test:DRIVER_SETTABLE_defrostZone()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								defrostZone = "FRONT"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								defrostZone = "FRONT"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								defrostZone = "FRONT"
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.2.5
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.2.6
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and acEnable parameter
				function Test:DRIVER_SETTABLE_acEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								acEnable = true
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								acEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								acEnable = true
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.2.6
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.2.7
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and desiredTemp parameter
				function Test:DRIVER_SETTABLE_desiredTemp()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								desiredTemp = 24
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								desiredTemp = 24
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								desiredTemp = 24
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.2.7
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.4.2.8
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and autoModeEnable parameter
				function Test:DRIVER_SETTABLE_autoModeEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								autoModeEnable = true
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								autoModeEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								autoModeEnable = true
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.2.8
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.4.2.9
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and temperatureUnit parameter
				function Test:DRIVER_SETTABLE_temperatureUnit()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								temperatureUnit = "CELSIUS"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								temperatureUnit = "CELSIUS"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								temperatureUnit = "CELSIUS"
							}
						}			
					})
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				end
			--End Test case CommonRequestCheck.4.2.9
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.4.2
	
--=================================================END TEST CASES 4==========================================================--
	
	
	
	
	
--=================================================BEGIN TEST CASES 5==========================================================--
	--Begin Test suit CommonRequestCheck.5 for Req.#5

	--Description: In case: application sends valid SetInteriorVehicleData with just read-only parameters in "radioControlData" struct, for muduleType: RADIO, RSDL must 
						--HMI responds with "resultCode: READ_ONLY" RSDL must send "resultCode: READ_ONLY, success:false" to the related mobile application. 
	

	--Begin Test case CommonRequestCheck.5.1
	--Description: 	--PASSENGER's Device
					--RSDL responds with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For PASSENGER'S Device
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.5.1.1
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and frequencyInteger parameter
				function Test:PASSENGER_READONLY_frequencyInteger()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyInteger = 105,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyInteger = 105
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.5.1.1
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.5.1.2
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and frequencyFraction parameter
				function Test:PASSENGER_READONLY_frequencyFraction()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyFraction = 3,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyFraction = 3
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.5.1.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.3
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and band parameter
				function Test:PASSENGER_READONLY_band()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								band = "AM",
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								band = "AM"
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.5.1.3
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.4
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and hdChannel parameter
				function Test:PASSENGER_READONLY_hdChannel()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								hdChannel = 1,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								hdChannel = 1
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.5.1.4
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.5
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and all parameters
				function Test:PASSENGER_READONLY_AllParams()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.5.1.5
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.1


	--Begin Test case CommonRequestCheck.5.2
	--Description: 	--DRIVER's Device
					--RSDL responds with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For DRIVER'S Device

			--Begin Test case CommonRequestCheck.5.2.0
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:SetPASSENGERToDRIVER()
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.5.2.0
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.5.2.1
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and frequencyInteger parameter
				function Test:DRIVER_READONLY_frequencyInteger()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyInteger = 105,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyInteger = 105
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.5.2.1
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.5.2.2
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and frequencyFraction parameter
				function Test:DRIVER_READONLY_frequencyFraction()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyFraction = 3,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyFraction = 3
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.5.2.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.3
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and band parameter
				function Test:DRIVER_READONLY_band()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								band = "AM",
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								band = "AM"
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.5.2.3
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.4
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and hdChannel parameter
				function Test:DRIVER_READONLY_hdChannel()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								hdChannel = 1,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								hdChannel = 1
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.5.2.4
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.5
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and all parameters
				function Test:DRIVER_READONLY_AllParams()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,--
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",--
								availableHDs = 1,--
								signalStrength = 50,--
								rdsData =--
								{
									PS = "12345678",
									RT = "",
									CT = "123456789012345678901234",
									PI = "",
									PTY = 0,
									TP = true,
									TA = false,
									REG = ""
								},
								signalChangeThreshold = 10--
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.radioControlData.radioEnable or data.params.moduleData.radioControlData.state or data.params.moduleData.radioControlData.availableHDs or data.params.moduleData.radioControlData.signalStrength or data.params.moduleData.radioControlData.rdsData or data.params.moduleData.radioControlData.signalChangeThreshold then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.radioControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.5.2.5
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.2
	
--=================================================END TEST CASES 5==========================================================--

	


--=================================================BEGIN TEST CASES 6==========================================================--
	--Begin Test suit CommonRequestCheck.6 for Req.#6

	--Description: In case: application sends valid SetInteriorVehicleData with just read-only parameters in "radioControlData" struct, for muduleType: CLIMATE, RSDL must 
						--HMI responds with "resultCode: READ_ONLY" RSDL must send "resultCode: READ_ONLY, success:false" to the related mobile application. 
	

	--Begin Test case CommonRequestCheck.6.1
	--Description: 	--PASSENGER's Device
					--RSDL responds with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For PASSENGER'S Device
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.6.1.1
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and all parameter
				function Test:PASSENGER_READONLY_AllParams()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.6.1.2
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and fanSpeed parameter
				function Test:PASSENGER_READONLY_fanSpeed()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.1.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.6.1.3
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and circulateAirEnable parameter
				function Test:PASSENGER_READONLY_circulateAirEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.1.3
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.6.1.4
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and dualModeEnable parameter
				function Test:PASSENGER_READONLY_dualModeEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								dualModeEnable = true,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								dualModeEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.1.4
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.6.1.5
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and defrostZone parameter
				function Test:PASSENGER_READONLY_defrostZone()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								defrostZone = "FRONT"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								defrostZone = "FRONT"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.1.5
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.6.1.6
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and acEnable parameter
				function Test:PASSENGER_READONLY_acEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								acEnable = true
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								acEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.1.6
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.6.1.7
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and desiredTemp parameter
				function Test:PASSENGER_READONLY_desiredTemp()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								desiredTemp = 24
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								desiredTemp = 24
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.1.7
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.6.1.8
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and autoModeEnable parameter
				function Test:PASSENGER_READONLY_autoModeEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								autoModeEnable = true
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								autoModeEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.1.8
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.6.1.9
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and temperatureUnit parameter
				function Test:PASSENGER_READONLY_temperatureUnit()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								temperatureUnit = "CELSIUS"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								temperatureUnit = "CELSIUS"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.1.9
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.6.1
	
	
	--Begin Test case CommonRequestCheck.6.2
	--Description: 	--DRIVER's Device
					--RSDL responds with "resultCode: READ_ONLY, success:false" to this application and do not process this RPC.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For DRIVER'S Device
				
		-----------------------------------------------------------------------------------------				
				
			--Begin Test case CommonRequestCheck.6.2.0
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:SetPASSENGERToDRIVER()
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.6.2.0
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.6.2.1
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and all parameter
				function Test:DRIVER_READONLY_AllParams()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.2.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.6.2.2
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and fanSpeed parameter
				function Test:DRIVER_READONLY_fanSpeed()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.2.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.6.2.3
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and circulateAirEnable parameter
				function Test:DRIVER_READONLY_circulateAirEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								circulateAirEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.2.3
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.6.2.4
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and dualModeEnable parameter
				function Test:DRIVER_READONLY_dualModeEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								dualModeEnable = true,
								currentTemp = 30
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								dualModeEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.2.4
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.6.2.5
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and defrostZone parameter
				function Test:DRIVER_READONLY_defrostZone()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								defrostZone = "FRONT"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								defrostZone = "FRONT"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.2.5
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.6.2.6
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and acEnable parameter
				function Test:DRIVER_READONLY_acEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								acEnable = true
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								acEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.2.6
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.6.2.7
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and desiredTemp parameter
				function Test:DRIVER_READONLY_desiredTemp()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								desiredTemp = 24
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								desiredTemp = 24
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.2.7
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.6.2.8
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and autoModeEnable parameter
				function Test:DRIVER_READONLY_autoModeEnable()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								autoModeEnable = true
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								autoModeEnable = true
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.2.8
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.6.2.9
			--Description: Sending SetInteriorVehicleData request with and read-only parameters and temperatureUnit parameter
				function Test:DRIVER_READONLY_temperatureUnit()
					--mobile side: sending SetInteriorVehicleData request with just read-only parameters and settable params in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								currentTemp = 30,
								temperatureUnit = "CELSIUS"
							}
						}					
					})
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								temperatureUnit = "CELSIUS"
							}
						}					
					}
				)
				:ValidIf (function(_,data)
					--RSDL must cut the read-only parameters off and process this RPC as assigned
					if data.params.moduleData.climateControlData.currentTemp then
						print(" --SDL sends fake parameter to HMI ")
						for key,value in pairs(data.params.moduleData.climateControlData) do print(key,value) end
						return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending RC.SetInteriorVehicleData response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.SetInteriorVehicleData"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect READ_ONLY response
				EXPECT_RESPONSE(cid, { success = false, resultCode = "READ_ONLY"})
				
				end
			--End Test case CommonRequestCheck.6.2.9
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.6.2
	
--=================================================END TEST CASES 6==========================================================--	
	
	
	
	
	
--=================================================BEGIN TEST CASES 7==========================================================--
	--Begin Test suit CommonRequestCheck.7 for Req.#7

	--Description: In case RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI, 
						--SDL must send <any-RPC-except-of-SetInteriorVehicleData>response (resultCode: GENERIC_ERROR, success: false) to the related mobile app.
	

	--Begin Test case CommonRequestCheck.7.1
	--Description: 	--PASSENGER's Device
					--In case RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For PASSENGER'S Device
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.7.1.1
			--Description: RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI
				function Test:PASSENGER_GetInteriorVehicleDataCapabilities()
					
					--mobile side: sending GetInteriorVehicleDataCapabilities request with just read-only parameters in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO"}
					})
					
				--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
				EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
				:Do(function(_,data)
					--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.GetInteriorVehicleDataCapabilities"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																							{
																								moduleZone = {
																									col = 0,
																									row = 0,
																									level = 0,
																									colspan = 2,
																									rowspan = 2,
																									levelspan = 1
																								},
																								moduleType = "RADIO"
																							}
																				}
				})
				
				end
			--End Test case CommonRequestCheck.7.1.1
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.1.2
			--Description: RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI
				function Test:PASSENGER_ButtonPressDriverAllow()
					
					--mobile side: sending ButtonPress request with just read-only parameters in "radioControlData" struct, for muduleType: RADIO
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
				
				--hmi side: expect RC.GetInteriorVehicleDataConsent request
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response
						self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true, isAllowed = false})
						
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
									ResponseId = data.id
									local function ValidationResponse()
										self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"Buttons.ButtonPress"}}}')
									end
									RUN_AFTER(ValidationResponse, 3000)
								end)
						
					end)				
					
					
				--mobile side: send <any-RPC-except-of-SetInteriorVehicleData>response (resultCode: GENERIC_ERROR, success: false) to the related mobile app
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
				
				end
			--End Test case CommonRequestCheck.7.1.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.1.3
			--Description: RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI
				function Test:PASSENGER_ButtonPressAutoAllow()
					
					--mobile side: sending ButtonPress request with just read-only parameters in "radioControlData" struct, for muduleType: RADIO
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
						ResponseId = data.id
						local function ValidationResponse()
							self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"Buttons.ButtonPress"}}}')
						end
						RUN_AFTER(ValidationResponse, 3000)
					end)			
					
					
				--mobile side: send <any-RPC-except-of-SetInteriorVehicleData>response (resultCode: GENERIC_ERROR, success: false) to the related mobile app
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
				
				end
			--End Test case CommonRequestCheck.7.1.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.7.1.4
			--Description: RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI
				function Test:PASSENGER_GetInteriorVehicleDataAutoAllow()
					
					--mobile side: sending GetInteriorVehicleData request with just read-only parameters in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true					
					})

					--hmi side: expect RC.GetInteriorVehicleData request
					EXPECT_HMICALL("RC.GetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.GetInteriorVehicleData response
							ResponseId = data.id
							local function ValidationResponse()
								self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.GetInteriorVehicleData"}}}')
							end
							RUN_AFTER(ValidationResponse, 3000)							
					end)			
					
					
				--mobile side: send <any-RPC-except-of-SetInteriorVehicleData>response (resultCode: GENERIC_ERROR, success: false) to the related mobile app
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
				
				end
			--End Test case CommonRequestCheck.7.1.4
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.7.1.5
			--Description: RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI
				function Test:PASSENGER_GetInteriorVehicleDataDriverAllow()
					
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true							
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "CLIMATE",
									zone =
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									}
								})
						:Do(function(_,data)						
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Do(function(_,data)
								--hmi side: sending RC.GetInteriorVehicleData response
								ResponseId = data.id
								local function ValidationResponse()
									self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.GetInteriorVehicleData"}}}')
								end
								RUN_AFTER(ValidationResponse, 3000)
							end)
					end)			
					
					
				--mobile side: send <any-RPC-except-of-SetInteriorVehicleData>response (resultCode: GENERIC_ERROR, success: false) to the related mobile app
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
				
				end
			--End Test case CommonRequestCheck.7.1.5
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.7.1



	--Begin Test case CommonRequestCheck.7.2
	--Description: 	--DRIVER's Device
					--In case RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI

		--Requirement/Diagrams id in jira: 
				--REVSDL-1702
				--https://adc.luxoft.com/jira/secure/attachment/127928/127928_model_SetInteriorVehicleData-READ_ONLY.png

		--Verification criteria: 
				--For DRIVER'S Device
		
		-----------------------------------------------------------------------------------------				
				
			--Begin Test case CommonRequestCheck.7.2.0
			--Description: Sending SetInteriorVehicleData request with just read-only parameters
				function Test:SetPASSENGERToDRIVER()
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
				
				end
			--End Test case CommonRequestCheck.7.2.0		
		
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case CommonRequestCheck.7.2.1
			--Description: RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI
				function Test:DRIVER_GetInteriorVehicleDataCapabilities()
					
					--mobile side: sending GetInteriorVehicleDataCapabilities request with just read-only parameters in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO"}
					})
					
				--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
				EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
				:Do(function(_,data)
					--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
					ResponseId = data.id
					local function ValidationResponse()
						self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.GetInteriorVehicleDataCapabilities"}}}')
					end
					RUN_AFTER(ValidationResponse, 3000)
				end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																							{
																								moduleZone = {
																									col = 0,
																									row = 0,
																									level = 0,
																									colspan = 2,
																									rowspan = 2,
																									levelspan = 1
																								},
																								moduleType = "RADIO"
																							}
																				}
				})
				
				end
			--End Test case CommonRequestCheck.7.2.1
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.2.2
			--Description: RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI
				function Test:DRIVER_ButtonPressAutoAllow()
					
					--mobile side: sending ButtonPress request with just read-only parameters in "radioControlData" struct, for muduleType: RADIO
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
						ResponseId = data.id
						local function ValidationResponse()
							self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"Buttons.ButtonPress"}}}')
						end
						RUN_AFTER(ValidationResponse, 3000)
					end)			
					
					
				--mobile side: send <any-RPC-except-of-SetInteriorVehicleData>response (resultCode: GENERIC_ERROR, success: false) to the related mobile app
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
				
				end
			--End Test case CommonRequestCheck.7.2.2
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.7.2.3
			--Description: RSDL gets <any-RPC-except-of-SetInteriorVehicleData>-response (resultCode: READ_ONLY) from HMI
				function Test:DRIVER_GetInteriorVehicleDataAutoAllow()
					
					--mobile side: sending GetInteriorVehicleData request with just read-only parameters in "radioControlData" struct, for muduleType: RADIO
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true					
					})

					--hmi side: expect RC.GetInteriorVehicleData request
					EXPECT_HMICALL("RC.GetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleData response
						ResponseId = data.id
						local function ValidationResponse()
							self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","error":{"code":25,"message":"One of the provided IDs is not valid","data":{"method":"RC.GetInteriorVehicleData"}}}')
						end
						RUN_AFTER(ValidationResponse, 3000)
							
					end)
					
					
				--mobile side: send <any-RPC-except-of-SetInteriorVehicleData>response (resultCode: GENERIC_ERROR, success: false) to the related mobile app
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
				
				end
			--End Test case CommonRequestCheck.7.2.3
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.7.2
	
--=================================================END TEST CASES 7==========================================================--
	
	

		
	
return Test	