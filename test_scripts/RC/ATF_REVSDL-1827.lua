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

---------------------------------------------------------------------------------------------
--Instruction for config multi-devcies: https://adc.luxoft.com/confluence/display/REVSDL/Connecting+Multi-Devices+with+ATF
--Declaration connected devices.
--1. Device 2:
local device2 = "192.168.100.199"
local device2Port = 12345
--2. Device 3:
local device3 = "10.42.0.1"
local device3Port = 12345

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

	
	
	
	

--======================================REVSDL-1827========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1827: Policies: "equipment" permissions must be checked-----------------
-------------------------- against location provided from HMI--------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1 (INCLUDING ATF_REVSDL-966.lua)

	--Description: 1. In case an RC application from <deviceID> device sends a valid rc-RPC with <app-provided interiorZone>, <moduleType> and <params> allowed by app's assigned policies 
						-- and RSDL has not received RC.OnDeviceLocationChanged(<deviceID>) from HMI 
						-- and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "auto_allow" sub-section of <app-provided interiorZone> section 
						-- RSDL must send this RPC with these <params> to the vehicle (HMI).
	

	--Begin Test case CommonRequestCheck.1.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827

		--Verification criteria: 
				--RSDL must send this RPC with these <params> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.1.1.1
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonPressMode = LONG
				function Test:ButtonPress_ButtonPressMode_LONG()
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.2
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonPressMode = SHORT
				function Test:ButtonPress_ButtonPressMode_SHORT()
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
						buttonPressMode = "SHORT",
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
									buttonPressMode = "SHORT",
									buttonName = "VOLUME_UP"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.3
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonName = VOLUME_UP
				function Test:ButtonPress_ButtonName_VOLUME_UP()
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
						buttonPressMode = "SHORT",
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
									buttonPressMode = "SHORT",
									buttonName = "VOLUME_UP"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.4
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonName = VOLUME_DOWN
				function Test:ButtonPress_ButtonName_VOLUME_DOWN()
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
						buttonPressMode = "SHORT",
						buttonName = "VOLUME_DOWN"						
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
									buttonPressMode = "SHORT",
									buttonName = "VOLUME_DOWN"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.4
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.1.1.5
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonName = EJECT
				function Test:ButtonPress_ButtonName_EJECT()
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
						buttonPressMode = "SHORT",
						buttonName = "EJECT"						
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
									buttonPressMode = "SHORT",
									buttonName = "EJECT"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.5
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.1.1.6
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonName = SOURCE
				function Test:ButtonPress_ButtonName_SOURCE()
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
						buttonPressMode = "SHORT",
						buttonName = "SOURCE"						
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
									buttonPressMode = "SHORT",
									buttonName = "SOURCE"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.6
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.7
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonName = SHUFFLE
				function Test:ButtonPress_ButtonName_SHUFFLE()
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
						buttonPressMode = "SHORT",
						buttonName = "SHUFFLE"						
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
									buttonPressMode = "SHORT",
									buttonName = "SHUFFLE"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.7
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.8
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonName = REPEAT
				function Test:ButtonPress_ButtonName_REPEAT()
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
						buttonPressMode = "SHORT",
						buttonName = "REPEAT"						
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
									buttonPressMode = "SHORT",
									buttonName = "REPEAT"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.8
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.9
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonPressMode = LONG
				function Test:ButtonPress_ButtonPressMode_LONG()
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.9
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.10
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonPressMode = SHORT
				function Test:ButtonPress_ButtonPressMode_SHORT()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
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
									buttonPressMode = "SHORT",
									buttonName = "AC_MAX"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.10
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.11
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = AC_MAX
				function Test:ButtonPress_ButtonName_AC_MAX()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
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
									buttonPressMode = "SHORT",
									buttonName = "AC_MAX"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.11
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.12
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = AC
				function Test:ButtonPress_ButtonName_AC()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "AC"						
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
									buttonPressMode = "SHORT",
									buttonName = "AC"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.12
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.13
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = RECIRCULATE
				function Test:ButtonPress_ButtonName_RECIRCULATE()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "RECIRCULATE"						
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
									buttonPressMode = "SHORT",
									buttonName = "RECIRCULATE"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.13
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.14
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = FAN_UP
				function Test:ButtonPress_ButtonName_FAN_UP()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "FAN_UP"						
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
									buttonPressMode = "SHORT",
									buttonName = "FAN_UP"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.14
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case CommonRequestCheck.1.1.15
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = FAN_DOWN
				function Test:ButtonPress_ButtonName_FAN_DOWN()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "FAN_DOWN"						
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
									buttonPressMode = "SHORT",
									buttonName = "FAN_DOWN"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.15
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.16
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = TEMP_UP
				function Test:ButtonPress_ButtonName_TEMP_UP()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "TEMP_UP"						
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
									buttonPressMode = "SHORT",
									buttonName = "TEMP_UP"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.16
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.17
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = TEMP_DOWN
				function Test:ButtonPress_ButtonName_TEMP_DOWN()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "TEMP_DOWN"						
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
									buttonPressMode = "SHORT",
									buttonName = "TEMP_DOWN"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.17
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.18
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = DEFROST_MAX
				function Test:ButtonPress_ButtonName_DEFROST_MAX()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "DEFROST_MAX"						
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
									buttonPressMode = "SHORT",
									buttonName = "DEFROST_MAX"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.18
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.19
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = DEFROST
				function Test:ButtonPress_ButtonName_DEFROST()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "DEFROST"						
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
									buttonPressMode = "SHORT",
									buttonName = "DEFROST"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.19
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.20
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = DEFROST_REAR
				function Test:ButtonPress_ButtonName_DEFROST_REAR()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "DEFROST_REAR"						
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
									buttonPressMode = "SHORT",
									buttonName = "DEFROST_REAR"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.20
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.21
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = UPPER_VENT
				function Test:ButtonPress_ButtonName_UPPER_VENT()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "UPPER_VENT"						
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
									buttonPressMode = "SHORT",
									buttonName = "UPPER_VENT"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.21
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.22
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE, buttonName = LOWER_VENT
				function Test:ButtonPress_ButtonName_LOWER_VENT()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
									buttonPressMode = "SHORT",
									buttonName = "LOWER_VENT"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.22
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.23
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonPressMode = LONG
				function Test:ButtonPress_ButtonPressMode_LONG()
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
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.23
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.24
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonPressMode = SHORT
				function Test:ButtonPress_ButtonPressMode_SHORT()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
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
									buttonPressMode = "SHORT",
									buttonName = "AC_MAX"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.24
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.25
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = AC_MAX
				function Test:ButtonPress_ButtonName_AC_MAX()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
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
									buttonPressMode = "SHORT",
									buttonName = "AC_MAX"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.25
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.26
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = AC
				function Test:ButtonPress_ButtonName_AC()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "AC"						
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
									buttonPressMode = "SHORT",
									buttonName = "AC"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.26
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.27
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = RECIRCULATE
				function Test:ButtonPress_ButtonName_RECIRCULATE()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "RECIRCULATE"						
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
									buttonPressMode = "SHORT",
									buttonName = "RECIRCULATE"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.27
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.28
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = FAN_UP
				function Test:ButtonPress_ButtonName_FAN_UP()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "FAN_UP"						
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
									buttonPressMode = "SHORT",
									buttonName = "FAN_UP"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.28
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case CommonRequestCheck.1.1.29
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = FAN_DOWN
				function Test:ButtonPress_ButtonName_FAN_DOWN()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "FAN_DOWN"						
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
									buttonPressMode = "SHORT",
									buttonName = "FAN_DOWN"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.29
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.30
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = TEMP_UP
				function Test:ButtonPress_ButtonName_TEMP_UP()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "TEMP_UP"						
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
									buttonPressMode = "SHORT",
									buttonName = "TEMP_UP"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.30
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.31
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = TEMP_DOWN
				function Test:ButtonPress_ButtonName_TEMP_DOWN()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "TEMP_DOWN"						
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
									buttonPressMode = "SHORT",
									buttonName = "TEMP_DOWN"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.31
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.32
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = DEFROST_MAX
				function Test:ButtonPress_ButtonName_DEFROST_MAX()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "DEFROST_MAX"						
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
									buttonPressMode = "SHORT",
									buttonName = "DEFROST_MAX"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.32
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.33
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = DEFROST
				function Test:ButtonPress_ButtonName_DEFROST()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "DEFROST"						
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
									buttonPressMode = "SHORT",
									buttonName = "DEFROST"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.33
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.34
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = DEFROST_REAR
				function Test:ButtonPress_ButtonName_DEFROST_REAR()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "DEFROST_REAR"						
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
									buttonPressMode = "SHORT",
									buttonName = "DEFROST_REAR"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.34
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.35
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = UPPER_VENT
				function Test:ButtonPress_ButtonName_UPPER_VENT()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "UPPER_VENT"						
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
									buttonPressMode = "SHORT",
									buttonName = "UPPER_VENT"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.35
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.36
			--Description: application sends ButtonPress as front passenger and ModuleType = CLIMATE, buttonName = LOWER_VENT
				function Test:ButtonPress_ButtonName_LOWER_VENT()
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
									buttonPressMode = "SHORT",
									buttonName = "LOWER_VENT"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.36
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case CommonRequestCheck.1.1.37
			--Description: application sends ButtonPress as Left Rare Passenger (col=0/ row=1/ level=0) and ModuleType = RADIO, buttonName = SHUFFLE
				function Test:ButtonPress_AutoAllowLeftRADIO()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 1,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "SHORT",
						buttonName = "SHUFFLE"						
					})
					
				--hmi side: expect Buttons.ButtonPress request
				EXPECT_HMICALL("Buttons.ButtonPress", 
								{ 
									zone =
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									},
									moduleType = "RADIO",
									buttonPressMode = "SHORT",
									buttonName = "SHUFFLE"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.1.1.37
			
		-----------------------------------------------------------------------------------------	
	--End Test case CommonRequestCheck.1.1
	
	
	--Begin Test case CommonRequestCheck.1.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827

		--Verification criteria: 
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "auto_allow" sub-section of <interiorZone> section - RSDL must send this RPC with these <params> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.1.2.1
			--Description: application sends GetInteriorVehicleData as Driver and ModuleType = RADIO
				function Test:GetInterior_AutoDriverRADIO()
					--mobile sends request for precondition
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 0,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 0,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99,
											frequencyFraction = 3,
											band = "FM",
											rdsData = {
												PS = "name",
												RT = "radio",
												CT = "YYYY-MM-DDThh:mm:ss.sTZD",
												PI = "Sign",
												PTY = 1,
												TP = true,
												TA = true,
												REG = "Murica"
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
									}	
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.2.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.2.2
			--Description: application sends GetInteriorVehicleData as Driver and ModuleType = CLIMATE
				function Test:GetInterior_AutoDriverCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
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
										currentTemp = 30,
										defrostZone = "FRONT",
										acEnable = true,
										desiredTemp = 24,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
							})
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.2.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.2.3
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1/ row=0/ level=0) and ModuleType = CLIMATE
				function Test:GetInterior_AutoFrontCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 1,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.2.3
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.1.2	
	
	
	
	--Begin Test case CommonRequestCheck.1.3
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827

		--Verification criteria: 
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "auto_allow" sub-section of <interiorZone> section - RSDL must send this RPC with these <params> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.1.3.1
			--Description: application sends SetInteriorVehicleData as Driver and ModuleType = RADIO
				function Test:SetInterior_AutoDriverRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})

					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 0,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 0,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99,
											frequencyFraction = 3,
											band = "FM",
											rdsData = {
												PS = "name",
												RT = "radio",
												CT = "YYYY-MM-DDThh:mm:ss.sTZD",
												PI = "Sign",
												PTY = 1,
												TP = true,
												TA = true,
												REG = "Murica"
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
									}	
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.3.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.3.2
			--Description: application sends SetInteriorVehicleData as Driver and ModuleType = CLIMATE
				function Test:SetInterior_AutoDriverCLIMATE()
					--mobile sends request for precondition
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
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
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
										currentTemp = 30,
										defrostZone = "FRONT",
										acEnable = true,
										desiredTemp = 24,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
							})
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.3.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.3.3
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1/ row=0/ level=0) and ModuleType = CLIMATE
				function Test:SetInterior_AutoFrontCLIMATE()
					--mobile sends request for precondition
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
								col = 1,
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
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
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
										col = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.3.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.3.4
			--Description: application sends GetInteriorVehicleData as Right Rare Passenger (col=1/ row=1/ level=0) and ModuleType = RADIO
				function Test:SetInterior_AutoRightRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}			
					})

					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 1,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 1,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.1.3.4
			
		-----------------------------------------------------------------------------------------		
		
	--End Test case CommonRequestCheck.1.3
	
