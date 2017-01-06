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
-------------------------------------STARTING COMMON FUNCTIONS-------------------------------
---------------------------------------------------------------------------------------------

--Creating array list for moduleTypes parameter.
-------strModuleType<String>: "RADIO" or "CLIMATE"
-------iMaxsize<Integer>	: the length or array
local function CreateModuleTypes(strModuleType, iMaxsize)	
	local items = {}
	for i=1, iMaxsize do
		table.insert(items, i, strModuleType)
	end
	return items
end

--Creating an interiorVehicleDataCapability with specificed zone and moduleType
local function interiorVehicleDataCapability(strModuleType, icol, icolspan, ilevel, ilevelspan, irow, irowspan)
	return{
			moduleZone = {
				col = icol,
				colspan = icolspan,
				level = ilevel,
				levelspan = ilevelspan,
				row = irow,
				rowspan=  irowspan
			},
			moduleType = strModuleType
	}
end

--Creating an interiorVehicleDataCapabilities array with maxsize = iMaxsize
local function interiorVehicleDataCapabilities(strModuleType, icol, icolspan, ilevel, ilevelspan, irow, irowspan, iMaxsize)	
	local items = {}
	if iItemCount == 1 then
		table.insert(items, interiorVehicleDataCapability(strModuleType, icol, icolspan, ilevel, ilevelspan, irow, irowspan))
	else
		for i=1, iMaxsize do
			table.insert(items, interiorVehicleDataCapability(strModuleType, icol, icolspan, ilevel, ilevelspan, irow, irowspan))
		end	
	end
	return items
end

---------------------------------------------------------------------------------------------
----------------------------------------END COMMON FUNCTIONS---------------------------------
---------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------
	--Begin Precondition.1. Need to be uncomment for checking Driver's device case
	--[[Description: Activation App by sending SDL.ActivateApp
	
		function Test:WaitActivation()
		
			--mobile side: Expect OnHMIStatus notification
			EXPECT_NOTIFICATION("OnHMIStatus")

			--hmi side: sending SDL.ActivateApp request
			local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", 
														{ appID = self.applications["Test Application"] })
														
			--hmi side: send request RC.OnSetDriversDevice
			self.hmiConnection:SendNotification("RC.OnSetDriversDevice", 
			{device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})															

			--hmi side: Waiting for SDL.ActivateApp response
			EXPECT_HMIRESPONSE(rid)

		end]]
	--End Precondition.1

	-----------------------------------------------------------------------------------------
	


---------------------------------------------------------------------------------------------
-----------------------REVSDL-1038: HMI's RPCs validation rules------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
	--Begin Test suit CommonRequestCheck

	--Description: RSDL must validate each and every RPC (that is, responses and notifications) that HMI sends per "Remote-Control-API" ([attached|^SDL_RC_HMI_API_from_Ford_v2.xml]).
		-- Invalid response expected by mobile app
		-- Invalid response expected by RSDL
		-- Invalid notification
		-- Fake params
	

	
