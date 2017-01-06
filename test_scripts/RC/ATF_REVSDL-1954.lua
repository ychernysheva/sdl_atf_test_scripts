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
--Declaration connected devices.
--1. Device 2:
local device2 = "192.168.100.199"
local device2Port = 12345
--2. Device 3:
local device3 = "10.42.0.1"
local device3Port = 12345

---------------------------------------------------------------------------------------------
--ID for app that duplicates name
local ID
						
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
--Using for delaying event when AppRegistration
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
	
	

--======================================REVSDL-1954========================================--
---------------------------------------------------------------------------------------------
-----------REVSDL-1954: Same-named applications with the same appIDs must be-----------------
--------------------------------allowed from different devices-------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--





--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: 1. In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from <deviceRank> device (1. driver's or 2. passenger's) and another REMOTE_CONTROL application with the same <appName> and different <appID> from a device of different <deviceRank> (1. passenger's or 2. driver's) requests registration 
							-- RSDL must:
							-- assign the second app with different internal integer appID than the first app has 
							-- allow this second app registration (that is, respond with RegisterAppInterface (resultCode: SUCCESS, success: true, params) and notify HMI via BC.OnAppRegistered)

	--Begin Test case CommonRequestCheck.1.1
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from <deviceRank> device (1. driver's or 2. passenger's) and another REMOTE_CONTROL application with the same <appName> and different <appID> from a device of different <deviceRank> (1. passenger's or 2. driver's) requests registration 
					--Different <deviceRank>: Driver's device first, passenger second
							--Device1: Driver
							--Device2: Passenger

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				-- RSDL must:
							-- assign the second app with different internal integer appID than the first app has 
							-- allow this second app registration (that is, respond with RegisterAppInterface (resultCode: SUCCESS, success: true, params) and notify HMI via BC.OnAppRegistered)

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC1_NewApps()
			
			  self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------  		
				
			--Begin Test case Precondition.1.1.2
			--Description: Connecting Device2 to RSDL and set Device1 to Driver
			function Test:TC1_ConnectDevice2Set1ToDriver()
			
				newConnectionDevice2(self, device2, device2Port)
				
				--hmi side: expect BasicCommunication.UpdateDeviceList request
				EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
					{deviceList = {{id = 1, isSDLAllowed = true, name = "127.0.0.1"}, {id = 2, isSDLAllowed = true, name = device2}}}
				
				)
				:Do(function(_,data)

					--hmi side: sending BasicCommunication.UpdateDeviceList response
					self.hmiConnection:SendResponse(data.id,"BasicCommunication.UpdateDeviceList", "SUCCESS", {})
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

				end)

			end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.3
			--Description: Register App1 from Device1
			   function Test:TC1_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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
						ID = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.1.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.1.3
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device2
			   function Test:TC1_App1FromDevice2() 

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
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})
				   
					--mobile side: Expect OnPermissionsChange notification for PASSENGER's device
					self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.1.1.3
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.4
			--Description: activate App1 to FULL
				function Test:TC1_App1FULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = ID })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession11:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				end
			--End Test case CommonRequestCheck.1.1.4
			
		-----------------------------------------------------------------------------------------			
		
	--End Test case CommonRequestCheck.1.1	
	

	--Begin Test case CommonRequestCheck.1.2 (stop SDL before running this test suite)
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from <deviceRank> device (1. driver's or 2. passenger's) and another REMOTE_CONTROL application with the same <appName> and different <appID> from a device of different <deviceRank> (1. passenger's or 2. driver's) requests registration 
					--Different <deviceRank>: Passenger's device first, Driver second
							--Device1: Passenger
							--Device2: Driver

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				-- RSDL must:
							-- assign the second app with different internal integer appID than the first app has 
							-- allow this second app registration (that is, respond with RegisterAppInterface (resultCode: SUCCESS, success: true, params) and notify HMI via BC.OnAppRegistered)

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.2.1
			--Description: Register new session for register new apps
			function Test:TC1_NewApps()
			
			  self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
			end
			--End Test case Precondition.1.2.1
			
		-----------------------------------------------------------------------------------------  		
				
			--Begin Test case Precondition.1.2.2
			--Description: Connecting Device2 to RSDL and set Device1 to Driver
			function Test:TC1_ConnectDevice2Set2ToDriver()
			
				newConnectionDevice2(self, device2, device2Port)
				
				--hmi side: expect BasicCommunication.UpdateDeviceList request
				EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
					{deviceList = {{id = 1, isSDLAllowed = true, name = "127.0.0.1"}, {id = 2, isSDLAllowed = true, name = device2}}}
				
				)
				:Do(function(_,data)

					--hmi side: sending BasicCommunication.UpdateDeviceList response
					self.hmiConnection:SendResponse(data.id,"BasicCommunication.UpdateDeviceList", "SUCCESS", {})
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = device2, id = 2, isSDLAllowed = true}})

				end)

			end
			--End Test case Precondition.1.2.2
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.2.3
			--Description: Register App1 from Device1
			   function Test:TC1_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for PASSENGER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.1.2.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.1.2.3
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device2
			   function Test:TC1_Ap2FromDevice2() 

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
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
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
						ID = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.1.2.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.2.4
			--Description: activate App1 to FULL
				function Test:TC1_App2FULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = ID })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession21:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				end
			--End Test case CommonRequestCheck.1.2.4
			
		-----------------------------------------------------------------------------------------			
		
	--End Test case CommonRequestCheck.1.2
	