--=================================================END TEST CASES 1==========================================================--


	
	
--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2

	--Description: 2. In case an RC application from <deviceID> device sends a valid rc-RPC with <app-provided interiorZone>, <moduleType> and <params> allowed by app's assigned policies 
							-- and RSDL has received RC.OnDeviceLocationChanged(<deviceID>, <HMI-provided interiorZone>) from HMI 
							-- and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "auto_allow" sub-section of <HMI-provided interiorZone> section 
							-- RSDL must send this RPC with these <params> to the vehicle (HMI). 
	

	--Begin Test case CommonRequestCheck.2.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				

		--Verification criteria: 
				--RSDL must send this RPC with these <params> to the vehicle (HMI). 

		-----------------------------------------------------------------------------------------				
		------------------------------FOR DRIVER ZONE--------------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Driver)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Driver()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------	
				
			--Begin Test case CommonRequestCheck.2.1.1
			--Description: application sends ButtonPress as Front Passenger and ModuleType = RADIO, buttonPressMode = LONG
				function Test:ButtonPress_FrontRADIO()
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.1
				
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.2
			--Description: application sends ButtonPress as Back Left and ModuleType = RADIO, buttonPressMode = LONG
				function Test:ButtonPress_LeftRADIO()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 1,
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
										row = 1,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.2
				
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.3
			--Description: application sends ButtonPress as Back Right and ModuleType = RADIO, buttonPressMode = LONG
				function Test:ButtonPress_RightRADIO()
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
					
				--hmi side: expect Buttons.ButtonPress request
				EXPECT_HMICALL("Buttons.ButtonPress", 
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
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.3
				
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.4
			--Description: application sends ButtonPress as Not exists and ModuleType = RADIO, buttonPressMode = LONG
				function Test:ButtonPress_NotExistedRADIO()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
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
										row = 2,
										rowspan = 2,
										col = 2,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.4
				
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.5
			--Description: application sends ButtonPress as Front Passenger and ModuleType = CLIMATE, buttonPressMode = LONG
				function Test:ButtonPress_FrontCLIMATE()
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
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.5
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.6
			--Description: application sends ButtonPress as Back Left and ModuleType = CLIMATE, buttonPressMode = LONG
				function Test:ButtonPress_LeftCLIMATE()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 1,
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
										row = 1,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.6
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.7
			--Description: application sends ButtonPress as Back Right and ModuleType = CLIMATE, buttonPressMode = LONG
				function Test:ButtonPress_RightCLIMATE()
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
										row = 1,
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
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.7
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.8
			--Description: application sends ButtonPress as Not existed and ModuleType = CLIMATE, buttonPressMode = LONG
				function Test:ButtonPress_NotExistedCLIMATE()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
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
										row = 2,
										rowspan = 2,
										col = 2,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.8
			
		-----------------------------------------------------------------------------------------

		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.9
			--Description: application sends ButtonPress as Driver and ModuleType = CLIMATE
				function Test:ButtonPress_DriverCLIMATE()
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.9
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.10
			--Description: application sends ButtonPress as Back Left and ModuleType = CLIMATE
				function Test:ButtonPress_LeftCLIMATE()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 1,
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
										row = 1,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.10
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.11
			--Description: application sends ButtonPress as Back Right and ModuleType = CLIMATE
				function Test:ButtonPress_RightCLIMATE()
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
										row = 1,
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
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.11
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.12
			--Description: application sends ButtonPress as Not Existed and ModuleType = CLIMATE
				function Test:ButtonPress_NotExistedCLIMATE()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
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
										row = 2,
										rowspan = 2,
										col = 2,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.12
			
		-----------------------------------------------------------------------------------------
		
		-------------------------FOR BACK LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.13
			--Description: application sends ButtonPress as driver zone and ModuleType = RADIO
				function Test:ButtonPress_DriverRADIO()
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
						buttonPressMode = "SHORT",
						buttonName = "SHUFFLE"						
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
									buttonPressMode = "SHORT",
									buttonName = "SHUFFLE"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.13
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.14
			--Description: application sends ButtonPress as Front Passenger and ModuleType = RADIO
				function Test:ButtonPress_FrontRADIO()
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
						buttonPressMode = "SHORT",
						buttonName = "SHUFFLE"						
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
									moduleType = "RADIO",
									buttonPressMode = "SHORT",
									buttonName = "SHUFFLE"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.14
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.15
			--Description: application sends ButtonPress as Back Right Passenger and ModuleType = RADIO
				function Test:ButtonPress_RightRADIO()
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
						buttonPressMode = "SHORT",
						buttonName = "SHUFFLE"						
					})
					
				--hmi side: expect Buttons.ButtonPress request
				EXPECT_HMICALL("Buttons.ButtonPress", 
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
									buttonPressMode = "SHORT",
									buttonName = "SHUFFLE"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.15
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.16
			--Description: application sends ButtonPress as Not Existed and ModuleType = RADIO
				function Test:ButtonPress_NotExistedRADIO()
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
							levelspan = 1,
							level = 0
						},
						moduleType = "RADIO",
						buttonPressMode = "SHORT",
						buttonName = "SHUFFLE"						
					})
					
				--hmi side: expect Buttons.ButtonPress request
				EXPECT_HMICALL("Buttons.ButtonPress", 
								{ 
									zone =
									{
										colspan = 2,
										row = 2,
										rowspan = 2,
										col = 2,
										levelspan = 1,
										level = 0
									},
									moduleType = "RADIO",
									buttonPressMode = "SHORT",
									buttonName = "SHUFFLE"
								})
					:Do(function(_,data)
						--hmi side: sending Buttons.ButtonPress response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.1.16
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.1
	
	
	
		
	--Begin Test case CommonRequestCheck.2.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				

		--Verification criteria: 
				--RSDL must send this RPC with these <params> to the vehicle (HMI). 

		-----------------------------------------------------------------------------------------
				
		------------------------------FOR DRIVER ZONE-----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Driver)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Driver()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1
		
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger and ModuleType = RADIO
				function Test:GetInterior_FrontRADIO()
					--mobile sends request for precondition
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
								col = 1,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 1,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 0,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99,
											frequencyFraction = 3,
											band = "FM",
											rdsData = {
												PS = "name",
												RT = "radio",
												CT = "YYYY-MM-DDThh:mm:ss.sTZD",
												PI = "Sign",
												PTY = 1,
												TP = true,
												TA = true,
												REG = "Murica"
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
									}	
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.1
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.2
			--Description: application sends GetInteriorVehicleData as Back Left and ModuleType = RADIO
				function Test:GetInterior_LeftRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
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

					--hmi side: expect RC.GetInteriorVehicleData request
					EXPECT_HMICALL("RC.GetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.GetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 0,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 1,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99,
											frequencyFraction = 3,
											band = "FM",
											rdsData = {
												PS = "name",
												RT = "radio",
												CT = "YYYY-MM-DDThh:mm:ss.sTZD",
												PI = "Sign",
												PTY = 1,
												TP = true,
												TA = true,
												REG = "Murica"
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
									}	
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.2
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.2.3
			--Description: application sends GetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:GetInterior_RightRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 1,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 1,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99,
											frequencyFraction = 3,
											band = "FM",
											rdsData = {
												PS = "name",
												RT = "radio",
												CT = "YYYY-MM-DDThh:mm:ss.sTZD",
												PI = "Sign",
												PTY = 1,
												TP = true,
												TA = true,
												REG = "Murica"
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
									}	
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.3
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.4
			--Description: application sends GetInteriorVehicleData as Not Existed and ModuleType = RADIO
				function Test:GetInterior_NotExistedRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 2,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 2,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99,
											frequencyFraction = 3,
											band = "FM",
											rdsData = {
												PS = "name",
												RT = "radio",
												CT = "YYYY-MM-DDThh:mm:ss.sTZD",
												PI = "Sign",
												PTY = 1,
												TP = true,
												TA = true,
												REG = "Murica"
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
									}	
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.4
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.5
			--Description: application sends GetInteriorVehicleData as Front Passenger and ModuleType = CLIMATE
				function Test:GetInterior_FrontCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 1,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.5
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.2.6
			--Description: application sends GetInteriorVehicleData as Back Left and ModuleType = CLIMATE
				function Test:GetInterior_LeftCLIMATE()
					--mobile sends request for precondition
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
					
					--hmi side: expect RC.GetInteriorVehicleData request
					EXPECT_HMICALL("RC.GetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.GetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.6
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.7
			--Description: application sends GetInteriorVehicleData as Back Right and ModuleType = CLIMATE
				function Test:GetInterior_RightCLIMATE()
					--mobile sends request for precondition
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
								col = 1,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.7
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.8
			--Description: application sends GetInteriorVehicleData as Not Existed and ModuleType = CLIMATE
				function Test:GetInterior_NotExistedCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 2,
										rowspan = 2,
										col = 2,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.8
			
		-----------------------------------------------------------------------------------------

		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.2.9
			--Description: application sends GetInteriorVehicleData as Driver and ModuleType = CLIMATE
				function Test:GetInterior_DriverCLIMATE()
					--mobile sends request for precondition
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
								col = 1,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.9
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.10
			--Description: application sends GetInteriorVehicleData as Back Left and ModuleType = CLIMATE
				function Test:GetInterior_LeftCLIMATE()
					--mobile sends request for precondition
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
					
					--hmi side: expect RC.GetInteriorVehicleData request
					EXPECT_HMICALL("RC.GetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.GetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.10
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.2.2.11
			--Description: application sends GetInteriorVehicleData as Back Right and ModuleType = CLIMATE
				function Test:GetInterior_RightCLIMATE()
					--mobile sends request for precondition
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
								col = 1,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.11
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.12
			--Description: application sends GetInteriorVehicleData as Not Existed and ModuleType = CLIMATE
				function Test:GetInterior_NotExistedCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 2,
										rowspan = 2,
										col = 2,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.2.12
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.2
		
		
	--Begin Test case CommonRequestCheck.2.3
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827				

		--Verification criteria: 
				--RSDL must send this RPC with these <params> to the vehicle (HMI). 

		-----------------------------------------------------------------------------------------
				
		------------------------------FOR DRIVER ZONE-----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Driver)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Driver()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger and ModuleType = RADIO
				function Test:SetInterior_FrontRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})

					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 1,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 0,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99,
											frequencyFraction = 3,
											band = "FM",
											rdsData = {
												PS = "name",
												RT = "radio",
												CT = "YYYY-MM-DDThh:mm:ss.sTZD",
												PI = "Sign",
												PTY = 1,
												TP = true,
												TA = true,
												REG = "Murica"
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
									}	
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.1
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.3.2
			--Description: application sends SetInteriorVehicleData as Back Left and ModuleType = RADIO
				function Test:SetInterior_LeftRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})

					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 0,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 1,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99,
											frequencyFraction = 3,
											band = "FM",
											rdsData = {
												PS = "name",
												RT = "radio",
												CT = "YYYY-MM-DDThh:mm:ss.sTZD",
												PI = "Sign",
												PTY = 1,
												TP = true,
												TA = true,
												REG = "Murica"
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
									}	
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.2
		
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.3
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:SetInterior_RightRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})

					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 1,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 1,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99,
											frequencyFraction = 3,
											band = "FM",
											rdsData = {
												PS = "name",
												RT = "radio",
												CT = "YYYY-MM-DDThh:mm:ss.sTZD",
												PI = "Sign",
												PTY = 1,
												TP = true,
												TA = true,
												REG = "Murica"
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
									}	
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.3
		
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.4
			--Description: application sends SetInteriorVehicleData as Not Existed and ModuleType = RADIO
				function Test:SetInterior_NotExistedRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 2,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 2,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})

					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 2,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 2,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99,
											frequencyFraction = 3,
											band = "FM",
											rdsData = {
												PS = "name",
												RT = "radio",
												CT = "YYYY-MM-DDThh:mm:ss.sTZD",
												PI = "Sign",
												PTY = 1,
												TP = true,
												TA = true,
												REG = "Murica"
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
									}	
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.4
		
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.2.3.5
			--Description: application sends SetInteriorVehicleData as Front Passenger and ModuleType = CLIMATE
				function Test:SetInterior_FrontCLIMATE()
					--mobile sends request for precondition
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
								col = 1,
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
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
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
										col = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.5
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.2.3.6
			--Description: application sends SetInteriorVehicleData as Back Left and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
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
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.6
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.7
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = CLIMATE
				function Test:SetInterior_RightCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
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
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.7
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.8
			--Description: application sends SetInteriorVehicleData as Not Existed and ModuleType = CLIMATE
				function Test:SetInterior_NotExistedCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 2,
										rowspan = 2,
										col = 2,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.8
			
		-----------------------------------------------------------------------------------------		
		
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.9
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = CLIMATE
				function Test:SetInterior_DriverCLIMATE()
					--mobile sends request for precondition
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
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
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
										currentTemp = 30,
										defrostZone = "FRONT",
										acEnable = true,
										desiredTemp = 24,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
							})
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.9
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.10
			--Description: application sends GetInteriorVehicleData as Back Left and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
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
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.10
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.3.11
			--Description: application sends GetInteriorVehicleData as Back Right and ModuleType = CLIMATE
				function Test:SetInterior_RightCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
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
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 1,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.11
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.12
			--Description: application sends GetInteriorVehicleData as Not Existed and ModuleType = CLIMATE
				function Test:SetInterior_NotExistedCLIMATE()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 2,
										rowspan = 2,
										col = 2,
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
						end)
					
					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.12
			
		-----------------------------------------------------------------------------------------		

		------------------------------FOR RIGHT PASSENGER ZONE-----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Right Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Right()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.3.13
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:SetInterior_DriverRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}			
					})

					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 0,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 0,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.13
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.14
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger and ModuleType = RADIO
				function Test:SetInterior_LeftRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}			
					})

					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 0,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 1,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.14
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.15
			--Description: application sends GetInteriorVehicleData as Front Passenger and ModuleType = RADIO
				function Test:SetInterior_FrontRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}			
					})

					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 1,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 0,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.15
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.16
			--Description: application sends GetInteriorVehicleData as Not Existed and ModuleType = RADIO
				function Test:SetInterior_NotExistedRADIO()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 2,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 2,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}			
					})

					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData = {
										moduleType = "RADIO",
										moduleZone = {
											col = 2,
											colspan = 2,
											level = 0,
											levelspan = 1,
											row = 2,
											rowspan = 2
										},
										radioControlData = {
											frequencyInteger = 99
											},
											availableHDs = 3,
											hdChannel = 1,
											signalStrength = 50,
											signalChangeThreshold = 60,
											radioEnable = true,
											state = "ACQUIRING"
										}
							})
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case CommonRequestCheck.2.3.16
			
		-----------------------------------------------------------------------------------------		
		
	--End Test case CommonRequestCheck.2.3
		
