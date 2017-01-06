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

--AppID configured in Preloaded PT file
local appid = "8675311"

						
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
	
	

--======================================REVSDL-2162========================================--
---------------------------------------------------------------------------------------------
----------REVSDL-2162: GetInteriorVehicleDataCapabilies - rules for policies checks----------
---------------------------------------------------------------------------------------------
--=========================================================================================--



--===============PLEASE USE PT FILE: "sdl_preloaded_pt.json" UNDER: \TestData\REVSDL-2162\ FOR THIS SCRIPT=====================--



--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: 1. In case 	a. remote-control passenger's app sends GetInteriorVehicleDataCapabilities request 
									-- > with defined zone 
									-- > with one moduleType in the array 
									-- and 
								-- b. RSDL has not received app's device location from the vehicle (via OnDeviceLocationChanged) 
									-- RSDL must 
									-- check "equipment" permissions against the zone from app's request. 
									-- Information: 
									-- per requirements from REVSDL-966: 
									-- -> if GetInteriorVehicleDataCapabilities is in "auto_allow", RSDL will transfer it to the vehicle 
									-- -> if GetInteriorVehicleDataCapabilities is in "driver_allow", RSDL will trigger a permission prompt (if accepted - then transfer app's request to the vehicle; if denied - then return "user_disallowed" to the app) 

	--Begin Test case CommonRequestCheck.1.1
	--Description: 	check "equipment" permissions against the zone from app's request in auto_allow

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- check "equipment" permissions against the zone from app's request. in auto_allow

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
<<<<<<< .mine
				function Test:AutoAllow_DriverRADIO()
=======
				function Test:TC_AutoAllow_DriverRADIO()
>>>>>>> .r913
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
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														interiorVehicleDataCapabilities = {
															{
																moduleZone = {
																	colspan = 2,
																	row = 0,
																	rowspan = 2,
																	col = 0,
																	levelspan = 1,
																	level = 0
																},
																moduleType = "RADIO"
															}
														}
						})
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
			--End Test case CommonRequestCheck.1.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.2
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = CLIMATE
				function Test:AutoAllow_DriverCLIMATE()
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
						moduleTypes = {"CLIMATE"}
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
					EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														interiorVehicleDataCapabilities = {
															{
																moduleZone = {
																	colspan = 2,
																	row = 0,
																	rowspan = 2,
																	col = 0,
																	levelspan = 1,
																	level = 0
																},
																moduleType = "CLIMATE"
															}
														}
						})
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
																									moduleType = "CLIMATE"
																								}
																							}
					})
				end
			--End Test case CommonRequestCheck.1.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.3
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = CLIMATE
				function Test:AutoAllow_FrontCLIMATE()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"CLIMATE"}
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
					EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														interiorVehicleDataCapabilities = {
															{
																moduleZone = {
																	colspan = 2,
																	row = 0,
																	rowspan = 2,
																	col = 1,
																	levelspan = 1,
																	level = 0
																},
																moduleType = "CLIMATE"
															}
														}
						})
					end)					
				
					--mobile side: expect SUCCESS response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																								{
																									moduleZone = {
																										col = 1,
																										row = 0,
																										level = 0,
																										colspan = 2,
																										rowspan = 2,
																										levelspan = 1
																									},
																									moduleType = "CLIMATE"
																								}
																							}
					})
				end
			--End Test case CommonRequestCheck.1.1.3

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.1.1.4
			--Description: application sends GetInteriorVehicleDataCapabilities as Right Passenger and ModuleType = RADIO
				function Test:AutoAllow_RightCLIMATE()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO"}
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
					EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														interiorVehicleDataCapabilities = {
															{
																moduleZone = {
																	colspan = 2,
																	row = 1,
																	rowspan = 2,
																	col = 1,
																	levelspan = 1,
																	level = 0
																},
																moduleType = "RADIO"
															}
														}
						})
					end)					
				
					--mobile side: expect SUCCESS response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																								{
																									moduleZone = {
																										col = 1,
																										row = 1,
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
			--End Test case CommonRequestCheck.1.1.4

		-----------------------------------------------------------------------------------------		
	--End Test case CommonRequestCheck.1.1


	--Begin Test case CommonRequestCheck.1.2
	--Description: 	check "equipment" permissions against the zone from app's request in driver_allow (denied)

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- check "equipment" permissions against the zone from app's request. in driver_allow (denied)

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.2.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:DriverAllow_FrontRADIO_Denied()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO"}
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
					
					
					--mobile side: expect USER_DISALLOWED response
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
					
				end
			--End Test case CommonRequestCheck.1.2.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.2.2
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:DriverAllow_LeftRADIO_Denied()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO"}
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
					end)
					
					
					--mobile side: expect USER_DISALLOWED response
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
					
				end
			--End Test case CommonRequestCheck.1.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.2.3
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = CLIMATE
				function Test:DriverAllow_LeftCLIMATE_Denied()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"CLIMATE"}
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
					
					
					--mobile side: expect USER_DISALLOWED response
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
					
				end
			--End Test case CommonRequestCheck.1.2.3

		-----------------------------------------------------------------------------------------	
		
	--End Test case CommonRequestCheck.1.2

	
	
	--Begin Test case CommonRequestCheck.1.3
	--Description: 	check "equipment" permissions against the zone from app's request in driver_allow (allowed)

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- check "equipment" permissions against the zone from app's request. in driver_allow (allowed)

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.3.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:DriverAllow_LeftRADIO_Allow()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO"}
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
				
						--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
						EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
						:Do(function(_,data)
							--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
															interiorVehicleDataCapabilities = {
																{
																	moduleZone = {
																		colspan = 2,
																		row = 1,
																		rowspan = 2,
																		col = 0,
																		levelspan = 1,
																		level = 0
																	},
																	moduleType = "RADIO"
																}
															}
							})
						end)					
					end)
					
					
					--mobile side: expect SUCCESS response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																								{
																									moduleZone = {
																										col = 0,
																										row = 1,
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
			--End Test case CommonRequestCheck.1.3.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.3.2
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = CLIMATE
				function Test:DriverAllow_LeftCLIMATE_Allow()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"CLIMATE"}
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
				
						--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
						EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
						:Do(function(_,data)
							--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
															interiorVehicleDataCapabilities = {
																{
																	moduleZone = {
																		colspan = 2,
																		row = 1,
																		rowspan = 2,
																		col = 0,
																		levelspan = 1,
																		level = 0
																	},
																	moduleType = "CLIMATE"
																}
															}
							})
						end)					
					end)
					
					
					--mobile side: expect SUCCESS response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																								{
																									moduleZone = {
																										col = 0,
																										row = 1,
																										level = 0,
																										colspan = 2,
																										rowspan = 2,
																										levelspan = 1
																									},
																									moduleType = "CLIMATE"
																								}
																							}
					})
					
				end
			--End Test case CommonRequestCheck.1.3.2

		-----------------------------------------------------------------------------------------
		
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.3.3
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:DriverAllow_FrontRADIO_Allow()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO"}
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
				
						--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
						EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
						:Do(function(_,data)
							--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
															interiorVehicleDataCapabilities = {
																{
																	moduleZone = {
																		colspan = 2,
																		row = 0,
																		rowspan = 2,
																		col = 1,
																		levelspan = 1,
																		level = 0
																	},
																	moduleType = "RADIO"
																}
															}
							})
						end)					
					end)
					
					
					--mobile side: expect SUCCESS response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																								{
																									moduleZone = {
																										col = 1,
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
			--End Test case CommonRequestCheck.1.3.3

		-----------------------------------------------------------------------------------------		
		
	--End Test case CommonRequestCheck.1.3	

	
--=================================================END TEST CASES 1==========================================================--	





--=================================================BEGIN TEST CASES 2.1==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2 (WITH DEFINED ZONE)

	--Description: 2. In case 	a. remote-control passenger's app sends GetInteriorVehicleDataCapabilities request 
									-- > with or without defined zone 
									-- > with one moduleType in the array 
									-- and 
								-- b. RSDL has received app's device location from the vehicle (via OnDeviceLocationChanged) 
									-- RSDL must 
									-- check "equipment" permissions against the zone from OnDeviceLocationChanged.
									-- Information: 
									-- per requirements from REVSDL-966: 
									-- -> if GetInteriorVehicleDataCapabilities is in "auto_allow", RSDL will transfer it to the vehicle 
									-- -> if GetInteriorVehicleDataCapabilities is in "driver_allow", RSDL will trigger a permission prompt (if accepted - then transfer app's request to the vehicle; if denied - then return "user_disallowed" to the app)

	--Begin Test case CommonRequestCheck.2.1
	--Description: 	RSDL has received app's device location from the vehicle (via OnDeviceLocationChanged)  in auto_allow

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- RSDL has received app's device location from the vehicle (via OnDeviceLocationChanged) in auto_allow

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
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO (app's requested zone is not exited)
				function Test:AutoAllow_DriverRADIO()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO"}
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
					EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														interiorVehicleDataCapabilities = {
															{
																moduleZone = {
																	colspan = 2,
																	row = 2,
																	rowspan = 2,
																	col = 2,
																	levelspan = 1,
																	level = 0
																},
																moduleType = "RADIO"
															}
														}
						})
					end)					
				
					--mobile side: expect SUCCESS response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																								{
																									moduleZone = {
																										col = 2,
																										row = 2,
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
			--End Test case CommonRequestCheck.2.1.1

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.1


	--Begin Test case CommonRequestCheck.2.2
	--Description: 	RSDL has received app's device location from the vehicle (via OnDeviceLocationChanged)  (denied)

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- check "equipment" permissions against the zone from app's request. in driver_allow (denied)

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

			--Begin Test case CommonRequestCheck.2.2.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:DriverAllow_FrontRADIO_Denied()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 2,
							row = 100,
							rowspan = 2,
							col = 100,
							levelspan = 1,
							level = 0
						},
						moduleTypes = {"RADIO"}
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
					
					
					--mobile side: expect USER_DISALLOWED response
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
					
				end
			--End Test case CommonRequestCheck.2.2.1

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.2

	
	
	--Begin Test case CommonRequestCheck.2.3
	--Description: 	RSDL has received app's device location from the vehicle (via OnDeviceLocationChanged)  (allowed)

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- check "equipment" permissions against the zone from app's request. in driver_allow (allowed)

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

			--Begin Test case CommonRequestCheck.2.3.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:DriverAllow_LeftRADIO_Allow()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 2,
							row = 100,
							rowspan = 2,
							col = 100,
							levelspan = 1,
							level = 0
						},
						moduleTypes = {"RADIO"}
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
				
						--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
						EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
						:Do(function(_,data)
							--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
															interiorVehicleDataCapabilities = {
																{
																	moduleZone = {
																		colspan = 2,
																		row = 100,
																		rowspan = 2,
																		col = 100,
																		levelspan = 1,
																		level = 0
																	},
																	moduleType = "RADIO"
																}
															}
							})
						end)					
					end)
					
					
					--mobile side: expect SUCCESS response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																								{
																									moduleZone = {
																										col = 100,
																										row = 100,
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
			--End Test case CommonRequestCheck.2.3.1

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.3	

	
--=================================================END TEST CASES 2.1==========================================================--





--=================================================BEGIN TEST CASES 2.2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2 (WITHOUT DEFINED ZONE)

	--Description: 2. In case 	a. remote-control passenger's app sends GetInteriorVehicleDataCapabilities request 
									-- > with or without defined zone 
									-- > with one moduleType in the array 
									-- and 
								-- b. RSDL has received app's device location from the vehicle (via OnDeviceLocationChanged) 
									-- RSDL must 
									-- check "equipment" permissions against the zone from OnDeviceLocationChanged.
									-- Information: 
									-- per requirements from REVSDL-966: 
									-- -> if GetInteriorVehicleDataCapabilities is in "auto_allow", RSDL will transfer it to the vehicle 
									-- -> if GetInteriorVehicleDataCapabilities is in "driver_allow", RSDL will trigger a permission prompt (if accepted - then transfer app's request to the vehicle; if denied - then return "user_disallowed" to the app)

	--Begin Test case CommonRequestCheck.2.1
	--Description: 	RSDL has received app's device location from the vehicle (via OnDeviceLocationChanged)  in auto_allow

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- RSDL has received app's device location from the vehicle (via OnDeviceLocationChanged) in auto_allow

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
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO (app's requested zone is not exited)
				function Test:AutoAllow_DriverRADIO()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO"}
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
					EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														interiorVehicleDataCapabilities = {
															{
																moduleZone = {
																	colspan = 2,
																	row = 2,
																	rowspan = 2,
																	col = 2,
																	levelspan = 1,
																	level = 0
																},
																moduleType = "RADIO"
															}
														}
						})
					end)					
				
					--mobile side: expect SUCCESS response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																								{
																									moduleZone = {
																										col = 2,
																										row = 2,
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
			--End Test case CommonRequestCheck.2.1.1

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.1


	--Begin Test case CommonRequestCheck.2.2
	--Description: 	RSDL has received app's device location from the vehicle (via OnDeviceLocationChanged)  (denied)

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- check "equipment" permissions against the zone from app's request. in driver_allow (denied)

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

			--Begin Test case CommonRequestCheck.2.2.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:DriverAllow_FrontRADIO_Denied()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO"}
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
					
					
					--mobile side: expect USER_DISALLOWED response
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
					
				end
			--End Test case CommonRequestCheck.2.2.1

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.2

	
	
	--Begin Test case CommonRequestCheck.2.3
	--Description: 	RSDL has received app's device location from the vehicle (via OnDeviceLocationChanged)  (allowed)

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- check "equipment" permissions against the zone from app's request. in driver_allow (allowed)

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

			--Begin Test case CommonRequestCheck.2.3.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:DriverAllow_LeftRADIO_Allow()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO"}
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
				
						--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
						EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
						:Do(function(_,data)
							--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
															interiorVehicleDataCapabilities = {
																{
																	moduleZone = {
																		colspan = 2,
																		row = 100,
																		rowspan = 2,
																		col = 100,
																		levelspan = 1,
																		level = 0
																	},
																	moduleType = "RADIO"
																}
															}
							})
						end)					
					end)
					
					
					--mobile side: expect SUCCESS response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
																								{
																									moduleZone = {
																										col = 100,
																										row = 100,
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
			--End Test case CommonRequestCheck.2.3.1

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.3	

	
--=================================================END TEST CASES 2.2==========================================================--





--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: 3. In case 	a. remote-control passenger's app sends GetInteriorVehicleDataCapabilities request 
									-- > with or without defined zone 
									-- > with more than one OR without moduleType in the array 
									-- and 
								-- b. RSDL has or has not received app's device location from the vehicle (via OnDeviceLocationChanged) 
									-- RSDL must 
									-- respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 

	--Begin Test case CommonRequestCheck.3.1
	--Description: 	check "equipment" permissions against the zone from app's request with OR without defined "zone" and more than one OR without "moduleType"

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- check "equipment" permissions against the zone from app's request.

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:DriverRADIO_DISALLOWED()
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
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.2
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:FrontRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.3
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:LeftRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.4
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:Driver_DISALLOWED()
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
						}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.5
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:Front_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.5

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.6
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:Left_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.6

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.7
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.7

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.8
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.8

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.2.9
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.9

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

			--Begin Test case CommonRequestCheck.3.2.10
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:WithoutModuleTypeAndZone_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.10

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.1
	
	


	--Begin Test case CommonRequestCheck.3.2
	--Description: 	check "equipment" permissions against the zone from app's request with OR without defined "zone" and more than one OR without "moduleType"
					-- and RSDL receives OnDeviceLocationChanged notification

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- check "equipment" permissions against the zone from app's request.

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

			--Begin Test case CommonRequestCheck.3.1.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:DriverRADIO_DISALLOWED()
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
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.2
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:FrontRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.3
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:LeftRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.4
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:Driver_DISALLOWED()
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
						}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.5
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:Front_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.5

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.6
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:Left_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.6

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.7
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.7

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.8
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.8

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.2.9
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.10
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:WithoutModuleTypeAndZone_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.10

		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK LEFT PASSENGER ZONE------------------------------------
				
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

			--Begin Test case CommonRequestCheck.3.1.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:DriverRADIO_DISALLOWED()
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
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.2
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:FrontRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.3
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:LeftRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.4
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:Driver_DISALLOWED()
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
						}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.5
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:Front_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.5

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.6
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:Left_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.6

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.7
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.7

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.8
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.8

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.2.9
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.10
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:WithoutModuleTypeAndZone_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.10

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
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:DriverRADIO_DISALLOWED()
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
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.2
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:FrontRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.3
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:LeftRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.4
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:Driver_DISALLOWED()
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
						}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.5
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:Front_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.5

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.6
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:Left_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.6

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.7
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.7

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.8
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.8

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.2.9
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.10
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:WithoutModuleTypeAndZone_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.10

		-----------------------------------------------------------------------------------------
		-------------------------FOR BACK RIGHT PASSENGER ZONE----------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK Right Passenger)
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

			--Begin Test case CommonRequestCheck.3.1.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:DriverRADIO_DISALLOWED()
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
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.2
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:FrontRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.3
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:LeftRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.4
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:Driver_DISALLOWED()
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
						}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.5
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:Front_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.5

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.6
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:Left_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.6

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.7
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.7

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.8
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.8

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.2.9
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.10
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:WithoutModuleTypeAndZone_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.10

		-----------------------------------------------------------------------------------------
		-------------------------FOR THE ZONE IS NOT EXISTED-------------------------------------
				
			--Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK Right Passenger)
			--Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
			
				function Test:ChangedLocation_Right()
					--hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
					self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged", 
						{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}, 
							deviceLocation =
								{
									colspan = 2,
									row = 100,
									rowspan = 2,
									col = 100,
									levelspan = 1,
									level = 0
								}
						})
				end
			--End Precondition.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:DriverRADIO_DISALLOWED()
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
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.1

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.2
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:FrontRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.3
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:LeftRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.4
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:Driver_DISALLOWED()
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
						}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.1.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.5
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:Front_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.5

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.1.6
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:Left_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
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
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.1.6

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.7
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "CLIMATE"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.7

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.2.8
			--Description: application sends GetInteriorVehicleDataCapabilities as Front Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.8

		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.3.2.9
			--Description: application sends GetInteriorVehicleDataCapabilities as Left Passenger and ModuleType = RADIO
				function Test:RADIO_CLIMATE_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"CLIMATE", "CLIMATE", "RADIO"}
					})
					
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
					
				end
			--End Test case CommonRequestCheck.3.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.10
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:WithoutModuleTypeAndZone_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: one moduleType must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: one moduleType must be provided" })
				end
			--End Test case CommonRequestCheck.3.2.10

		-----------------------------------------------------------------------------------------
		
	--End Test case CommonRequestCheck.3.2	

	