--=================================================BEGIN TEST CASES 1==========================================================--	
	
	--Begin Test case ResponseMissingCheck.1
	--Description: 	--Invalid response expected by mobile app

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<2.>In case a mobile app sends a valid request to RSDL, RSDL transfers this request to HMI, and HMI responds with one or more of mandatory per rc-HMI_API params missing to RSDL, RSDL must log an error and respond with "resultCode: GENERIC_ERROR, success: false, info: 'Invalid response from the vehicle'" to this mobile app's request (Exception: GetInteriorVehicleData, see REVSDL-991).
				--<TODO>: REVSDL-1418 Need to update script after for this question
				
			--Begin Test case ResponseMissingCheck.1.1
			--Description: Check processing response with interiorVehicleDataCapabilities missing
				function Test:GetInteriorVehicleDataCapabilities_ResponseMissingInteriorVehicleDataCapabilities()
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
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
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
			--End Test case ResponseMissingCheck.1.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.2
			--Description: Check processing response with moduleZone missing
				function Test:GetInteriorVehicleDataCapabilities_ResponseMissingModuleZone()
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
			--End Test case ResponseMissingCheck.1.2
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseMissingCheck.1.3
			--Description: Check processing response with col missing
				function Test:GetInteriorVehicleDataCapabilities_ResponseMissingCol()
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
																						level = 0,
																						levelspan = 1,
																						row = 0,
																						rowspan=  2
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
			--End Test case ResponseMissingCheck.1.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.4
			--Description: Check processing response with colspan missing
				function Test:GetInteriorVehicleDataCapabilities_ResponseMissingColspan()
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
																						col = 0,
																						level = 0,
																						levelspan = 1,
																						row = 0,
																						rowspan=  2
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
			--End Test case ResponseMissingCheck.1.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.5
			--Description: Check processing response with level missing
				function Test:GetInteriorVehicleDataCapabilities_ResponseMissingLevel()
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
																						col = 0,
																						colspan = 2,
																						levelspan = 1,
																						row = 0,
																						rowspan=  2
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
			--End Test case ResponseMissingCheck.1.5

		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.6
			--Description: Check processing response with levelspan missing
				function Test:GetInteriorVehicleDataCapabilities_ResponseMissingLevelspan()
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
																						col = 0,
																						colspan = 2,
																						level = 0,
																						row = 0,
																						rowspan=  2
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
			--End Test case ResponseMissingCheck.1.6

		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseMissingCheck.1.7
			--Description: Check processing response with row missing
				function Test:GetInteriorVehicleDataCapabilities_ResponseMissingRow()
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
																						col = 0,
																						colspan = 2,
																						level = 0,
																						levelspan = 1,
																						rowspan=  2
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
			--End Test case ResponseMissingCheck.1.7

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.8
			--Description: Check processing response with rowspan missing
				function Test:GetInteriorVehicleDataCapabilities_ResponseMissingRowspan()
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
																						col = 0,
																						colspan = 2,
																						level = 0,
																						levelspan = 1,
																						row = 0
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
			--End Test case ResponseMissingCheck.1.8

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.9
			--Description: Check processing response with moduleType missing
				function Test:GetInteriorVehicleDataCapabilities_ResponseMissingModuleType()
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
																						col = 0,
																						colspan = 2,
																						level = 0,
																						levelspan = 1,
																						row = 0,
																						rowspan=  2
																					}
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
			--End Test case ResponseMissingCheck.1.9

		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.10
			--Description: Check processing response with moduleData missing
				function Test:SetInteriorVehicleData_ResponseMissingModuleData()
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
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.10
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.11
			--Description: Check processing response with moduleType missing
				function Test:SetInteriorVehicleData_ResponseMissingModuleType()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.11
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.12
			--Description: Check processing response with moduleZone missing
				function Test:SetInteriorVehicleData_ResponseMissingModuleZone()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.12
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.13
			--Description: Check processing response with colspan missing
				function Test:SetInteriorVehicleData_ResponseMissingColspan()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.13
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.14
			--Description: Check processing response with row missing
				function Test:SetInteriorVehicleData_ResponseMissingRow()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.14
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.15
			--Description: Check processing response with rowspan missing
				function Test:SetInteriorVehicleData_ResponseMissingRowspan()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.15
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.16
			--Description: Check processing response with col missing
				function Test:SetInteriorVehicleData_ResponseMissingCol()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.16
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseMissingCheck.1.17
			--Description: Check processing response with levelspan missing
				function Test:SetInteriorVehicleData_ResponseMissingLevelspan()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.17
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.18
			--Description: Check processing response with level missing
				function Test:SetInteriorVehicleData_ResponseMissingLevel()
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
																levelspan = 1
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.18
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.20
			--Description: Check processing response with climateControlData missing
				function Test:SetInteriorVehicleData_ResponseMissingClimateControlData()
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
															}
														}		
						})
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				
				end
			--End Test case ResponseMissingCheck.1.20
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.21
			--Description: Check processing response with fanSpeed missing
				function Test:SetInteriorVehicleData_ResponseMissingFanSpeed()
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
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.21
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.22
			--Description: Check processing response with circulateAirEnable missing
				function Test:SetInteriorVehicleData_ResponseMissingCirculateAirEnable()
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
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.22
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.23
			--Description: Check processing response with dualModeEnable missing
				function Test:SetInteriorVehicleData_ResponseMissingDualModeEnable()
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
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.23
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.24
			--Description: Check processing response with currentTemp missing
				function Test:SetInteriorVehicleData_ResponseMissingCurrentTemp()
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
			--End Test case ResponseMissingCheck.1.24
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.25
			--Description: Check processing response with defrostZone missing
				function Test:SetInteriorVehicleData_ResponseMissingDefrostZone()
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
								fandSpeed = 50,
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
			--End Test case ResponseMissingCheck.1.25
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.26
			--Description: Check processing response with acEnable missing
				function Test:SetInteriorVehicleData_ResponseMissingAcEnable()
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
			--End Test case ResponseMissingCheck.1.26
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.27
			--Description: Check processing response with desiredTemp missing
				function Test:SetInteriorVehicleData_ResponseMissingDesiredTemp()
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
																autoModeEnable = true,
																temperatureUnit = "CELSIUS"
															}
														}				
						})
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.27
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.28
			--Description: Check processing response with autoModeEnable missing
				function Test:SetInteriorVehicleData_ResponseMissingAutoModeEnable()
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
																temperatureUnit = "CELSIUS"
															}
														}				
						})
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.28
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.29
			--Description: Check processing response with TemperatureUnit missing
				function Test:SetInteriorVehicleData_ResponseMissingTemperatureUnit()
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
																autoModeEnable = true
															}
														}
						})
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.29
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.30
			--Description: Check processing response with radioControlData missing
				function Test:SetInteriorVehicleData_ResponseMissingRadioControlData()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				
				end
			--End Test case ResponseMissingCheck.1.30
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.31
			--Description: Check processing response with radioEnable missing
				function Test:SetInteriorVehicleData_ResponseMissingRadioEnable()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
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
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.31
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseMissingCheck.1.32
			--Description: Check processing response with frequencyInteger missing
				function Test:SetInteriorVehicleData_ResponseMissingFrequencyInteger()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.32
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.33
			--Description: Check processing response with frequencyFraction missing
				function Test:SetInteriorVehicleData_ResponseMissingFrequencyFraction()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.33
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.34
			--Description: Check processing response with band missing
				function Test:SetInteriorVehicleData_ResponseMissingBand()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.34
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.35
			--Description: Check processing response with hdChannel missing
				function Test:SetInteriorVehicleData_ResponseMissingHdChannel()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.35
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.36
			--Description: Check processing response with state missing
				function Test:SetInteriorVehicleData_ResponseMissingState()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.36
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.37
			--Description: Check processing response with availableHDs missing
				function Test:SetInteriorVehicleData_ResponseMissingAvailableHDs()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.37
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.38
			--Description: Check processing response with signalStrength missing
				function Test:SetInteriorVehicleData_ResponseMissingSignalStrength()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.38
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.39
			--Description: Check processing response with rdsData missing
				function Test:SetInteriorVehicleData_ResponseMissingRdsData()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,																
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.39
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.40
			--Description: Check processing response with PS missing
				function Test:SetInteriorVehicleData_ResponseMissingPS()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.40
			
		-----------------------------------------------------------------------------------------	
		
			--Begin Test case ResponseMissingCheck.1.41
			--Description: Check processing response with RT missing
				function Test:SetInteriorVehicleData_ResponseMissingRT()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.41
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.42
			--Description: Check processing response with CT missing
				function Test:SetInteriorVehicleData_ResponseMissingCT()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.42
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.43
			--Description: Check processing response with PI missing
				function Test:SetInteriorVehicleData_ResponseMissingPI()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.43
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.44
			--Description: Check processing response with PTY missing
				function Test:SetInteriorVehicleData_ResponseMissingPTY()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.44
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.45
			--Description: Check processing response with TP missing
				function Test:SetInteriorVehicleData_ResponseMissingTP()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.45
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.46
			--Description: Check processing response with TA missing
				function Test:SetInteriorVehicleData_ResponseMissingTA()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.46
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.47
			--Description: Check processing response with REG missing
				function Test:SetInteriorVehicleData_ResponseMissingREG()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
																	TA = false
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.47
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.48
			--Description: Check processing response with signalChangeThreshold missing
				function Test:SetInteriorVehicleData_ResponseMissingSignalChangeThreshold()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
																}							
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
			--End Test case ResponseMissingCheck.1.48
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.49
			--Description: Check processing response with moduleType missing
				function Test:SetInteriorVehicleData_ResponseMissingModuleType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
				EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Do(function(_,data)
						--hmi side: sending RC.SetInteriorVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.49
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseMissingCheck.1.51
			--Description: Check processing response with moduleData missing
				function Test:GetInteriorVehicleData_ResponseMissingModuleData()
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
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.51
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.52
			--Description: Check processing response with moduleType missing
				function Test:GetInteriorVehicleData_ResponseMissingModuleType()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.52
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.53
			--Description: Check processing response with moduleZone missing
				function Test:GetInteriorVehicleData_ResponseMissingModuleZone()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.53
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.54
			--Description: Check processing response with colspan missing
				function Test:GetInteriorVehicleData_ResponseMissingColspan()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.54
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.55
			--Description: Check processing response with row missing
				function Test:GetInteriorVehicleData_ResponseMissingRow()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.55
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.56
			--Description: Check processing response with rowspan missing
				function Test:GetInteriorVehicleData_ResponseMissingRowspan()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.56
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.57
			--Description: Check processing response with col missing
				function Test:GetInteriorVehicleData_ResponseMissingCol()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.57
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseMissingCheck.1.58
			--Description: Check processing response with levelspan missing
				function Test:GetInteriorVehicleData_ResponseMissingLevelspan()
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.58
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.59
			--Description: Check processing response with level missing
				function Test:GetInteriorVehicleData_ResponseMissingLevel()
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
																levelspan = 1
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.59
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.60
			--Description: Check processing response with climateControlData missing
				function Test:GetInteriorVehicleData_ResponseMissingClimateControlData()
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
															}
														}		
						})
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				
				end
			--End Test case ResponseMissingCheck.1.60
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.61
			--Description: Check processing response with fanSpeed missing
				function Test:GetInteriorVehicleData_ResponseMissingFanSpeed()
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
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.61
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.62
			--Description: Check processing response with circulateAirEnable missing
				function Test:GetInteriorVehicleData_ResponseMissingCirculateAirEnable()
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
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.62
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.63
			--Description: Check processing response with dualModeEnable missing
				function Test:GetInteriorVehicleData_ResponseMissingDualModeEnable()
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
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.63
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.64
			--Description: Check processing response with currentTemp missing
				function Test:GetInteriorVehicleData_ResponseMissingCurrentTemp()
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
			--End Test case ResponseMissingCheck.1.64
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.65
			--Description: Check processing response with defrostZone missing
				function Test:GetInteriorVehicleData_ResponseMissingDefrostZone()
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
			--End Test case ResponseMissingCheck.1.65
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.66
			--Description: Check processing response with acEnable missing
				function Test:GetInteriorVehicleData_ResponseMissingAcEnable()
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
			--End Test case ResponseMissingCheck.1.66
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.67
			--Description: Check processing response with desiredTemp missing
				function Test:GetInteriorVehicleData_ResponseMissingDesiredTemp()
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
																autoModeEnable = true,
																temperatureUnit = "CELSIUS"
															}
														}				
						})
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.67
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.68
			--Description: Check processing response with autoModeEnable missing
				function Test:GetInteriorVehicleData_ResponseMissingAutoModeEnable()
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
																temperatureUnit = "CELSIUS"
															}
														}				
						})
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.68
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.69
			--Description: Check processing response with TemperatureUnit missing
				function Test:GetInteriorVehicleData_ResponseMissingTemperatureUnit()
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
																autoModeEnable = true
															}
														}
						})
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.69
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.70
			--Description: Check processing response with radioControlData missing
				function Test:GetInteriorVehicleData_ResponseMissingRadioControlData()
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
														moduleData =
														{
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				
				end
			--End Test case ResponseMissingCheck.1.70
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.71
			--Description: Check processing response with radioEnable missing
				function Test:GetInteriorVehicleData_ResponseMissingRadioEnable()
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
														moduleData =
														{
															radioControlData = 
															{
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.71
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseMissingCheck.1.72
			--Description: Check processing response with frequencyInteger missing
				function Test:GetInteriorVehicleData_ResponseMissingFrequencyInteger()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.72
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.73
			--Description: Check processing response with frequencyFraction missing
				function Test:GetInteriorVehicleData_ResponseMissingFrequencyFraction()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.73
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.74
			--Description: Check processing response with band missing
				function Test:GetInteriorVehicleData_ResponseMissingBand()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.74
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.75
			--Description: Check processing response with hdChannel missing
				function Test:GetInteriorVehicleData_ResponseMissingHdChannel()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.75
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.76
			--Description: Check processing response with state missing
				function Test:GetInteriorVehicleData_ResponseMissingState()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.76
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.77
			--Description: Check processing response with availableHDs missing
				function Test:GetInteriorVehicleData_ResponseMissingAvailableHDs()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.77
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.78
			--Description: Check processing response with signalStrength missing
				function Test:GetInteriorVehicleData_ResponseMissingSignalStrength()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.78
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.79
			--Description: Check processing response with rdsData missing
				function Test:GetInteriorVehicleData_ResponseMissingRdsData()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,																
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
					end)					
				
				--mobile side: expect SUCCESS response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case ResponseMissingCheck.1.79
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.80
			--Description: Check processing response with PS missing
				function Test:GetInteriorVehicleData_ResponseMissingPS()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.80
			
		-----------------------------------------------------------------------------------------	
		
			--Begin Test case ResponseMissingCheck.1.81
			--Description: Check processing response with RT missing
				function Test:GetInteriorVehicleData_ResponseMissingRT()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.81
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.82
			--Description: Check processing response with CT missing
				function Test:GetInteriorVehicleData_ResponseMissingCT()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.82
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.83
			--Description: Check processing response with PI missing
				function Test:GetInteriorVehicleData_ResponseMissingPI()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.83
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.84
			--Description: Check processing response with PTY missing
				function Test:GetInteriorVehicleData_ResponseMissingPTY()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
																state = "ACQUIRED",
																availableHDs = 1,
																signalStrength = 50,
																rdsData =
																{
																	PS = "12345678",
																	RT = "",
																	CT = "123456789012345678901234",
																	PI = "",
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.84
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheck.1.85
			--Description: Check processing response with TP missing
				function Test:GetInteriorVehicleData_ResponseMissingTP()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.85
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheck.1.86
			--Description: Check processing response with TA missing
				function Test:GetInteriorVehicleData_ResponseMissingTA()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.86
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheck.1.87
			--Description: Check processing response with REG missing
				function Test:GetInteriorVehicleData_ResponseMissingREG()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
																	TA = false
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
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.87
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheck.1.88
			--Description: Check processing response with signalChangeThreshold missing
				function Test:GetInteriorVehicleData_ResponseMissingSignalChangeThreshold()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
																}							
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
			--End Test case ResponseMissingCheck.1.88
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheck.1.89
			--Description: Check processing response with moduleType missing
				function Test:GetInteriorVehicleData_ResponseMissingModuleType()
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
														moduleData =
														{
															radioControlData = 
															{
																radioEnable = true,
																frequencyInteger = 105,
																frequencyFraction = 3,
																band = "AM",
																hdChannel = 1,
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseMissingCheck.1.89
		
	--End Test case ResponseMissingCheck.1
--=================================================END TEST CASES 1==========================================================--
	

	
	


--=================================================BEGIN TEST CASES 2==========================================================--	
	--Begin Test case ResponseOutOfBoundCheck.2
	--Description: 	--Invalid response expected by mobile app

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<3.>In case a mobile app sends a valid request to RSDL, RSDL transfers this request to HMI, and HMI responds with one or more of out-of-bounds per rc-HMI_API values to RSDL, RSDL must log an error and respond with "resultCode: GENERIC_ERROR, success: false, info: 'Invalid response from the vehicle'" to this mobile app's request (Exception: GetInteriorVehicleDataCapabilities, see REVSDL-991).

			--Begin Test case ResponseOutOfBoundCheck.2.1
			--Description: Check processing response with interiorVehicleDataCapabilities out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutLowerBoundInteriorVehicleDataCapabilities()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										interiorVehicleDataCapabilities = {}
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.2
			--Description: Check processing response with col out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutLowerBoundCol()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = -1,
																				colspan = 2,
																				level = 0,
																				levelspan = 1,
																				row = 0,
																				rowspan=  2
																			},
																			moduleType = "RADIO"
																		}
																}
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.2
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseOutOfBoundCheck.2.3
			--Description: Check processing response with colspan out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutLowerBoundColspan()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 0,
																				colspan = -1,
																				level = 0,
																				levelspan = 1,
																				row = 0,
																				rowspan=  2
																			},
																			moduleType = "RADIO"
																		}
																}	
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.3
			
		-----------------------------------------------------------------------------------------	
		
			--Begin Test case ResponseOutOfBoundCheck.2.4
			--Description: Check processing response with level out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutLowerBoundLevel()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 0,
																				colspan = 2,
																				level = -1,
																				levelspan = 1,
																				row = 0,
																				rowspan=  2
																			},
																			moduleType = "RADIO"
																		}
																}	
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.4
			
		-----------------------------------------------------------------------------------------		
	
			--Begin Test case ResponseOutOfBoundCheck.2.5
			--Description: Check processing response with levelspan out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutLowerBoundLevelspan()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 0,
																				colspan = 2,
																				level = 0,
																				levelspan = -1,
																				row = 0,
																				rowspan=  2
																			},
																			moduleType = "RADIO"
																		}
																}	
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.5
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundCheck.2.6
			--Description: Check processing response with row out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutLowerBoundRow()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 0,
																				colspan = 2,
																				level = 0,
																				levelspan = 1,
																				row = -1,
																				rowspan =  2
																			},
																			moduleType = "RADIO"
																		}
																}	
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.6
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundCheck.2.7
			--Description: Check processing response with rowspan out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutLowerBoundRowspan()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 0,
																				colspan = 2,
																				level = 0,
																				levelspan = 1,
																				row = 0,
																				rowspan=  -1
																			},
																			moduleType = "RADIO"
																		}
																}	
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.7
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundCheck.2.8
			--Description: Check processing response with interiorVehicleDataCapabilities out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutUpperBoundInteriorVehicleDataCapabilities()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with interiorVehicleDataCapabilities size = 1001
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
										interiorVehicleDataCapabilities = interiorVehicleDataCapabilities("RADIO", 2, 0, 2, 0, 1, 0, 1001)
						
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
			--End Test case ResponseOutOfBoundCheck.2.8
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.9
			--Description: Check processing response with col out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutUpperBoundCol()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with col out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 101,
																				colspan = 2,
																				level = 0,
																				levelspan = 1,
																				row = 0,
																				rowspan=  2
																			},
																			moduleType = "RADIO"
																		}
																}
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.9
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseOutOfBoundCheck.2.10
			--Description: Check processing response with colspan out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutUpperBoundColspan()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 0,
																				colspan = 101,
																				level = 0,
																				levelspan = 1,
																				row = 0,
																				rowspan=  2
																			},
																			moduleType = "CLIMATE"
																		}
																}	
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.10
			
		-----------------------------------------------------------------------------------------	
		
			--Begin Test case ResponseOutOfBoundCheck.2.11
			--Description: Check processing response with level out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutUpperBoundLevel()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 0,
																				colspan = 2,
																				level = 101,
																				levelspan = 1,
																				row = 0,
																				rowspan=  2
																			},
																			moduleType = "CLIMATE"
																		}
																}	
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.11
			
		-----------------------------------------------------------------------------------------		
	
			--Begin Test case ResponseOutOfBoundCheck.2.12
			--Description: Check processing response with levelspan out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutUpperBoundLevelspan()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 0,
																				colspan = 2,
																				level = 0,
																				levelspan = 101,
																				row = 0,
																				rowspan=  2
																			},
																			moduleType = "CLIMATE"
																		}
																}	
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.12
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundCheck.2.13
			--Description: Check processing response with row out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutUpperBoundRow()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 0,
																				colspan = 2,
																				level = 0,
																				levelspan = 1,
																				row = 101,
																				rowspan =  2
																			},
																			moduleType = "CLIMATE"
																		}
																}	
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.13
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundCheck.2.14
			--Description: Check processing response with rowspan out of bound
				function Test:GetInteriorVehicleDataCapabilities_ResponseOutUpperBoundRowspan()
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
						--hmi side: sending RC.GetInteriorVehicleDataCapabilities response with out of bound
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
														        interiorVehicleDataCapabilities = {
																		{
																			moduleZone = {
																				col = 0,
																				colspan = 2,
																				level = 0,
																				levelspan = 1,
																				row = 0,
																				rowspan=  101
																			},
																			moduleType = "CLIMATE"
																		}
																}	
						
							}
						)
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
			--End Test case ResponseOutOfBoundCheck.2.14
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundCheck.2.1
			--Description: SetInteriorVehicleData with all parameters out of bounds
				function Test:SetInteriorVehicleData_ResponseAllParamsOutLowerBound()
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
								colspan = -1,
								row = -1,
								rowspan = -1,
								col = -1,
								levelspan = -1,
								level = -1
							},
							climateControlData =
							{
								fanSpeed = -1,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = -1,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = -1,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}	
						})
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})

				end
			--End Test case ResponseOutOfBoundCheck.2.1
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.2
			--Description: SetInteriorVehicleData with Colspan parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseColspanOutLowerBound()
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
								colspan = -1,
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.2
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.3
			--Description: SetInteriorVehicleData with row parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseRowOutLowerBound()
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
								row = -1,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
					end
			--End Test case ResponseOutOfBoundCheck.2.3
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.4
			--Description: SetInteriorVehicleData with rowspan parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseRowspanOutLowerBound()
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
								rowspan = -1,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.4
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.5
			--Description: SetInteriorVehicleData with col parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseColOutLowerBound()
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
								col = -1,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.5
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.6
			--Description: SetInteriorVehicleData with levelspan parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseLevelspanOutLowerBound()
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
								levelspan = -1,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.6
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseOutOfBoundCheck.2.7
			--Description: SetInteriorVehicleData with level parameter out of bounds
				function Test:SetInteriorVehicleData_ResponselevelOutLowerBound()
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
								level = -1
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.7
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.8
			--Description: SetInteriorVehicleData with frequencyInteger parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseFrequencyIntegerOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = -1,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.8
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.9
			--Description: SetInteriorVehicleData with frequencyFraction parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseFrequencyFractionOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = -1,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.9
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.10
			--Description: SetInteriorVehicleData with hdChannel parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseHdChannelOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 0,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.10
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.11
			--Description: SetInteriorVehicleData with availableHDs parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseAvailableHDsOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 0,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.11
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.12
			--Description: SetInteriorVehicleData with signalStrength parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseSignalStrengthOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = -1,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.12
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseOutOfBoundCheck.2.13
			--Description: SetInteriorVehicleData with signalChangeThreshold parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseSignalChangeThresholdOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = -1
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.13
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundCheck.2.14
			--Description: SetInteriorVehicleData with fanSpeed parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseFanSpeedOutLowerBound()
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
								fanSpeed = -1,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.14
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.15
			--Description: SetInteriorVehicleData with currentTemp parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseCurrentTempOutLowerBound()
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
								currentTemp = -1,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}	
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.15
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.16
			--Description: SetInteriorVehicleData with desiredTemp parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseDesiredTempOutLowerBound()
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
								desiredTemp = -1,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.16
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.17
			--Description: SetInteriorVehicleData with all parameters out of bounds
				function Test:SetInteriorVehicleData_ResponseAllParamsOutUpperBound()
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
								colspan = 101,
								row = 101,
								rowspan = 101,
								col = 101,
								levelspan = 101,
								level = 101
							},
							climateControlData =
							{
								fanSpeed = 101,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 101,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 101,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.17
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.18
			--Description: SetInteriorVehicleData with Colspan parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseColspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 101,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}		
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.18
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.19
			--Description: SetInteriorVehicleData with row parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseRowOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 101,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}		
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.19
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.20
			--Description: SetInteriorVehicleData with rowspan parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseRowspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 101,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}			
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.20
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.21
			--Description: SetInteriorVehicleData with col parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseColOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 101,
								levelspan = 1,
								level = 0
							}
						}		
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.21
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.22
			--Description: SetInteriorVehicleData with levelspan parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseLevelspanOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
								levelspan = 101,
								level = 0
							}
						}	
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.22
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseOutOfBoundCheck.2.23
			--Description: SetInteriorVehicleData with level parameter out of bounds
				function Test:SetInteriorVehicleData_ResponselevelOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
								level = 101
							}
						}		
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.23
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.24
			--Description: SetInteriorVehicleData with frequencyInteger parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseFrequencyIntegerOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 1711,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.24
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.25
			--Description: SetInteriorVehicleData with frequencyFraction parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseFrequencyFractionOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 10,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.25
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.26
			--Description: SetInteriorVehicleData with hdChannel parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseHdChannelOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 4,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.26
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.27
			--Description: SetInteriorVehicleData with availableHDs parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseAvailableHDsOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 4,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.27
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.28
			--Description: SetInteriorVehicleData with signalStrength parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseSignalStrengthOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 101,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.28
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseOutOfBoundCheck.2.29
			--Description: SetInteriorVehicleData with signalChangeThreshold parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseSignalChangeThresholdOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 101								
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.29
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundCheck.2.30
			--Description: SetInteriorVehicleData with fanSpeed parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseFanSpeedOutUpperBound()
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
								fanSpeed = 101,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.30
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.31
			--Description: SetInteriorVehicleData with currentTemp parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseCurrentTempOutUpperBound()
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
								currentTemp = 101,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.31
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.32
			--Description: SetInteriorVehicleData with desiredTemp parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseDesiredTempOutUpperBound()
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
								desiredTemp = 101,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.32
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.33
			--Description: SetInteriorVehicleData with CT parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseCTOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-070",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.33
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.34
			--Description: SetInteriorVehicleData with PTY parameter out of bounds
				function Test:SetInteriorVehicleData_ResponsePTYOutLowerBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = -1,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.34		

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.35
			--Description: SetInteriorVehicleData with PS parameter out of bounds
				function Test:SetInteriorVehicleData_ResponsePSOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "123456789",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.35

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.36
			--Description: SetInteriorVehicleData with PI parameter out of bounds
				function Test:SetInteriorVehicleData_ResponsePIOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdentI",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.36

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.37
			--Description: SetInteriorVehicleData with RT parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseRTOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "RADIO TEXT Minlength = 0, Maxlength = 64 RADIO TEXT Minlength = 6",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.37

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.38
			--Description: SetInteriorVehicleData with CT parameter out of bounds
				function Test:SetInteriorVehicleData_ResponseCTOutUpperBound()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-07009",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.38
			
			
		-----------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------		
			

			--Begin Test case ResponseOutOfBoundCheck.2.1
			--Description: GetInteriorVehicleData with all parameters out of bounds
				function Test:GetInteriorVehicleData_ResponseAllParamsOutLowerBound()
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
								level = 0
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
								colspan = -1,
								row = -1,
								rowspan = -1,
								col = -1,
								levelspan = -1,
								level = -1
							},
							climateControlData =
							{
								fanSpeed = -1,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = -1,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = -1,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}	
						})
					end)					
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})

				end
			--End Test case ResponseOutOfBoundCheck.2.1
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.2
			--Description: GetInteriorVehicleData with Colspan parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseColspanOutLowerBound()
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
								level = 0
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
								colspan = -1,
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
				
				--mobile side: expect GENERIC_ERROR response with info
				EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.2
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.3
			--Description: GetInteriorVehicleData with row parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseRowOutLowerBound()
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
								level = 0
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
								row = -1,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
					end
			--End Test case ResponseOutOfBoundCheck.2.3
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.4
			--Description: GetInteriorVehicleData with rowspan parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseRowspanOutLowerBound()
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
								level = 0
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
								rowspan = -1,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.4
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.5
			--Description: GetInteriorVehicleData with col parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseColOutLowerBound()
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
								level = 0
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
								col = -1,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.5
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.6
			--Description: GetInteriorVehicleData with levelspan parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseLevelspanOutLowerBound()
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
								level = 0
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
								levelspan = -1,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.6
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseOutOfBoundCheck.2.7
			--Description: GetInteriorVehicleData with level parameter out of bounds
				function Test:GetInteriorVehicleData_ResponselevelOutLowerBound()
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
								level = 0
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
								level = -1
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.7
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.8
			--Description: GetInteriorVehicleData with frequencyInteger parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseFrequencyIntegerOutLowerBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = -1,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.8
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.9
			--Description: GetInteriorVehicleData with frequencyFraction parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseFrequencyFractionOutLowerBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = -1,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.9
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.10
			--Description: GetInteriorVehicleData with hdChannel parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseHdChannelOutLowerBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 0,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.10
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.11
			--Description: GetInteriorVehicleData with availableHDs parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseAvailableHDsOutLowerBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 0,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.11
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.12
			--Description: GetInteriorVehicleData with signalStrength parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseSignalStrengthOutLowerBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = -1,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.12
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseOutOfBoundCheck.2.13
			--Description: GetInteriorVehicleData with signalChangeThreshold parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseSignalChangeThresholdOutLowerBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = -1
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.13
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundCheck.2.14
			--Description: GetInteriorVehicleData with fanSpeed parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseFanSpeedOutLowerBound()
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
								level = 0
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
								fanSpeed = -1,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.14
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.15
			--Description: GetInteriorVehicleData with currentTemp parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseCurrentTempOutLowerBound()
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
								level = 0
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
								currentTemp = -1,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}	
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.15
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.16
			--Description: GetInteriorVehicleData with desiredTemp parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseDesiredTempOutLowerBound()
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
								level = 0
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
								desiredTemp = -1,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.16
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.17
			--Description: GetInteriorVehicleData with all parameters out of bounds
				function Test:GetInteriorVehicleData_ResponseAllParamsOutUpperBound()
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
								level = 0
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
								colspan = 101,
								row = 101,
								rowspan = 101,
								col = 101,
								levelspan = 101,
								level = 101
							},
							climateControlData =
							{
								fanSpeed = 101,
								circulateAirEnable = true,
								dualModeEnable = true,
								currentTemp = 101,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 101,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.17
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.18
			--Description: GetInteriorVehicleData with Colspan parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseColspanOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 101,
								row = 0,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}		
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.18
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.19
			--Description: GetInteriorVehicleData with row parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseRowOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 101,
								rowspan = 2,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}		
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.19
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.20
			--Description: GetInteriorVehicleData with rowspan parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseRowspanOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 101,
								col = 0,
								levelspan = 1,
								level = 0
							}
						}			
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.20
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.21
			--Description: GetInteriorVehicleData with col parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseColOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								colspan = 2,
								row = 0,
								rowspan = 2,
								col = 101,
								levelspan = 1,
								level = 0
							}
						}		
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.21
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.22
			--Description: GetInteriorVehicleData with levelspan parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseLevelspanOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
								levelspan = 101,
								level = 0
							}
						}	
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.22
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseOutOfBoundCheck.2.23
			--Description: GetInteriorVehicleData with level parameter out of bounds
				function Test:GetInteriorVehicleData_ResponselevelOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
								level = 101
							}
						}		
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.23
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.24
			--Description: GetInteriorVehicleData with frequencyInteger parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseFrequencyIntegerOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 1711,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.24
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.25
			--Description: GetInteriorVehicleData with frequencyFraction parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseFrequencyFractionOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 10,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.25
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundCheck.2.26
			--Description: GetInteriorVehicleData with hdChannel parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseHdChannelOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 4,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.26
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.27
			--Description: GetInteriorVehicleData with availableHDs parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseAvailableHDsOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 4,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.27
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundCheck.2.28
			--Description: GetInteriorVehicleData with signalStrength parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseSignalStrengthOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 101,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.28
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseOutOfBoundCheck.2.29
			--Description: GetInteriorVehicleData with signalChangeThreshold parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseSignalChangeThresholdOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 101								
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.29
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundCheck.2.30
			--Description: GetInteriorVehicleData with fanSpeed parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseFanSpeedOutUpperBound()
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
								level = 0
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
								fanSpeed = 101,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.30
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.31
			--Description: GetInteriorVehicleData with currentTemp parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseCurrentTempOutUpperBound()
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
								level = 0
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
								currentTemp = 101,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.31
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.32
			--Description: GetInteriorVehicleData with desiredTemp parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseDesiredTempOutUpperBound()
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
								level = 0
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
								desiredTemp = 101,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.32
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.33
			--Description: GetInteriorVehicleData with CT parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseCTOutLowerBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-070",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}			
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.33
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.34
			--Description: GetInteriorVehicleData with PTY parameter out of bounds
				function Test:GetInteriorVehicleData_ResponsePTYOutLowerBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = -1,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}		
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.34		

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.35
			--Description: GetInteriorVehicleData with PS parameter out of bounds
				function Test:GetInteriorVehicleData_ResponsePSOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "123456789",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}			
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.35

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.36
			--Description: GetInteriorVehicleData with PI parameter out of bounds
				function Test:GetInteriorVehicleData_ResponsePIOutUpperBound()
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
								level = 0
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
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdentI",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}		
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.36

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.37
			--Description: GetInteriorVehicleData with RT parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseRTOutUpperBound()
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
								level = 0
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
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "RADIO TEXT Minlength = 0, Maxlength = 64 RADIO TEXT Minlength = 6",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.37

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundCheck.2.38
			--Description: GetInteriorVehicleData with CT parameter out of bounds
				function Test:GetInteriorVehicleData_ResponseCTOutUpperBound()
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
								level = 0
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
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-07009",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseOutOfBoundCheck.2.38
	
	--End Test case ResponseOutOfBoundCheck.2