--=================================================END TEST CASES 2==========================================================--
	
	



--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: 3. In case an RC application from <deviceID> device sends a valid rc-RPC with <app-provided interiorZone>, <moduleType> and <params> allowed by app's assigned policies 
							-- and RSDL has received RC.OnDeviceLocationChanged(<deviceID>, <HMI-provided interiorZone>) from HMI 
							-- and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <HMI-provided interiorZone> section 
							-- and driver's permission has not yet been obtained for this app&<interiorZone>&<moduleType> 
							-- RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI). 
	

	--Begin Test case CommonRequestCheck.3.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827				

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI)

		-----------------------------------------------------------------------------------------		
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.3.1.1
			--Description: application sends ButtonPress as Driver zone and ModuleType = RADIO
				function Test:ButtonPress_DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.1.1
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Back Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.2
			--Description: application sends ButtonPress as Back Right and ModuleType = CLIMATE
				function Test:ButtonPress_RightCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
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
												moduleType = "CLIMATE",
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.1.2
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.1
	
		
	--Begin Test case CommonRequestCheck.3.2 (Stop SDL before running this test suite)
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI)

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.3.2.1
			--Description: application sends GetInteriorVehicleData as Back Left and ModuleType = RADIO
				function Test:GetInterior_LeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
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
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.2.1
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Back Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.2.2
			--Description: application sends GetInteriorVehicleData as Right Rare Passenger (col=1, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_LeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
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
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.2.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.3
			--Description: application sends GetInteriorVehicleData as Not existed zone (col=2, row=2, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_LeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 100,
								rowspan = 2,
								col = 100,
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 100,
												rowspan = 2,
												col = 100,
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
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.2.3
		
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.3.2
		
		
	--Begin Test case CommonRequestCheck.3.3 (Stop SDL before running this test suite)
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI)

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.3.3.1
			--Description: application sends SetInteriorVehicleData as not exists zone (col=100, row=100, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 100,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 100,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 100,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 100,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.3.1
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Back Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.3.2
			--Description: application sends SetInteriorVehicleData as Right Rare Passenger (col=1, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_LeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.3.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.3.3
			--Description: application sends SetInteriorVehicleData as not existed (col=100, row=100, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 100,
								rowspan = 2,
								col = 100,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 100,
												rowspan = 2,
												col = 100,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.3.3
		
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.3.3
		
--=================================================END TEST CASES 3==========================================================--
	




--THE "TEST CASES 3" IS INCLUDING THIS REQUIREMENT
--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for Req.#4

	--Description: 4. In case an RC application from <deviceID> device sends a valid rc-RPC with <app-provided interiorZone>, <moduleType> and <params> allowed by app's assigned policies 
						-- and RSDL has received RC.OnDeviceLocationChanged(<deviceID>, <HMI-provided interiorZone>) from HMI 
						-- and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <HMI-provided interiorZone> section 
						-- and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent 
						-- RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
	

	--Begin Test case CommonRequestCheck.4.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827				

		--Verification criteria: 
				--RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).

--=================================================END TEST CASES 4==========================================================--	





--=================================================BEGIN TEST CASES 5==========================================================--
	--Begin Test suit CommonRequestCheck.5 for Req.#5

	--Description: 5. In case an RC application from <deviceID> device sends a valid rc-RPC with <app-provided interiorZone>, <moduleType> and <params> allowed by app's assigned policies 
						-- and RSDL has received RC.OnDeviceLocationChanged(<deviceID>, <HMI-provided interiorZone>) from HMI 
						-- and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <HMI-provided interiorZone> section 
						-- and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent 
						-- and RSDL has processed this app's initial RPC 
						-- RSDL must further process rc-RPCs from the same app for the same <moduleType> and any <app-provided interiorZone>
	

	--Begin Test case CommonRequestCheck.5.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827				

		--Verification criteria: 
				--RSDL must further process rc-RPCs from the same app for the same <moduleType> and any <app-provided interiorZone>

		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.5.1.1
			--Description: application sends ButtonPress as Left Rare Passenger and ModuleType = CLIMATE
				function Test:ButtonPress_LeftCLIMATE_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 1,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 1,
													rowspan = 2,
													col = 0,
													levelspan = 1,
													level = 0
												},
												moduleType = "CLIMATE",
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.1				

		-----------------------------------------------------------------------------------------
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				

			--Begin Test case CommonRequestCheck.5.1.1
			--Description: application sends ButtonPress as Driver Rare Passenger and ModuleType = CLIMATE
				function Test:ButtonPress_DriverCLIMATE_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.1
		
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.5.1.2
			--Description: application sends GetInteriorVehicleData as Right Rare Passenger (col=1, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_RightCLIMATE()
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
								col = 1,
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 1,
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
							
					end)
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.1.3
			--Description: application sends SetInteriorVehicleData as Not existed (col=100, row=100, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 100,
								rowspan = 2,
								col = 100,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 100,
												rowspan = 2,
												col = 100,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.3
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.1.4
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (asking permission)
				function Test:SetInterior_LeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.4
		
		-----------------------------------------------------------------------------------------		
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.5
			--Description: application sends ButtonPress as not existed zone and ModuleType = CLIMATE
				function Test:SetInterior_FrontRADIO_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 100,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 100,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 100,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 100,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.5
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.1
	
--=================================================END TEST CASES 5==========================================================--






--=================================================BEGIN TEST CASES 6==========================================================--
	--Begin Test suit CommonRequestCheck.6 for Req.#6

	--Description: 6. In case an RC application from <deviceID> device has driver's permission to control <moduleType> from <HMI-provided interiorZone> (via RC.OnDeviceLocationChanged from HMI) 
						-- and any application from the same device sends an rc-RPC for controlling a different <moduleType> 
						-- RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).
	

	--Begin Test case CommonRequestCheck.6.1
	--Description: 	RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1858

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------		
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger) (col=0, row=1, level=0)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocationDevice1_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.1.1
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:GetInterior_DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.6.1.1
		
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.6.1.2
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = CLIMATE (different moduleType and the same app)
				function Test:SetInterior_RightCLIMATE_SamneApp()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 1,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.6.1.2
		
		-----------------------------------------------------------------------------------------	
	--End Test case CommonRequestCheck.6.1


		
	--Begin Test case CommonRequestCheck.6.2
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1858

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).
				
		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.6.2.1
			--Description: Register new sessions
				function Test:PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self.expectations_list,
						self.mobileConnection)
				end
			--End Test case Precondition.6.2.1

		-----------------------------------------------------------------------------------------
			
			--Begin Test case Precondition.6.2.2
			--Description: Register App1 for precondition
					function Test:TC6_PassengerDevice_App1()
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
								
							end)
						end
			--End Test case Precondition.6.2.2	

		-----------------------------------------------------------------------------------------				

		-----------------------------------------------------------------------------------------		
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger) (col=0, row=1, level=0)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocationDevice1_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.2.1
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:GetInterior_DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.6.2.1
		
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.6.2.2
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = CLIMATE (different moduleType app2)
				function Test:SetInterior_RightCLIMATE_App2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession1:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application1"],
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 1,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.6.2.2
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.6.2		
	