--=================================================END TEST CASES 1==========================================================--







--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2

	--Description: 2. In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from <deviceRank> device (1. driver's or 2. passenger's) and another REMOTE_CONTROL application with different <appName> and the same <appID> from a device of different <deviceRank> (1. passenger's or 2. driver's) requests registration 
						-- RSDL must:
						-- assign the second app with different internal integer appID than the first app has 
						-- allow this second app registration (that is, respond with RegisterAppInterface (resultCode: SUCCESS, success: true, params) and notify HMI via BC.OnAppRegistered) 

	--Begin Test case CommonRequestCheck.2.1
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from <deviceRank> device (1. driver's or 2. passenger's) and another REMOTE_CONTROL application with different <appName> and the same <appID> from a device of different <deviceRank> (1. passenger's or 2. driver's) requests registration 
					--Different <deviceRank>: Driver's device first, passenger second
							--Device1: Driver
							--Device2: Passenger

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				-- RSDL must:
						-- assign the second app with different internal integer appID than the first app has 
						-- allow this second app registration (that is, respond with RegisterAppInterface (resultCode: SUCCESS, success: true, params) and notify HMI via BC.OnAppRegistered) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.2.1.1
			--Description: Register new session for register new apps
			function Test:TC2_NewApps()
			
			  self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
			end
			--End Test case Precondition.2.1.1
			
		-----------------------------------------------------------------------------------------  		
				
			--Begin Test case Precondition.2.1.2
			--Description: Connecting Device2 to RSDL and set Device1 to Driver
			function Test:TC2_ConnectDevice2Set1ToDriver()
			
				newConnectionDevice2(self, device2, device2Port)
				
				--hmi side: expect BasicCommunication.UpdateDeviceList request
				EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
					{deviceList = {{id = 1, isSDLAllowed = true, name = "127.0.0.1"}, {id = 2, isSDLAllowed = true, name = device2}}}
				
				)
				:Do(function(_,data)

					--hmi side: sending BasicCommunication.UpdateDeviceList response
					self.hmiConnection:SendResponse(data.id,"BasicCommunication.UpdateDeviceList", "SUCCESS", {})
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

				end)

			end
			--End Test case Precondition.2.1.2
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.3
			--Description: Register App1 from Device1
			   function Test:TC2_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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
						ID = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.2.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.2.1.3
			--Description: Register App2 with the same <appID> and different <appName> from a passenger device2
			   function Test:TC2_App1FromDevice2() 

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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
				   
					--mobile side: Expect OnPermissionsChange notification for PASSENGER's device
					self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.2.1.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.4
			--Description: activate App2 to FULL
				function Test:TC2_App1FULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = ID })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession11:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				end
			--End Test case CommonRequestCheck.2.1.4
			
		-----------------------------------------------------------------------------------------			
		
	--End Test case CommonRequestCheck.2.1	
	

	--Begin Test case CommonRequestCheck.2.2 (stop SDL before running this test suite)
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from <deviceRank> device (1. driver's or 2. passenger's) and another REMOTE_CONTROL application with different <appName> and the same <appID> from a device of different <deviceRank> (1. passenger's or 2. driver's) requests registration 
					--Different <deviceRank>: Passenger's device first, Driver second
							--Device1: Passenger
							--Device2: Driver

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				-- RSDL must:
						-- assign the second app with different internal integer appID than the first app has 
						-- allow this second app registration (that is, respond with RegisterAppInterface (resultCode: SUCCESS, success: true, params) and notify HMI via BC.OnAppRegistered) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.2.2.1
			--Description: Register new session for register new apps
			function Test:TC2_NewApps()
			
			  self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
			end
			--End Test case Precondition.2.2.1
			
		-----------------------------------------------------------------------------------------  		
				
			--Begin Test case Precondition.2.2.2
			--Description: Connecting Device2 to RSDL and set Device1 to Driver
			function Test:TC2_ConnectDevice2Set2ToDriver()
			
				newConnectionDevice2(self, device2, device2Port)
				
				--hmi side: expect BasicCommunication.UpdateDeviceList request
				EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
					{deviceList = {{id = 1, isSDLAllowed = true, name = "127.0.0.1"}, {id = 2, isSDLAllowed = true, name = device2}}}
				
				)
				:Do(function(_,data)

					--hmi side: sending BasicCommunication.UpdateDeviceList response
					self.hmiConnection:SendResponse(data.id,"BasicCommunication.UpdateDeviceList", "SUCCESS", {})
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = device2, id = 2, isSDLAllowed = true}})

				end)

			end
			--End Test case Precondition.2.2.2
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.2.3
			--Description: Register App1 from Device1
			   function Test:TC2_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for PASSENGER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.2.2.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.2.2.3
			--Description: Register App2 with the same <appID> and different <appName> from a passenger device2
			   function Test:TC2_Ap2FromDevice2() 

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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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
						ID = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.2.2.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.2.4
			--Description: activate App2 to FULL
				function Test:TC2_App2FULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = ID })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession21:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				end
			--End Test case CommonRequestCheck.2.2.4
			
		-----------------------------------------------------------------------------------------			
		
	--End Test case CommonRequestCheck.2.2

	