--=================================================END TEST CASES 2==========================================================--


	
	
	
	
--=================================================BEGIN TEST CASES 3==========================================================--	
	--Begin Test case ResponseWrongTypeCheck.3
	--Description: 	--Invalid response expected by mobile app

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<4.>In case a mobile app sends a valid request to RSDL, RSDL transfers this request to HMI, and HMI responds with one or more params of wrong type per rc-HMI_API to RSDL, RSDL must log an error and respond with "resultCode: GENERIC_ERROR, success: false, info: 'Invalid response from the vehicle'" to this mobile app's request (Exception: GetInteriorVehicleDataCapabilities, see REVSDL-991).

			--Begin Test case case ResponseWrongTypeCheck.3.1
			--Description: GetInteriorVehicleDataCapabilities with all parameters of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ResposeAllParamsWrongType()
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
							colspan = "1",
							row = "1",
							rowspan = "1",
							col = "1",
							levelspan = "1",
							level = "1"
						},
						moduleType = {111, 111}
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
			--End Test case case ResponseWrongTypeCheck.3.1
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case case ResponseWrongTypeCheck.3.2
			--Description: GetInteriorVehicleDataCapabilities with Colspan parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ResposeColspanWrongType()
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
							colspan = "1",
							row = 1,
							rowspan = 1,
							col = 1,
							levelspan = 1,
							level = 1
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
			--End Test case case ResponseWrongTypeCheck.3.2
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case case ResponseWrongTypeCheck.3.3
			--Description: GetInteriorVehicleDataCapabilities with row parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ResposeRowWrongType()
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
								row = "0",
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
			--End Test case case ResponseWrongTypeCheck.3.3
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case case ResponseWrongTypeCheck.3.4
			--Description: GetInteriorVehicleDataCapabilities with rowspan parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ResposeRowspanWrongType()
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
								rowspan = "2",
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
			--End Test case case ResponseWrongTypeCheck.3.4
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case case ResponseWrongTypeCheck.3.5
			--Description: GetInteriorVehicleDataCapabilities with col parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ResposeColWrongType()
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
								col = "0",
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
			--End Test case case ResponseWrongTypeCheck.3.5
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case case ResponseWrongTypeCheck.3.6
			--Description: GetInteriorVehicleDataCapabilities with levelspan parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ResposeLevelspanWrongType()
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
								levelspan = "1",
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
			--End Test case case ResponseWrongTypeCheck.3.6
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case case ResponseWrongTypeCheck.3.7
			--Description: GetInteriorVehicleDataCapabilities with level parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ResposelevelWrongType()
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
								level = "0"
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
			--End Test case case ResponseWrongTypeCheck.3.7
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case case ResponseWrongTypeCheck.3.8
			--Description: GetInteriorVehicleDataCapabilities with moduleType parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ResposeModuleTypeWrongType()
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
								moduleType = 111
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
			--End Test case case ResponseWrongTypeCheck.3.8
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case case ResponseWrongTypeCheck.3.9
			--Description: GetInteriorVehicleDataCapabilities with zone parameter of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ResposeZoneWrongType()
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
							colspan = "1",
							row = true,
							rowspan = false,
							col = 1,
							levelspan = "1",
							level = "abc"
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
			--End Test case case ResponseWrongTypeCheck.3.9

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case case ResponseWrongTypeCheck.3.10
			--Description: GetInteriorVehicleDataCapabilities with rowspan and ModuleType parameters of wrong type
				function Test:GetInteriorVehicleDataCapabilities_ResposeRowspanAndModuleTypeWrongType()
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
								rowspan = "2",
								col = 0,
								levelspan = 1,
								level = 0
						},
						moduleType = {111, "abc"}
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
			--End Test case case ResponseWrongTypeCheck.3.10

		-----------------------------------------------------------------------------------------			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseWrongTypeCheck.3.1
			--Description: SetInteriorVehicleData with all parameters of wrong type
				function Test:SetInteriorVehicleData_ResponseAllParamsWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = "true",
											frequencyInteger = "105",
											frequencyFraction = "3",
											band = true,
											hdChannel = "1",
											state = 123,
											availableHDs = "1",
											signalStrength = "50",
											rdsData =
											{
												PS = 12345678,
												RT = false,
												CT = 123456789123456789123456,
												PI = true,
												PTY = "0",
												TP = "true",
												TA = "false",
												REG = 123
											},
											signalChangeThreshold = "10"
										},
										moduleType = true,
										moduleZone = 
										{
											colspan = "2",
											row = "0",
											rowspan = "2",
											col = "0",
											levelspan = "1",
											level = "0"
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})

				end
			--End Test case ResponseWrongTypeCheck.3.1
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseWrongTypeCheck.3.2
			--Description: SetInteriorVehicleData with radioEnable parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseRadioEnableWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = 123,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.2
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseWrongTypeCheck.3.3
			--Description: SetInteriorVehicleData with frequencyInteger parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseFrequencyIntegerWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = "105",
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.3
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseWrongTypeCheck.3.4
			--Description: SetInteriorVehicleData with frequencyFraction parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseFrequencyFractionWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = "3",
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.4
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeCheck.3.5
			--Description: SetInteriorVehicleData with band parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseBandWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = 123,
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.5
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseWrongTypeCheck.3.6
			--Description: SetInteriorVehicleData with hdChannel parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseHdChannelWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = "1",
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.6
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.7
			--Description: SetInteriorVehicleData with state parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseStateWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = true,
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.7
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseWrongTypeCheck.3.8
			--Description: SetInteriorVehicleData with availableHDs parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseAvailableHDsWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = "1",
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.8
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.9
			--Description: SetInteriorVehicleData with signalStrength parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseSignalStrengthWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = "50",
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.9
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.10
			--Description: SetInteriorVehicleData with PS parameter of wrong type
				function Test:SetInteriorVehicleData_ResponsePSWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = 12345678,
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.10
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.11
			--Description: SetInteriorVehicleData with RT parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseRTWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = 123,
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.11
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.12
			--Description: SetInteriorVehicleData with CT parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseCTWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = 123456789123456789123456,
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.12
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.13
			--Description: SetInteriorVehicleData with PI parameter of wrong type
				function Test:SetInteriorVehicleData_ResponsePIWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = false,
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.13
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseWrongTypeCheck.3.14
			--Description: SetInteriorVehicleData with PTY parameter of wrong type
				function Test:SetInteriorVehicleData_ResponsePTYWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = "0",
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.14
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.15
			--Description: SetInteriorVehicleData with TP parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseTPWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = "true",
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.15
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeCheck.3.16
			--Description: SetInteriorVehicleData with TA parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseTAWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = "false",
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.16
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.17
			--Description: SetInteriorVehicleData with REG parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseREGWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = 123
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.17
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.18
			--Description: SetInteriorVehicleData with signalChangeThreshold parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseSignalChangeThresholdWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = "10"								
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.18
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.19
			--Description: SetInteriorVehicleData with moduleType parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseModuleTypeWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = true,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.19
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.20
			--Description: SetInteriorVehicleData with clospan parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseClospanWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "RADIO",
										moduleZone = 
										{
											colspan = "2",
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.20
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeCheck.3.21
			--Description: SetInteriorVehicleData with row parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseRowWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "RADIO",
										moduleZone = 
										{
											colspan = 2,
											row = "0",
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.21
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.22
			--Description: SetInteriorVehicleData with rowspan parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseRowspanWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "RADIO",
										moduleZone = 
										{
											colspan = 2,
											row = 0,
											rowspan = "2",
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.22
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeCheck.3.23
			--Description: SetInteriorVehicleData with col parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseColWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "RADIO",
										moduleZone = 
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = "0",
											levelspan = 1,
											level = 0
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.23
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseWrongTypeCheck.3.24
			--Description: SetInteriorVehicleData with levelspan parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseLevelspanWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
											levelspan = "1",
											level = 0
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.24
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.25
			--Description: SetInteriorVehicleData with level parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseLevelWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
											level = "0"
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.25
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.26
			--Description: SetInteriorVehicleData with fanSpeed parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseFanSpeedWrongType()
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
										fanSpeed = "50",
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.26
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.27
			--Description: SetInteriorVehicleData with circulateAirEnable parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseCirculateAirEnableWrongType()
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
								circulateAirEnable = "true",
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.27
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.28
			--Description: SetInteriorVehicleData with dualModeEnable parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseDualModeEnableWrongType()
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
								dualModeEnable = "true",
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.28
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.29
			--Description: SetInteriorVehicleData with currentTemp parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseCurrentTempWrongType()
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
								currentTemp = false,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.29
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.30
			--Description: SetInteriorVehicleData with defrostZone parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseDefrostZoneWrongType()
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
								defrostZone = 123,
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.30
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.31
			--Description: SetInteriorVehicleData with acEnable parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseAcEnableWrongType()
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
								acEnable = "true",
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.31
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.32
			--Description: SetInteriorVehicleData with desiredTemp parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseDesiredTempWrongType()
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
								desiredTemp = "24",
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.32
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.33
			--Description: SetInteriorVehicleData with autoModeEnable parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseAutoModeEnableWrongType()
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
								autoModeEnable = 123,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.33

		-----------------------------------------------------------------------------------------
			
			--Begin Test case ResponseWrongTypeCheck.3.34
			--Description: SetInteriorVehicleData with TemperatureUnit parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseTemperatureUnitWrongType()
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
								temperatureUnit = 123
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.34		

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseWrongTypeCheck.3.35
			--Description: SetInteriorVehicleData with moduleData parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseModuleDataWrongType()
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
								moduleData = "abc"
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.35

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.36
			--Description: SetInteriorVehicleData with climateControlData parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseClimateControlDataWrongType()
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
							climateControlData = "  a b c  "
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.36

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.37
			--Description: SetInteriorVehicleData with radioControlData parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseRadioControlDataDataWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = true,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.37		

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.38
			--Description: SetInteriorVehicleData with moduleZone parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseModuleZoneDataDataWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = true
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.38

		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseWrongTypeCheck.3.39
			--Description: SetInteriorVehicleData with rdsData parameter of wrong type
				function Test:SetInteriorVehicleData_ResponseRdsDataWrongType()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData = "  a b c ",
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.39
		
		
		-----------------------------------------------------------------------------------------
		-----------------------------------------------------------------------------------------		
		
		
			
			--Begin Test case ResponseWrongTypeCheck.3.1
			--Description: GetInteriorVehicleData with all parameters of wrong type
				function Test:GetInteriorVehicleData_ResponseAllParamsWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = "true",
											frequencyInteger = "105",
											frequencyFraction = "3",
											band = true,
											hdChannel = "1",
											state = 123,
											availableHDs = "1",
											signalStrength = "50",
											rdsData =
											{
												PS = 12345678,
												RT = false,
												CT = 123456789123456789123456,
												PI = true,
												PTY = "0",
												TP = "true",
												TA = "false",
												REG = 123
											},
											signalChangeThreshold = "10"
										},
										moduleType = true,
										moduleZone = 
										{
											colspan = "2",
											row = "0",
											rowspan = "2",
											col = "0",
											levelspan = "1",
											level = "0"
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})

				end
			--End Test case ResponseWrongTypeCheck.3.1
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseWrongTypeCheck.3.2
			--Description: GetInteriorVehicleData with radioEnable parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseRadioEnableWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = 123,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.2
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseWrongTypeCheck.3.3
			--Description: GetInteriorVehicleData with frequencyInteger parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseFrequencyIntegerWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = "105",
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.3
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseWrongTypeCheck.3.4
			--Description: GetInteriorVehicleData with frequencyFraction parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseFrequencyFractionWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = "3",
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.4
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeCheck.3.5
			--Description: GetInteriorVehicleData with band parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseBandWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = 123,
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.5
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseWrongTypeCheck.3.6
			--Description: GetInteriorVehicleData with hdChannel parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseHdChannelWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = "1",
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.6
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.7
			--Description: GetInteriorVehicleData with state parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseStateWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = true,
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.7
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseWrongTypeCheck.3.8
			--Description: GetInteriorVehicleData with availableHDs parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseAvailableHDsWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = "1",
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.8
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.9
			--Description: GetInteriorVehicleData with signalStrength parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseSignalStrengthWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = "50",
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.9
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.10
			--Description: GetInteriorVehicleData with PS parameter of wrong type
				function Test:GetInteriorVehicleData_ResponsePSWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = 12345678,
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.10
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.11
			--Description: GetInteriorVehicleData with RT parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseRTWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = 123,
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.11
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.12
			--Description: GetInteriorVehicleData with CT parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseCTWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = 123456789123456789123456,
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.12
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.13
			--Description: GetInteriorVehicleData with PI parameter of wrong type
				function Test:GetInteriorVehicleData_ResponsePIWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = false,
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.13
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseWrongTypeCheck.3.14
			--Description: GetInteriorVehicleData with PTY parameter of wrong type
				function Test:GetInteriorVehicleData_ResponsePTYWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = "0",
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.14
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.15
			--Description: GetInteriorVehicleData with TP parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseTPWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = "true",
												TA = false,
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.15
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeCheck.3.16
			--Description: GetInteriorVehicleData with TA parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseTAWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = "false",
												REG = "don't mention min,max length"
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.16
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.17
			--Description: GetInteriorVehicleData with REG parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseREGWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = 123
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.17
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.18
			--Description: GetInteriorVehicleData with signalChangeThreshold parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseSignalChangeThresholdWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = "10"								
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.18
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.19
			--Description: GetInteriorVehicleData with moduleType parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseModuleTypeWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = true,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.19
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.20
			--Description: GetInteriorVehicleData with clospan parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseClospanWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "RADIO",
										moduleZone = 
										{
											colspan = "2",
											row = 0,
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.20
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeCheck.3.21
			--Description: GetInteriorVehicleData with row parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseRowWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "RADIO",
										moduleZone = 
										{
											colspan = 2,
											row = "0",
											rowspan = 2,
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.21
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.22
			--Description: GetInteriorVehicleData with rowspan parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseRowspanWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "RADIO",
										moduleZone = 
										{
											colspan = 2,
											row = 0,
											rowspan = "2",
											col = 0,
											levelspan = 1,
											level = 0
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.22
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeCheck.3.23
			--Description: GetInteriorVehicleData with col parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseColWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "RADIO",
										moduleZone = 
										{
											colspan = 2,
											row = 0,
											rowspan = 2,
											col = "0",
											levelspan = 1,
											level = 0
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.23
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseWrongTypeCheck.3.24
			--Description: GetInteriorVehicleData with levelspan parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseLevelspanWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
											levelspan = "1",
											level = 0
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.24
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.25
			--Description: GetInteriorVehicleData with level parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseLevelWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
											level = "0"
										}
									}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.25
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.26
			--Description: GetInteriorVehicleData with fanSpeed parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseFanSpeedWrongType()
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
								fanSpeed = "50",
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.26
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.27
			--Description: GetInteriorVehicleData with circulateAirEnable parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseCirculateAirEnableWrongType()
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
								circulateAirEnable = "true",
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.27
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.28
			--Description: GetInteriorVehicleData with dualModeEnable parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseDualModeEnableWrongType()
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
								dualModeEnable = "true",
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.28
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.29
			--Description: GetInteriorVehicleData with currentTemp parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseCurrentTempWrongType()
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
								currentTemp = false,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.29
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.30
			--Description: GetInteriorVehicleData with defrostZone parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseDefrostZoneWrongType()
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
								defrostZone = 123,
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.30
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.31
			--Description: GetInteriorVehicleData with acEnable parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseAcEnableWrongType()
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
								acEnable = "true",
								desiredTemp = 24,
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.31
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeCheck.3.32
			--Description: GetInteriorVehicleData with desiredTemp parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseDesiredTempWrongType()
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
								desiredTemp = "24",
								autoModeEnable = true,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.32
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.33
			--Description: GetInteriorVehicleData with autoModeEnable parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseAutoModeEnableWrongType()
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
								autoModeEnable = 123,
								temperatureUnit = "CELSIUS"
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.33

		-----------------------------------------------------------------------------------------
			
			--Begin Test case ResponseWrongTypeCheck.3.34
			--Description: GetInteriorVehicleData with TemperatureUnit parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseTemperatureUnitWrongType()
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
								temperatureUnit = 123
							}
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.34		

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseWrongTypeCheck.3.35
			--Description: GetInteriorVehicleData with moduleData parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseModuleDataWrongType()
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
								moduleData = "abc"
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.35

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.36
			--Description: GetInteriorVehicleData with climateControlData parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseClimateControlDataWrongType()
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
							climateControlData = "  a b c  "
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.36

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.37
			--Description: GetInteriorVehicleData with radioControlData parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseRadioControlDataDataWrongType()
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
						moduleData =
						{
							radioControlData = true,
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.37		

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeCheck.3.38
			--Description: GetInteriorVehicleData with moduleZone parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseModuleZoneDataDataWrongType()
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
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = true
						}
							})
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.38
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseWrongTypeCheck.3.39
			--Description: GetInteriorVehicleData with rdsData parameter of wrong type
				function Test:GetInteriorVehicleData_ResponseRdsDataWrongType()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData = true,
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
						end)					
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongTypeCheck.3.39			
				
	--End Test case ResponseWrongTypeCheck.3