--=================================================END TEST CASES 6==========================================================--






--=================================================BEGIN TEST CASES 7==========================================================--
	--Begin Test suit CommonRequestCheck.7 for Req.#7

	--Description: 7. In case an RC application from <deviceID> device has driver's permission to control <moduleType> from <HMI-provided interiorZone> (via RC.OnDeviceLocationChanged from HMI) 
						-- and any application from the same device sends an rc-RPC for controlling a different <moduleType> 
						-- RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).
	

	--Begin Test case CommonRequestCheck.7.1
	--Description: 	RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1858

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).
				
		----------------------------------------------------------------------------------------- 
				
			--Begin Test case CommonRequestCheck.7.1.1
			--Description: Connecting Device2 to RSDL
			function Test:TC7_ConnectDevice2()
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case CommonRequestCheck.7.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.7.1.2
			--Description: Register App2 from Device2
			   function Test:TC7_App2Device2() 

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
							appName ="App2",
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
							appID ="1234569",
						   
						   })

				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				  end)    

			   end
			--End Test case CommonRequestCheck.7.1.2	

		-----------------------------------------------------------------------------------------		
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger) (col=0, row=1, level=0)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocationDevice1_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.1.1
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:GetInterior_App1DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.7.1.1
		
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger) (col=0, row=1, level=0)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocationDevice2_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = device2, id = 2, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.1.2
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = CLIMATE (different moduleType and the same app)
				function Test:SetInterior_App2RightCLIMATE_ReceivedChangedLocation()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession21:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["App2"],
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 1,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					self.mobileSession21:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.7.1.2
		
		-----------------------------------------------------------------------------------------	
	--End Test case CommonRequestCheck.7.1
	


	--Begin Test case CommonRequestCheck.7.2
	--Description: 	RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1858

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).
				
		----------------------------------------------------------------------------------------- 
				
			--Begin Test case CommonRequestCheck.7.1.1
			--Description: Connecting Device2 to RSDL
			function Test:TC7_ConnectDevice2()
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case CommonRequestCheck.7.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.7.1.2
			--Description: Register App2 from Device2
			   function Test:TC7_App2Device2() 

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
							appName ="App2",
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
							appID ="1234569",
						   
						   })

				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				  end)    

			   end
			--End Test case CommonRequestCheck.7.1.2
			
		-----------------------------------------------------------------------------------------		
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger) (col=0, row=1, level=0)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocationDevice1_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.2.1
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:GetInterior_App1DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.7.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.2.2
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = CLIMATE (different moduleType and the same app)
				function Test:SetInterior_App2RightCLIMATE_NonReceivedChangedLocation()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession21:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 1,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["App2"],
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
						
						--hmi side: expect Buttons.ButtonPress request
						EXPECT_HMICALL("Buttons.ButtonPress", 
										{ 
											zone =
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 0,
												levelspan = 1,
												level = 0
											},
											moduleType = "CLIMATE",
											buttonPressMode = "SHORT",
											buttonName = "LOWER_VENT"
						})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)
					end)								
					
					self.mobileSession21:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.7.2.2
		
		-----------------------------------------------------------------------------------------	
	--End Test case CommonRequestCheck.7.2		
		
	
--=================================================END TEST CASES 7==========================================================--






--=================================================BEGIN TEST CASES 8==========================================================--
	--Begin Test suit CommonRequestCheck.8 for Req.#8

	--Description: 8. In case an RC application from <deviceID> device sends a valid rc-RPC with <app-provided interiorZone>, <moduleType> and <params> allowed by app's assigned policies 
							-- and RSDL has received RC.OnDeviceLocationChanged(<deviceID>, <HMI-provided interiorZone>) from HMI 
							-- and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <HMI-provided interiorZone> section 
							-- and the vehicle (HMI) responds with "allowed: false" for RSDL's RC.GetInteriorVehicleDataConsent 
							-- RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application. 
	

	--Begin Test case CommonRequestCheck.8.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827				

		--Verification criteria: 
				--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application. 

		-----------------------------------------------------------------------------------------		
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.8.1.1
			--Description: application sends ButtonPress as Driver zone and ModuleType = RADIO
				function Test:ButtonPress_DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
						self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					
				end
			--End Test case CommonRequestCheck.8.1.1
			
		-----------------------------------------------------------------------------------------		
		-------------------------FOR BACK LEFT PASSENGER ZONE------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Back Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.8.1.2
			--Description: application sends ButtonPress as Back Right and ModuleType = CLIMATE
				function Test:ButtonPress_RightCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.8.1.2
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.8.1
	
		
	--Begin Test case CommonRequestCheck.8.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				

		--Verification criteria: 
				--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application. 

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.8.2.1
			--Description: application sends GetInteriorVehicleData as Back Left and ModuleType = RADIO (first time, asking permission)
				function Test:GetInterior_LeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
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
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					
				end
			--End Test case CommonRequestCheck.8.2.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.8.2.2
			--Description: application sends GetInteriorVehicleData as Back Left and ModuleType = RADIO (second time, continuing ask permission)
				function Test:GetInterior_LeftRADIO_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
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
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					
				end
			--End Test case CommonRequestCheck.8.2.2
			
		-----------------------------------------------------------------------------------------

		
--=================================================END TEST CASES 8==========================================================--






--=================================================BEGIN TEST CASES 9==========================================================--
	--Begin Test suit CommonRequestCheck.9 for Req.#9

	--Description: 9. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies 
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section 
						--and the vehicle (HMI) responds with "disallow" for RC.GetInteriorVehicleDataConsent 
						--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
	

	--Begin Test case CommonRequestCheck.9.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1861

		--Verification criteria: 
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies 

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.9.1.1
			--Description: application sends ButtonPress as Driver Passenger and ModuleType = RADIO
				function Test:ButtonPress_DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
														col = 0,
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
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.9.1.1
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1		
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.9.1.2
			--Description: application sends ButtonPress as Back Right and ModuleType = CLIMATE
				function Test:ButtonPress_RightCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
							local function HMIResponse()						
									--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
									self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
									
									--hmi side: expect Buttons.ButtonPress request
									EXPECT_HMICALL("Buttons.ButtonPress", 
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
														moduleType = "CLIMATE",
														buttonPressMode = "SHORT",
														buttonName = "LOWER_VENT"
									})
									:Times(0)
							end

							RUN_AFTER(HMIResponse, 10000)									
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.9.1.2
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.9.1
	
		
	--Begin Test case CommonRequestCheck.9.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1861

		--Verification criteria: 
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies 

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------			
				
			--Begin Test case CommonRequestCheck.9.2.1
			--Description: application sends GetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:GetInterior_RightRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true							
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
									
									--hmi side: expect RC.GetInteriorVehicleData request
									EXPECT_HMICALL("RC.GetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.GetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData = {
														moduleType = "RADIO",
														moduleZone = {
															col = 1,
															colspan = 2,
															level = 0,
															levelspan = 1,
															row = 1,
															rowspan = 2
														},
														radioControlData = {
															frequencyInteger = 99,
															frequencyFraction = 3,
															band = "FM",
															rdsData = {
																PS = "name",
																RT = "radio",
																CT = "YYYY-MM-DDThh:mm:ss.sTZD",
																PI = "Sign",
																PTY = 1,
																TP = true,
																TA = true,
																REG = "Murica"
															},
															availableHDs = 3,
															hdChannel = 1,
															signalStrength = 50,
															signalChangeThreshold = 60,
															radioEnable = true,
															state = "ACQUIRING"
														}
													}	
									})
											
									end)
							end

							RUN_AFTER(HMIResponse, 10000)									
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.9.2.1
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1		
		
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.9.2.2
			--Description: application sends GetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:GetInterior_RightRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true							
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							local function HMIResponse()						
									--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
									self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
									
									--hmi side: expect RC.GetInteriorVehicleData request
									EXPECT_HMICALL("RC.GetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.GetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData = {
														moduleType = "RADIO",
														moduleZone = {
															col = 1,
															colspan = 2,
															level = 0,
															levelspan = 1,
															row = 1,
															rowspan = 2
														},
														radioControlData = {
															frequencyInteger = 99,
															frequencyFraction = 3,
															band = "FM",
															rdsData = {
																PS = "name",
																RT = "radio",
																CT = "YYYY-MM-DDThh:mm:ss.sTZD",
																PI = "Sign",
																PTY = 1,
																TP = true,
																TA = true,
																REG = "Murica"
															},
															availableHDs = 3,
															hdChannel = 1,
															signalStrength = 50,
															signalChangeThreshold = 60,
															radioEnable = true,
															state = "ACQUIRING"
														}
													}	
											})
											
									end)
							end

							RUN_AFTER(HMIResponse, 10000)									
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.9.2.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.9.2.3
			--Description: application sends GetInteriorVehicleData as Not Existed zone and ModuleType = CLIMATE
				function Test:GetInterior_NotExistedCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true							
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
							local function HMIResponse()						
									--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
									self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
									
									--hmi side: expect RC.GetInteriorVehicleData request
									EXPECT_HMICALL("RC.GetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.GetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
												moduleData =
												{
													moduleType = "CLIMATE",
													moduleZone = 
													{
														colspan = 2,
														row = 2,
														rowspan = 2,
														col = 2,
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
											
									end)
							end

							RUN_AFTER(HMIResponse, 10000)									
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.9.2.3
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.9.2
		
		
	--Begin Test case CommonRequestCheck.9.3
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1861

		--Verification criteria: 
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies 

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.9.3.1
			--Description: application sends SetInteriorVehicleData as Back Left and ModuleType = RADIO
				function Test:SetInterior_BackLeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
									
									--hmi side: expect RC.SetInteriorVehicleData request
									EXPECT_HMICALL("RC.SetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.SetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData = {
														moduleType = "RADIO",
														moduleZone = {
															col = 0,
															colspan = 2,
															level = 0,
															levelspan = 1,
															row = 1,
															rowspan = 2
														},
														radioControlData = {
															frequencyInteger = 99,
															frequencyFraction = 3,
															band = "FM",
															rdsData = {
																PS = "name",
																RT = "radio",
																CT = "YYYY-MM-DDThh:mm:ss.sTZD",
																PI = "Sign",
																PTY = 1,
																TP = true,
																TA = true,
																REG = "Murica"
															},
															availableHDs = 3,
															hdChannel = 1,
															signalStrength = 50,
															signalChangeThreshold = 60,
															radioEnable = true,
															state = "ACQUIRING"
														}
													}	
											})
											
										end)
							end

							RUN_AFTER(HMIResponse, 10000)										
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.9.3.1
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1		
		
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.9.3.2
			--Description: application sends SetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:SetInterior_DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							local function HMIResponse()						
									--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
									self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
									
									--hmi side: expect RC.SetInteriorVehicleData request
									EXPECT_HMICALL("RC.SetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.SetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData = {
														moduleType = "RADIO",
														moduleZone = {
															col = 0,
															colspan = 2,
															level = 0,
															levelspan = 1,
															row = 0,
															rowspan = 2
														},
														radioControlData = {
															frequencyInteger = 99,
															frequencyFraction = 3,
															band = "FM"
														}
													}	
											})
											
										end)
							end

							RUN_AFTER(HMIResponse, 10000)										
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.9.3.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.9.3.3
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = CLIMATE
				function Test:SetInterior_DriverAllowLeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
							local function HMIResponse()						
									--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
									self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
									
									--hmi side: expect RC.SetInteriorVehicleData request
									EXPECT_HMICALL("RC.SetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.SetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
												moduleData =
												{
													moduleType = "CLIMATE",
													moduleZone = 
													{
														colspan = 2,
														row = 1,
														rowspan = 2,
														col = 1,
														levelspan = 1,
														level = 0
													},
													climateControlData =
													{
														fanSpeed = 50,
														desiredTemp = 24,
														temperatureUnit = "CELSIUS"
													}
												}
											})
											
										end)
							end

							RUN_AFTER(HMIResponse, 10000)										
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.9.3.3
		
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.9.3
		