--=================================================END TEST CASES 2==========================================================--






--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: 3. In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from <deviceRank> device (1. driver's or 2. passenger's) and another REMOTE_CONTROL application with the same <appName> and the same <appID> from a device of different <deviceRank> (1. passenger's or 2. driver's) requests registration 
						-- RSDL must:
						-- assign the second app with different internal integer appID than the first app has 
						-- allow this second app registration (that is, respond with RegisterAppInterface (resultCode: SUCCESS, success: true, params) and notify HMI via BC.OnAppRegistered) 

	--Begin Test case CommonRequestCheck.3.1
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from <deviceRank> device (1. driver's or 2. passenger's) and another REMOTE_CONTROL application with the same <appName> and the same <appID> from a device of different <deviceRank> (1. passenger's or 2. driver's) requests registration 
					--Different <deviceRank>: Driver's device first, passenger second
							--Device1: Driver
							--Device2: Passenger

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				-- RSDL must:
						-- assign the second app with different internal integer appID than the first app has 
						-- allow this second app registration (that is, respond with RegisterAppInterface (resultCode: SUCCESS, success: true, params) and notify HMI via BC.OnAppRegistered) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.2.1.1
			--Description: Register new session for register new apps
			function Test:TC3_NewApps()
			
			  self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
			end
			--End Test case Precondition.2.1.1
			
		-----------------------------------------------------------------------------------------  		
				
			--Begin Test case Precondition.2.1.2
			--Description: Connecting Device2 to RSDL and set Device1 to Driver
			function Test:TC3_ConnectDevice2Set1ToDriver()
			
				newConnectionDevice2(self, device2, device2Port)
				
				--hmi side: expect BasicCommunication.UpdateDeviceList request
				EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
					{deviceList = {{id = 1, isSDLAllowed = true, name = "127.0.0.1"}, {id = 2, isSDLAllowed = true, name = device2}}}
				
				)
				:Do(function(_,data)

					--hmi side: sending BasicCommunication.UpdateDeviceList response
					self.hmiConnection:SendResponse(data.id,"BasicCommunication.UpdateDeviceList", "SUCCESS", {})
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

				end)

			end
			--End Test case Precondition.2.1.2
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.3
			--Description: Register App1 from Device1
			   function Test:TC3_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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
						ID = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.3.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.3.1.3
			--Description: Register App2 with the same <appID> and same <appName> from a passenger device2
			   function Test:TC3_App1FromDevice2() 

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
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
				   
					--mobile side: Expect OnPermissionsChange notification for PASSENGER's device
					self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.3.1.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.4
			--Description: activate App1 to FULL
				function Test:TC3_App1FULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = ID })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession11:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				end
			--End Test case CommonRequestCheck.3.1.4
			
		-----------------------------------------------------------------------------------------			
		
	--End Test case CommonRequestCheck.3.1	
	

	--Begin Test case CommonRequestCheck.3.2 (stop SDL before running this test suite)
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from <deviceRank> device (1. driver's or 2. passenger's) and another REMOTE_CONTROL application with the same <appName> and the same <appID> from a device of different <deviceRank> (1. passenger's or 2. driver's) requests registration 
					--Different <deviceRank>: Passenger's device first, Driver second
							--Device1: Passenger
							--Device2: Driver

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				-- RSDL must:
						-- assign the second app with different internal integer appID than the first app has 
						-- allow this second app registration (that is, respond with RegisterAppInterface (resultCode: SUCCESS, success: true, params) and notify HMI via BC.OnAppRegistered) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.3.2.1
			--Description: Register new session for register new apps
			function Test:TC3_NewApps()
			
			  self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
			end
			--End Test case Precondition.3.2.1
			
		-----------------------------------------------------------------------------------------  		
				
			--Begin Test case Precondition.3.2.2
			--Description: Connecting Device2 to RSDL and set Device1 to Driver
			function Test:TC3_ConnectDevice2Set2ToDriver()
			
				newConnectionDevice2(self, device2, device2Port)
				
				--hmi side: expect BasicCommunication.UpdateDeviceList request
				EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
					{deviceList = {{id = 1, isSDLAllowed = true, name = "127.0.0.1"}, {id = 2, isSDLAllowed = true, name = device2}}}
				
				)
				:Do(function(_,data)

					--hmi side: sending BasicCommunication.UpdateDeviceList response
					self.hmiConnection:SendResponse(data.id,"BasicCommunication.UpdateDeviceList", "SUCCESS", {})
					
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = device2, id = 2, isSDLAllowed = true}})

				end)

			end
			--End Test case Precondition.3.2.2
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.3
			--Description: Register App1 from Device1
			   function Test:TC3_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for PASSENGER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.3.2.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.3.2.3
			--Description: Register App2 with the same <appID> and same <appName> from a passenger device2
			   function Test:TC3_Ap2FromDevice2() 

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
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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
						ID = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.3.2.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.4
			--Description: activate App2 to FULL
				function Test:TC3_App2FULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
																{ appID = ID })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession21:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"})
				end
			--End Test case CommonRequestCheck.3.2.4
			
		-----------------------------------------------------------------------------------------			
		
	--End Test case CommonRequestCheck.3.2
	