--=================================================END TEST CASES 3==========================================================--	
	
				
	


--NOTE: CANNOT EXECUTE THESE TESTCASES BECAUSE OF DEFECT: REVSDL-1369:
----<Not related to RSDL functionality. Limitation of SDL project.>----
--=================================================BEGIN TEST CASES 4==========================================================--	
--[[	--Begin Test case ResponseInvalidJsonCheck.4
	--Description: 	--Invalid response expected by mobile app

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<5.>In case a mobile app sends a valid request to RSDL, RSDL transfers this request to HMI, and HMI responds with a message of invalid JSON to RSDL, RSDL must log an error and respond with "resultCode: GENERIC_ERROR, success: false, info: 'Invalid response from the vehicle'" to this mobile app's request (Exception: GetInteriorVehicleDataCapabilities, see REVSDL-991).
	
			--Begin Test case ResponseInvalidJsonCheck.4.1
			--Description:  Response GetInteriorVehicleDataCapabilities with invalid json
				function Test:GetInteriorVehicleDataCapabilities_ResponseInvalidJson()
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
						ResponseId = data.id

						local function ValidationResponse()
							self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","result":{"code":0,"method":"RC.GetInteriorVehicleDataCapabilities","interiorVehicleDataCapabilities":[{"moduleZone":{"col":0,"colspan":2,"level":0,"levelspan":1,"row":0,"rowspan":2},"moduleType""CLIMATE"}]}}')

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
																								moduleType = "CLIMATE"
																							}
																						}
				})
				end
			--End Test case ResponseInvalidJsonCheck.4.1
			
		-----------------------------------------------------------------------------------------				

			--Begin Test case ResponseInvalidJsonCheck.4.2
			--Description:  Response SetInteriorVehicleData with invalid json
				function Test:SetInteriorVehicleData_ResponseInvalidJson()
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
						ResponseId = data.id						 

						local function ValidationResponse()
							self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","result":{"code":0,"method":"RC.SetInteriorVehicleData","moduleData":{"climateControlData":{"TemperatureUnit":"CELSIUS","acEnable":true,"autoModeEnable":true,"circulateAirEnable":true,"currentTemp":30,"defrostZone":"FRONT","desiredTemp":24,"dualModeEnable":true,"fanSpeed":50},"moduleType":"CLIMATE","moduleZone":{"col":0,"colspan":2,"level":0,"levelspan":1,"row":0,"rowspan"2}}}}')

						end

						RUN_AFTER(ValidationResponse, 3000)
					end)				
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseInvalidJsonCheck.4.2
			
		-----------------------------------------------------------------------------------------				

			--Begin Test case ResponseInvalidJsonCheck.4.3
			--Description:  Response GetInteriorVehicleData with invalid json
				function Test:GetInteriorVehicleData_ResponseInvalidJson()
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
								level = 0
							}
						},
						subscribe = true
						})		
					
				--hmi side: expect RC.GetInteriorVehicleData request
					EXPECT_HMICALL("RC.GetInteriorVehicleData")
					:Do(function(_,data)
						ResponseId = data.id

						local function ValidationResponse()
							self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","result":{"code":0,"method":"RC.GetInteriorVehicleData","moduleData":{"moduleType":"RADIO","moduleZone":{"col":0,"colspan":2,"level":0,"levelspan":1,"row":0,"rowspan":2},"radioControlData":{"frequencyInteger":99,"frequencyFraction":3,"band":"FM","rdsData":{"PS":"name","RT":"radio","CT":"YYYY-MM-DDThh:mm:ss.sTZD","PI":"Sign","PTY":1,"TP":true,"TA":true,"REG":"Murica"},"availableHDs":3,"hdChannel":1,"signalStrength":50,"signalChangeThreshold":60,"radioEnable":true,"state""ACQUIRING"}}}}')

						end

						RUN_AFTER(ValidationResponse, 3000)
					end)				
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseInvalidJsonCheck.4.3	

		-----------------------------------------------------------------------------------------				
			
			--Begin Test case ResponseInvalidJsonCheck.4.4
			--Description:  Response ButtonPress with invalid json
				function Test:ButtonPress_ResponseInvalidJson()
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
					EXPECT_HMICALL("Buttons.ButtonPress", {
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
						ResponseId = data.id  

						local function ValidationResponse()
							self.hmiConnection:Send('{"id":'..tostring(ResponseId)..',"jsonrpc":"2.0","result":{"code":0,"method" "Buttons.ButtonPress"}}')

						end

						RUN_AFTER(ValidationResponse, 3000)
					end)				
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseInvalidJsonCheck.4.4			
			
	--End Test case ResponseInvalidJsonCheck.4]]
--=================================================END TEST CASES 4==========================================================--




--=================================================BEGIN TEST CASES 5==========================================================--	
	--Begin Test case ResponseWrongModuleTypeAndControlDataCheck.5
	--Description: 	--Invalid response expected by mobile app

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<6.>In case a mobile app sends a valid request to RSDL, RSDL transfers this request to HMI, and HMI responds non-corresponding-to-each-other moduleType and <module>ControlData (example: module: RADIO & climateControlData), RSDL must log an error and respond with "resultCode: GENERIC_ERROR, success: false, info: 'Invalid response from the vehicle'" to this mobile app's request (Exception: GetInteriorVehicleDataCapabilities, see REVSDL-991).
	
			--Begin Test case ResponseWrongModuleTypeAndControlDataCheck.5.1
			--Description: SetInteriorVehicleData response with wrong moduleType and <module>ControlData
				function Test:SetInteriorVehicleData_ResponseWrongModuleTypeAndControlData_RADIO()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
				--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "CLIMATE",
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongModuleTypeAndControlDataCheck.5.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseWrongModuleTypeAndControlDataCheck.5.2
			--Description: SetInteriorVehicleData response with wrong moduleType and <module>ControlData
				function Test:SetInteriorVehicleData_ResponseWrongModuleTypeAndControlData_CLIMATE()
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
									moduleType = "RADIO",
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongModuleTypeAndControlDataCheck.5.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongModuleTypeAndControlDataCheck.5.3
			--Description: GetInteriorVehicleData response with wrong moduleType and <module>ControlData
				function Test:GetInteriorVehicleData_ResponseWrongModuleTypeAndControlData_RADIO()
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
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "CLIMATE",
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongModuleTypeAndControlDataCheck.5.3
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongModuleTypeAndControlDataCheck.5.4
			--Description: GetInteriorVehicleData response with wrong moduleType and <module>ControlData
				function Test:GetInteriorVehicleData_ResponseWrongModuleTypeAndControlData_CLIMATE()
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
							moduleType = "RADIO",
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
				end
			--End Test case ResponseWrongModuleTypeAndControlDataCheck.5.4

	--End Test case ResponseWrongModuleTypeAndControlDataCheck.5
--=================================================END TEST CASES 5==========================================================--	
	
	
	
	
	
	
--=================================================BEGIN TEST CASES 6==========================================================--	
	
	--Begin Test case ResponseMissingCheck.6
	--Description: 	--Invalid response expected by RSDL

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038
				--GetInteriorVehicleDataConsent

		--Verification criteria: 
				--<7.>In case RSDL sends a request following the internal processes to HMI (example: permission request), and HMI responds with one or more of mandatory per rc-HMI_API params missing to RSDL, RSDL must log an error and ignore the received message (meaning: not process the values from response)
	

			--Begin Test case ResponseMissing.6.1
			--Description: GetInteriorVehicleDataConsent responses with allowed missing
				function Test:GetInteriorVehicleDataConsent_ResponseMissingAllowed()
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
						self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {})						
					end)					
					
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
					:Timeout(3000)
				end
			--End Test case ResponseMissing.6.1	
	
--=================================================END TEST CASES 6==========================================================--		
	
	



--=================================================BEGIN TEST CASES 7==========================================================--	
	
	--Begin Test case ResponseOutOfBoundCheck.7
	--Description: 	--Invalid response expected by RSDL

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038
				--GetInteriorVehicleDataConsent

		--Verification criteria: 
				--<8.>In case RSDL sends a request following the internal processes to HMI (example: permission request), and HMI responds with one or more of out-of-bounds per rc-HMI_API values to RSDL, RSDL must log an error and ignore the received message (meaning: not process the values from response)
	
			--allowed = true doesn't have out of bound values

	
--=================================================END TEST CASES 7==========================================================--	


	



--=================================================BEGIN TEST CASES 8==========================================================--	
	
	--Begin Test case ResponseWrongTypeCheck.8
	--Description: 	--Invalid response expected by RSDL

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038
				--GetInteriorVehicleDataConsent

		--Verification criteria: 
				--<9.>In case RSDL sends a request following the internal processes to HMI (example: permission request), and HMI responds with one or more params of wrong type per rc-HMI_API to RSDL, RSDL must log an error and ignore the received message (meaning: not process the values from response)
	

			--Begin Test case ResponseWrongTypeCheck.8.1
			--Description: GetInteriorVehicleDataConsent responses with allowed wrong type
				function Test:GetInteriorVehicleDataConsent_ResponseWrongTypeAllowed()
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
						self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = "true"})
						
					end)					
					
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
					:Timeout(3000)
				end
			--End Test case ResponseWrongTypeCheck.8.1	
	