--=================================================END TEST CASES 9==========================================================--





--=================================================BEGIN TEST CASES 10==========================================================--
	--Begin Test suit CommonRequestCheck.10 for Req.#10

	--Description: 10. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies 
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section 
						--and the vehicle (HMI) responds with any erroneous resultCode for RC.GetInteriorVehicleDataConsent 
						--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
	

	--Begin Test case CommonRequestCheck.10.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1861

		--Verification criteria: 
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies 

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.10.1.1
			--Description: application sends ButtonPress as Driver zone and ModuleType = RADIO
				function Test:ButtonPress_DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
													col = 0,
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
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.1.1
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1		
		
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.10.1.2
			--Description: application sends ButtonPress as Back Right and ModuleType = CLIMATE
				function Test:ButtonPress_RightCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "ERROR", {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
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
												moduleType = "CLIMATE",
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
							})
							:Times(0)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.1.2
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.10.1
	
		
	--Begin Test case CommonRequestCheck.10.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1861

		--Verification criteria: 
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies 

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.10.2.1
			--Description: application sends GetInteriorVehicleData as Driver Passenger and ModuleType = RADIO
				function Test:GetInterior_DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "", {allowed = true})
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
							})
									
							end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.2.1
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1		
		
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.10.2.2
			--Description: application sends GetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:GetInterior_RightRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true							
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", 123, {allowed = true})
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.2.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.10.2.3
			--Description: application sends GetInteriorVehicleData as Not Existed zone and ModuleType = CLIMATE
				function Test:GetInterior_NotExistedCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true							
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", true, {allowed = true})
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 2,
												rowspan = 2,
												col = 2,
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
									
							end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.2.3
		
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.10.2
		
		
	--Begin Test case CommonRequestCheck.10.3
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1861

		--Verification criteria: 
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies 

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.10.3.1
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:SetInterior_RightRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "RADIO", {allowed = true})
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.3.1
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1		
		
		-----------------------------------------------------------------------------------------			

			--Begin Test case CommonRequestCheck.10.3.2
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:SetInterior_RightRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "reboot", {allowed = true})
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.3.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.10.3.3
			--Description: application sends SetInteriorVehicleData as Driver zone and ModuleType = CLIMATE
				function Test:SetInterior_DriverCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", {}, {allowed = true})
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Times(0)
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
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.3.3
		
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.10.3
		
--=================================================END TEST CASES 10==========================================================--







--=================================================BEGIN TEST CASES 11==========================================================--
	--Begin Test suit CommonRequestCheck.6 for Req.#6

	--Description: 11. In case an RC application from <deviceID> device has driver's permission to control <moduleType> from <HMI-provided interiorZone> (via RC.OnDeviceLocationChanged from HMI) 
							-- and different application from the same device sends an rc-RPC for controlling the same <moduleType> 
							-- RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance for this different application to the vehicle (HMI).

		
	--Begin Test case CommonRequestCheck.11.1
	--Description: 	RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance for this different application to the vehicle (HMI).

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1863

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance for this different application to the vehicle (HMI).
				
		-----------------------------------------------------------------------------------------
				
			--Begin Test case Precondition.11.1.1
			--Description: Register new sessions
				function Test:TC11_PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self.expectations_list,
						self.mobileConnection)
				end
			--End Test case Precondition.11.1.1

		-----------------------------------------------------------------------------------------
			
			--Begin Test case Precondition.11.1.2
			--Description: Register App1 for precondition
					function Test:TC11_PassengerDevice_App1()
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
								
							end)
						end
			--End Test case Precondition.11.1.2	

		-----------------------------------------------------------------------------------------		
		-------------------------FOR LEFT PASSENGER ZONE-----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger) (col=0, row=1, level=0)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:TC11_ChangedLocationDevice1_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.1.1
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:TC11_GetInterior_DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.11.1.1
		
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.11.1.2
			--Description: application sends SetInteriorVehicleData as Right Rare Passenger (col=1, row=1, level=0) and ModuleType = RADIO
				function Test:TC11_SetInterior_LeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession1:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application1"],
									moduleType = "RADIO",
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.11.1.2
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.11.1		
		
	
--=================================================END TEST CASES 11==========================================================--





--=================================================BEGIN TEST CASES 12==========================================================--
	--Begin Test suit CommonRequestCheck.12 for Req.#12

	--Description: 12. In case an RC application from <deviceID> device has driver's permission to control <moduleType> from <HMI-provided interiorZone> (via RC.OnDeviceLocationChanged from HMI) 
							-- and different application from different device sends an rc-RPC for controlling the same <moduleType> 
							-- RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this different <moduleType> to the vehicle (HMI).
	

	--Begin Test case CommonRequestCheck.12.1
	--Description: 	RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this same <moduleType> to the vehicle (HMI).
					--In case received OnDeviceLocationChanged for device_2

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1864

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this same <moduleType> to the vehicle (HMI).
				
		----------------------------------------------------------------------------------------- 
				
			--Begin Test case CommonRequestCheck.12.1.1
			--Description: Connecting Device2 to RSDL
			function Test:TC12_ConnectDevice2()
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case CommonRequestCheck.12.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.12.1.2
			--Description: Register App2 from Device2
			   function Test:TC12_App2Device2() 

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
							appName ="App2",
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
							appID ="1234569",
						   
						   })

				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				  end)    

			   end
			--End Test case CommonRequestCheck.12.1.2

		-----------------------------------------------------------------------------------------		
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger) (col=0, row=1, level=0)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:TC12_ChangedLocationDevice1_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.12.1.1
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:TC12_GetInterior_App1DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.12.1.1
		
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger) (col=0, row=1, level=0)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:TC12_ChangedLocationDevice2_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = device2, id = 2, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.12.1.2
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = RADIO (same moduleType and different device)
				function Test:TC12_SetInterior_App2RightRADIO_ReceivedChangedLocation()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession21:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["App2"],
									moduleType = "RADIO",
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					self.mobileSession21:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.12.1.2
		
		-----------------------------------------------------------------------------------------	
	--End Test case CommonRequestCheck.12.1
	


	--Begin Test case CommonRequestCheck.12.2 (have to STOP SDL after running CommonRequestCheck.12.1)
	--Description: 	RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this same <moduleType> to the vehicle (HMI).
					--In case non-received OnDeviceLocationChanged for device_2

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1864

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to control this dame <moduleType> to the vehicle (HMI).
				
		----------------------------------------------------------------------------------------- 
				
			--Begin Test case CommonRequestCheck.12.1.1
			--Description: Connecting Device2 to RSDL
			function Test:TC12_ConnectDevice2()
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case CommonRequestCheck.12.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.12.1.2
			--Description: Register App2 from Device2
			   function Test:TC12_App2Device2() 

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
							appName ="App3",
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
							appID ="123458",
						   
						   })

				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				  end)    

			   end
			--End Test case CommonRequestCheck.12.1.2
			
		-----------------------------------------------------------------------------------------		
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Left Passenger) (col=0, row=1, level=0)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:TC12_ChangedLocationDevice1_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.12.2.1
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:TC12_GetInterior_App1DriverRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.12.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.12.2.2
			--Description: application sends SetInteriorVehicleData as Back Left and ModuleType = RADIO (same moduleType and the different device)
				function Test:TC12_SetInterior_App2LeftRADIO_NonReceivedChangedLocation()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession21:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["App3"],
									moduleType = "RADIO",
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					self.mobileSession21:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.12.2.2
		
		-----------------------------------------------------------------------------------------	
	--End Test case CommonRequestCheck.12.2	
		
	
--=================================================END TEST CASES 12==========================================================--