--=================================================END TEST CASES 3==========================================================--






--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for Req.#4

	--Description: 4. In case In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from driver's device 
							-- and another REMOTE_CONTROL application with the same <appName> and the different <appID> from the same or another driver's device requests registration via a separate session 
							-- RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

	--Begin Test case CommonRequestCheck.4.1
	--Description: 	In case In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from driver's device 
					--Same <deviceRank>: Setting Driver's device before App1 Connected

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC4_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------  		
				
			--Begin Test case Precondition.1.1.2
			--Description: Set Device1 to Driver's device
			   function Test:TC4_SetDevice1ToDriver() 

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					--self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
			   
				end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.1.3
			--Description: Register App1 from Device1
			   function Test:TC4_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.4.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.4
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device1
			   function Test:TC4_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.4.1.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.4.1	
	


	--Begin Test case CommonRequestCheck.4.2
	--Description: 	In case In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from driver's device 
					--Same <deviceRank>: Setting Driver's device after App1 Connected

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC4_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.2.2
			--Description: Register App1 from Device1
			   function Test:TC4_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.4.2.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.1.1.3
			--Description: Set Device1 to Driver's device
			   function Test:TC4_SetDevice1ToDriver() 

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					--self.mobileSession11:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
			   
				end
			--End Test case Precondition.1.1.3
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.2.4
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device1
			   function Test:TC4_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.4.2.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.4.2	
	
	
