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

---------------------------------------------------------------------------------------------
----------------------------------------END COMMON FUNCTIONS---------------------------------
---------------------------------------------------------------------------------------------



--======================================REVSDL-1749========================================--
---------------------------------------------------------------------------------------------
-----------REVSDL-1749: Subscriptions: reset upon device rank change and RC disabling--------
---------------------------------------------------------------------------------------------
--=========================================================================================--


--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: 1. In case RC app from driver's <deviceID> device is subscribed to InteriorVehicleData notifications in <module+zone> and RSDL gets RC.OnDeviceRankChanged ("PASSENGER", <deviceID>) from HMI
						-- RSDL must
						-- 1.1. internally unsubscribe this app
						-- 1.2. send RC.GetInteriorVehicleData ("subscribe:false", <module+zone>) to HMI.

	--Begin Test case CommonRequestCheck.1.1
	--Description: 	In case RC app from driver's <deviceID> device is subscribed to InteriorVehicleData notifications in <module+zone> and RSDL gets RC.OnDeviceRankChanged ("PASSENGER", <deviceID>) from HMI

		--Requirement/Diagrams id in jira:
				--REVSDL-1749
				--Diagram(See opt.#1): https://adc.luxoft.com/jira/secure/attachment/128872/128872_Model_subscriptions-taking-off.png

		--Verification criteria:
				--In case RC app from driver's <deviceID> device is subscribed to InteriorVehicleData notifications in <module+zone> and RSDL gets RC.OnDeviceRankChanged ("PASSENGER", <deviceID>) from HMI

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.0
			--Description: --Set device to Driver's device for precondition
				function Test:Pre_SetDriverDevice()
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for Driver's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

				end
			--End Test case CommonRequestCheck.1.1.0

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.1
			--Description: activate App1 to FULL
				function Test:Precondition_Activation()

					--hmi side: sending SDL.ActivateApp request
					local rid = self.hmiConnection:SendRequest("SDL.ActivateApp",
																{ appID = self.applications["Test Application"] })

					--hmi side: Waiting for SDL.ActivateApp response
					EXPECT_HMIRESPONSE(rid)
					self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "FULL" })
				end
			--End Test case CommonRequestCheck.3.2.1
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.1
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Driver and ModuleType = CLIMATE
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_DriverDriverCLIMATE()
					--mobile sends request for precondition as Driver
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
						--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									fanSpeed = 51,
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
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.1.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.2
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Front Passenger and ModuleType = CLIMATE
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_DriverFrontCLIMATE()
					--mobile sends request for precondition as Front Passenger
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
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

							--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
										fanSpeed = 51,
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
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.1.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.3
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Left Rare Passenger and ModuleType = CLIMATE
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_DriverLeftCLIMATE()
					--mobile side: --mobile sends request for precondition as Left Rare Passenger
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
									--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

									--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
									self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
												circulateAirEnable = false,
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
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.1.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.4
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Driver and ModuleType = RADIO
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_DriverDriverRADIO()
					--mobile sends request for precondition as Driver
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
							--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

							--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
										band = "AM",
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



					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.1.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.5
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Front Passenger and ModuleType = RADIO
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_DriverFrontRADIO()
					--mobile sends request for precondition as Front Passenger
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
									--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

									--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
									self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
												band = "AM",
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


					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.1.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.6
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Left Rare Passenger and ModuleType = RADIO
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_DriverLeftRADIO()
					--mobile sends request for precondition as Left Rare Passenger
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
									--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

									--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
									self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
												band = "AM",
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


					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.1.1.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.7
			--Description: --Set device to Passenger's device and checking Unsubscribed
				function Test:CheckUnsubscribedPassengerDevice()
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for Passenger's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )

					--RSDL -> HMI: RC.GetInteriorVehicleData ("subscribe:false", <module+zone>).
					EXPECT_HMICALL("RC.GetInteriorVehicleData",
					{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						}
					)
					:Times(6)
					:Do(function(_,data)
						--Send RC.OnInteriorVehicleData (<module+zone>) from emulation HMI.

						--table.print = print_r
						--table.print( data.params )

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									fanSpeed = 51,
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


						--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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
										fanSpeed = 51,
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


						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									circulateAirEnable = false,
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									band = "AM",
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									band = "AM",
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									band = "AM",
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

					--mobile side: App is unsubscribed and does not receive notification.
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(0)

				end
			--End Test case CommonRequestCheck.1.1.7

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.1.1


--=================================================END TEST CASES 1==========================================================--






--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2

	--Description: 2. In case RC app from passenger's <deviceID> device is subscribed to InteriorVehicleData notifications in <module+zone> and RSDL gets RC.OnDeviceRankChanged ("DRIVER", <deviceID>) from HMI
						-- RSDL must
						-- 2.1. internally unsubscribe this app
						-- 2.2. send RC.GetInteriorVehicleData ("subscribe:false", <module+zone>) to HMI.

	--Begin Test case CommonRequestCheck.2.1
	--Description: 	In case RC app from passenger's <deviceID> device is subscribed to InteriorVehicleData notifications in <module+zone> and RSDL gets RC.OnDeviceRankChanged ("DRIVER", <deviceID>) from HMI

		--Requirement/Diagrams id in jira:
				--REVSDL-1749
				--Diagram(See opt.#2): https://adc.luxoft.com/jira/secure/attachment/128872/128872_Model_subscriptions-taking-off.png

		--Verification criteria:
				--In case RC app from passenger's <deviceID> device is subscribed to InteriorVehicleData notifications in <module+zone> and RSDL gets RC.OnDeviceRankChanged ("DRIVER", <deviceID>) from HMI

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.1
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Driver and ModuleType = CLIMATE
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerDriverCLIMATE()
					--mobile sends request for precondition as Driver
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
						--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									fanSpeed = 51,
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
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.2.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.2
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Front Passenger and ModuleType = CLIMATE
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerFrontCLIMATE()
					--mobile sends request for precondition as Front Passenger
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
							--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

							--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
										fanSpeed = 51,
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
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.2.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.3
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Left Rare Passenger and ModuleType = CLIMATE
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerLeftCLIMATE()
					--mobile side: --mobile sends request for precondition as Left Rare Passenger
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
									--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

									--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
									self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
												circulateAirEnable = false,
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



					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.2.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.4
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Driver and ModuleType = RADIO
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerDriverRADIO()
					--mobile sends request for precondition as Driver
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
							--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

							--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
										band = "AM",
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



					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.2.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.5
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Front Passenger and ModuleType = RADIO
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerFrontRADIO()
					--mobile sends request for precondition as Front Passenger
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
									--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

									--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
									self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
												band = "AM",
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


					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.2.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.6
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Left Rare Passenger and ModuleType = RADIO
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerLeftRADIO()
					--mobile sends request for precondition as Left Rare Passenger
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
									--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

									--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
									self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
												band = "AM",
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


					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.2.1.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.7
			--Description: --Set device to Driver's device and checking Unsubscribed
				function Test:CheckUnsubscribedDriverDevice()
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

					--mobile side: Expect OnPermissionsChange notification for DRIVER's device
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

					--RSDL -> HMI: RC.GetInteriorVehicleData ("subscribe:false", <module+zone>).
					EXPECT_HMICALL("RC.GetInteriorVehicleData",
					{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						}
					)
					:Times(6)
					:Do(function(_,data)
						--Send RC.OnInteriorVehicleData (<module+zone>) from emulation HMI.

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									fanSpeed = 51,
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


						--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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
										fanSpeed = 51,
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


						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									circulateAirEnable = false,
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									band = "AM",
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									band = "AM",
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									band = "AM",
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

					--mobile side: App is unsubscribed and does not receive notification.
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(0)

				end
			--End Test case CommonRequestCheck.2.1.7

		-----------------------------------------------------------------------------------------

	--End Test case CommonRequestCheck.2.1


--=================================================END TEST CASES 2==========================================================--



--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: 3. In case RC app from passenger's <deviceID> device is subscribed to InteriorVehicleData notifications in <module+zone> and RSDL gets RC.OnReverseAppsAllowing (allowed: false) from HMI
						-- RSDL must
						-- 3.1. internally unsubscribe this app
						-- 3.2. send RC.GetInteriorVehicleData ("subscribe:false", <module+zone>) to HMI.

	--Begin Test case CommonRequestCheck.3.1
	--Description: 	In case RC app from passenger's <deviceID> device is subscribed to InteriorVehicleData notifications in <module+zone> and RSDL gets RC.OnReverseAppsAllowing (allowed: false) from HMI

		--Requirement/Diagrams id in jira:
				--REVSDL-1749
				--Diagram(See opt.#3): https://adc.luxoft.com/jira/secure/attachment/128872/128872_Model_subscriptions-taking-off.png

		--Verification criteria:
				--In case RC app from passenger's <deviceID> device is subscribed to InteriorVehicleData notifications in <module+zone> and RSDL gets RC.OnReverseAppsAllowing (allowed: false) from HMI

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.1
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Driver and ModuleType = CLIMATE
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerDriverCLIMATE()
					--mobile sends request for precondition as Driver
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
						--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									fanSpeed = 51,
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
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.3.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.2
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Front Passenger and ModuleType = CLIMATE
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerFrontCLIMATE()
					--mobile sends request for precondition as Front Passenger
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
							--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

							--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
										fanSpeed = 51,
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
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.3
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Left Rare Passenger and ModuleType = CLIMATE
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerLeftCLIMATE()
					--mobile side: --mobile sends request for precondition as Left Rare Passenger
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
									--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

									--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
									self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
												circulateAirEnable = false,
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



					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.3.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.4
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Driver and ModuleType = RADIO
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerDriverRADIO()
					--mobile sends request for precondition as Driver
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
							--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

							--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
										band = "AM",
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



					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.3.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.5
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Front Passenger and ModuleType = RADIO
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerFrontRADIO()
					--mobile sends request for precondition as Front Passenger
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
									--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

									--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
									self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
												band = "AM",
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


					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.3.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.6
			--Description: --1. Application sends GetInteriorVehicleData as Zone = Left Rare Passenger and ModuleType = RADIO
						   --2. HMI sends OnInteriorVehicleData notification to RSDL
				function Test:TC1_Pre_PassengerLeftRADIO()
					--mobile sends request for precondition as Left Rare Passenger
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
									--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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

									--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
									self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
												band = "AM",
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


					--mobile side: expect SUCCESS response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", isSubscribed = true})

					--mobile side: RSDL sends notifications to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)

				end
			--End Test case CommonRequestCheck.3.1.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.7
			--Description: --Disable RemoteControl from passenger's device and checking Unsubscribed
				function Test:CheckUnsubscribedDisableRC()

					--hmi side: Send valid RC.OnReverseAppsAllowing (allowed: false) from emulation HMI.
					self.hmiConnection:SendNotification("VehicleInfo.OnReverseAppsAllowing", {allowed = false})

					--mobile side: mobile receives notification
					EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRCNotification)

					--RSDL -> HMI: RC.GetInteriorVehicleData ("subscribe:false", <module+zone>).
					EXPECT_HMICALL("RC.GetInteriorVehicleData",
					{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						},
						{
							appID = self.applications["Test Application"],
							moduleDescription = {
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
							subscribe = false
						}
					)
					:Times(6)
					:Do(function(_,data)
						--Send RC.OnInteriorVehicleData (<module+zone>) from emulation HMI.

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									fanSpeed = 51,
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


						--hmi side: sending GetInteriorVehicleData_response (<module+zone>, "isSubscribed:true", resultCode:SUCCESS)
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
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
										fanSpeed = 51,
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


						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									circulateAirEnable = false,
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									band = "AM",
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									band = "AM",
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

						--hmi side: HMI sends OnInteriorVehicleData notification to RSDL
						self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
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
									band = "AM",
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

					--mobile side: App is unsubscribed and does not receive notification.
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(0)

				end
			--End Test case CommonRequestCheck.3.1.7

		-----------------------------------------------------------------------------------------

	--End Test case CommonRequestCheck.3.1


--=================================================END TEST CASES 3==========================================================--




return Test