--=================================================END TEST CASES 8==========================================================--	





--NOTE: CANNOT EXECUTE THESE TESTCASES BECAUSE OF DEFECT: REVSDL-1369:
----<Not related to RSDL functionality. Limitation of SDL project.>----
--=================================================BEGIN TEST CASES 9==========================================================--	
	
--[[	--Begin Test case ResponseWrongTypeCheck.9
	--Description: 	--Invalid response expected by RSDL

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038
				--GetInteriorVehicleDataConsent

		--Verification criteria: 
				--<10.>In case RSDL sends a request following the internal processes to HMI (example: permission request), and HMI responds with a message of invalid JSON to RSDL, RSDL must log an error and ignore the received message (meaning: not process the values from response)
	

			--Begin Test case ResponseInvalidJsonCheck.9.1
			--Description: GetInteriorVehicleDataConsent responses with invalid Json
				function Test:GetInteriorVehicleDataConsent_ResponseInvalidJson()
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
						ResponseId = data.id
						--hmi side: sending RC.GetInteriorVehicleDataConsent response
						--self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS" with Invalid Json
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(ResponseId)..',"result":{"code":0,"method":"RC.GetInteriorVehicleDataConsent","allowed"true}}')
						
						
					end)					
					
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
					:Timeout(5000)
				end
			--End Test case ResponseInvalidJsonCheck.9.1]]
	
--=================================================END TEST CASES 9==========================================================--	


	
	
	
	
--=================================================BEGIN TEST CASES 10==========================================================--	
	
	--Begin Test case ResponseMissingCheckNotification.10
	--Description: 	--Invalid notification

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038
				
---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

			--Begin Test case Precondition.1
			--Description: mobile sends GetInteriorVehicleData request with subscribe = true for precondtion
				function Test:OnInteriorVehicleData_Precondition_RADIO()
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
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
						
				end
			--End Test case Precondition.1
			
			--Begin Test case Precondition.2
			--Description: GetInteriorVehicleData response with subscribe = true for precondtion
				function Test:GetInteriorVehicleData_Precondition_CLIMATE()
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
						end)
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

				end
			--End Test case Precondition.2		

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

		--Verification criteria: 
				--<11.>In case HMI sends a notification with one or more of mandatory per rc-HMI_API params missing to RSDL, RSDL must log an error and ignore this notification.
	
			--Begin Test case ResponseMissingCheckNotification.10.1
			--Description: send notification with all params missing
				function Test:OnInteriorVehicleData_MissingAllParams()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.1
			
		-----------------------------------------------------------------------------------------			
		
			
			--Begin Test case ResponseMissingCheckNotification.10.2
			--Description: send notification with moduleType missing
				function Test:OnInteriorVehicleData_MissingModuleType()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}					
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.2

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseMissingCheckNotification.10.3
			--Description: send notification with moduleZone missing
				function Test:OnInteriorVehicleData_MissingModuleZone()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}				
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.3

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseMissingCheckNotification.10.4
			--Description: send notification with col missing
				function Test:OnInteriorVehicleData_MissingCol()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}				
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.4
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseMissingCheckNotification.10.5
			--Description: send notification with row missing
				function Test:OnInteriorVehicleData_MissingRow()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}			
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.5
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.6
			--Description: send notification with level missing
				function Test:OnInteriorVehicleData_MissingLevel()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}		
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.6
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.7
			--Description: send notification with colspan missing
				function Test:OnInteriorVehicleData_MissingColspan()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}		
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.7
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.8
			--Description: send notification with rowspan missing
				function Test:OnInteriorVehicleData_MissingRowspan()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}		
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.8
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.9
			--Description: send notification with levelspan missing
				function Test:OnInteriorVehicleData_MissingLevelspan()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}	
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.9
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheckNotification.10.10
			--Description: send notification with climateControlData missing
				function Test:OnInteriorVehicleData_MissingClimateControlData()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										}
									}	
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.10
			
		-----------------------------------------------------------------------------------------		
		
			
			--Begin Test case ResponseMissingCheckNotification.10.11
			--Description: send notification with fanSpeed missing
				function Test:OnInteriorVehicleData_MissingFanSpeed()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.11
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.12
			--Description: send notification with currentTemp missing
				function Test:OnInteriorVehicleData_MissingCurrentTemp()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.12
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.13
			--Description: send notification with desiredTemp missing
				function Test:OnInteriorVehicleData_MissingDesiredTemp()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.13
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheckNotification.10.14
			--Description: send notification with temperatureUnit missing
				function Test:OnInteriorVehicleData_MissingTemperatureUnit()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.14
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.15
			--Description: send notification with acEnable missing
				function Test:OnInteriorVehicleData_MissingAcEnable()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.15
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.16
			--Description: send notification with circulateAirEnable missing
				function Test:OnInteriorVehicleData_MissingCirculateAirEnable()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.16
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheckNotification.10.17
			--Description: send notification with autoModeEnable missing
				function Test:OnInteriorVehicleData_MissingAutoModeEnable()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											defrostZone = "FRONT",
											dualModeEnable = true
										}
									}
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.17
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheckNotification.10.18
			--Description: send notification with defrostZone missing
				function Test:OnInteriorVehicleData_MissingDefrostZone()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											dualModeEnable = true
										}
									}
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.18
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheckNotification.10.19
			--Description: send notification with dualModeEnable missing
				function Test:OnInteriorVehicleData_MissingDualModeEnable()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
								moduleData = {
										moduleType = "CLIMATE",
										moduleZone = {
											col = 0,
											row = 0,
											level = 0,
											colspan = 2,
											rowspan = 2,
											levelspan = 1
										},
										climateControlData = {
											fanSpeed = 50,
											currentTemp = 86,
											desiredTemp = 75,
											temperatureUnit = "FAHRENHEIT",
											acEnable = true,
											circulateAirEnable = true,
											autoModeEnable = true,
											defrostZone = "FRONT"
										}
									}
							})
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.19
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.20
			--Description: send notification with radioControlData missing
				function Test:OnInteriorVehicleData_MissingRadioControlData()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.20
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheckNotification.10.21
			--Description: send notification with radioEnable missing
				function Test:OnInteriorVehicleData_MissingRadioEnable()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.21
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheckNotification.10.22
			--Description: send notification with frequencyInteger missing
				function Test:OnInteriorVehicleData_MissingFrequencyInteger()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.22
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.23
			--Description: send notification with frequencyFraction missing
				function Test:OnInteriorVehicleData_MissingFrequencyFraction()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													band = "AM",
													hdChannel = 1,
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)

				end
			--End Test case ResponseMissingCheckNotification.10.23
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.24
			--Description: send notification with band missing
				function Test:OnInteriorVehicleData_MissingBand()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													hdChannel = 1,
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.24
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.25
			--Description: send notification with hdChannel missing
				function Test:OnInteriorVehicleData_MissinghdChannel()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.25
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.26
			--Description: send notification with state missing
				function Test:OnInteriorVehicleData_MissingState()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.26
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheckNotification.10.27
			--Description: send notification with availableHDs missing
				function Test:OnInteriorVehicleData_MissingAvailableHDs()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.27
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.28
			--Description: send notification with signalStrength missing
				function Test:OnInteriorVehicleData_MissingSignalStrength()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.28
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.29
			--Description: send notification with rdsData missing
				function Test:OnInteriorVehicleData_MissingRdsData()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.29
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheckNotification.10.30
			--Description: send notification with PS missing
				function Test:OnInteriorVehicleData_MissingPS()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.30
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheckNotification.10.31
			--Description: send notification with RT missing
				function Test:OnInteriorVehicleData_MissingRT()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.31
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheckNotification.10.32
			--Description: send notification with CT missing
				function Test:OnInteriorVehicleData_MissingCT()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "",
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.32
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheckNotification.10.33
			--Description: send notification with PI missing
				function Test:OnInteriorVehicleData_MissingPI()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "",
														CT = "123456789012345678901234",
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.33
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseMissingCheckNotification.10.34
			--Description: send notification with PTY missing
				function Test:OnInteriorVehicleData_MissingPTY()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "",
														CT = "123456789012345678901234",
														PI = "",
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.34
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseMissingCheckNotification.10.35
			--Description: send notification with TP missing
				function Test:OnInteriorVehicleData_MissingTP()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.35
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.36
			--Description: send notification with TA missing
				function Test:OnInteriorVehicleData_MissingTA()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.36
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.37
			--Description: send notification with REG missing
				function Test:OnInteriorVehicleData_MissingREG()
	
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
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
														TA = false
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseMissingCheckNotification.10.37
			
		-----------------------------------------------------------------------------------------
			
			--Begin Test case ResponseMissingCheckNotification.10.38
			--Description: send notification with signalChangeThreshold missing
				function Test:OnInteriorVehicleData_MissingsignalChangeThreshold()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
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
													}							
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)


				end
			--End Test case ResponseMissingCheckNotification.10.38
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseMissingCheckNotification.10.39
			--Description: send notification with all params missing
				function Test:OnSetDriversDevice_MissingAllParams()
				
					--hmi side: sending RC.OnSetDriversDevice notification
					self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {})
							
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)

				end
			--End Test case ResponseMissingCheckNotification.10.39
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseMissingCheckNotification.10.40
			--Description: send notification with name missing
				function Test:OnSetDriversDevice_MissingName()
				
					--hmi side: sending RC.OnSetDriversDevice notification
					self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {
									device = {
										id = 1,
										isSDLAllowed = true
									}					
					})
							
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)

				end
			--End Test case ResponseMissingCheckNotification.10.40
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseMissingCheckNotification.10.41
			--Description: send notification with ID missing
				function Test:OnSetDriversDevice_MissingID()
				
					--hmi side: sending RC.OnSetDriversDevice notification
					self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {
									device = {
										name = "127.0.0.1",
										isSDLAllowed = true
									}				
					})
							
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)

				end
			--End Test case ResponseMissingCheckNotification.10.41
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseMissingCheckNotification.10.42
			--Description: send notification with allowed missing
				function Test:OnReverseAppsAllowing_MissingAllowed()
				
					--hmi side: sending VehicleInfo.OnReverseAppsAllowing notification
					self.hmiConnection:SendNotification("VehicleInfo.OnReverseAppsAllowing", {			
					})
							
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)

				end
			--End Test case ResponseMissingCheckNotification.10.42			
	
	--End Test case ResponseMissingCheckNotification.10	
--=================================================END TEST CASES 10==========================================================--	
	


	
	
	
--=================================================BEGIN TEST CASES 11==========================================================--	