--=================================================END TEST CASES 4==========================================================--





--=================================================BEGIN TEST CASES 5==========================================================--
	--Begin Test suit CommonRequestCheck.5 for Req.#5

	--Description: 5. In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from driver's device 
							-- and another REMOTE_CONTROL application with the different <appName> and the same <appID> from the same or another driver's device requests registration via a separate session 
							-- RSDL must respond with RegisterAppInterface (resultCode: DISALLOWED, success: false, params) 

	--Begin Test case CommonRequestCheck.5.1
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from driver's device 
							-- and another REMOTE_CONTROL application with the different <appName> and the same <appID> from the same or another driver's device requests registration via a separate session 
							--Same <deviceRank>: Setting Driver's device before App1 Connected

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DISALLOWED, success: false, params)

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC5_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------  		
				
			--Begin Test case Precondition.1.1.2
			--Description: Set Device1 to Driver's device
			   function Test:TC5_SetDevice1ToDriver() 

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					--self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
			   
				end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.1.3
			--Description: Register App1 from Device1
			   function Test:TC5_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.5.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.5.1.4
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device1
			   function Test:TC5_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App2"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App2"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DISALLOWED"},
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.5.1.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.1	
	


	--Begin Test case CommonRequestCheck.5.2
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from driver's device 
							-- and another REMOTE_CONTROL application with the different <appName> and the same <appID> from the same or another driver's device requests registration via a separate session 
							--Same <deviceRank>: Setting Driver's device after App1 Connected

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DISALLOWED, success: false, params)

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC5_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.5.2.2
			--Description: Register App1 from Device1
			   function Test:TC5_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.5.2.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.1.1.3
			--Description: Set Device1 to Driver's device
			   function Test:TC5_SetDevice1ToDriver() 

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					--self.mobileSession11:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
			   
				end
			--End Test case Precondition.1.1.3
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.5.2.4
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device1
			   function Test:TC5_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App2"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App2"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DISALLOWED"},
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.5.2.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.2	
	
	
--=================================================END TEST CASES 5==========================================================--





--=================================================BEGIN TEST CASES 6==========================================================--
	--Begin Test suit CommonRequestCheck.6 for Req.#6

	--Description: 6. In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from driver's device 
							-- and another REMOTE_CONTROL application with the same <appName> and the same <appID> from the same or another driver's device requests registration via a separate session 
							-- RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

	--Begin Test case CommonRequestCheck.6.1
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from driver's device 
							-- and another REMOTE_CONTROL application with the same <appName> and the same <appID> from the same or another driver's device requests registration via a separate session 
							--Same <deviceRank>: Setting Driver's device before App1 Connected

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC4_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------  		
				
			--Begin Test case Precondition.1.1.2
			--Description: Set Device1 to Driver's device
			   function Test:TC4_SetDevice1ToDriver() 

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					--self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
			   
				end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.6.1.3
			--Description: Register App1 from Device1
			   function Test:TC4_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.6.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.6.1.4
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device1
			   function Test:TC4_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.6.1.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.6.1	
	


	--Begin Test case CommonRequestCheck.6.2
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from driver's device 
							-- and another REMOTE_CONTROL application with the same <appName> and the same <appID> from the same or another driver's device requests registration via a separate session 
							--Same <deviceRank>: Setting Driver's device after App1 Connected

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC4_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.6.2.2
			--Description: Register App1 from Device1
			   function Test:TC4_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.6.2.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.1.1.3
			--Description: Set Device1 to Driver's device
			   function Test:TC4_SetDevice1ToDriver() 

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					--self.mobileSession11:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })
			   
				end
			--End Test case Precondition.1.1.3
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.6.2.4
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device1
			   function Test:TC4_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.6.2.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.6.2	
	
	