--=================================================END TEST CASES 3==========================================================--





--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for Req.#4

	--Description: 4. In case 	a. remote-control driver's app sends GetInteriorVehicleDataCapabilities request (with any set of parameters) 
								-- RSDL must check this app's assigned policies and transfer only allowed moduleTypes via RC.GetInteriorVehicleDataCapabilities to the vehicle

	--Begin Test case CommonRequestCheck.4.1
	--Description: 	RSDL must check this app's assigned policies and transfer only allowed moduleTypes via RC.GetInteriorVehicleDataCapabilities to the vehicle

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- RSDL must check this app's assigned policies and transfer only allowed moduleTypes via RC.GetInteriorVehicleDataCapabilities to the vehicle

		-----------------------------------------------------------------------------------------
		
			--Begin Test case Precondition.4.1
			--Description: Register new session for register new apps
				function Test:TC4_NewApps()
				
				  self.mobileSession1 = mobile_session.MobileSession(
					self.expectations_list,
					self.mobileConnection)
					
				end
			--End Test case Precondition.4.1
			
		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.4.1
			--Description: Register new session for register new apps
				function Test:TC4_RegisterAppID()
				
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
								appID = appid,
							   
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
					   self.mobileSession1:ExpectResponse(CorIdRAI, { success = true, resultCode = "WARNINGS"},
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
								appID = appid,
							   
							}
					   )
					   
						--mobile side: Expect OnPermissionsChange notification for Passenger's device
						self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )				
					end)
					
				end
			--End Test case Precondition.4.1
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.4.1.1
			--Description: Set device1 to Driver's device from HMI
				function Test:OnDeviceRankChanged_Driver()

					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})
					
					--mobile side: Expect OnPermissionsChange notification for Driver's device
					self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
					
					--mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
					self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })					
				
				end
			--End Test case CommonRequestCheck.4.1.1
	
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.4.1.2
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:AutoAllow_DriverRADIO()
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleDataCapabilities",
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
						moduleTypes = {"RADIO", "RADIO", "CLIMATE"}
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
					EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														interiorVehicleDataCapabilities = {
															{
																moduleZone = {
																	colspan = 2,
																	row = 0,
																	rowspan = 2,
																	col = 0,
																	levelspan = 1,
																	level = 0
																},
																moduleType = "RADIO"
															},
															{
																moduleZone = {
																	colspan = 2,
																	row = 0,
																	rowspan = 2,
																	col = 0,
																	levelspan = 1,
																	level = 0
																},
																moduleType = "RADIO"
															}
														}
						})
					end)					
				
					--mobile side: expect SUCCESS response
					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
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
																								},
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
			--End Test case CommonRequestCheck.4.1.2

		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.1.3
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and without ModuleType
				function Test:AutoAllow_DriverWithoutModuleType()
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						zone =
						{
							colspan = 2,
							row = 0,
							rowspan = 2,
							col = 0,
							levelspan = 1,
							level = 0
						}
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
					EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														interiorVehicleDataCapabilities = {
															{
																moduleZone = {
																	colspan = 2,
																	row = 0,
																	rowspan = 2,
																	col = 0,
																	levelspan = 1,
																	level = 0
																},
																moduleType = "RADIO"
															}
														}
						})
					end)					
				
					--mobile side: expect SUCCESS response
					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
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
			--End Test case CommonRequestCheck.4.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.3
			--Description: application sends GetInteriorVehicleDataCapabilities missing zone and ModuleType
				function Test:AutoAllow_MissingZoneAndModuleType()
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleDataCapabilities",
					{
					
					})
					
					--hmi side: expect RC.GetInteriorVehicleDataCapabilities request
					EXPECT_HMICALL("RC.GetInteriorVehicleDataCapabilities")
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														interiorVehicleDataCapabilities = {
															{
																moduleZone = {
																	colspan = 2,
																	row = 0,
																	rowspan = 2,
																	col = 0,
																	levelspan = 1,
																	level = 0
																},
																moduleType = "RADIO"
															}
														}
						})
					end)					
				
					--mobile side: expect SUCCESS response
					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
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
			--End Test case CommonRequestCheck.4.1.3

		-----------------------------------------------------------------------------------------		
		
	--End Test case CommonRequestCheck.4.1

	