---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

			--Begin Test case Precondition.1
			--Description: mobile sends GetInteriorVehicleData request with subscribe = true for precondtion
				function Test:OnInteriorVehicleData_Precondition_RADIO()
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
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
						
				end
			--End Test case Precondition.1
			
			--Begin Test case Precondition.2
			--Description: GetInteriorVehicleData response with subscribe = true for precondtion
				function Test:GetInteriorVehicleData_Precondition_CLIMATE()
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
						end)
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

				end
			--End Test case Precondition.2		

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

	
	--Begin Test case ResponseOutOfBoundNotification.11
	--Description: 	--Invalid notification

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<12.>In case HMI sends a notification with one or more of out-of-bounds per rc-HMI_API values to RSDL, RSDL must log an error and ignore this notification.
	
			--Begin Test case ResponseOutOfBoundNotification.11.1
			--Description: OnInteriorVehicleData with all parameters out of bounds
				function Test:OnInteriorVehicleData_AllParamsOutLowerBound()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = -1,
										row = -1,
										rowspan = -1,
										col = -1,
										levelspan = -1,
										level = -1
									},
									climateControlData =
									{
										fanSpeed = -1,
										circulateAirEnable = true,
										dualModeEnable = true,
										currentTemp = -1,
										defrostZone = "FRONT",
										acEnable = true,
										desiredTemp = -1,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.1
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.2
			--Description: OnInteriorVehicleData with Colspan parameter out of bounds
				function Test:OnInteriorVehicleData_ColspanOutLowerBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = -1,
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.2
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.3
			--Description: OnInteriorVehicleData with row parameter out of bounds
				function Test:OnInteriorVehicleData_RowOutLowerBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = -1,
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.3
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.4
			--Description: OnInteriorVehicleData with rowspan parameter out of bounds
				function Test:OnInteriorVehicleData_RowspanOutLowerBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 0,
										rowspan = -1,
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.4
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.5
			--Description: OnInteriorVehicleData with col parameter out of bounds
				function Test:OnInteriorVehicleData_ColOutLowerBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = -1,
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.5
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.6
			--Description: OnInteriorVehicleData with levelspan parameter out of bounds
				function Test:OnInteriorVehicleData_LevelspanOutLowerBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										levelspan = -1,
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.6
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseOutOfBoundNotification.11.7
			--Description: OnInteriorVehicleData with level parameter out of bounds
				function Test:OnInteriorVehicleData_LevelOutLowerBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										level = -1
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.7
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.8
			--Description: OnInteriorVehicleData with frequencyInteger parameter out of bounds
				function Test:OnInteriorVehicleData_FrequencyIntegerOutLowerBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = -1,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.8
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundNotification.11.9
			--Description: OnInteriorVehicleData with frequencyFraction parameter out of bounds
				function Test:OnInteriorVehicleData_FrequencyFractionOutLowerBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = -1,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.9
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundNotification.11.10
			--Description: OnInteriorVehicleData with hdChannel parameter out of bounds
				function Test:OnInteriorVehicleData_HdChannelOutLowerBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 0,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.10
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.11
			--Description: OnInteriorVehicleData with availableHDs parameter out of bounds
				function Test:OnInteriorVehicleData_AvailableHDsOutLowerBound()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 0,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.11
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.12
			--Description: OnInteriorVehicleData with signalStrength parameter out of bounds
				function Test:OnInteriorVehicleData_SignalStrengthOutLowerBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = -1,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.12
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseOutOfBoundNotification.11.13
			--Description: OnInteriorVehicleData with signalChangeThreshold parameter out of bounds
				function Test:OnInteriorVehicleData_SignalChangeThresholdOutLowerBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
										},
										signalChangeThreshold = -1
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.13
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundNotification.11.14
			--Description: OnInteriorVehicleData with fanSpeed parameter out of bounds
				function Test:OnInteriorVehicleData_FanSpeedOutLowerBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										fanSpeed = -1,
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.14
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.15
			--Description: OnInteriorVehicleData with currentTemp parameter out of bounds
				function Test:OnInteriorVehicleData_CurrentTempOutLowerBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										currentTemp = -1,
										defrostZone = "FRONT",
										acEnable = true,
										desiredTemp = 24,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.15
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.16
			--Description: OnInteriorVehicleData with desiredTemp parameter out of bounds
				function Test:OnInteriorVehicleData_DesiredTempOutLowerBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										desiredTemp = -1,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.16
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundNotification.11.17
			--Description: OnInteriorVehicleData with all parameters out of bounds
				function Test:OnInteriorVehicleData_AllParamsOutUpperBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									moduleType = "CLIMATE",
									moduleZone = 
									{
										colspan = 101,
										row = 101,
										rowspan = 101,
										col = 101,
										levelspan = 101,
										level = 101
									},
									climateControlData =
									{
										fanSpeed = 101,
										circulateAirEnable = true,
										dualModeEnable = true,
										currentTemp = 101,
										defrostZone = "FRONT",
										acEnable = true,
										desiredTemp = 101,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.17
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.18
			--Description: OnInteriorVehicleData with Colspan parameter out of bounds
				function Test:OnInteriorVehicleData_ColspanOutUpperBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
										},
										signalChangeThreshold = 10								
									},
									moduleType = "RADIO",
									moduleZone = 
									{
										colspan = 101,
										row = 0,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.18
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.19
			--Description: OnInteriorVehicleData with row parameter out of bounds
				function Test:OnInteriorVehicleData_RowOutUpperBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
										},
										signalChangeThreshold = 10								
									},
									moduleType = "RADIO",
									moduleZone = 
									{
										colspan = 2,
										row = 101,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.19
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.20
			--Description: OnInteriorVehicleData with rowspan parameter out of bounds
				function Test:OnInteriorVehicleData_RowspanOutUpperBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
										},
										signalChangeThreshold = 10								
									},
									moduleType = "RADIO",
									moduleZone = 
									{
										colspan = 2,
										row = 0,
										rowspan = 101,
										col = 0,
										levelspan = 1,
										level = 0
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.20
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.21
			--Description: OnInteriorVehicleData with col parameter out of bounds
				function Test:OnInteriorVehicleData_ColOutUpperBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
										},
										signalChangeThreshold = 10								
									},
									moduleType = "RADIO",
									moduleZone = 
									{
										colspan = 2,
										row = 0,
										rowspan = 2,
										col = 101,
										levelspan = 1,
										level = 0
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.21
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.22
			--Description: OnInteriorVehicleData with levelspan parameter out of bounds
				function Test:OnInteriorVehicleData_LevelspanOutUpperBound()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
										levelspan = 101,
										level = 0
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.22
			
		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseOutOfBoundNotification.11.23
			--Description: OnInteriorVehicleData with level parameter out of bounds
				function Test:OnInteriorVehicleData_levelOutUpperBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
										level = 101
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.23
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.24
			--Description: OnInteriorVehicleData with frequencyInteger parameter out of bounds
				function Test:OnInteriorVehicleData_FrequencyIntegerOutUpperBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 1711,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.24
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundNotification.11.25
			--Description: OnInteriorVehicleData with frequencyFraction parameter out of bounds
				function Test:OnInteriorVehicleData_FrequencyFractionOutUpperBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 10,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.25
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseOutOfBoundNotification.11.26
			--Description: OnInteriorVehicleData with hdChannel parameter out of bounds
				function Test:OnInteriorVehicleData_HdChannelOutUpperBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 4,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.26
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.27
			--Description: OnInteriorVehicleData with availableHDs parameter out of bounds
				function Test:OnInteriorVehicleData_AvailableHDsOutUpperBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 4,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.27
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseOutOfBoundNotification.11.28
			--Description: OnInteriorVehicleData with signalStrength parameter out of bounds
				function Test:OnInteriorVehicleData_SignalStrengthOutUpperBound()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 101,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.28
			
		-----------------------------------------------------------------------------------------	

			--Begin Test case ResponseOutOfBoundNotification.11.29
			--Description: OnInteriorVehicleData with signalChangeThreshold parameter out of bounds
				function Test:OnInteriorVehicleData_SignalChangeThresholdOutUpperBound()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
										},
										signalChangeThreshold = 101								
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.29
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseOutOfBoundNotification.11.30
			--Description: OnInteriorVehicleData with fanSpeed parameter out of bounds
				function Test:OnInteriorVehicleData_FanSpeedOutUpperBound()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										fanSpeed = 101,
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.30
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.31
			--Description: OnInteriorVehicleData with currentTemp parameter out of bounds
				function Test:OnInteriorVehicleData_CurrentTempOutUpperBound()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										currentTemp = 101,
										defrostZone = "FRONT",
										acEnable = true,
										desiredTemp = 24,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.31
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.32
			--Description: OnInteriorVehicleData with desiredTemp parameter out of bounds
				function Test:OnInteriorVehicleData_DesiredTempOutUpperBound()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										desiredTemp = 101,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.32
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.33
			--Description: OnInteriorVehicleData with CT parameter out of bounds
				function Test:OnInteriorVehicleData_CTOutLowerBound()
	
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-070",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
										},
										signalChangeThreshold = 10								
									},
									moduleType = "RADIO",
									moduleZone = 
									{
										clospan = 1,
										row = 1,
										rowspan = 1,
										col = 1,
										levelspan = 1,
										level = 1
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.33
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.34
			--Description: OnInteriorVehicleData with PTY parameter out of bounds
				function Test:OnInteriorVehicleData_PTYOutLowerBound()
	
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = -1,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
										},
										signalChangeThreshold = 10								
									},
									moduleType = "RADIO",
									moduleZone = 
									{
										clospan = 1,
										row = 1,
										rowspan = 1,
										col = 1,
										levelspan = 1,
										level = 1
									}
								}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.34		

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.35
			--Description: OnInteriorVehicleData with PS parameter out of bounds
				function Test:OnInteriorVehicleData_PSOutUpperBound()
				
					--hmi side: sending RC.OnInteriorVehicleData notification
					self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "123456789",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdent",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}
					})		
					
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(0)
	
				end
			--End Test case ResponseOutOfBoundNotification.11.35

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.36
			--Description: OnInteriorVehicleData with PI parameter out of bounds
				function Test:OnInteriorVehicleData_PIOutUpperBound()
			
					--hmi side: sending RC.OnInteriorVehicleData notification
					self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
					{
						moduleData =
						{
							radioControlData = 
							{
								radioEnable = true,
								frequencyInteger = 105,
								frequencyFraction = 3,
								band = "AM",
								hdChannel = 1,
								state = "ACQUIRED",
								availableHDs = 1,
								signalStrength = 50,
								rdsData =
								{
									PS = "12345678",
									RT = "Radio text minlength = 0, maxlength = 64",
									CT = "2015-09-29T18:46:19-0700",
									PI = "PIdentI",
									PTY = 0,
									TP = true,
									TA = false,
									REG = "don't mention min,max length"
								},
								signalChangeThreshold = 10								
							},
							moduleType = "RADIO",
							moduleZone = 
							{
								clospan = 1,
								row = 1,
								rowspan = 1,
								col = 1,
								levelspan = 1,
								level = 1
							}
						}
					})		
					
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(0)
	
				end
			--End Test case ResponseOutOfBoundNotification.11.36

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.37
			--Description: OnInteriorVehicleData with RT parameter out of bounds
				function Test:OnInteriorVehicleData_RTOutUpperBound()
			
					--hmi side: sending RC.OnInteriorVehicleData notification
					self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "RADIO TEXT Minlength = 0, Maxlength = 64 RADIO TEXT Minlength = 6",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
					
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(0)
	
				end
			--End Test case ResponseOutOfBoundNotification.11.37

		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseOutOfBoundNotification.11.38
			--Description: OnInteriorVehicleData with CT parameter out of bounds
				function Test:OnInteriorVehicleData_CTOutUpperBound()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-07009",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

	
				end
			--End Test case ResponseOutOfBoundNotification.11.38
	
	--End Test case ResponseOutOfBoundNotification.11
--=================================================END TEST CASES 11==========================================================--




	
	
	
--=================================================BEGIN TEST CASES 12==========================================================--

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

			--Begin Test case Precondition.1
			--Description: mobile sends GetInteriorVehicleData request with subscribe = true for precondtion
				function Test:OnInteriorVehicleData_Precondition_RADIO()
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
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
						
				end
			--End Test case Precondition.1
			
			--Begin Test case Precondition.2
			--Description: GetInteriorVehicleData response with subscribe = true for precondtion
				function Test:GetInteriorVehicleData_Precondition_CLIMATE()
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
						end)
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

				end
			--End Test case Precondition.2		

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------


	--Begin Test case ResponseWrongTypeNotification.12
	--Description: 	--Invalid notification

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<13.>In case HMI sends a notification with one or more params of wrong type per rc-HMI_API to RSDL, RSDL must log an error and ignore this notification.
	
			--Begin Test case ResponseWrongTypeNotification.12.1
			--Description: OnInteriorVehicleData with all parameters of wrong type
				function Test:OnInteriorVehicleData_AllParamsWrongType()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = "true",
													frequencyInteger = "105",
													frequencyFraction = "3",
													band = true,
													hdChannel = "1",
													state = 123,
													availableHDs = "1",
													signalStrength = "50",
													rdsData =
													{
														PS = 12345678,
														RT = false,
														CT = 123456789123456789123456,
														PI = true,
														PTY = "0",
														TP = "true",
														TA = "false",
														REG = 123
													},
													signalChangeThreshold = "10"
												},
												moduleType = true,
												moduleZone = 
												{
													colspan = "2",
													row = "0",
													rowspan = "2",
													col = "0",
													levelspan = "1",
													level = "0"
												}
											}				
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.1
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseWrongTypeNotification.12.2
			--Description: OnInteriorVehicleData with radioEnable parameter of wrong type
				function Test:OnInteriorVehicleData_RadioEnableWrongType()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = 123,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.2
			
		-----------------------------------------------------------------------------------------			

			--Begin Test case ResponseWrongTypeNotification.12.3
			--Description: OnInteriorVehicleData with frequencyInteger parameter of wrong type
				function Test:OnInteriorVehicleData_FrequencyIntegerWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = "105",
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.3
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseWrongTypeNotification.12.4
			--Description: OnInteriorVehicleData with frequencyFraction parameter of wrong type
				function Test:OnInteriorVehicleData_FrequencyFractionWrongType()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = "3",
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.4
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeNotification.12.5
			--Description: OnInteriorVehicleData with band parameter of wrong type
				function Test:OnInteriorVehicleData_BandWrongType()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = 123,
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.5
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseWrongTypeNotification.12.6
			--Description: OnInteriorVehicleData with hdChannel parameter of wrong type
				function Test:OnInteriorVehicleData_HdChannelWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = "1",
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.6
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.7
			--Description: OnInteriorVehicleData with state parameter of wrong type
				function Test:OnInteriorVehicleData_StateWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = true,
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.7
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseWrongTypeNotification.12.8
			--Description: OnInteriorVehicleData with availableHDs parameter of wrong type
				function Test:OnInteriorVehicleData_AvailableHDsWrongType()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = "1",
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.8
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.9
			--Description: OnInteriorVehicleData with signalStrength parameter of wrong type
				function Test:OnInteriorVehicleData_SignalStrengthWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = "50",
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.9
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.10
			--Description: OnInteriorVehicleData with PS parameter of wrong type
				function Test:OnInteriorVehicleData_PSWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = 12345678,
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.10
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.11
			--Description: OnInteriorVehicleData with RT parameter of wrong type
				function Test:OnInteriorVehicleData_RTWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = 123,
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.11
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.12
			--Description: OnInteriorVehicleData with CT parameter of wrong type
				function Test:OnInteriorVehicleData_CTWrongType()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = 123456789123456789123456,
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.12
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.13
			--Description: OnInteriorVehicleData with PI parameter of wrong type
				function Test:OnInteriorVehicleData_PIWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = false,
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.13
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseWrongTypeNotification.12.14
			--Description: OnInteriorVehicleData with PTY parameter of wrong type
				function Test:OnInteriorVehicleData_PTYWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = "0",
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.14
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeNotification.12.15
			--Description: OnInteriorVehicleData with TP parameter of wrong type
				function Test:OnInteriorVehicleData_TPWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = "true",
														TA = false,
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.15
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeNotification.12.16
			--Description: OnInteriorVehicleData with TA parameter of wrong type
				function Test:OnInteriorVehicleData_TAWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = "false",
														REG = "don't mention min,max length"
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.16
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.17
			--Description: OnInteriorVehicleData with REG parameter of wrong type
				function Test:OnInteriorVehicleData_REGWrongType()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = 123
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.17
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeNotification.12.18
			--Description: OnInteriorVehicleData with signalChangeThreshold parameter of wrong type
				function Test:OnInteriorVehicleData_SignalChangeThresholdWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
													},
													signalChangeThreshold = "10"								
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.18
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeNotification.12.19
			--Description: OnInteriorVehicleData with moduleType parameter of wrong type
				function Test:OnInteriorVehicleData_ModuleTypeWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
													},
													signalChangeThreshold = 10								
												},
												moduleType = true,
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.19
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeNotification.12.20
			--Description: OnInteriorVehicleData with clospan parameter of wrong type
				function Test:OnInteriorVehicleData_ClospanWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
													},
													signalChangeThreshold = 10								
												},
												moduleType = "RADIO",
												moduleZone = 
												{
													colspan = "2",
													row = 0,
													rowspan = 2,
													col = 0,
													levelspan = 1,
													level = 0
												}
											}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.20
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeNotification.12.21
			--Description: OnInteriorVehicleData with row parameter of wrong type
				function Test:OnInteriorVehicleData_RowWrongType()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
													},
													signalChangeThreshold = 10								
												},
												moduleType = "RADIO",
												moduleZone = 
												{
													colspan = 2,
													row = "0",
													rowspan = 2,
													col = 0,
													levelspan = 1,
													level = 0
												}
											}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.21
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeNotification.12.22
			--Description: OnInteriorVehicleData with rowspan parameter of wrong type
				function Test:OnInteriorVehicleData_RowspanWrongType()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
													},
													signalChangeThreshold = 10								
												},
												moduleType = "RADIO",
												moduleZone = 
												{
													colspan = 2,
													row = 0,
													rowspan = "2",
													col = 0,
													levelspan = 1,
													level = 0
												}
											}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.22
			
		-----------------------------------------------------------------------------------------			
		
			--Begin Test case ResponseWrongTypeNotification.12.23
			--Description: OnInteriorVehicleData with col parameter of wrong type
				function Test:OnInteriorVehicleData_ColWrongType()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
													},
													signalChangeThreshold = 10								
												},
												moduleType = "RADIO",
												moduleZone = 
												{
													colspan = 2,
													row = 0,
													rowspan = 2,
													col = "0",
													levelspan = 1,
													level = 0
												}
											}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.23
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case ResponseWrongTypeNotification.12.24
			--Description: OnInteriorVehicleData with levelspan parameter of wrong type
				function Test:OnInteriorVehicleData_LevelspanWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
													levelspan = "1",
													level = 0
												}
											}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.24
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.25
			--Description: OnInteriorVehicleData with level parameter of wrong type
				function Test:OnInteriorVehicleData_LevelWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData =
													{
														PS = "12345678",
														RT = "Radio text minlength = 0, maxlength = 64",
														CT = "2015-09-29T18:46:19-0700",
														PI = "PIdent",
														PTY = 0,
														TP = true,
														TA = false,
														REG = "don't mention min,max length"
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
													level = "0"
												}
											}
							})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.25
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.26
			--Description: OnInteriorVehicleData with fanSpeed parameter of wrong type
				function Test:OnInteriorVehicleData_FanSpeedWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										fanSpeed = "50",
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.26
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.27
			--Description: OnInteriorVehicleData with circulateAirEnable parameter of wrong type
				function Test:OnInteriorVehicleData_CirculateAirEnableWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										circulateAirEnable = "true",
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.27
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.28
			--Description: OnInteriorVehicleData with dualModeEnable parameter of wrong type
				function Test:OnInteriorVehicleData_DualModeEnableWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										dualModeEnable = "true",
										currentTemp = 30,
										defrostZone = "FRONT",
										acEnable = true,
										desiredTemp = 24,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
								})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.28
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.29
			--Description: OnInteriorVehicleData with currentTemp parameter of wrong type
				function Test:OnInteriorVehicleData_CurrentTempWrongType()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										currentTemp = false,
										defrostZone = "FRONT",
										acEnable = true,
										desiredTemp = 24,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
								})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.29
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.30
			--Description: OnInteriorVehicleData with defrostZone parameter of wrong type
				function Test:OnInteriorVehicleData_DefrostZoneWrongType()
			
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										defrostZone = 123,
										acEnable = true,
										desiredTemp = 24,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
								})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.30
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.31
			--Description: OnInteriorVehicleData with acEnable parameter of wrong type
				function Test:OnInteriorVehicleData_AcEnableWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										acEnable = "true",
										desiredTemp = 24,
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
								})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.31
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case ResponseWrongTypeNotification.12.32
			--Description: OnInteriorVehicleData with desiredTemp parameter of wrong type
				function Test:OnInteriorVehicleData_DesiredTempWrongType()
		
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										desiredTemp = "24",
										autoModeEnable = true,
										temperatureUnit = "CELSIUS"
									}
								}
								})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.32
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.33
			--Description: OnInteriorVehicleData with autoModeEnable parameter of wrong type
				function Test:OnInteriorVehicleData_AutoModeEnableWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										autoModeEnable = 123,
										temperatureUnit = "CELSIUS"
									}
								}
								})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.33

		-----------------------------------------------------------------------------------------
			
			--Begin Test case ResponseWrongTypeNotification.12.34
			--Description: OnInteriorVehicleData with TemperatureUnit parameter of wrong type
				function Test:OnInteriorVehicleData_TemperatureUnitWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
										temperatureUnit = 123
									}
								}
								})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.34		

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseWrongTypeNotification.12.35
			--Description: OnInteriorVehicleData with moduleData parameter of wrong type
				function Test:OnInteriorVehicleData_ModuleDataWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData = "abc"
								})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.35

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.36
			--Description: OnInteriorVehicleData with climateControlData parameter of wrong type
				function Test:OnInteriorVehicleData_ClimateControlDataWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
									climateControlData = "  a b c  "
								}
								})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.36

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.37
			--Description: OnInteriorVehicleData with radioControlData parameter of wrong type
				function Test:OnInteriorVehicleData_RadioControlDataDataWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = true,
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.37		

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.38
			--Description: OnInteriorVehicleData with moduleZone parameter of wrong type
				function Test:OnInteriorVehicleData_ModuleZoneDataDataWrongType()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
								moduleData =
								{
									radioControlData = 
									{
										radioEnable = true,
										frequencyInteger = 105,
										frequencyFraction = 3,
										band = "AM",
										hdChannel = 1,
										state = "ACQUIRED",
										availableHDs = 1,
										signalStrength = 50,
										rdsData =
										{
											PS = "12345678",
											RT = "Radio text minlength = 0, maxlength = 64",
											CT = "2015-09-29T18:46:19-0700",
											PI = "PIdent",
											PTY = 0,
											TP = true,
											TA = false,
											REG = "don't mention min,max length"
										},
										signalChangeThreshold = 10								
									},
									moduleType = "RADIO",
									moduleZone = true
								}
								})		
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.38

		-----------------------------------------------------------------------------------------
			
			--Begin Test case ResponseWrongTypeNotification.12.39
			--Description: OnInteriorVehicleData with rdsData parameter of wrong type
				function Test:OnInteriorVehicleData_RdsDataWrongType()
					
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
							{
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													hdChannel = 1,
													state = "ACQUIRED",
													availableHDs = 1,
													signalStrength = 50,
													rdsData = true,
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
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)


				end
			--End Test case ResponseWrongTypeNotification.12.39	
	
			--Begin Test case ResponseWrongTypeNotification.12.39
			--Description: send notification with all params WrongType
				function Test:OnSetDriversDevice_WrongTypeAllParams()
				
					--hmi side: sending RC.OnSetDriversDevice notification
					self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {
									device = {
										name = true,
										id = "1",
										isSDLAllowed = "true"
									}					
					})
							
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)

				end
			--End Test case ResponseWrongTypeNotification.12.39
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseWrongTypeNotification.12.40
			--Description: send notification with name WrongType
				function Test:OnSetDriversDevice_WrongTypeName()
				
					--hmi side: sending RC.OnSetDriversDevice notification
					self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {
									device = {
										name = 123,
										id = 1,
										isSDLAllowed = true
									}				
					})
							
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)

				end
			--End Test case ResponseWrongTypeNotification.12.40
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseWrongTypeNotification.12.41
			--Description: send notification with ID WrongType
				function Test:OnSetDriversDevice_WrongTypeID()
				
					--hmi side: sending RC.OnSetDriversDevice notification
					self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {
									device = {
										name = "127.0.0.1",
										id = {1},
										isSDLAllowed = true
									}			
					})
							
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)

				end
			--End Test case ResponseWrongTypeNotification.12.41

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseWrongTypeNotification.12.42
			--Description: send notification with device WrongType
				function Test:OnSetDriversDevice_WrongTypeDevice()
				
					--hmi side: sending RC.OnSetDriversDevice notification
					self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {
									device = true
					})
							
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)

				end
			--End Test case ResponseWrongTypeNotification.12.42	

		-----------------------------------------------------------------------------------------			
			
			--<TODO>: Question: REVSDL-1050
			--Begin Test case ResponseWrongTypeNotification.12.43
			--Description: send notification with allowed WrongType
				function Test:OnReverseAppsAllowing_WrongTypeAllowed()
				
					--hmi side: sending VehicleInfo.OnReverseAppsAllowing notification
					self.hmiConnection:SendNotification("VehicleInfo.OnReverseAppsAllowing", {allowed = "true"})
							
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)

				end
			--End Test case ResponseWrongTypeNotification.12.43			
	
	--End Test case ResponseWrongTypeNotification.12