--=================================================BEGIN TEST CASES 13==========================================================--
	--Begin Test suit CommonRequestCheck.13 for Req.#13

	--Description: 13. In case an RC application from <deviceID> device has obtained denial (= either "allowed:false", or timed out, or non-responded GetInteriorVehicleDataConsent) to control <moduleType> from <HMI-provided interiorZone> (via RC.OnDeviceLocationChanged from HMI) 
							-- and the same application from the same device sends an rc-RPC for controlling the same <moduleType> 
							-- RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
	

	--Begin Test case CommonRequestCheck.13.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1865

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.13.1.1
			--Description: application sends ButtonPress as Driver zone and ModuleType = RADIO (first time)
				function Test:ButtonPress_FrontRADIO_DriverDenied()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
							
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
								:Times(0)
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.13.1.2
			--Description: application sends ButtonPress as Back Left and ModuleType = RADIO (first time)
				function Test:ButtonPress_FrontRADIO_Error()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 1,
							rowspan = 2,
							col = 0,
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "ERROR", {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 1,
													rowspan = 2,
													col = 0,
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
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.1.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.13.1.3
			--Description: application sends ButtonPress as Back Right and ModuleType = RADIO
				function Test:ButtonPress_FrontRADIO_TimeOut()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
								:Times(0)
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
							end

							RUN_AFTER(HMIResponse, 10000)							
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.13.1.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.13.1.4
			--Description: application sends ButtonPress as Not Existed zone and ModuleType = RADIO (first time)
				function Test:ButtonPress_FrontRADIO_SUCCESS()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
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
													row = 2,
													rowspan = 2,
													col = 2,
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
					
					--RSDL must respond with "resultCode: SUCCESS, success: true
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.13.1.4
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.13.1.5
			--Description: application sends ButtonPress as Driver zone and ModuleType = CLIMATE
				function Test:ButtonPress_LeftCLIMATE_DriverDenied()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
							
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
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
								})
								:Times(0)
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.1.5
		
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.13.1.6
			--Description: application sends ButtonPress as Back Right and ModuleType = CLIMATE
				function Test:ButtonPress_LeftCLIMATE_Error()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "Error", {allowed = true})
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
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
												moduleType = "CLIMATE",
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
								})
								:Times(0)
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.1.6
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.13.1.7
			--Description: application sends ButtonPress as Front Passenger and ModuleType = CLIMATE
				function Test:ButtonPress_LeftCLIMATE_TimeOut()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
														moduleType = "CLIMATE",
														buttonPressMode = "SHORT",
														buttonName = "LOWER_VENT"
									})
									:Times(0)
							end

							RUN_AFTER(HMIResponse, 10000)									
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.13.1.7
		
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.13.1.8
			--Description: application sends ButtonPress as Not Existed and ModuleType = CLIMATE
				function Test:ButtonPress_LeftCLIMATE_Success()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 2,
													rowspan = 2,
													col = 2,
													levelspan = 1,
													level = 0
												},
												moduleType = "CLIMATE",
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.13.1.8
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.13.1
	
		
	--Begin Test case CommonRequestCheck.13.2 (have to STOP SDL after running CommonRequestCheck.13.1)
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1865

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI). 

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.13.2.1
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:GetInterior_FrontRADIO_DriverDenied()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.2.1
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.13.2.2
			--Description: application sends GetInteriorVehicleData as Back Left and ModuleType = RADIO
				function Test:GetInterior_FrontRADIO_Error()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", {}, {allowed = true})
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.2.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.13.2.3
			--Description: application sends GetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:GetInterior_FrontRADIO_TimeOut()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true							
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
									
									--hmi side: expect RC.GetInteriorVehicleData request
									EXPECT_HMICALL("RC.GetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.GetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData = {
														moduleType = "RADIO",
														moduleZone = {
															col = 1,
															colspan = 2,
															level = 0,
															levelspan = 1,
															row = 1,
															rowspan = 2
														},
														radioControlData = {
															frequencyInteger = 99,
															frequencyFraction = 3,
															band = "FM",
															rdsData = {
																PS = "name",
																RT = "radio",
																CT = "YYYY-MM-DDThh:mm:ss.sTZD",
																PI = "Sign",
																PTY = 1,
																TP = true,
																TA = true,
																REG = "Murica"
															},
															availableHDs = 3,
															hdChannel = 1,
															signalStrength = 50,
															signalChangeThreshold = 60,
															radioEnable = true,
															state = "ACQUIRING"
														}
													}	
									})
											
									end)
							end

							RUN_AFTER(HMIResponse, 10000)									
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.13.2.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.13.2.4
			--Description: application sends GetInteriorVehicleData as Not Existed and ModuleType = RADIO
				function Test:GetInterior_FrontRADIO_Sucess()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.13.2.4
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.13.2.5
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:GetInterior_LeftRADIO_DriverDenied()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.2.5
		
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.13.2.6
			--Description: application sends GetInteriorVehicleData as Front Passenger and ModuleType = RADIO
				function Test:GetInterior_LeftRADIO_Error()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
								col = 1,
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
									moduleType = "RADIO",
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", 123, {allowed = true})
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.2.6
		
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.13.2.7
			--Description: application sends GetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:GetInterior_LeftRADIO_TimeOut()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true							
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							local function HMIResponse()						
									--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
									self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
									
									--hmi side: expect RC.GetInteriorVehicleData request
									EXPECT_HMICALL("RC.GetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.GetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData = {
														moduleType = "RADIO",
														moduleZone = {
															col = 1,
															colspan = 2,
															level = 0,
															levelspan = 1,
															row = 1,
															rowspan = 2
														},
														radioControlData = {
															frequencyInteger = 99,
															frequencyFraction = 3,
															band = "FM",
															rdsData = {
																PS = "name",
																RT = "radio",
																CT = "YYYY-MM-DDThh:mm:ss.sTZD",
																PI = "Sign",
																PTY = 1,
																TP = true,
																TA = true,
																REG = "Murica"
															},
															availableHDs = 3,
															hdChannel = 1,
															signalStrength = 50,
															signalChangeThreshold = 60,
															radioEnable = true,
															state = "ACQUIRING"
														}
													}	
											})
											
									end)
							end

							RUN_AFTER(HMIResponse, 10000)									
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.13.2.7
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.13.2.8
			--Description: application sends GetInteriorVehicleData as Not Existed and ModuleType = RADIO
				function Test:GetInterior_LeftRADIO_Success()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.13.2.8
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.13.2.9
			--Description: application sends GetInteriorVehicleData as Driver zone and ModuleType = CLIMATE
				function Test:GetInterior_LeftCLIMATE_DriverDenied()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
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
												currentTemp = 30,
												defrostZone = "FRONT",
												acEnable = true,
												desiredTemp = 24,
												autoModeEnable = true,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
							end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.2.9
		
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.13.2.10
			--Description: application sends GetInteriorVehicleData as Front Passenger and ModuleType = CLIMATE
				function Test:GetInterior_LeftCLIMATE_Error()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 1,
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", true, {allowed = true})
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 0,
												rowspan = 2,
												col = 1,
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
									
							end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.2.10
		
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.13.2.11
			--Description: application sends GetInteriorVehicleData as Back Right and ModuleType = CLIMATE
				function Test:GetInterior_LeftCLIMATE_TimeOut()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
								col = 1,
								levelspan = 1,
								level = 0,
							}
						},
						subscribe = true							
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
							local function HMIResponse()						
									--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
									self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
									
									--hmi side: expect RC.GetInteriorVehicleData request
									EXPECT_HMICALL("RC.GetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.GetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
												moduleData =
												{
													moduleType = "CLIMATE",
													moduleZone = 
													{
														colspan = 2,
														row = 1,
														rowspan = 2,
														col = 1,
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
											
									end)
							end

							RUN_AFTER(HMIResponse, 10000)									
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.13.2.11
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.13.2.12
			--Description: application sends GetInteriorVehicleData as Not Existed and ModuleType = CLIMATE
				function Test:GetInterior_LeftCLIMATE_Success()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 2,
												rowspan = 2,
												col = 2,
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
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.13.2.12
		
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.13.2
		
		
	--Begin Test case CommonRequestCheck.13.3 (have to STOP SDL after running CommonRequestCheck.13.2)
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1865

		--Verification criteria: 
				--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI). 

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.13.3.1
			--Description: application sends SetInteriorVehicleData as Driver Zone and ModuleType = RADIO
				function Test:SetInterior_FrontRADIO_DriverDenied()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.3.1
			
		-----------------------------------------------------------------------------------------				
				
			--Begin Test case CommonRequestCheck.13.3.2
			--Description: application sends SetInteriorVehicleData as Back Left and ModuleType = RADIO
				function Test:SetInterior_FrontRADIO_Error()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", false, {allowed = true})
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.3.2
			
		-----------------------------------------------------------------------------------------				
				
			--Begin Test case CommonRequestCheck.13.3.3
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:SetInterior_FrontRADIO_TimeOut()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
									
									--hmi side: expect RC.SetInteriorVehicleData request
									EXPECT_HMICALL("RC.SetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.SetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData = {
														moduleType = "RADIO",
														moduleZone = {
															col = 1,
															colspan = 2,
															level = 0,
															levelspan = 1,
															row = 1,
															rowspan = 2
														},
														radioControlData = {
															frequencyInteger = 99,
															frequencyFraction = 3,
															band = "FM",
															rdsData = {
																PS = "name",
																RT = "radio",
																CT = "YYYY-MM-DDThh:mm:ss.sTZD",
																PI = "Sign",
																PTY = 1,
																TP = true,
																TA = true,
																REG = "Murica"
															},
															availableHDs = 3,
															hdChannel = 1,
															signalStrength = 50,
															signalChangeThreshold = 60,
															radioEnable = true,
															state = "ACQUIRING"
														}
													}	
											})
											
										end)
							end

							RUN_AFTER(HMIResponse, 10000)										
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.13.3.3
			
		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.13.3.4
			--Description: application sends SetInteriorVehicleData as Not Existed and ModuleType = RADIO
				function Test:SetInterior_FrontRADIO_Success()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 2,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 2,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.13.3.4
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.13.3.5
			--Description: application sends SetInteriorVehicleData as Driver zone and ModuleType = RADIO
				function Test:SetInterior_LeftRADIO_DriverDenied()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 0,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.3.5
		
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.13.3.6
			--Description: application sends SetInteriorVehicleData as Front Passenger and ModuleType = RADIO
				function Test:SetInterior_LeftRADIO_Error()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "", {allowed = true})
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Times(0)
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 0,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.3.6
		
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.13.3.7
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = RADIO
				function Test:SetInterior_LeftRADIO_TimeOut()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							local function HMIResponse()						
									--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
									self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
									
									--hmi side: expect RC.SetInteriorVehicleData request
									EXPECT_HMICALL("RC.SetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.SetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
													moduleData = {
														moduleType = "RADIO",
														moduleZone = {
															col = 1,
															colspan = 2,
															level = 0,
															levelspan = 1,
															row = 1,
															rowspan = 2
														},
														radioControlData = {
															frequencyInteger = 99,
															frequencyFraction = 3,
															band = "FM"
														}
													}	
											})
											
										end)
							end

							RUN_AFTER(HMIResponse, 10000)										
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.13.3.7
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.13.3.8
			--Description: application sends SetInteriorVehicleData as Not Existed zone and ModuleType = RADIO
				function Test:SetInterior_LeftRADIO_Success()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 2,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 2,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.13.3.8
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.13.3.9
			--Description: application sends SetInteriorVehicleData as Driver zone and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE_DriverDenied()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Times(0)
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
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.3.9
		
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.13.3.10
			--Description: application sends SetInteriorVehicleData as Front Passenger and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE_Error()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
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
								col = 1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "UNSUCCESS", {allowed = true})
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Times(0)
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
												col = 1,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.13.3.10
		
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.13.3.11
			--Description: application sends SetInteriorVehicleData as Back Right and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE_TimeOut()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})
					
					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
							local function HMIResponse()						
									--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
									self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})
									
									--hmi side: expect RC.SetInteriorVehicleData request
									EXPECT_HMICALL("RC.SetInteriorVehicleData")
									:Times(0)
									:Do(function(_,data)
											--hmi side: sending RC.SetInteriorVehicleData response
											self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
												moduleData =
												{
													moduleType = "CLIMATE",
													moduleZone = 
													{
														colspan = 2,
														row = 1,
														rowspan = 2,
														col = 1,
														levelspan = 1,
														level = 0
													},
													climateControlData =
													{
														fanSpeed = 50,
														desiredTemp = 24,
														temperatureUnit = "CELSIUS"
													}
												}
											})
											
										end)
							end

							RUN_AFTER(HMIResponse, 10000)										
					end)								
					
					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.13.3.12
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.13.3.13
			--Description: application sends SetInteriorVehicleData as Not Existed zone and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE_Success()
					--mobile side: RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 2,
												rowspan = 2,
												col = 2,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.13.3.13
		
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.13.3
		
