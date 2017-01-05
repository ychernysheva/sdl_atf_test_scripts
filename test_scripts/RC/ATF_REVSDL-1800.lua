Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local config = require('config')
local module = require('testbase')

						

	
	
	

--======================================REVSDL-1800========================================--
---------------------------------------------------------------------------------------------
-----------REVSDL-1800: Validation: RPC with mismatched control-params and-------------------
----------------------moduleType from mobile app must get INVALID_DATA-----------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: 1. In case application registered with REMOTE_CONTROL AppHMIType sends ButtonPress RPC with <climate-related-buttons> and RADIO moduleType 
							--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.

	--Begin Test case CommonRequestCheck.1.1
	--Description: 	RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1800

		--Verification criteria: 
				--In case application registered with REMOTE_CONTROL AppHMIType sends ButtonPress RPC with <climate-related-buttons> and RADIO moduleType 

		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.1.1.1
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = AC_MAX
				function Test:ButtonPress_RADIO_ACMAX()
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
						buttonName = "AC_MAX"						
					})

					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.1
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.2
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = AC
				function Test:ButtonPress_RADIO_AC()
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
						buttonName = "AC"						
					})

					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.2
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.3
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = RECIRCULATE
				function Test:ButtonPress_RADIO_RECIRCULATE()
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
						buttonName = "RECIRCULATE"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.3
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.4
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = FAN_UP
				function Test:ButtonPress_RADIO_FANUP()
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
						buttonName = "FAN_UP"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.4
			
		-----------------------------------------------------------------------------------------		

			--Begin Test case CommonRequestCheck.1.1.5
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = FAN_DOWN
				function Test:ButtonPress_RADIO_FANDOWN()
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
						buttonName = "FAN_DOWN"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.5
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.6
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = TEMP_UP
				function Test:ButtonPress_RADIO_TEMPUP()
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
						buttonName = "TEMP_UP"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.6
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.7
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = TEMP_DOWN
				function Test:ButtonPress_RADIO_TEMPDOWN()
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
						buttonName = "TEMP_DOWN"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.7
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.8
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = DEFROST_MAX
				function Test:ButtonPress_RADIO_DEFROSTMAX()
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
						buttonName = "DEFROST_MAX"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.8
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.9
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = DEFROST
				function Test:ButtonPress_RADIO_DEFROST()
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
						buttonName = "DEFROST"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.9
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.10
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = DEFROST_REAR
				function Test:ButtonPress_RADIO_DEFROSTREAR()
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
						buttonName = "DEFROST_REAR"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.10
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.11
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = UPPER_VENT
				function Test:ButtonPress_RADIO_UPPERVENT()
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
						buttonName = "UPPER_VENT"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.11
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.12
			--Description: application sends ButtonPress with ModuleType = RADIO, buttonName = LOWER_VENT
				function Test:ButtonPress_RADIO_LOWERVENT()
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
						buttonName = "LOWER_VENT"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
				end
			--End Test case CommonRequestCheck.1.1.12
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.1.1.13
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO, ButtonName = DEFROST_REAR
				function Test:ButtonPress_FrontRADIO_DEFROSTREAR()
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
						buttonName = "DEFROST_REAR"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)
								
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
					
				end
			--End Test case CommonRequestCheck.1.1.13
			
		-----------------------------------------------------------------------------------------
		
	--End Test case CommonRequestCheck.1.1	
	
	
--=================================================END TEST CASES 1==========================================================--	