--=================================================END TEST CASES 12==========================================================--
	
	
	
	
	
	

--=================================================BEGIN TEST CASES 13==========================================================--

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

			--Begin Test case Precondition.1
			--Description: mobile sends GetInteriorVehicleData request with subscribe = true for precondtion
				function Test:OnInteriorVehicleData_Precondition_RADIO()
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
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
						
				end
			--End Test case Precondition.1
			
			--Begin Test case Precondition.2
			--Description: GetInteriorVehicleData response with subscribe = true for precondtion
				function Test:GetInteriorVehicleData_Precondition_CLIMATE()
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
						end)
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

				end
			--End Test case Precondition.2		

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------
	
	--Begin Test case ResponseInvalidJsonNotification.13
	--Description: 	--Invalid notification

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<14.>In case HMI sends a notification of invalid JSON to RSDL, RSDL must log an error and ignore this notification.

			--Begin Test case ResponseInvalidJsonNotification.13.1
			--Description: OnInteriorVehicleData with wrong json
				function Test:OnInteriorVehicleData_WrongJson()
				
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:Send('{"jsonrpc":"2.0","method":"RC.OnInteriorVehicleData","params":{"moduleData":{"moduleType":"CLIMATE","moduleZone":{"col":0,"row":0,"level":0,"colspan":2,"rowspan":2,"levelspan":1},"climateControlData":{"fanSpeed":50,"currentTemp":86,"desiredTemp":75,"temperatureUnit":"FAHRENHEIT","acEnable":true,"circulateAirEnable":true,"autoModeEnable":true,"defrostZone":"FRONT","dualModeEnable" true}}}}')
							
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)

				
				end
			--End Test case ResponseInvalidJsonNotification.13.1
	
		-----------------------------------------------------------------------------------------	
	
			--Begin Test case ResponseInvalidJsonNotification.13.2
			--Description: OnSetDriversDevice with wrong json
				function Test:OnSetDriversDevice_WrongJson()
					--hmi side: sending RC.OnSetDriversDevice notification
					self.hmiConnection:Send('{"jsonrpc":"2.0","method":"RC.OnSetDriversDevice","params":{"device":{"name":"10.42.0.73","id":1,"isSDLAllowed" false}}}')
					
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)
				end
			--End Test case ResponseInvalidJsonNotification.13.2

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseInvalidJsonNotification.13.3
			--Description: OnReverseAppsAllowing with wrong json
				function Test:OnReverseAppsAllowing_WrongJson()
					--hmi side: sending RC.OnReverseAppsAllowing notification
					self.hmiConnection:Send('{"jsonrpc":"2.0","method":"RC.OnReverseAppsAllowing","params":{"allowed" false}}')
					
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)
				end
			--End Test case ResponseInvalidJsonNotification.13.3			

	--End Test case ResponseInvalidJsonNotification.13
--=================================================END TEST CASES 13==========================================================--


	
	
	
	
--=================================================BEGIN TEST CASES 14==========================================================--

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

			--Begin Test case Precondition.1
			--Description: mobile sends GetInteriorVehicleData request with subscribe = true for precondtion
				function Test:OnInteriorVehicleData_Precondition_RADIO()
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
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
						
				end
			--End Test case Precondition.1
			
			--Begin Test case Precondition.2
			--Description: GetInteriorVehicleData response with subscribe = true for precondtion
				function Test:GetInteriorVehicleData_Precondition_CLIMATE()
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
						end)
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

				end
			--End Test case Precondition.2		

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

	--Begin Test case ResponseWrongModuleTypeAnd<module>ControlDataNotification.14
	--Description: 	--Invalid notification

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<15.>In case HMI sends a notification with non-corresponding-to-each-other moduleType and <module>ControlData (example: module: RADIO & climateControlData) to RSDL, RSDL must log an error and ignore this notification.

			--Begin Test case NotificationWrongModuleTypeAnd<module>ControlDataNotification.14.1
			--Description: OnInteriorVehicleData Notification with wrong moduleType and <module>ControlData
				function Test:OnInteriorVehicleData_NotificationWrongModuleTypeAndControlData_RADIO()
					--hmi side: sending RC.OnInteriorVehicleData notification
					self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "CLIMATE",
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
					
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)
					
				end
			--End Test case NotificationWrongModuleTypeAnd<module>ControlDataNotification.14.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case NotificationWrongModuleTypeAnd<module>ControlDataNotification.14.2
			--Description: OnInteriorVehicleData Notification with wrong moduleType and <module>ControlData
				function Test:OnInteriorVehicleData_NotificationWrongModuleTypeAndControlData_CLIMATE()
					--hmi side: sending RC.OnInteriorVehicleData notification
					self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
					{
								moduleData =
								{
									moduleType = "RADIO",
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
					
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(0)
					
				end
			--End Test case NotificationWrongModuleTypeAnd<module>ControlDataNotification.14.2		

	--End Test case ResponseWrongModuleTypeAnd<module>ControlDataNotification.14
--=================================================END TEST CASES 14==========================================================--	
	
	
	
	
	
	
	
--=================================================BEGIN TEST CASES 15==========================================================--

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

			--Begin Test case Precondition.1
			--Description: mobile sends GetInteriorVehicleData request with subscribe = true for precondtion
				function Test:OnInteriorVehicleData_Precondition_RADIO()
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
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
						
				end
			--End Test case Precondition.1
			
			--Begin Test case Precondition.2
			--Description: GetInteriorVehicleData response with subscribe = true for precondtion
				function Test:GetInteriorVehicleData_Precondition_CLIMATE()
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
						end)
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

				end
			--End Test case Precondition.2		

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

	--Begin Test case ResponseFakeParamsNotification.15
	--Description: 	--Fake params

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<16.>In case HMI sends a notification, expected by a mobile app, with one or more fake params (that is, non-existent per HMI_API) to RSDL, RSDL must cut these fake params off and transfer this notification to the mobile app 
						--Information: applicable RPCs: 
						--OnInteriorVehicleData
						
						
---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

			--Begin Test case Precondition.1
			--Description: mobile sends GetInteriorVehicleData request with subscribe = true for precondtion
				function Test:GetInteriorVehicleData_Precondition_RADIO()
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
			--End Test case Precondition.1
			
			--Begin Test case Precondition.2
			--Description: GetInteriorVehicleData response with subscribe = true for precondtion
				function Test:GetInteriorVehicleData_Precondition_CLIMATE()
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
					
					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

				end
			--End Test case Precondition.2		

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------						
						

			--Begin Test case ResponseFakeParamsNotification.15.1
			--Description: OnInteriorVehicleData notification with fake parameters
				function Test:OnInteriorVehicleData_FakeParamsInsideModuleZone()
					--hmi side: sending RC.OnInteriorVehicleData notification
					self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
					{
						moduleData =
						{
							moduleType = "CLIMATE",
							moduleZone = 
							{
								fake1 = 123,
								colspan = 2,
								row = 0,
								fake2 = {1},
								rowspan = 2,
								col = 0,
								levelspan = 1,
								fake3 = "   fake params ",
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
					
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:ValidIf (function(_,data)
						--for key,value in pairs(data.payload.moduleData.moduleZone) do print(key,value) end
							if data.payload.moduleData.moduleZone.fake1 or data.payload.moduleData.moduleZone.fake2 or data.payload.moduleData.moduleZone.fake3 then
								print(" SDL resend fake parameter to mobile app ")
								for key,value in pairs(data.payload.moduleData.moduleZone) do print(key,value) end
								return false
							else 
								return true
							end
					end)

				end
			--End Test case ResponseFakeParamsNotification.15.1

		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseFakeParamsNotification.15.2
			--Description: OnInteriorVehicleData notification with fake parameters
				function Test:OnInteriorVehicleData_FakeParamsInsideClimateControlData()
					--hmi side: sending RC.OnInteriorVehicleData notification
					self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
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
								fake1 = {},
								fanSpeed = 50,
								circulateAirEnable = true,
								dualModeEnable = true,
								fake2 = " fake",
								currentTemp = 30,
								defrostZone = "FRONT",
								acEnable = true,
								desiredTemp = 24,
								autoModeEnable = true,
								fake3 = true,
								temperatureUnit = "CELSIUS"
							}
						}
						})		
					
					--mobile side: SDL does not send fake params to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")					
					:ValidIf (function(_,data)
						--for key,value in pairs(data.payload.moduleData.climateControlData) do print(key,value) end
							if data.payload.moduleData.climateControlData.fake1 or data.payload.moduleData.climateControlData.fake2 or data.payload.moduleData.climateControlData.fake3 then
								print(" SDL resend fake parameter to mobile app ")
								for key,value in pairs(data.payload.moduleData.climateControlData) do print(key,value) end
								return false
							else 
								return true
							end
					end)

				end
			--End Test case ResponseFakeParamsNotification.15.2
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseFakeParamsNotification.15.3
			--Description: OnInteriorVehicleData notification with fake parameters
				function Test:OnInteriorVehicleData_FakeParamsOutsideModuleData()
					--hmi side: sending RC.OnInteriorVehicleData notification
					self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
					{
						fake1 = "fake params ",
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
						},
						fake2 = true,
						fake3 = 123
						})		
					
					--mobile side: SDL does not send fake params to mobile app
					EXPECT_NOTIFICATION("OnInteriorVehicleData")
					:Times(1)
					:ValidIf (function(_,data)
						--for key,value in pairs(data.payload.moduleData.climateControlData) do print(key,value) end
							if data.payload.fake1 or data.payload.fake2 or data.payload.fake3 then
								print(" SDL resend fake parameter to mobile app ")
								for key,value in pairs(data.payload) do print(key,value) end
								return false
							else 
								return true
							end
					end)

				end
			--End Test case ResponseFakeParamsNotification.15.3

	--End Test case ResponseFakeParamsNotification.15