--=================================================END TEST CASES 13==========================================================--







--=================================================BEGIN TEST CASES 14==========================================================--
	--Begin Test suit CommonRequestCheck.14 for Req.#14

	--Description: 14. In case an RC application from <deviceID> device has driver's permission to control <moduleType> from <HMI-provided interiorZone> (via RC.OnDeviceLocationChanged from HMI) 
							-- and RSDL gets BC.OnExitApplication (USER_EXIT) for this application from HMI 
							-- RSDL must take off the driver's permissions from this application (that is, trigger a permission prompt upon this app's next controlling request).
	

	--Begin Test case CommonRequestCheck.14.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1866

		--Verification criteria: 
				--RSDL must take off the driver's permissions from this application (that is, trigger a permission prompt upon this app's next controlling request).

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.14.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_FrontRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
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
													row = 2,
													rowspan = 2,
													col = 2,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.1.2
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.14.1.2

		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.14.1.3
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_FrontRADIO_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
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
													row = 2,
													rowspan = 2,
													col = 2,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.1.3
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.14.1.4
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_LeftCLIMATE_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 2,
													rowspan = 2,
													col = 2,
													levelspan = 1,
													level = 0
												},
												moduleType = "CLIMATE",
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.1.4
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.1.5
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.14.1.5

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.14.1.6
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_LeftCLIMATE_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 2,
													rowspan = 2,
													col = 0,
													levelspan = 1,
													level = 0
												},
												moduleType = "CLIMATE",
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.1.6
		
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.14.1
	
		
	--Begin Test case CommonRequestCheck.14.2 (have to STOP SDL after running CommonRequestCheck.14.1)
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1866

		--Verification criteria: 
				--RSDL must take off the driver's permissions from this application (that is, trigger a permission prompt upon this app's next controlling request).

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.14.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_FrontRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.2.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.2.2
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.14.2.2

		-----------------------------------------------------------------------------------------			
		
			--Begin Test case CommonRequestCheck.14.2.3
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_FrontRADIO_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.2.3
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.14.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_LeftRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.2.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.2.3
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.14.2.3

		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.14.2.4
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_LeftRADIO_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
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
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.2.4
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.2.5
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_LeftCLIMATE_Time1()
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
								col = 1,
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 1,
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
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.2.5
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.2.6
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.14.2.6

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.2.7
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_LeftCLIMATE_Time2()
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
								col = 1,
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 1,
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
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.2.7
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.14.2
		
		
	--Begin Test case CommonRequestCheck.14.3 (have to STOP SDL after running CommonRequestCheck.14.2)
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1866

		--Verification criteria: 
				--RSDL must take off the driver's permissions from this application (that is, trigger a permission prompt upon this app's next controlling request).

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.14.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_FrontRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.3.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.3.2
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.14.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.14.3.3
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_FrontRADIO_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.3.3
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.14.3.4
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_LeftRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.3.4
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.3.5
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.14.3.5

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.14.3.6
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_LeftRADIO_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 2,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 2,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.3.6
		
		-----------------------------------------------------------------------------------------
		
		
			--Begin Test case CommonRequestCheck.14.3.7
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 1,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.3.7
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.3.8
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})
					
					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)
				
				end
			--End Test case CommonRequestCheck.14.3.8

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.14.3.9
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 2,
												rowspan = 2,
												col = 2,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.14.3.9
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.14.3
		
--=================================================END TEST CASES 14==========================================================--







--=================================================BEGIN TEST CASES 15==========================================================--
	--Begin Test suit CommonRequestCheck.15 for Req.#15

	--Description: 15. In case an RC application from <deviceID> device sends a valid rc-RPC with <app-provided interiorZone>, <moduleType> and <params> allowed by app's assigned policies 
							-- and RSDL has received RC.OnDeviceLocationChanged(<deviceID>, <HMI-provided interiorZone>) from HMI 
							-- and "equipment" section of policies database omits this RPC name with <params> in <moduleType> in both "auro_allow" and "driver_allow" sub-sections of <HMI-provided interiorZone> sections 
							-- RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application (that is, without asking a driver for permission).

	--Begin Test case CommonRequestCheck.15.1
	--Description: 	RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application (that is, without asking a driver for permission).

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1867

		--Verification criteria: 
				--In case and "equipment" section of policies database omits this RPC name with <params> in <moduleType> in both "auro_allow" and "driver_allow" sub-sections of <HMI-provided interiorZone> sections 
				--RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application (that is, without asking a driver for permission).

		-----------------------------------------------------------------------------------------
		-------------------------FOR RIGHT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Back Right)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Right()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.15.1.1
			--Description: application sends ButtonPress as Back Left and ModuleType = CLIMATE (DISALLOWED)
				function Test:ButtonPress_CLIMATE_DISALLOWED()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 1,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
					})
					
					--hmi side: RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "CLIMATE",
									zone =
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
					})
					:Times(0)
						
								
					--RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
				end
			--End Test case CommonRequestCheck.15.1.1
		
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.15.1.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (DISALLOWED)
				function Test:GetInterior_CLIMATE_DISALLOWED()
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
					
					--hmi side: --hmi side: RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "CLIMATE",
									zone =
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
					})
					:Times(0)
								
					
					--RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
				end
			--End Test case CommonRequestCheck.15.1.2
		
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.15.1.3
			--Description: application sends SetInteriorVehicleData as Right Rare Passenger (col=1, row=1, level=0) and ModuleType = RADIO (DISSALLOWED)
				function Test:SetInterior_RightRADIO_DISSALLOWED()
					--mobile side: In case the application sends all invalid rc-RPCs with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid1 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})
					local cid2 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 2,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 2,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})					
					local cid3 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})					
					local cid4 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								hdChannel = 1,
								state = "ACQUIRING"
							}
						}
						})					
					local cid5 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								signalChangeThreshold = 60,
								radioEnable = true,
								hdChannel = 1,
								state = "ACQUIRING"
							}
						}				
					})					
					local cid6 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								radioEnable = true,
								hdChannel = 1,
								state = "ACQUIRING"
							}
						}
						})					
					local cid7 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								hdChannel = 1,
								state = "ACQUIRING"
							}
						}				
					})
					local cid8 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								hdChannel = 1,
								band = "FM"
							}
						}				
					})
					local cid9 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								hdChannel = 1,
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								}
							}
						}				
					})
					local cid10 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							
							radioControlData = {
								frequencyInteger = 99,
								hdChannel = 1,
								band = "FM"
								}
							}
						})					
					
					
					--hmi side: RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
									zone =
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 1,
										levelspan = 1,
										level = 0
									}
					})
					:Times(0)
							
					
					--RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application
					EXPECT_RESPONSE(cid1, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid2, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid3, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid4, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid5, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid6, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid7, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid8, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid9, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid10, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
				end
			--End Test case CommonRequestCheck.15.1.3
			
		-----------------------------------------------------------------------------------------				
		-------------------------FOR LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Back Right)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.15.1.4
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (DISSALLOWED)
				function Test:SetInterior_LeftRADIO_DISSALLOWED()
					--mobile side: In case the application sends all invalid rc-RPCs with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid1 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})
					local cid2 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})					
					local cid3 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})					
					local cid4 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								hdChannel = 1,
								state = "ACQUIRING"
							}
						}
						})					
					local cid5 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								signalChangeThreshold = 60,
								radioEnable = true,
								hdChannel = 1,
								state = "ACQUIRING"
							}
						}				
					})					
					local cid6 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								radioEnable = true,
								hdChannel = 1,
								state = "ACQUIRING"
							}
						}
						})					
					local cid7 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								hdChannel = 1,
								state = "ACQUIRING"
							}
						}				
					})
					local cid8 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								hdChannel = 1,
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								}
							}
						}				
					})
					local cid9 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								hdChannel = 1,
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								}
							}
						}				
					})
					local cid10 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								band = "FM",
								hdChannel = 1,
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								}
							}
						}				
					})					
					
					
					--hmi side: RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
					:Times(0)
							
					
					--RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application
					EXPECT_RESPONSE(cid1, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid2, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid3, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid4, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid5, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid6, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid7, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid8, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid9, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid10, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
				end
			--End Test case CommonRequestCheck.15.1.4
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.15.1.5
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (DISSALLOWED)
				function Test:SetInterior_LeftCLIMATE_DISSALLOWED()
					--mobile side: In case the application sends all invalid rc-RPCs with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid1 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
					local cid2 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
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
					local cid3 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}						
					})
					local cid4 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}						
					})
					local cid5 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}						
					})
					local cid6 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}						
					})					
					local cid7 = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}						
					})
					
					--hmi side: RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)
					
					--RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application
					EXPECT_RESPONSE(cid1, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid2, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid3, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid4, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid5, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid6, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
					EXPECT_RESPONSE(cid7, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
				end
			--End Test case CommonRequestCheck.15.1.5
		
		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.15.1
		
--=================================================END TEST CASES 15==========================================================--






--=================================================BEGIN TEST CASES 16==========================================================--
	--Begin Test suit CommonRequestCheck.16 for Req.#16

	--Description: 16. In case an RC application from <deviceID> device has driver's permission to control <moduleType> from <HMI-provided interiorZone> (via RC.OnDeviceLocationChanged from HMI) 
							-- and RSDL gets RC.OnDeviceLocationChanged for the same device with the different <HMI-provided interiorZone> 
							-- RSDL must:
								-- send OnHMIStatus (NONE) to such app 
								-- take off the driver's permissions from this application in the previous <HMI-provided interiorZone> (that is, trigger a permission prompt upon this app's next controlling request).
	

	--Begin Test case CommonRequestCheck.16.1
	--Description: 	-- RSDL must:
								-- send OnHMIStatus (NONE) to such app 
								-- take off the driver's permissions from this application in the previous <HMI-provided interiorZone> (that is, trigger a permission prompt upon this app's next controlling request).

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1868

		--Verification criteria: 
				--RSDL must:
						-- send OnHMIStatus (NONE) to such app 
						-- take off the driver's permissions from this application in the previous <HMI-provided interiorZone> (that is, trigger a permission prompt upon this app's next controlling request).

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.16.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_FrontRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
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
													row = 2,
													rowspan = 2,
													col = 2,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.16.1.1
			
		-----------------------------------------------------------------------------------------	
		
			--Begin Test case CommonRequestCheck.16.1.2
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (doesn't ask permission)
				function Test:ButtonPress_FrontRADIO_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
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
											row = 2,
											rowspan = 2,
											col = 2,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.16.1.2
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
					
					--Send OnHMIStatus (NONE) to such app 
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.16.1.3
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_LeftCLIMATE_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 2,
													rowspan = 2,
													col = 2,
													levelspan = 1,
													level = 0
												},
												moduleType = "CLIMATE",
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.16.1.3
		
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.16.1.4
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (time2 doesn't ask permission)
				function Test:ButtonPress_LeftCLIMATE_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
					})
							
					--hmi side: expect Buttons.ButtonPress request
					EXPECT_HMICALL("Buttons.ButtonPress", 
									{ 
										zone =
										{
											colspan = 2,
											row = 2,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										},
										moduleType = "CLIMATE",
										buttonPressMode = "SHORT",
										buttonName = "LOWER_VENT"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.16.1.4
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.16.1
	
	
	--Begin Test case CommonRequestCheck.16.2 (have to STOP SDL after running CommonRequestCheck.16.1)
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1868

		--Verification criteria: 
				--RSDL must take off the driver's permissions from this application (that is, trigger a permission prompt upon this app's next controlling request).

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.16.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_FrontRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.16.2.1
			
		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
						
					--Send OnHMIStatus (NONE) to such app 
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.16.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_LeftRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.16.2.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.16.2.3
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_LeftCLIMATE_Time1()
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
								col = 1,
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 1,
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
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.16.2.3
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.16.2
		
		
	--Begin Test case CommonRequestCheck.16.3 (have to STOP SDL after running CommonRequestCheck.16.2)
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1868

		--Verification criteria: 
				--RSDL must take off the driver's permissions from this application (that is, trigger a permission prompt upon this app's next controlling request).

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.16.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_FrontRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.16.3.1
			
		------------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE-------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Left()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 1,
									rowspan = 2,
									col = 0,
									levelspan = 1,
									level = 0
								}
						})
						
					--Send OnHMIStatus (NONE) to such app 
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.16.3.2
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_LeftRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.16.3.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.16.3.3
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_LeftCLIMATE_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 1,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.16.3.3
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.16.3	
		