--=================================================END TEST CASES 4==========================================================--




<<<<<<< .mine
=======


>>>>>>> .r907
--=================================================BEGIN TEST CASES 5==========================================================--
	--Begin Test suit CommonRequestCheck.5 for Req.#5

	--Description: 3. In case 	a. remote-control passenger's app sends GetInteriorVehicleDataCapabilities request 
									-- > without defined zone 
									-- > with one moduleType in the array 
									-- and 
								-- b. RSDL has not received app's device location from the vehicle (via OnDeviceLocationChanged) 
									-- RSDL must respond with (DISALLOWED, success:false, "Information: zone must be provided") 

	--Begin Test case CommonRequestCheck.5.1
	--Description: 	RSDL must respond with (DISALLOWED, success:false, "Information: zone must be provided") 

		--Requirement/Diagrams id in jira: 
				--REVSDL-2162

		--Verification criteria: 
				-- RSDL must respond with (DISALLOWED, success:false, "Information: zone must be provided") 

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.1
			--Description: application sends GetInteriorVehicleDataCapabilities as Driver and ModuleType = RADIO
				function Test:PassengerRADIO_DISALLOWED()
					local cid = self.mobileSession:SendRPC("GetInteriorVehicleDataCapabilities",
					{
						moduleTypes = {"RADIO"}
					})
					
				
					--RSDL must respond with (DISALLOWED, success:false, "Information: zone must be provided") 
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "Information: zone must be provided" })
				end
			--End Test case CommonRequestCheck.5.1.1

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.1

	
--=================================================END TEST CASES 5==========================================================--

		
return Test