--=================================================END TEST CASES 15==========================================================--	
	
	
	
	
	
	
--NOTE: UPDATED "OnSetDriversDevice" to "OnDeviceRankChanged" base on REVSDL-1577
--=================================================BEGIN TEST CASES 16==========================================================--	

	--Begin Test case ResponseFakeParamsNotification.16
	--Description: 	--Fake params

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<17.>In case HMI sends a notification, expected by RSDL for internal processing, with one or more fake params (that is, non-existent per HMI_API) to RSDL, RSDL must cut these fake params off and process the notification 
						--Information: applicable RPCs: 
						--OnSetDriversDevice 
						--OnReverseAppsAllowing						

			--Begin Test case ResponseFakeParamsNotification.16.1
			--Description: send notification with fake params
							--NOTE: UPDATED "OnSetDriversDevice" to "OnDeviceRankChanged" base on REVSDL-1577
				function Test:OnSetDriversDevice_FakeParamsInsideDevice()
				
					-- --hmi side: sending RC.OnSetDriversDevice notification
					-- self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {							
									-- device = {
										-- fake1 = true,
										-- name = "127.0.0.1",
										-- fake2 = {1},
										-- id = 1,
										-- isSDLAllowed = true,
										-- fake3 = "   fake params   "
									-- }
							-- })
							
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{deviceRank = "DRIVER", fake1 = true, device = {name = "127.0.0.1", fake2 = {1}, id = 1, isSDLAllowed = true, fake3 = "   fake params   "}})
					
					--mobile side: SDL does not send fake params to mobile app
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(1)

				end
			--End Test case ResponseFakeParamsNotification.16.1						

		-----------------------------------------------------------------------------------------			
			
			--Begin Test case ResponseFakeParamsNotification.16.2
			--Description: send notification with fake params
							--NOTE: UPDATED "OnSetDriversDevice" to "OnDeviceRankChanged" base on REVSDL-1577
				function Test:OnSetDriversDevice_FakeParamsOutsideDevice()
				
					-- --hmi side: sending RC.OnSetDriversDevice notification
					-- self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {
									-- fake1 = {1},
									-- device = {
										-- name = "127.0.0.1",
										-- id = 1,
										-- isSDLAllowed = true
									-- }
							-- })
							
					--hmi side: send request RC.OnDeviceRankChanged
					self.hmiConnection:SendNotification("RC.OnDeviceRankChanged", 
															{fake0 = "ERROR", deviceRank = "PASSENGER", fake1 = true, device = {name = "127.0.0.1", fake2 = {1}, id = 1, isSDLAllowed = true, fake3 = "   fake params   "}})			
					
					--mobile side: SDL does not send fake params to mobile app
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(1)

				end
			--End Test case ResponseFakeParamsNotification.16.2

		-----------------------------------------------------------------------------------------
			
			--Begin Test case ResponseFakeParamsNotification.16.3
			--Description: send notification with fake params
				function Test:OnReverseAppsAllowing_FakeParams()
				
					--hmi side: sending VehicleInfo.OnReverseAppsAllowing notification
					self.hmiConnection:SendNotification("VehicleInfo.OnReverseAppsAllowing", {allowed = true, isAllowed = false})
							
					--mobile side: Absence of notifications
					EXPECT_NOTIFICATION("OnPermissionsChange")
					:Times(1)

				end
			--End Test case ResponseFakeParamsNotification.16.3		

	--End Test case ResponseFakeParamsNotification.16
--=================================================END TEST CASES 16==========================================================--	
	
	
	





--=================================================BEGIN TEST CASES 17==========================================================--	

	--Begin Test case ResponseFakeParamsNotification.17
	--Description: 	--Fake params

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<18.>In case a mobile app sends a valid request to RSDL, RSDL transfers this request to HMI, and HMI responds with one or more fake params (that is, non-existent per HMI_API) to RSDL, RSDL must cut these fake params off and transfer the response to the mobile app 
							--Information: applicable RPCs: 
							--GetInteriorVehicleDataCapabilities 
							--GetInteriorVehicleData 
							--SetInteriorVehicleData

			--Begin Test case case ResponseFakeParamsNotification.17.1
			--Description: GetInteriorVehicleDataCapabilities response with fake params
				function Test:GetInteriorVehicleDataCapabilities_ResposeFakeParams()
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
								fake1 = true,
								colspan = 2,
								row = 0,
								fake2 = 123,
								rowspan = 2,
								col = 0,
								fake3 = {1},
								levelspan = 1,
								level = 0
							},
							moduleType = "RADIO"
						}
						}
						})
					end)

					--mobile side: SDL returns SUCCESS and cuts fake params
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
					:ValidIf (function(_,data)
						--for key,value in pairs(data.payload.interiorVehicleDataCapabilities[1].moduleZone) do print(key,value) end
						
							if data.payload.interiorVehicleDataCapabilities[1].moduleZone.fake1 or data.payload.interiorVehicleDataCapabilities[1].moduleZone.fake2 or data.payload.interiorVehicleDataCapabilities[1].moduleZone.fake3 then
								print(" SDL resend fake parameter to mobile app ")
								for key,value in pairs(data.payload.interiorVehicleDataCapabilities[1].moduleZone) do print(key,value) end
								return false
							else 
								return true
							end
					end)				
				end
			--End Test case case ResponseFakeParamsNotification.17.1
			
		-----------------------------------------------------------------------------------------

			--Begin Test case ResponseFakeParamsNotification.17.2
			--Description: SetInteriorVehicleData response with fake params
				function Test:SetInteriorVehicleData_ResposeFakeParamsInsideModuleData()
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
										fake1 = true,
										colspan = 2,
										row = 0,
										rowspan = 2,
										fake2 = 123,
										col = 0,
										levelspan = 1,
										level = 0,
										fake3 = " a b c "
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
					
					--mobile side: SDL returns SUCCESS and cuts fake params
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
					:ValidIf (function(_,data)
						--for key,value in pairs(data.payload.moduleData.moduleZone) do print(key,value) end						
							if data.payload.moduleData.moduleZone.fake1 or data.payload.moduleData.moduleZone.fake2 or data.payload.moduleData.moduleZone.fake3 then
								print(" SDL resend fake parameter to mobile app ")
								for key,value in pairs(data.payload.moduleData.moduleZone) do print(key,value) end
								return false
							else 
								return true
							end
					end)	
				end
			--End Test case ResponseFakeParamsNotification.17.2
			
		-----------------------------------------------------------------------------------------	
		
			--Begin Test case ResponseFakeParamsNotification.17.3
			--Description: SetInteriorVehicleData response with fake params
				function Test:SetInteriorVehicleData_ResposeFakeParamsOutsideModuleData()
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
								fake1 = true,
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
								},
								fake2 = {1},
								fake3 = " fake parameters   "
							})
						end)					
					
					--mobile side: SDL returns SUCCESS and cuts fake params
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
					:ValidIf (function(_,data)
						--for key,value in pairs(data.payload) do print(key,value) end
						
							if data.payload.fake1 or data.payload.fake2 or data.payload.fake3 then
								print(" SDL resend fake parameter to mobile app ")
								for key,value in pairs(data.payload) do print(key,value) end
								return false
							else 
								return true
							end
					end)	
				end
			--End Test case ResponseFakeParamsNotification.17.3
			
		-----------------------------------------------------------------------------------------								

			--Begin Test case ResponseFakeParamsNotification.17.4
			--Description: GetInteriorVehicleData response with fake params
				function Test:GetInteriorVehicleData_ResposeFakeParamsInsideModuleData()
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
									moduleData =
									{
										radioControlData = 
										{
											fake1 = true,
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												fake2 = {1},
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
											},
											signalChangeThreshold = 10								
										},
										moduleType = "RADIO",
										moduleZone = 
										{
											fake3 = " fake params  ",
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
					
					--mobile side: SDL returns SUCCESS and cuts fake params
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
					:ValidIf (function(_,data)
						--for key,value in pairs(data.payload.moduleData) do print(key,value) end
						
							if data.payload.moduleData.radioControlData.fake1 or data.payload.moduleData.radioControlData.rdsData.fake2 or data.payload.moduleData.moduleZone.fake3 then
								print(" SDL resend fake parameter to mobile app ")
								for key,value in pairs(data.payload.moduleData.radioControlData) do print(key,value) end
								return false
							else 
								return true
							end
					end)
				end
			--End Test case ResponseFakeParamsNotification.17.4
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case ResponseFakeParamsNotification.17.5
			--Description: GetInteriorVehicleData response with fake params
				function Test:GetInteriorVehicleData_ResposeFakeParamsOutsideModuleData()
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
									fake1 = {1},
									moduleData =
									{
										fake2 = true,
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
											state = "ACQUIRED",
											availableHDs = 1,
											signalStrength = 50,
											rdsData =
											{
												PS = "12345678",
												RT = "Radio text minlength = 0, maxlength = 64",
												CT = "2015-09-29T18:46:19-0700",
												PI = "PIdent",
												PTY = 0,
												TP = true,
												TA = false,
												REG = "don't mention min,max length"
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
									},
									fake3 = " fake params "
							})
						end)					
					
					--mobile side: SDL returns SUCCESS and cuts fake params
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
					:ValidIf (function(_,data)
						--for key,value in pairs(data.payload.moduleData) do print(key,value) end
						
							if data.payload.fake1 or data.payload.moduleData.fake2 or data.payload.fake3 then
								print(" SDL resend fake parameter to mobile app ")
								for key,value in pairs(data.payload) do print(key,value) end
								return false
							else 
								return true
							end
					end)
				end
			--End Test case ResponseFakeParamsNotification.17.5

	--End Test case ResponseFakeParamsNotification.17
--=================================================END TEST CASES 17==========================================================--
	
	
	
	
	
	
	
	



--=================================================BEGIN TEST CASES 18==========================================================--	

	--Begin Test case ResponseFakeParamsNotification.18
	--Description: 	--Fake params

		--Requirement/Diagrams id in jira: 
				--REVSDL-1038

		--Verification criteria: 
				--<19.>In case RSDL sends a request following the internal processes to HMI (example: permission request), and HMI responds with one or more fake params (that is, non-existent per HMI_API) to RSDL, RSDL must cut these fake params off and process the response 
						--Information: applicable RPCs: 
						--GetInteriorVehicleDataConsent


			--Begin Test case ResponseFakeParamsNotification.18.1
			--Description: send notification with fake params
				function Test:GetInteriorVehicleDataConsent_FakeParams()
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
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
						
					end)				
					
					
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
					:Timeout(3000)
				end
			--End Test case ResponseFakeParamsNotification.18.1	

	--End Test case ResponseFakeParamsNotification.18
--=================================================END TEST CASES 18==========================================================--




--=================================================BEGIN TEST CASES 19==========================================================--

	--Begin Test case ResponseFakeParamsNotification.19
	--Description: 	--8. driver_allow - erroneous resultCode

		--Requirement/Diagrams id in jira: 
				--REVSDL-966
				--[REVSDL-966][TC-09]: 8. driver_allow - erroneous resultCode
	
			--Begin Test case ResponseAnyErroneousResultCode
			--Description: HMI responds with any erroneous resultCode for RC.GetInteriorVehicleDataConsent (This test to [REVSDL-966][TC-09]: 8. driver_allow - erroneous resultCode)
				function Test:GetInteriorVehicleDataConsent_ResponseAnyErroneousResultCode()
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
						self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "ERROR", {allowed = true})
						
					end)				
					
					
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
					:Timeout(3000)
				end
			--End Test case ResponseAnyErroneousResultCode
	--End Test case ResponseFakeParamsNotification.19
--=================================================BEGIN TEST CASES 19==========================================================--




--=================================================BEGIN TEST CASES 20==========================================================--

	--Begin Test case MaxlengthREG.20
	--Description: 	--APP's, HMI's RPCs Validation: should we set Maxlength for "REG" param?

		--Requirement/Diagrams id in jira: 
				--REVSDL-1542 (Question)
				--minlength="0" maxlength=”255"
	
			--Begin Test case MaxlengthREG.20.1
			--Description: mobile sends GetInteriorVehicleData request with subscribe = true and HMI responds upper bound for REG (256)
				function Test:GetInteriorVehicleData_Response_UpperBoundREG()
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
												REG = "This is mainly used in countries where national broadcasters run 'region-specific' programming such as regional opt-outs on some of their transmitters. This functionality allows the user to 'lock-down' the set to their current region or let the radio tune"
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
			--End Test case MaxlengthREG.20.1
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case MaxlengthREG.20.2
			--Description: mobile sends GetInteriorVehicleData request with subscribe = true and HMI responds out upper bound for REG (257)
				function Test:GetInteriorVehicleData_Response_OutUpperBoundREG()
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
												REG = "This is mainly used in countries where national broadcasters run 'region-specific' programming such as regional opt-outs on some of their transmitters. This functionality allows the user to 'lock-down' the set to their current region or let the radio tunez"
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

					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
						
				end
			--End Test case MaxlengthREG.20.2

		-----------------------------------------------------------------------------------------
		
			--Begin Test case MaxlengthREG.20.3
			--Description: mobile sends SetInteriorVehicleData request and HMI responds upper bound for REG (256)
				function Test:SetInteriorVehicleData_Response_UpperBoundREG()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
												REG = "This is mainly used in countries where national broadcasters run 'region-specific' programming such as regional opt-outs on some of their transmitters. This functionality allows the user to 'lock-down' the set to their current region or let the radio tune"
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
						end)					
					
						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case MaxlengthREG.20.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case MaxlengthREG.20.4
			--Description: mobile sends SetInteriorVehicleData request and HMI responds out upper bound for REG (257)
				function Test:SetInteriorVehicleData_Response_OutUpperBoundREG()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
					
					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
												REG = "This is mainly used in countries where national broadcasters run 'region-specific' programming such as regional opt-outs on some of their transmitters. This functionality allows the user to 'lock-down' the set to their current region or let the radio tunez"
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
						end)						

					--mobile side: expect GENERIC_ERROR response with info
					EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid response from the vehicle"})
						
				end
			--End Test case MaxlengthREG.20.4

		-----------------------------------------------------------------------------------------
		
			--Begin Test case MaxlengthREG.20.5
			--Description: mobile sends SetInteriorVehicleData request with upper bound for REG (256)
				function Test:SetInteriorVehicleData_UpperBoundREG()
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
												REG = "This is mainly used in countries where national broadcasters run 'region-specific' programming such as regional opt-outs on some of their transmitters. This functionality allows the user to 'lock-down' the set to their current region or let the radio tune"
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
					
					--hmi side: expect RC.SetInteriorVehicleData request
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
						:Do(function(_,data)
							--hmi side: sending RC.SetInteriorVehicleData response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
												REG = "This is mainly used in countries where national broadcasters run 'region-specific' programming such as regional opt-outs on some of their transmitters. This functionality allows the user to 'lock-down' the set to their current region or let the radio tune"
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
						end)					
					
						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				end
			--End Test case MaxlengthREG.20.5
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case MaxlengthREG.20.6
			--Description: mobile sends SetInteriorVehicleData request with out upper bound for REG (257)
				function Test:SetInteriorVehicleData_OutUpperBoundREG()
					--mobile sends request for precondition
					local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
					{
									moduleData =
									{
										radioControlData = 
										{
											radioEnable = true,
											frequencyInteger = 105,
											frequencyFraction = 3,
											band = "AM",
											hdChannel = 1,
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
												REG = "This is mainly used in countries where national broadcasters run 'region-specific' programming such as regional opt-outs on some of their transmitters. This functionality allows the user to 'lock-down' the set to their current region or let the radio tunez"
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
						

					--mobile side: expect INVALID_DATA response
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA"})
						
				end
			--End Test case MaxlengthREG.20.6
			
---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

			--Begin Test case Precondition.1
			--Description: mobile sends GetInteriorVehicleData request with subscribe = true for precondtion
				function Test:GetInteriorVehicleData_Precondition_RADIO()
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
							
						end)						

						--mobile side: expect SUCCESS response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
						
				end
			--End Test case Precondition.1

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------				

			--Begin Test case MaxlengthREG.20.7
			--Description: HMI responds OnInteriorVehicleData to RSDL with upper bound for REG (256)
				function Test:OnInteriorVehicleData_UpperBoundREG()
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													state = "ACQUIRED",
													hdChannel = 1,
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
														REG = "This is mainly used in countries where national broadcasters run 'region-specific' programming such as regional opt-outs on some of their transmitters. This functionality allows the user to 'lock-down' the set to their current region or let the radio tune"
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
									
							--mobile side: receiving of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(1)
				end
			--End Test case MaxlengthREG.20.7
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case MaxlengthREG.20.8
			--Description: HMI responds OnInteriorVehicleData to RSDL with out upper bound for REG (257)
				function Test:OnInteriorVehicleData_OutUpperBoundREG()
							--hmi side: sending RC.OnInteriorVehicleData notification
							self.hmiConnection:SendNotification("RC.OnInteriorVehicleData", {
											moduleData =
											{
												radioControlData = 
												{
													radioEnable = true,
													frequencyInteger = 105,
													frequencyFraction = 3,
													band = "AM",
													state = "ACQUIRED",
													hdChannel = 1,
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
														REG = "This is mainly used in countries where national broadcasters run 'region-specific' programming such as regional opt-outs on some of their transmitters. This functionality allows the user to 'lock-down' the set to their current region or let the radio tunez"
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
									
							--mobile side: Absence of notifications
							EXPECT_NOTIFICATION("OnInteriorVehicleData")
							:Times(0)
						
				end
			--End Test case MaxlengthREG.20.8
			
		
	--End Test case MaxlengthREG.20
--=================================================BEGIN TEST CASES 20==========================================================--

			
	
return Test	