--=================================================END TEST CASES 6==========================================================--







--=================================================BEGIN TEST CASES 7==========================================================--
	--Begin Test suit CommonRequestCheck.7 for Req.#7

	--Description: 7. In case In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
							-- and another REMOTE_CONTROL application with the same <appName> and the different <appID> from the same or another passenger's device requests registration via a separate session 
							-- RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

	--Begin Test case CommonRequestCheck.7.1
	--Description: 	In case In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
					--Same <deviceRank>: Different device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC7_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.2
			--Description: Connecting Device2 to RSDL
			function Test:TC7_ConnectDevice2()
			
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.7.1.3
			--Description: Register App1 from Device1
			   function Test:TC7_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.7.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.7.1.4
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device2
			   function Test:TC7_App2FromDevice2() 

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
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.7.1.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.7.1	
	


	--Begin Test case CommonRequestCheck.7.2
	--Description: 	In case In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
					--Same <deviceRank>: Same device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC7_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.7.2.2
			--Description: Register App1 from Device1
			   function Test:TC7_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for PASSENGER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.7.2.2
			
		-----------------------------------------------------------------------------------------	
		
			--Begin Test case CommonRequestCheck.7.2.3
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device1
			   function Test:TC7_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.7.2.3
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.7.2



	--Begin Test case CommonRequestCheck.7.3
	--Description: 	In case In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
					--Same <deviceRank>: Setting passenger's device after App1 Connected

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC7_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.3
			--Description: Set Device1 to Driver's device
			   function Test:TC7_SetDevice1ToDriver() 

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
				end
			--End Test case Precondition.1.1.3
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.7.3.3
			--Description: Register App1 from Device1
			   function Test:TC7_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.7.3.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.3
			--Description: Set Device1 to passenger's device
			   function Test:TC7_SetDevice1ToPassenger() 

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for PASSENGER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					--self.mobileSession11:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
			   
				end
			--End Test case Precondition.1.1.3
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.7.3.4
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device1
			   function Test:TC7_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="2",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.7.3.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.7.3	
	
	
--=================================================END TEST CASES 7==========================================================--





--=================================================BEGIN TEST CASES 8==========================================================--
	--Begin Test suit CommonRequestCheck.8 for Req.#8

	--Description: 8. In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
							-- and another REMOTE_CONTROL application with the different <appName> and the same <appID> from the same or another passenger's device requests registration via a separate session 
							-- RSDL must respond with RegisterAppInterface (resultCode: DISALLOWED, success: false, params) 

	--Begin Test case CommonRequestCheck.8.1
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
							-- and another REMOTE_CONTROL application with the different <appName> and the same <appID> from the same or another passenger's device requests registration via a separate session 
							--Same <deviceRank>: different device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DISALLOWED, success: false, params)

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC5_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.2
			--Description: Connecting Device2 to RSDL
			function Test:TC7_ConnectDevice2()
			
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.8.1.2
			--Description: Register App1 from Device1
			   function Test:TC5_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.8.1.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.8.1.3
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device2
			   function Test:TC5_App2FromDevice2() 

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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App2"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App2"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = false, resultCode = "DISALLOWED"},
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.8.1.3
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.8.1	
	


	--Begin Test case CommonRequestCheck.8.2
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
							-- and another REMOTE_CONTROL application with the different <appName> and the same <appID> from the same or another passenger's device requests registration via a separate session 
							--Same <deviceRank>: same device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DISALLOWED, success: false, params)

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC5_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.8.2.2
			--Description: Register App1 from Device1
			   function Test:TC5_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.8.2.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.8.2.3
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device2
			   function Test:TC5_App2FromDevice2() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App2"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App2"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DISALLOWED"},
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.8.2.3
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.8.2	
	
	
--=================================================END TEST CASES 8==========================================================--