--=================================================END TEST CASES 16==========================================================--






--=================================================BEGIN TEST CASES 17==========================================================--
	--Begin Test suit CommonRequestCheck.17 for Req.#17

	--Description: 17. In case RSDL has received an RPC from RC-application from <deviceID> device and started processing it with the currently known <interiorZone> (either 'app-provided' if no OnDeviceLocationChanged received, or 'HMI-provided' if OnDeviceLocationChanged is obtained from HMI) 
							-- and RSDL gets OnDeviceLocationChanged for this <deviceID> with different <interiorZone> \ RSDL must:
							-- finish processing RPC 
							-- only then apply rules of req. 16.
	

	--Begin Test case CommonRequestCheck.17.1
	--Description: 	-- RSDL must:
							-- finish processing RPC 
							-- only then apply rules of req. 16.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1868

		--Verification criteria: 
				--RSDL must:
						-- finish processing RPC 
						-- only then apply rules of req. 16.

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.17.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_FrontRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
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
													row = 2,
													rowspan = 2,
													col = 2,
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
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.17.1.1
			
		-----------------------------------------------------------------------------------------	
		
			--Begin Test case CommonRequestCheck.17.1.2
			--Description: application sends ButtonPress as Front Passenger and HMI sends RC.OnDeviceLocationChanged zone:BACK LEFT Passenger)
				function Test:ButtonPress_FrontRADIO_Time2AndChangedLocation()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
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
											row = 2,
											rowspan = 2,
											col = 2,
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
							
							--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
							self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
							{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
								deviceLocation =
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									}
							})
							
						end)
					
					-- finish processing RPC 
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
					
					--Send OnHMIStatus (NONE) to such app 
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					
				end
			--End Test case CommonRequestCheck.17.1.2
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.17.1.3
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (asking permision again)
				function Test:ButtonPress_LeftCLIMATE_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 2,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
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
							
							--hmi side: expect Buttons.ButtonPress request
							EXPECT_HMICALL("Buttons.ButtonPress", 
											{ 
												zone =
												{
													colspan = 2,
													row = 2,
													rowspan = 2,
													col = 2,
													levelspan = 1,
													level = 0
												},
												moduleType = "CLIMATE",
												buttonPressMode = "SHORT",
												buttonName = "LOWER_VENT"
											})
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.17.1.3
		
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.17.1.4
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (time2 doesn't ask permission)
				function Test:ButtonPress_LeftCLIMATE_Time2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("ButtonPress",
					{
						zone =
						{
							colspan = 2,
							row = 2,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						},
						moduleType = "CLIMATE",
						buttonPressMode = "SHORT",
						buttonName = "LOWER_VENT"						
					})
							
					--hmi side: expect Buttons.ButtonPress request
					EXPECT_HMICALL("Buttons.ButtonPress", 
									{ 
										zone =
										{
											colspan = 2,
											row = 2,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										},
										moduleType = "CLIMATE",
										buttonPressMode = "SHORT",
										buttonName = "LOWER_VENT"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.17.1.4
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.17.1
	
	
	--Begin Test case CommonRequestCheck.17.2 (have to STOP SDL after running CommonRequestCheck.17.1)
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1868

		--Verification criteria: 
				--RSDL must take off the driver's permissions from this application (that is, trigger a permission prompt upon this app's next controlling request).

		-----------------------------------------------------------------------------------------
		-------------------------FOR FRONT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:Front Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Front()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 0,
									rowspan = 2,
									col = 1,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------		
				
			--Begin Test case CommonRequestCheck.17.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger and HMI sends RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
				function Test:GetInterior_FrontRADIO_Time1AndChangedLocation()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
							
							--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
							self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
							{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
								deviceLocation =
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									}
							})
							
							
							--hmi side: expect RC.GetInteriorVehicleData request
							EXPECT_HMICALL("RC.GetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.GetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					-- finish processing RPC 
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
					
					--Send OnHMIStatus (NONE) to such app 
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE" }, { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Times(2)
					
				end
			--End Test case CommonRequestCheck.17.2.1
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case CommonRequestCheck.17.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (asking driver's permission)
				function Test:GetInterior_LeftRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
					{
						moduleDescription =
						{
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 2,
								rowspan = 2,
								col = 2,
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
									moduleType = "RADIO",
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 2,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 2,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM",
													rdsData = {
														PS = "name",
														RT = "radio",
														CT = "YYYY-MM-DDThh:mm:ss.sTZD",
														PI = "Sign",
														PTY = 1,
														TP = true,
														TA = true,
														REG = "Murica"
													},
													availableHDs = 3,
													hdChannel = 1,
													signalStrength = 50,
													signalChangeThreshold = 60,
													radioEnable = true,
													state = "ACQUIRING"
												}
											}	
									})
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.17.2.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.17.2.3
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (asking driver's permission)
				function Test:GetInterior_LeftCLIMATE_Time1()
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
								col = 1,
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 1,
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
									
							end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.17.2.3
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.17.2
		
		
	--Begin Test case CommonRequestCheck.17.3 (have to STOP SDL after running CommonRequestCheck.17.2)
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira: 
				--REVSDL-1827
				--REVSDL-1868

		--Verification criteria: 
				--RSDL must take off the driver's permissions from this application (that is, trigger a permission prompt upon this app's next controlling request).

		-----------------------------------------------------------------------------------------	
				
			--Begin Test case CommonRequestCheck.17.3.1
			--Description: application sends SetInteriorVehicleData as Driver zone and ModuleType = RADIO and HMI sends  RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
				function Test:SetInterior_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 0,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM",
								rdsData = {
									PS = "name",
									RT = "radio",
									CT = "YYYY-MM-DDThh:mm:ss.sTZD",
									PI = "Sign",
									PTY = 1,
									TP = true,
									TA = true,
									REG = "Murica"
								},
								availableHDs = 3,
								hdChannel = 1,
								signalStrength = 50,
								signalChangeThreshold = 60,
								radioEnable = true,
								state = "ACQUIRING"
							}
						}				
					})
							
					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
					
						--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
						self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
							{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
								deviceLocation =
									{
										colspan = 2,
										row = 1,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									}
							})
					
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
								moduleData = {
									moduleType = "RADIO",
									moduleZone = {
										col = 0,
										colspan = 2,
										level = 0,
										levelspan = 1,
										row = 0,
										rowspan = 2
									},
									radioControlData = {
										frequencyInteger = 99,
										frequencyFraction = 3,
										band = "FM",
										rdsData = {
											PS = "name",
											RT = "radio",
											CT = "YYYY-MM-DDThh:mm:ss.sTZD",
											PI = "Sign",
											PTY = 1,
											TP = true,
											TA = true,
											REG = "Murica"
										},
										availableHDs = 3,
										hdChannel = 1,
										signalStrength = 50,
										signalChangeThreshold = 60,
										radioEnable = true,
										state = "ACQUIRING"
									}
								}	
						})
						
					end)							
					
					-- finish processing RPC 
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
					
					--Send OnHMIStatus (NONE) to such app 
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" }, { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE" })
					:Times(2)
					
				end
			--End Test case CommonRequestCheck.17.3.1
			
		------------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.17.3.2
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (asking permission)
				function Test:SetInterior_LeftRADIO_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData = {
							moduleType = "RADIO",
							moduleZone = {
								col = 1,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
								rowspan = 2
							},
							radioControlData = {
								frequencyInteger = 99,
								frequencyFraction = 3,
								band = "FM"
							}
						}				
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent", 
								{ 
									appID = self.applications["Test Application"],
									moduleType = "RADIO",
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
											moduleData = {
												moduleType = "RADIO",
												moduleZone = {
													col = 1,
													colspan = 2,
													level = 0,
													levelspan = 1,
													row = 1,
													rowspan = 2
												},
												radioControlData = {
													frequencyInteger = 99,
													frequencyFraction = 3,
													band = "FM"
												}
											}	
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.17.3.2
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.17.3.3
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (asking permission)
				function Test:SetInterior_LeftCLIMATE_Time1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								colspan = 2,
								row = 1,
								rowspan = 2,
								col = 1,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 50,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
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
							
							--hmi side: expect RC.SetInteriorVehicleData request
							EXPECT_HMICALL("RC.SetInteriorVehicleData")
							:Do(function(_,data)
									--hmi side: sending RC.SetInteriorVehicleData response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										moduleData =
										{
											moduleType = "CLIMATE",
											moduleZone = 
											{
												colspan = 2,
												row = 1,
												rowspan = 2,
												col = 1,
												levelspan = 1,
												level = 0
											},
											climateControlData =
											{
												fanSpeed = 50,
												desiredTemp = 24,
												temperatureUnit = "CELSIUS"
											}
										}
									})
									
								end)
					end)								
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.17.3.3
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.17.3	
		
--=================================================END TEST CASES 17==========================================================--




	
return Test	