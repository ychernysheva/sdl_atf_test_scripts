local commonSteps = require("user_modules/shared_testcases/commonSteps")
commonSteps:DeleteLogsFileAndPolicyTable()

revsdl = require("user_modules/revsdl")

revsdl.AddUnknownFunctionIDs()
revsdl.SubscribeToRcInterface()
config.ValidateSchema = false
config.application1.registerAppInterfaceParams.appHMIType = { "REMOTE_CONTROL" }

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
local device2 = "172.30.192.146"
local device2Port = 12345
--2. Device 3:
local device3 = "192.168.101.199"
local device3Port = 12345
---------------------------------------------------------------------------------------------



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
		self,
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
		self,
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






--======================================REVSDL-1577========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1577: A device previously set as "driver's" must be---------------------
------------------------------ switchable to "passenger's"-----------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--




--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1 (TCs: REVSDL-1616 - [REVSDL-1577][TC-04]: RSDL sets device as driver in case receiving RC.OnDeviceRankChanged ("DRIVER", deviceID).)

	--Description: In case RSDL receives RC.OnDeviceRankChanged ("DRIVER", deviceID) from HMI, Rev-SDL must set the named device as driver's one.


	--Begin Test case CommonRequestCheck.1
	--Description: 	In case RSDL receives RC.OnDeviceRankChanged ("DRIVER", deviceID) from HMI, Rev-SDL must set the named device as driver's one.


		--Requirement/Diagrams id in jira:
				--REVSDL-1577
				--TC: REVSDL-1616, REVSDL-1617

		--Verification criteria:
				--In case RSDL receives RC.OnDeviceRankChanged ("DRIVER", deviceID) from HMI, Rev-SDL must set the named device as driver's one.

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1
			--Description: Set device1 to Driver's device from HMI (TC: REVSDL-1617)
				function Test:OnDeviceRankChanged_Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

				end
			--End Test case CommonRequestCheck.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.2
			--Description: Set device1 to Passenger's device from HMI (TC: REVSDL-1616)
				function Test:OnDeviceRankChanged_Passenger()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for Passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )

					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

				end
			--End Test case CommonRequestCheck.1.2

		-----------------------------------------------------------------------------------------

	--End Test case CommonRequestCheck.1

--=================================================END TEST CASES 1==========================================================--






--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2 (TCs: REVSDL-1618 - [REVSDL-1577][TC-06]: Switch from driver's to passenger's device and vice versa when receiving OnDeviceRankChanged().)

	--Description: In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("DRIVER", deviceID) for another device comes from HMI, RSDL must set the named device as driver's and set the previous one to passenger's.


	--Begin Test case CommonRequestCheck.2.1
	--Description: 	In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("DRIVER", deviceID) for another device comes from HMI, RSDL must set the named device as driver's and set the previous one to passenger's.


		--Requirement/Diagrams id in jira:
				--REVSDL-1577
				--TC: REVSDL-1618

		--Verification criteria:
				--In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("DRIVER", deviceID) for another device comes from HMI, RSDL must set the named device as driver's and set the previous one to passenger's.

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.1
			--Description: Connect device2 for precondition
				function Test:ConnectDevice2()

					newConnectionDevice2(self, device2, device2Port)

				end
			--End Test case Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.2
			--Description: Register App from Device2
				function Test:App1Device2Register()

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
			--End Test case Precondition.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.1
			--Description: Set device1 to Driver's device from HMI
				function Test:OnDeviceRankChanged_Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

				end
			--End Test case CommonRequestCheck.2.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.2
			--Description: Set device2 to Driver's device from HMI, after that Device1 become Passenger's device.
				function Test:OnDeviceRankChanged_SetAnotherToDriver()

					--hmi side: send request RC.OnDeviceRankChanged to Device2
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "DRIVER", device = {name = device2, id = 2, isSDLAllowed = true}})

					--APP FROM DEVICE1:
					--mobile side: Expect OnPermissionsChange notification for Device1 is Passenger
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

					--APP FROM DEVICE2:
					self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					self.mobileSession21:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

				end
			--End Test case CommonRequestCheck.2.1.2

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.1


--=================================================END TEST CASES 2==========================================================--