--=================================================BEGIN TEST CASES 9==========================================================--
	--Begin Test suit CommonRequestCheck.9 for Req.#9

	--Description: 9. In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
							-- and another REMOTE_CONTROL application with the same <appName> and the same <appID> from the same or another passenger's device requests registration via a separate session 
							-- RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

	--Begin Test case CommonRequestCheck.9.1
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
							-- and another REMOTE_CONTROL application with the same <appName> and the same <appID> from the same or another passenger's device requests registration via a separate session 
							--Same <deviceRank>: different device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC7_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.2
			--Description: Connecting Device2 to RSDL
			function Test:TC7_ConnectDevice2()
			
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.9.1.2
			--Description: Register App1 from Device1
			   function Test:TC7_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.9.1.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.9.1.3
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device2
			   function Test:TC7_App2FromDevice2() 

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
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.9.1.3
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.9.1	
	


	--Begin Test case CommonRequestCheck.9.2
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
							-- and another REMOTE_CONTROL application with the same <appName> and the same <appID> from the same or another passenger's device requests registration via a separate session 
							--Same <deviceRank>: same device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC7_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.9.2.2
			--Description: Register App1 from Device1
			   function Test:TC7_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					self.mobileSession11:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.9.2.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.9.2.4
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device1
			   function Test:TC7_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.9.2.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.9.2	
	
	
--=================================================END TEST CASES 9==========================================================--




--========================================FOR NON REMOTE CONTROL APPS========================================================--


--=================================================BEGIN TEST CASES 10==========================================================--
	--Begin Test suit CommonRequestCheck.10 for Req.#7

	--Description: 10. 2. In case the app registers with the same "appName" and different "appID" as the already registered one, SDL must return "resultCode: DUPLICATE_NAME, success: false" to such app.

	--Begin Test case CommonRequestCheck.10.1
	--Description: 	In case the app registers with the same "appName" and different "appID" as the already registered one, SDL must return "resultCode: DUPLICATE_NAME, success: false" to such app.
					--Same <deviceRank>: Different device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC10_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.2
			--Description: Connecting Device2 to RSDL
			function Test:TC10_ConnectDevice2()
			
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.10.1.3
			--Description: Register App1 from Device1
			   function Test:TC10_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						}
				   )
				   
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.10.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.10.1.4
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device2
			   function Test:TC10_App2FromDevice2() 

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
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="2",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="2",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.10.1.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.10.1	
	


	--Begin Test case CommonRequestCheck.10.2
	--Description: 	In case the app registers with the same "appName" and different "appID" as the already registered one, SDL must return "resultCode: DUPLICATE_NAME, success: false" to such app.
					--Same <deviceRank>: Same device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC10_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.10.2.2
			--Description: Register App1 from Device1
			   function Test:TC10_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						}
				   )
				   
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.10.2.2
			
		-----------------------------------------------------------------------------------------	
		
			--Begin Test case CommonRequestCheck.10.2.3
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device1
			   function Test:TC10_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="2",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="2",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.10.2.3
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.10.2
	
	
	
--=================================================END TEST CASES 10==========================================================--






--=================================================BEGIN TEST CASES 11==========================================================--
	--Begin Test suit CommonRequestCheck.11 for Req.#11

	--Description: 9. In case the app registers with the same "appName" and the same "appID" as the already registered one, SDL must return "resultCode: DUPLICATE_NAME, success: false" to such app.

	--Begin Test case CommonRequestCheck.11.1
	--Description: 	In case the app registers with the same "appName" and the same "appID" as the already registered one, SDL must return "resultCode: DUPLICATE_NAME, success: false" to such app.
							--Same <deviceRank>: different device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC11_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.2
			--Description: Connecting Device2 to RSDL
			function Test:TC11_ConnectDevice2()
			
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.11.1.2
			--Description: Register App1 from Device1
			   function Test:TC11_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION"},
							appID ="1",
						   
						}
				   )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.11.1.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.11.1.3
			--Description: Register App2 with the same <appName> and same <appID> from a passenger device2
			   function Test:TC11_App2FromDevice2() 

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
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.11.1.3
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.11.1
	


	--Begin Test case CommonRequestCheck.11.2
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
							-- and another REMOTE_CONTROL application with the same <appName> and the same <appID> from the same or another passenger's device requests registration via a separate session 
							--Same <deviceRank>: same device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DUPLICATE_NAME, success: false, params) 

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC11_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.11.2.2
			--Description: Register App1 from Device1
			   function Test:TC11_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
							appID ="1",
						   
						}
				   )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.11.2.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.11.2.4
			--Description: Register App2 with the same <appName> and same <appID> from a passenger device1
			   function Test:TC11_App2FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App1"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App1"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DUPLICATE_NAME"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.11.2.4
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.11.2	
	
	
--=================================================END TEST CASES 11==========================================================--