--=================================================BEGIN TEST CASES 2==========================================================--
	--Begin Test suit CommonRequestCheck.2 for Req.#2

	--Description: 2. In case application registered with REMOTE_CONTROL AppHMIType sends ButtonPress RPC with <radio-related-buttons> and CLIMATE moduleType 
							--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle. 

	--Begin Test case CommonRequestCheck.2.1
	--Description: 	RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle. 

		--Requirement/Diagrams id in jira: 
				--REVSDL-1800

		--Verification criteria: 
				--In case application registered with REMOTE_CONTROL AppHMIType sends ButtonPress RPC with <radio-related-buttons> and CLIMATE moduleType

		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.2.1.1
			--Description: application sends ButtonPress with ModuleType = CLIMATE, buttonName = VOLUME_UP
				function Test:ButtonPress_CLIMATE_SHORT()
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
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
					
				end
			--End Test case CommonRequestCheck.2.1.1
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.2
			--Description: application sends ButtonPress with ModuleType = CLIMATE, buttonName = VOLUME_DOWN
				function Test:ButtonPress_CLIMATE_VOLUMEDOWN()
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
						buttonName = "VOLUME_DOWN"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
					
				end
			--End Test case CommonRequestCheck.2.1.2
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.3
			--Description: application sends ButtonPress with ModuleType = CLIMATE, buttonName = EJECT
				function Test:ButtonPress_CLIMATE_EJECT()
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
						buttonName = "EJECT"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
					
				end
			--End Test case CommonRequestCheck.2.1.3
			
		-----------------------------------------------------------------------------------------		
		
			--Begin Test case CommonRequestCheck.2.1.4
			--Description: application sends ButtonPress with ModuleType = CLIMATE, buttonName = SOURCE
				function Test:ButtonPress_CLIMATE_SOURCE()
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
						buttonName = "SOURCE"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
					
				end
			--End Test case CommonRequestCheck.2.1.4
			
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.5
			--Description: application sends ButtonPress with ModuleType = CLIMATE, buttonName = SHUFFLE
				function Test:ButtonPress_CLIMATE_SHUFFLE()
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
						buttonName = "SHUFFLE"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
					
				end
			--End Test case CommonRequestCheck.2.1.5
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.6
			--Description: application sends ButtonPress with ModuleType = CLIMATE, buttonName = REPEAT
				function Test:ButtonPress_CLIMATE_REPEAT()
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
						buttonName = "REPEAT"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
					
				end
			--End Test case CommonRequestCheck.2.1.6
			
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.2.1.7
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE, ButtonName=VOLUME_UP
				function Test:ButtonPress_LeftCLIMATE_VOLUMEUP()
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
						buttonName = "VOLUME_UP"						
					})
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("Buttons.ButtonPress")
					:Times(0)					
					
					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
					
				end
			--End Test case CommonRequestCheck.2.1.7
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.1	
	
	
--=================================================END TEST CASES 2==========================================================--	






--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: 3. In case application registered with REMOTE_CONTROL AppHMIType sends SetInteriorVehicleData RPC with "climateControlData" and RADIO moduleType 
							-- RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.

	--Begin Test case CommonRequestCheck.3.1
	--Description: 	RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1800

		--Verification criteria: 
				--In case application registered with REMOTE_CONTROL AppHMIType sends SetInteriorVehicleData RPC with "climateControlData" and RADIO moduleType 

		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.3.1.1
			--Description: application sends SetInteriorVehicleData as Driver and ModuleType = RADIO
				function Test:SetInterior_RADIO_WrongControlData()
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
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Times(0)

					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })

				end
			--End Test case CommonRequestCheck.3.1.1
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.3.1.2
			--Description: application sends SetInteriorVehicleData as Front Passenger and ModuleType = RADIO
				function Test:SetInterior_RADIO_FrontClimateControlData()
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
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Times(0)

					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })					

				end
			--End Test case CommonRequestCheck.3.1.2
		
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.1	
	
	
--=================================================END TEST CASES 3==========================================================--






--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for Req.#4

	--Description: 4. In case application registered with REMOTE_CONTROL AppHMIType sends SetInteriorVehicleData RPC with "radioControlData" and CLIMATE moduleType 
							-- RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.

	--Begin Test case CommonRequestCheck.4.1
	--Description: 	RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.

		--Requirement/Diagrams id in jira: 
				--REVSDL-1800

		--Verification criteria: 
				--In case application registered with REMOTE_CONTROL AppHMIType sends SetInteriorVehicleData RPC with "radioControlData" and CLIMATE moduleType 

		-----------------------------------------------------------------------------------------
				
			--Begin Test case CommonRequestCheck.4.1.1
			--Description: application sends SetInteriorVehicleData as Driver and ModuleType = CLIMATE (auto allow case)
				function Test:SetInterior_CLIMATE_RadioControlData()
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
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Times(0)

					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
					
				end
			--End Test case CommonRequestCheck.4.1.1
		
		-----------------------------------------------------------------------------------------
		
			--Begin Test case CommonRequestCheck.4.1.2
			--Description: application sends SetInteriorVehicleData as Driver and ModuleType = CLIMATE (for Driver allow case)
				function Test:SetInterior_CLIMATE_LeftRadioControlData()
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
					
					--hmi side: not transferring this RPC to the vehicle.
					EXPECT_HMICALL("RC.SetInteriorVehicleData")
					:Times(0)

					--RSDL must respond with "resultCode: INVALID_DATA, success: false" to this mobile app, not transferring this RPC to the vehicle.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
					
				end
			--End Test case CommonRequestCheck.4.1.2
		
		-----------------------------------------------------------------------------------------		
		
	--End Test case CommonRequestCheck.4.1	
	
	
--=================================================END TEST CASES 4==========================================================--




		
return Test