--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3 (TCs: REVSDL-1617 - [REVSDL-1577][TC-05]: RSDL sets device as passenger in case receiving RC.OnDeviceRankChanged ("PASSENGER", deviceID))

	--Description: In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's


	--Begin Test case CommonRequestCheck.3.1
	--Description: 	In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's


		--Requirement/Diagrams id in jira:
				--REVSDL-1577

		--Verification criteria:
				--In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.1
			--Description: Set device1 to Driver's device from HMI
				function Test:OnDeviceRankChanged_Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

				end
			--End Test case CommonRequestCheck.3.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.2
			--Description: Set device1 to Passenger's device from HMI
				function Test:OnDeviceRankChanged_DriverToPassenger()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for Passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )

					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

				end
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.1


	--Begin Test case CommonRequestCheck.3.2
	--Description: 	In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's


		--Requirement/Diagrams id in jira:
				--REVSDL-1577
				--TC: REVSDL-1619

		--Verification criteria:
				--In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.1
			--Description: Set device1 to Driver's device from HMI
				function Test:TC3_Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

				end
			--End Test case CommonRequestCheck.3.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.2
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (SUCCESS)
				function Test:TC3_App1ButtonPress()
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

					--App_1 recevies SUCCESS.
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.3
			--Description: activate App1 to FULL
				function Test:TC3_App1FULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp",
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL"})
				end
			--End Test case CommonRequestCheck.3.2.3

		-----------------------------------------------------------------------------------------

		--Begin Test case CommonRequestCheck.3.2.4
			--Description: Positive case and in boundary conditions (SUCCESS)
			function Test:TC3_ShowUI_SUCCESS()

				--mobile side: sending Show request
				local cid = self.mobileSession:SendRPC("Show",
														{
															mainField1 = "Show Line 1"
														})
				--hmi side: expect UI.Show request
				EXPECT_HMICALL("UI.Show",
								{

									showStrings =
									{
										{
										fieldName = "mainField1",
										fieldText = "Show Line 1"
										}
									}
								})
					:Do(function(_,data)
						--hmi side: sending UI.Show response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)

				--mobile side: expect Show response SUCCESS
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })

			end
		--End Test case CommonRequestCheck.3.2.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.5
			--Description: Set device1 to Passenger's device from HMI
				function Test:TC3_DriverToPassenger()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for Passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )

					--mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", deviceRank = "PASSENGER" })

				end
			--End Test case CommonRequestCheck.3.2.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.6
			--Description: application sends ButtonPress as Front Passenger (driver_allow SUCCESS)
				function Test:TC3_App1DriverAllow()
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

					--App_1 recevies SUCCESS.
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.2.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.7
			--Description: application sends ButtonPress as Driver (auto_allow SUCCESS)
				function Test:TC3_App1AutoAllow()
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
			--End Test case CommonRequestCheck.3.2.7

		-----------------------------------------------------------------------------------------

		--Begin Test case CommonRequestCheck.3.2.4
			--Description: Positive case and in boundary conditions (DISALLOWED)
			function Test:TC3_ShowUI_DISALLOWED()

				--mobile side: sending Show request
				local cid = self.mobileSession:SendRPC("Show",
														{
															mainField1 = "Show Line 1"
														})

				--mobile side: expect Show response DISALLOWED
				EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED" })

			end
		--End Test case CommonRequestCheck.3.2.4

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.2


	--Begin Test case CommonRequestCheck.3.3 (restart SDL before running this test suite)
	--Description: 	In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's


		--Requirement/Diagrams id in jira:
				--REVSDL-1577
				--TC: REVSDL-1620

		--Verification criteria:
				--In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("PASSENGER", deviceID) for the same device comes from HMI, RSDL must set this device as passenger's

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.3.1
			--Description: application sends ButtonPress as Front Passenger (driver_allow SUCCESS)
				function Test:TC3_App1DriverAllow()
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

					--App_1 recevies SUCCESS.
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.3.2
			--Description: application sends ButtonPress as Driver (auto_allow SUCCESS)
				function Test:TC3_App1AutoAllow()
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
			--End Test case CommonRequestCheck.3.3.2

		-----------------------------------------------------------------------------------------

		--Begin Test case CommonRequestCheck.3.3.3
			--Description: Positive case and in boundary conditions (DISALLOWED)
			function Test:TC3_ShowUI_DISALLOWED()

				--mobile side: sending Show request
				local cid = self.mobileSession:SendRPC("Show",
														{
															mainField1 = "Show Line 1"
														})

				--mobile side: expect Show response DISALLOWED
				EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED" })

			end
		--End Test case CommonRequestCheck.3.3.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.3.4
			--Description: Set device1 to Driver's device from HMI
				function Test:TC3_Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

				end
			--End Test case CommonRequestCheck.3.3.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.3.5
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (SUCCESS)
				function Test:TC3_App1ButtonPress()
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

					--App_1 recevies SUCCESS.
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.3.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.3.6
			--Description: activate App1 to FULL
				function Test:TC3_App1FULL()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp",
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL" })
				end
			--End Test case CommonRequestCheck.3.3.6

		-----------------------------------------------------------------------------------------

		--Begin Test case CommonRequestCheck.3.3.7
			--Description: Positive case and in boundary conditions (SUCCESS)
			function Test:TC3_ShowUI_SUCCESS()

				--mobile side: sending Show request
				local cid = self.mobileSession:SendRPC("Show",
														{
															mainField1 = "Show Line 1"
														})
				--hmi side: expect UI.Show request
				EXPECT_HMICALL("UI.Show",
								{

									showStrings =
									{
										{
										fieldName = "mainField1",
										fieldText = "Show Line 1"
										}
									}
								})
					:Do(function(_,data)
						--hmi side: sending UI.Show response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)

				--mobile side: expect Show response SUCCESS
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })

			end
		--End Test case CommonRequestCheck.3.3.7

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.3

--=================================================END TEST CASES 3==========================================================--











return Test