--=================================================BEGIN TEST CASES 12==========================================================--
	--Begin Test suit CommonRequestCheck.12 for Req.#12

	--Description: 12. In case the app registers with the same "appID" and different "appName" as the already registered one, SDL must return "resultCode: DISALLOWED, success: false" to such app.

	--Begin Test case CommonRequestCheck.12.1
	--Description: 	In case the app registers with the same "appID" and different "appName" as the already registered one, SDL must return "resultCode: DISALLOWED, success: false" to such app.
							--Same <deviceRank>: different device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DISALLOWED, success: false, params)

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC5_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.2
			--Description: Connecting Device2 to RSDL
			function Test:TC7_ConnectDevice2()
			
				newConnectionDevice2(self, device2, device2Port)

			end
			--End Test case Precondition.1.1.2
	
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.12.1.2
			--Description: Register App1 from Device1
			   function Test:TC5_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						}
				   )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.12.1.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.12.1.3
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device2
			   function Test:TC5_App2FromDevice2() 

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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App2"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App2"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession21:ExpectResponse(CorIdRAI, { success = false, resultCode = "DISALLOWED"},
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.12.1.3
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.12.1	
	


	--Begin Test case CommonRequestCheck.12.2
	--Description: 	In case a REMOTE_CONTROL application with <appName> and <appID> is registered with SDL from passenger's device 
							-- and another REMOTE_CONTROL application with the different <appName> and the same <appID> from the same or another passenger's device requests registration via a separate session 
							--Same <deviceRank>: same device

		--Requirement/Diagrams id in jira: 
				--REVSDL-1954

		--Verification criteria: 
				--RSDL must respond with RegisterAppInterface (resultCode: DISALLOWED, success: false, params)

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.1.1.1
			--Description: Register new session for register new apps
			function Test:TC5_NewApps()
			
			self.mobileSession11 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)					
				
			self.mobileSession12 = mobile_session.MobileSession(
				self.expectations_list,
				self.mobileConnection)	
				
			end
			--End Test case Precondition.1.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.12.2.2
			--Description: Register App1 from Device1
			   function Test:TC5_App1FromDevice1() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession11:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession11:SendRPC("RegisterAppInterface",
						   {
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
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

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession11:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"},
						{
							   
							syncMsgVersion = 
							{ 
							 majorVersion = 2,
							 minorVersion = 2,
							}, 
							appName ="App1",
							ttsName = 
							{ 
								 
								{ 
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						}
				   )
				   
				  end)    

			   end
			--End Test case CommonRequestCheck.12.2.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.12.2.3
			--Description: Register App2 with the same <appName> and different <appID> from a passenger device2
			   function Test:TC5_App2FromDevice2() 

				--mobile side: RegisterAppInterface request
				  self.mobileSession12:StartService(7)
				  :Do(function()    
				   local CorIdRAI = self.mobileSession12:SendRPC("RegisterAppInterface",
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
					  application = 
					  {
						appName = "App2"
					  }
					})
					:Times(0)
					:Do(function(_,data)
						self.applications["App2"] = data.params.application.appID
					end)						   

						   
				   --mobile side: RegisterAppInterface response 
				   self.mobileSession12:ExpectResponse(CorIdRAI, { success = false, resultCode = "DISALLOWED"},
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
									text ="Testes",
									type ="TEXT",
								}, 
							}, 
							vrSynonyms = 
							{ 
								"Testes",
							},
							isMediaApplication = true,
							languageDesired ="EN-US",
							hmiDisplayLanguageDesired ="EN-US",
							appHMIType = { "NAVIGATION" },
							appID ="1",
						   
						})
									   
				  end)    

			   end
			--End Test case CommonRequestCheck.12.2.3
			
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.12.2	
	
	
--=================================================END TEST CASES 12==========================================================--



		
return Test