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

--List of resultscode
local RESULTS_CODE = {"SUCCESS", "WARNINGS", "RESUME_FAILED", "WRONG_LANGUAGE"}

--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice
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

---------------------------------------------------------------------------------------------
----------------------------------------END COMMON FUNCTIONS---------------------------------
---------------------------------------------------------------------------------------------






--======================================REVSDL-966=========================================--
---------------------------------------------------------------------------------------------
-----------REVSDL-966: "Allow", "Ask Driver" or "Disallow" permissions - depending-----------
------------------on zone value in RPC and this zone permissions in Policies-----------------
---------------------------------------------------------------------------------------------
--=========================================================================================--

---------------------NOTE: THIS SCRIPT ONLY TEST FOR PASSENGER'S DEVICE----------------------

--=================================================BEGIN TEST CASES 1==========================================================--
	--Begin Test suit CommonRequestCheck.1 for Req.#1

	--Description: 1. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "auto_allow" sub-section of <interiorZone> section - RSDL must send this RPC with these <params> to the vehicle (HMI).


	--Begin Test case CommonRequestCheck.1.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1219

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "auto_allow" sub-section of <interiorZone> section - RSDL must send this RPC with these <params> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.1.1.1
			--Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonPressMode = LONG
				function Test:ButtonPress_AutoAllowDriverRADIO_ButtonPressMode_LONG()
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
				function Test:ButtonPress_AutoAllowDriverRADIO_ButtonPressMode_SHORT()
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
				function Test:ButtonPress_AutoAllowDriverRADIO_ButtonName_VOLUME_UP()
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
				function Test:ButtonPress_AutoAllowDriverRADIO_ButtonName_VOLUME_DOWN()
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
				function Test:ButtonPress_AutoAllowDriverRADIO_ButtonName_EJECT()
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
				function Test:ButtonPress_AutoAllowDriverRADIO_ButtonName_SOURCE()
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
				function Test:ButtonPress_AutoAllowDriverRADIO_ButtonName_SHUFFLE()
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
				function Test:ButtonPress_AutoAllowDriverRADIO_ButtonName_REPEAT()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonPressMode_LONG()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonPressMode_SHORT()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_AC_MAX()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_AC()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_RECIRCULATE()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_FAN_UP()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_FAN_DOWN()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_TEMP_UP()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_TEMP_DOWN()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_DEFROST_MAX()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_DEFROST()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_DEFROST_REAR()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_UPPER_VENT()
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
				function Test:ButtonPress_AutoAllowDriverCLIMATE_ButtonName_LOWER_VENT()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonPressMode_LONG()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonPressMode_SHORT()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_AC_MAX()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_AC()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_RECIRCULATE()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_FAN_UP()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_FAN_DOWN()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_TEMP_UP()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_TEMP_DOWN()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_DEFROST_MAX()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_DEFROST()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_DEFROST_REAR()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_UPPER_VENT()
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
				function Test:ButtonPress_AutoAllowFrontCLIMATE_ButtonName_LOWER_VENT()
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
				--REVSDL-966
				--TC: REVSDL-1219

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
				--REVSDL-966
				--TC: REVSDL-1219

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

	--Description: 2. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
						--and driver's permission has not yet been obtained for this app&<interiorZone>&<moduleType>
						--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).


	--Begin Test case CommonRequestCheck.2.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1380

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_DriverAllowFrontRADIO()
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
				end
			--End Test case CommonRequestCheck.2.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.1.2
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE()
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
			--End Test case CommonRequestCheck.2.1.2

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.1


	--Begin Test case CommonRequestCheck.2.2 (Stop SDL before running this test suite)
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1380

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO()
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
			--End Test case CommonRequestCheck.2.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO()
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
			--End Test case CommonRequestCheck.2.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.2.3
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE()
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
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.2.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.2


	--Begin Test case CommonRequestCheck.2.3 (Stop SDL before running this test suite)
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1380

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO()
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
			--End Test case CommonRequestCheck.2.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.2
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO()
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
			--End Test case CommonRequestCheck.2.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.2.3.3
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.2.3.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.3

--=================================================END TEST CASES 2==========================================================--



--=================================================BEGIN TEST CASES 3==========================================================--
	--Begin Test suit CommonRequestCheck.3 for Req.#3

	--Description: 1. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI). and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).


	--Begin Test case CommonRequestCheck.3.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1382

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_DriverAllowFrontRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
				end
			--End Test case CommonRequestCheck.3.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.1.2
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
			--End Test case CommonRequestCheck.3.1.2

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.1


	--Begin Test case CommonRequestCheck.3.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1382

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

			--Begin Test case CommonRequestCheck.3.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.2.3
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.2.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.2


	--Begin Test case CommonRequestCheck.3.3
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1382

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
			--End Test case CommonRequestCheck.3.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.3.2
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
			--End Test case CommonRequestCheck.3.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.3.3.3
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_DriverAllowLeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.3.3.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.3.3

--=================================================END TEST CASES 3==========================================================--




--=================================================BEGIN TEST CASES 4==========================================================--
	--Begin Test suit CommonRequestCheck.4 for Req.#4

	--Description: 4. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
						--and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent
						--and RSDL has processed this (app's initial) RPC
						--RSDL must further process RPCs with the same <interiorZone> for the same <moduleType> controlling from the same application without new permission request.


	--Begin Test case CommonRequestCheck.4.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1383

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the first time
				function Test:ButtonPress_DriverAllowFrontRADIO_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
				end
			--End Test case CommonRequestCheck.4.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.2
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the second time
				function Test:ButtonPress_DriverAllowFrontRADIO_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI doesn't appear
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
					:Times(0)


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
			--End Test case CommonRequestCheck.4.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.3
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the third time (different buttonPressMode, buttonName)
				function Test:ButtonPress_DriverAllowFrontRADIO_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						buttonName = "REPEAT"
					})

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI doesn't appear
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
					:Times(0)


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
										buttonName = "REPEAT"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)


					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.4
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the second time
				function Test:GetInterior_DriverAllowFrontRADIO_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.5
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the third time
				function Test:GetInterior_DriverAllowFrontRADIO_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.6
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the second time
				function Test:SetInterior_DriverAllowFrontRADIO_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.7
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the third time
				function Test:SetInterior_DriverAllowFrontRADIO_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								frequencyInteger = 95,
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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
											frequencyInteger = 95,
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.7

		-----------------------------------------------------------------------------------------



			--Begin Test case CommonRequestCheck.4.1.8
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the first time
				function Test:ButtonPress_DriverAllowLeftCLIMATE_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
			--End Test case CommonRequestCheck.4.1.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.9
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time
				function Test:ButtonPress_DriverAllowLeftCLIMATE_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.10
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time
				function Test:ButtonPress_DriverAllowLeftCLIMATE_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						buttonName = "DEFROST_MAX"
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										buttonName = "DEFROST_MAX"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.11
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time
				function Test:GetInterior_DriverAllowLeftCLIMATE_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.12
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time
				function Test:GetInterior_DriverAllowLeftCLIMATE_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.13
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time
				function Test:SetInterior_DriverAllowLeftCLIMATE_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.1.14
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time
				function Test:SetInterior_DriverAllowLeftCLIMATE_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								fanSpeed = 49,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										fanSpeed = 49,
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.1.14

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.4.1



	--Begin Test case CommonRequestCheck.4.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1383

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the first time
				function Test:GetInterior_DriverAllowFrontRADIO_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
			--End Test case CommonRequestCheck.4.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.2
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the second time
				function Test:GetInterior_DriverAllowFrontRADIO_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.3
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the third time
				function Test:GetInterior_DriverAllowFrontRADIO_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.4
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the second time
				function Test:ButtonPress_DriverAllowFrontRADIO_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI doesn't appear
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
					:Times(0)


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
			--End Test case CommonRequestCheck.4.2.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.5
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the third time (different buttonPressMode, buttonName)
				function Test:ButtonPress_DriverAllowFrontRADIO_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						buttonName = "REPEAT"
					})

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI doesn't appear
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
					:Times(0)


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
										buttonName = "REPEAT"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)


					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.6
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the second time
				function Test:SetInterior_DriverAllowFrontRADIO_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.7
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the third time
				function Test:SetInterior_DriverAllowFrontRADIO_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								frequencyInteger = 95,
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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
											frequencyInteger = 95,
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.7

		-----------------------------------------------------------------------------------------


			--Begin Test case CommonRequestCheck.4.2.8
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the first time
				function Test:GetInterior_DriverAllowLeftRADIO_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.9
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time
				function Test:GetInterior_DriverAllowLeftRADIO_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.10
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time
				function Test:GetInterior_DriverAllowLeftRADIO_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.11
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time
				function Test:SetInterior_DriverAllowLeftRADIO_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time
				function Test:SetInterior_DriverAllowLeftRADIO_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								frequencyInteger = 95,
								frequencyFraction = 3,
								band = "AM"
							}
						}
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
											frequencyInteger = 95,
											frequencyFraction = 3,
											band = "AM"
										}
									}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.12

		-----------------------------------------------------------------------------------------


			--Begin Test case CommonRequestCheck.4.2.13
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the first time
				function Test:GetInterior_DriverAllowLeftCLIMATE_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.14
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time
				function Test:GetInterior_DriverAllowLeftCLIMATE_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.14

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.15
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time
				function Test:GetInterior_DriverAllowLeftCLIMATE_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.15

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.16
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time
				function Test:ButtonPress_DriverAllowLeftCLIMATE_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.16

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.17
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time
				function Test:ButtonPress_DriverAllowLeftCLIMATE_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						buttonName = "DEFROST_MAX"
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										buttonName = "DEFROST_MAX"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.17

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.18
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time
				function Test:SetInterior_DriverAllowLeftCLIMATE_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.18

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.2.19
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time
				function Test:SetInterior_DriverAllowLeftCLIMATE_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								fanSpeed = 49,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										fanSpeed = 49,
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.2.19

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.4.2




	--Begin Test case CommonRequestCheck.4.3
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1383

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the first time
				function Test:SetInterior_DriverAllowFrontRADIO_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
			--End Test case CommonRequestCheck.4.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.2
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the second time
				function Test:SetInterior_DriverAllowFrontRADIO_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.3
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the third time
				function Test:SetInterior_DriverAllowFrontRADIO_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								frequencyInteger = 95,
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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
											frequencyInteger = 95,
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.4
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the second time
				function Test:ButtonPress_DriverAllowFrontRADIO_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI doesn't appear
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
					:Times(0)


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
			--End Test case CommonRequestCheck.4.3.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.5
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the third time (different buttonPressMode, buttonName)
				function Test:ButtonPress_DriverAllowFrontRADIO_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						buttonName = "REPEAT"
					})

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI doesn't appear
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
					:Times(0)


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
										buttonName = "REPEAT"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)


					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.6
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the second time
				function Test:GetInterior_DriverAllowFrontRADIO_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.7
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO in the third time
				function Test:GetInterior_DriverAllowFrontRADIO_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.8
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the fist time
				function Test:SetInterior_DriverAllowLeftRADIO_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
			--End Test case CommonRequestCheck.4.3.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.9
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time
				function Test:SetInterior_DriverAllowLeftRADIO_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.10
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time
				function Test:SetInterior_DriverAllowLeftRADIO_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								frequencyInteger = 95,
								frequencyFraction = 3,
								band = "AM"
							}
						}
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
											frequencyInteger = 95,
											frequencyFraction = 3,
											band = "AM"
										}
									}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.11
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time
				function Test:GetInterior_DriverAllowLeftRADIO_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.12
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time
				function Test:GetInterior_DriverAllowLeftRADIO_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.13
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the first time
				function Test:SetInterior_DriverAllowLeftCLIMATE_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.14
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time
				function Test:SetInterior_DriverAllowLeftCLIMATE_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.14

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.15
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time
				function Test:SetInterior_DriverAllowLeftCLIMATE_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								fanSpeed = 49,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										fanSpeed = 49,
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.15

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.16
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time
				function Test:ButtonPress_DriverAllowLeftCLIMATE_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.16

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.17
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time
				function Test:ButtonPress_DriverAllowLeftCLIMATE_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						buttonName = "DEFROST_MAX"
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										buttonName = "DEFROST_MAX"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.17

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.18
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time
				function Test:GetInterior_DriverAllowLeftCLIMATE_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.18

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.4.3.19
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time
				function Test:GetInterior_DriverAllowLeftCLIMATE_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.4.3.19

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.4.3

--=================================================END TEST CASES 4==========================================================--





--=================================================BEGIN TEST CASES 5==========================================================--
	--Begin Test suit CommonRequestCheck.5 for Req.#5

	--Description: 5. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
						--and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent
						--and RSDL has processed this (app's initial) RPC
						--and the same or another application sends a valid RPC with the same <interiorZone> and different <moduleType> and params that exist in "driver_allow" sub-section
						--RSDL must send a new RC.GetInteriorVehicleDataConsent for this different <moduleType> to the vehicle (HMI)


	--Begin Test case CommonRequestCheck.5.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1385, REVSDL-1386

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.1
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the first time (asking driver's permission)
				function Test:ButtonPress_SameAppLeftCLIMATE_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

			--Begin Test case CommonRequestCheck.5.1.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the frist time (asking driver's permission)
				function Test:GetInterior_SameAppLeftRADIO_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.3
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:ButtonPress_SameAppLeftCLIMATE_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.4
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time doesn't ask driver's permission)
				function Test:ButtonPress_SameAppLeftCLIMATE_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						buttonName = "DEFROST_MAX"
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										buttonName = "DEFROST_MAX"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.5
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time(doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftCLIMATE_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.6
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftCLIMATE_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.7
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftCLIMATE_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.8
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftCLIMATE_8()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								fanSpeed = 49,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										fanSpeed = 49,
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.9
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftRADIO_9()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.10
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftRADIO_10()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.11
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftRADIO_11()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.1.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftRADIO_12()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								frequencyInteger = 95,
								frequencyFraction = 3,
								band = "AM"
							}
						}
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
											frequencyInteger = 95,
											frequencyFraction = 3,
											band = "AM"
										}
									}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.1.12

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.1


	--Begin Test case CommonRequestCheck.5.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1385, REVSDL-1386

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.1
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (first time, asking driver's permission)
				function Test:GetInterior_SameAppLeftRADIO_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (first asking driver's permission)
				function Test:GetInterior_SameAppLeftCLIMATE_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.3
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:ButtonPress_SameAppLeftCLIMATE_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.4
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time doesn't ask driver's permission)
				function Test:ButtonPress_SameAppLeftCLIMATE_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						buttonName = "DEFROST_MAX"
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										buttonName = "DEFROST_MAX"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.5
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time(doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftCLIMATE_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.6
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftCLIMATE_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.7
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftCLIMATE_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.8
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftCLIMATE_8()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								fanSpeed = 49,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										fanSpeed = 49,
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.9
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftRADIO_9()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.10
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftRADIO_10()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.11
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftRADIO_11()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.2.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftRADIO_12()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								frequencyInteger = 95,
								frequencyFraction = 3,
								band = "AM"
							}
						}
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
											frequencyInteger = 95,
											frequencyFraction = 3,
											band = "AM"
										}
									}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.2.12

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.2


	--Begin Test case CommonRequestCheck.5.3
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1385, REVSDL-1386

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.1
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (first time, asking driver's permission)
				function Test:SetInterior_SameAppLeftRADIO_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
			--End Test case CommonRequestCheck.5.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.2
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (first time, asking driver's permission)
				function Test:SetInterior_SameAppLeftCLIMATE_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.3
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:ButtonPress_SameAppLeftCLIMATE_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.4
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time doesn't ask driver's permission)
				function Test:ButtonPress_SameAppLeftCLIMATE_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						buttonName = "DEFROST_MAX"
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										buttonName = "DEFROST_MAX"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.5
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time(doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftCLIMATE_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.6
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftCLIMATE_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.7
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftCLIMATE_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.8
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftCLIMATE_8()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								fanSpeed = 49,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
										fanSpeed = 49,
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.9
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftRADIO_9()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.10
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:GetInterior_SameAppLeftRADIO_10()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.11
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftRADIO_11()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.3.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:SetInterior_SameAppLeftRADIO_12()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								frequencyInteger = 95,
								frequencyFraction = 3,
								band = "AM"
							}
						}
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
											frequencyInteger = 95,
											frequencyFraction = 3,
											band = "AM"
										}
									}
							})

					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.3.12

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.3


	--Begin Test case CommonRequestCheck.5.4
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1385, REVSDL-1386

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.5.
			--Description: Register new session
				function Test:PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self,
						self.mobileConnection)
				end
			--End Test case Precondition.5.

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.5.
			--Description: Register App1 for precondition
					function Test:TC5_PassengerDevice_App1()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.5.

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.1
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the first time (asking driver's permission)
				function Test:ButtonPress_App1AppLeftCLIMATE_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.4.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the frist time (asking driver's permission)
				function Test:GetInterior_App2LeftRADIO_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
					end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.4.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.3
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (asking driver's permission)
				function Test:ButtonPress_App2LeftCLIMATE_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("ButtonPress",
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.4.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.4
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time doesn't ask driver's permission)
				function Test:ButtonPress_App2LeftCLIMATE_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("ButtonPress",
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
						buttonName = "DEFROST_MAX"
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.4.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.5
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time(doesn't ask driver's permission)
				function Test:GetInterior_App2LeftCLIMATE_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.4.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.6
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:GetInterior_App2LeftCLIMATE_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.4.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.7
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:SetInterior_App2LeftCLIMATE_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.4.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.8
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:SetInterior_App2LeftCLIMATE_8()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 49,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.4.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.9
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:GetInterior_App2LeftRADIO_9()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.4.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.10
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:GetInterior_App2LeftRADIO_10()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.4.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.11
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:SetInterior_App2LeftRADIO_11()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("SetInteriorVehicleData",
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.4.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.4.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:SetInterior_App2LeftRADIO_12()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("SetInteriorVehicleData",
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
								frequencyInteger = 95,
								frequencyFraction = 3,
								band = "AM"
							}
						}
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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
											frequencyInteger = 95,
											frequencyFraction = 3,
											band = "AM"
										}
									}
							})

					end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.4.12

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.4


	--Begin Test case CommonRequestCheck.5.5
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1385, REVSDL-1386

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.5.
			--Description: Register new session
				function Test:PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self,
						self.mobileConnection)
				end
			--End Test case Precondition.5.

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.5.
			--Description: Register App1 for precondition
					function Test:TC1_PassengerDevice_App1()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.5.
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.1
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (first time, asking driver's permission)
				function Test:GetInterior_DifferentAppLeftRADIO_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.5.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (first asking driver's permission)
				function Test:GetInterior_DifferentAppLeftCLIMATE_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
					end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.5.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.3
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:ButtonPress_DifferentAppLeftCLIMATE_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("ButtonPress",
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.5.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.4
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time doesn't ask driver's permission)
				function Test:ButtonPress_DifferentAppLeftCLIMATE_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("ButtonPress",
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
						buttonName = "DEFROST_MAX"
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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
										buttonName = "DEFROST_MAX"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.5.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.5
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time(doesn't ask driver's permission)
				function Test:GetInterior_DifferentAppLeftCLIMATE_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.5.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.6
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:GetInterior_DifferentAppLeftCLIMATE_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.5.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.7
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:SetInterior_DifferentAppLeftCLIMATE_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.5.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.8
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:SetInterior_DifferentAppLeftCLIMATE_8()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 49,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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
										fanSpeed = 49,
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.5.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.9
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(asking driver's permission)
				function Test:GetInterior_DifferentAppLeftRADIO_9()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
									appID = self.applications["Test Application4"],
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.5.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.10
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:GetInterior_DifferentAppLeftRADIO_10()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.5.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.11
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:SetInterior_DifferentAppLeftRADIO_11()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("SetInteriorVehicleData",
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.5.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.5.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:SetInterior_DifferentAppLeftRADIO_12()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("SetInteriorVehicleData",
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
								frequencyInteger = 95,
								frequencyFraction = 3,
								band = "AM"
							}
						}
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.5.12

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.5


	--Begin Test case CommonRequestCheck.5.6
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1385, REVSDL-1386

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.5.
			--Description: Register new session
				function Test:PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self,
						self.mobileConnection)
				end
			--End Test case Precondition.5.

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.5.
			--Description: Register App1 for precondition
					function Test:TC1_PassengerDevice_App1()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.5.
		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.1
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (first time, asking driver's permission)
				function Test:SetInterior_App1LeftRADIO_1()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.6.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.2
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (first time, asking driver's permission)
				function Test:SetInterior_App2LeftCLIMATE_2()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.6.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.3
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:ButtonPress_App2LeftCLIMATE_3()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("ButtonPress",
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.6.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.4
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time doesn't ask driver's permission)
				function Test:ButtonPress_DifferentAppLeftCLIMATE_4()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("ButtonPress",
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
						buttonName = "DEFROST_MAX"
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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
										buttonName = "DEFROST_MAX"
									})
						:Do(function(_,data)
							--hmi side: sending Buttons.ButtonPress response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.6.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.5
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time(doesn't ask driver's permission)
				function Test:GetInterior_DifferentAppLeftCLIMATE_5()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.6.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.6
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:GetInterior_DifferentAppLeftCLIMATE_6()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.6.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.7
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the second time (doesn't ask driver's permission)
				function Test:SetInterior_DifferentAppLeftCLIMATE_7()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.6.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.8
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE in the third time (doesn't ask driver's permission)
				function Test:SetInterior_DifferentAppLeftCLIMATE_8()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
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
								col = 0,
								levelspan = 1,
								level = 0
							},
							climateControlData =
							{
								fanSpeed = 49,
								desiredTemp = 24,
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
					:Times(0)


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
										fanSpeed = 49,
										desiredTemp = 24,
										temperatureUnit = "CELSIUS"
									}
								}
							})

					end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.5.6.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.9
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:GetInterior_DifferentAppLeftRADIO_9()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.6.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.10
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:GetInterior_DifferentAppLeftRADIO_10()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
						subscribe = false
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.6.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.11
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the second time(doesn't ask driver's permission)
				function Test:SetInterior_DifferentAppLeftRADIO_11()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("SetInteriorVehicleData",
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

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.6.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.5.6.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO in the third time(doesn't ask driver's permission)
				function Test:SetInterior_DifferentAppLeftRADIO_12()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession1:SendRPC("SetInteriorVehicleData",
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
								frequencyInteger = 95,
								frequencyFraction = 3,
								band = "AM"
							}
						}
					})

					--hmi side: expect RSDL doesn't send RC.GetInteriorVehicleDataConsent request to HMI
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.5.6.12
		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.5.6


--=================================================END TEST CASES 5==========================================================--





--=================================================BEGIN TEST CASES 6==========================================================--
	--Begin Test suit CommonRequestCheck.6 for Req.#6

	--Description: 1. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
						--and the vehicle (HMI) responds with "disallow" for RC.GetInteriorVehicleDataConsent
						--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.


	--Begin Test case CommonRequestCheck.6.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1389

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_DriverAllowFrontRADIO()
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

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
							:Times(0)
							:Do(function(_,data)
								--hmi side: sending Buttons.ButtonPress response
								self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
							end)

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.6.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.1.2
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE()
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

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
							:Times(0)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.6.1.2

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.6.1


	--Begin Test case CommonRequestCheck.6.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1389

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO()
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
			--End Test case CommonRequestCheck.6.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO()
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
			--End Test case CommonRequestCheck.6.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.2.3
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE()
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
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.6.2.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.6.2


	--Begin Test case CommonRequestCheck.6.3
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1389

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO()
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
			--End Test case CommonRequestCheck.6.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.3.2
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO()
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
			--End Test case CommonRequestCheck.6.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.6.3.3
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
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
												temperatureUnit = "CELSIUS"
											}
										}
									})

								end)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.6.3.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.6.3

--=================================================END TEST CASES 6==========================================================--






--=================================================BEGIN TEST CASES 7==========================================================--
	--Begin Test suit CommonRequestCheck.7 for Req.#7

	--Description: 7. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
						--and the vehicle (HMI) responds with "disallow" for RC.GetInteriorVehicleDataConsent
						--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.


	--Begin Test case CommonRequestCheck.7.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1390

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_DriverAllowFrontRADIO()
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
			--End Test case CommonRequestCheck.7.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.1.2
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE()
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
															col = 0,
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
			--End Test case CommonRequestCheck.7.1.2

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.7.1


	--Begin Test case CommonRequestCheck.7.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1390

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO()
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
							end

							RUN_AFTER(HMIResponse, 10000)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.7.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO()
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
			--End Test case CommonRequestCheck.7.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.2.3
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE()
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
							end

							RUN_AFTER(HMIResponse, 10000)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.7.2.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.7.2


	--Begin Test case CommonRequestCheck.7.3
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1390

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO()
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
							end

							RUN_AFTER(HMIResponse, 10000)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.7.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.3.2
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO()
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
			--End Test case CommonRequestCheck.7.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.7.3.3
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
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
							end

							RUN_AFTER(HMIResponse, 10000)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.7.3.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.7.3

--=================================================END TEST CASES 7==========================================================--







--=================================================BEGIN TEST CASES 8==========================================================--
	--Begin Test suit CommonRequestCheck.8 for Req.#8

	--Description: 8. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
						--and the vehicle (HMI) responds with any erroneous resultCode for RC.GetInteriorVehicleDataConsent
						--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.


	--Begin Test case CommonRequestCheck.8.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1391

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.8.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_DriverAllowFrontRADIO()
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

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.8.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.8.1.2
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE()
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
													col = 0,
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
			--End Test case CommonRequestCheck.8.1.2

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.8.1


	--Begin Test case CommonRequestCheck.8.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1391

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.8.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO()
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
			--End Test case CommonRequestCheck.8.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.8.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO()
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
			--End Test case CommonRequestCheck.8.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.8.2.3
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE()
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
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.8.2.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.8.2


	--Begin Test case CommonRequestCheck.8.3
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1391

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.8.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO()
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
			--End Test case CommonRequestCheck.8.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.8.3.2
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO()
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

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.8.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.8.3.3
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
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
												temperatureUnit = "CELSIUS"
											}
										}
									})

								end)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.8.3.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.8.3

--=================================================END TEST CASES 8==========================================================--






--=================================================BEGIN TEST CASES 9==========================================================--
	--Begin Test suit CommonRequestCheck.9 for Req.#9

	--Description: 9. In case:
						--the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
						--and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent
						--and RSDL has processed this (app's initial) RPC
						--and another application sends a valid RPC with the same or different <interiorZone> and same <moduleType> and params that exist in "driver_allow" sub-section
						--==> RSDL must send a new RC.GetInteriorVehicleDataConsent for such application to the vehicle (HMI)
						--Source: MOM, p.9


	--Begin Test case CommonRequestCheck.9.1
	--Description: 	For ButtonPress (RADIO)

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1392

		--Verification criteria:
				--In case: the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.1.1
			--Description: Register new session for check OnHMIStatus with deviceRank = "PASSENGER"
				function Test:PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session2
					self.mobileSession2 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session3
					self.mobileSession3 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session1
					self.mobileSession4 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session2
					self.mobileSession5 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session3
					self.mobileSession6 = mobile_session.MobileSession(
						self,
						self.mobileConnection)
				end
			--End Test case Precondition.9.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.1.2
			--Description: Register App1 for precondition
					function Test:TC1_PassengerDevice_App1()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.1.3
			--Description: Register App2 for precondition
					function Test:TC1_PassengerDevice_App2()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.1.4
			--Description: Register App3 for precondition
					function Test:TC1_PassengerDevice_App3()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.1.5
			--Description: Register App4 for precondition
					function Test:TC1_PassengerDevice_App4()
						self.mobileSession4:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession4:SendRPC("RegisterAppInterface",
								{
								  syncMsgVersion =
								  {
									majorVersion = 3,
									minorVersion = 0
								  },
								  appName = "Test Application4",
								  isMediaApplication = true,
								  languageDesired = 'EN-US',
								  hmiDisplayLanguageDesired = 'EN-US',
								  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
								  appID = "4"
								})

								EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
								{
								  application =
								  {
									appName = "Test Application4"
								  }
								})
								:Do(function(_,data)
									self.applications["Test Application4"] = data.params.application.appID
								end)

								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession4:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession4:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession4:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.1.6
			--Description: Register App5 for precondition
					function Test:TC1_PassengerDevice_App5()
						self.mobileSession5:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession5:SendRPC("RegisterAppInterface",
								{
								  syncMsgVersion =
								  {
									majorVersion = 3,
									minorVersion = 0
								  },
								  appName = "Test Application5",
								  isMediaApplication = true,
								  languageDesired = 'EN-US',
								  hmiDisplayLanguageDesired = 'EN-US',
								  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
								  appID = "5"
								})

								EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
								{
								  application =
								  {
									appName = "Test Application5"
								  }
								})
								:Do(function(_,data)
									self.applications["Test Application5"] = data.params.application.appID
								end)

								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession5:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession5:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession5:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.1.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.1.7
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_App1FrontRADIO()
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

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.9.1.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.1.8
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (same zone and same moduleType)
				function Test:ButtonPress_App2FrontRADIO_SameZone()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession1:SendRPC("ButtonPress",
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

					--hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.9.1.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.1.9
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (same zone and same moduleType)
				function Test:GetInterior_App3FrontRADIO_SameZone()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession2:SendRPC("GetInteriorVehicleData",
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession2:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.9.1.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.1.10
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (same zone and same moduleType)
				function Test:SetInterior_App4FrontRADIO_SameZone()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
					local cid = self.mobileSession3:SendRPC("SetInteriorVehicleData",
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

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
								{
									appID = self.applications["Test Application3"],
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession3:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.9.1.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.1.11
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (Different zone and same moduleType)
				function Test:GetInterior_App5LeftRADIO_DifferentZone()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession4:SendRPC("GetInteriorVehicleData",
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
									appID = self.applications["Test Application4"],
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
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession4:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.9.1.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.1.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (Different zone and same moduleType)
				function Test:SetInterior_App6LeftRADIO_DifferentZone()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession5:SendRPC("SetInteriorVehicleData",
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
									appID = self.applications["Test Application5"],
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession5:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.9.1.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.1.13
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (first time, asking permission)
				function Test:ButtonPress_App1LeftCLIMATE()
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
			--End Test case CommonRequestCheck.9.1.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.1.14
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (same zone and same moduleType)
				function Test:GetInterior_App2LeftCLIMATE_SameZone()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.9.1.14

		-----------------------------------------------------------------------------------------


			--Begin Test case CommonRequestCheck.9.1.15
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (same zone and same moduleType)
				function Test:SetInterior_App3LeftCLIMATE_SameZone()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession2:SendRPC("SetInteriorVehicleData",
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
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
								{
									appID = self.applications["Test Application2"],
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
							--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
							self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					self.mobileSession2:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.9.1.15

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.9.1



	--Begin Test case CommonRequestCheck.9.2
	--Description: 	For GetInteriorVehicleData (RADIO and CLIMATE)

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1392

		--Verification criteria:
				--In case: the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.2.1
			--Description: Register new session for check OnHMIStatus with deviceRank = "PASSENGER"
				function Test:PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session2
					self.mobileSession2 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session3
					self.mobileSession3 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session1
					self.mobileSession4 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session2
					self.mobileSession5 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session3
					self.mobileSession6 = mobile_session.MobileSession(
						self,
						self.mobileConnection)
				end
			--End Test case Precondition.9.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.2.2
			--Description: Register App1 for precondition
					function Test:Pre_PassengerDevice_App1()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.2.3
			--Description: Register App2 for precondition
					function Test:Pre_PassengerDevice_App2()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.2.3

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.2.4
			--Description: Register App3 for precondition
					function Test:Pre_PassengerDevice_App3()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.2.4

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.2.5
			--Description: Register App4 for precondition
					function Test:Pre_PassengerDevice_App4()
						self.mobileSession4:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession4:SendRPC("RegisterAppInterface",
								{
								  syncMsgVersion =
								  {
									majorVersion = 3,
									minorVersion = 0
								  },
								  appName = "Test Application4",
								  isMediaApplication = true,
								  languageDesired = 'EN-US',
								  hmiDisplayLanguageDesired = 'EN-US',
								  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
								  appID = "4"
								})

								EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
								{
								  application =
								  {
									appName = "Test Application4"
								  }
								})
								:Do(function(_,data)
									self.applications["Test Application4"] = data.params.application.appID
								end)

								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession4:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession4:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession4:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.2.5

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.2.6
			--Description: Register App5 for precondition
					function Test:Pre_PassengerDevice_App5()
						self.mobileSession5:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession5:SendRPC("RegisterAppInterface",
								{
								  syncMsgVersion =
								  {
									majorVersion = 3,
									minorVersion = 0
								  },
								  appName = "Test Application5",
								  isMediaApplication = true,
								  languageDesired = 'EN-US',
								  hmiDisplayLanguageDesired = 'EN-US',
								  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
								  appID = "5"
								})

								EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
								{
								  application =
								  {
									appName = "Test Application5"
								  }
								})
								:Do(function(_,data)
									self.applications["Test Application5"] = data.params.application.appID
								end)

								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession5:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession5:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession5:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.2.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.2.7
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time, asking permission)
				function Test:GetInterior_App1FrontRADIO()
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
			--End Test case CommonRequestCheck.9.2.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.2.8
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_App2FrontRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.2.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.2.9
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_App3FrontRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
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

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
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

					self.mobileSession2:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.2.10
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_App4FrontRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession3:SendRPC("GetInteriorVehicleData",
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
									appID = self.applications["Test Application3"],
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

					self.mobileSession3:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.2.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.2.11
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_App5LeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession4:SendRPC("GetInteriorVehicleData",
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
									appID = self.applications["Test Application4"],
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

					self.mobileSession4:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.2.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.2.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_App6LeftRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession5:SendRPC("SetInteriorVehicleData",
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
									appID = self.applications["Test Application5"],
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

					self.mobileSession5:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.2.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.2.13
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_App1LeftCLIMATE()
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
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.2.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.2.14
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_App2LeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
					end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.2.14

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.2.15
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_App3LeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession2:SendRPC("ButtonPress",
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
									appID = self.applications["Test Application2"],
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

					self.mobileSession2:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.2.15

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.2.16
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_App4LeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession3:SendRPC("SetInteriorVehicleData",
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
								temperatureUnit = "CELSIUS"
							}
						}
					})

					--hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
					EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
								{
									appID = self.applications["Test Application3"],
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

					self.mobileSession3:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.2.16

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.9.2


	--Begin Test case CommonRequestCheck.9.3
	--Description: 	For SetInteriorVehicleData (RADIO and CLIMATE)

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1392

		--Verification criteria:
				--In case: the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.3.1
			--Description: Register new session for check OnHMIStatus with deviceRank = "PASSENGER"
				function Test:PreconditionNewSession()
					--New session1
					self.mobileSession1 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session2
					self.mobileSession2 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session3
					self.mobileSession3 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session1
					self.mobileSession4 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session2
					self.mobileSession5 = mobile_session.MobileSession(
						self,
						self.mobileConnection)

					--New session3
					self.mobileSession6 = mobile_session.MobileSession(
						self,
						self.mobileConnection)
				end
			--End Test case Precondition.9.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.3.2
			--Description: Register App1 for precondition
					function Test:Pre_PassengerDevice_App1()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.3.3
			--Description: Register App2 for precondition
					function Test:Pre_PassengerDevice_App2()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.3.3

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.3.4
			--Description: Register App3 for precondition
					function Test:Pre_PassengerDevice_App3()
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

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.3.4

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.3.5
			--Description: Register App4 for precondition
					function Test:Pre_PassengerDevice_App4()
						self.mobileSession4:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession4:SendRPC("RegisterAppInterface",
								{
								  syncMsgVersion =
								  {
									majorVersion = 3,
									minorVersion = 0
								  },
								  appName = "Test Application4",
								  isMediaApplication = true,
								  languageDesired = 'EN-US',
								  hmiDisplayLanguageDesired = 'EN-US',
								  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
								  appID = "4"
								})

								EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
								{
								  application =
								  {
									appName = "Test Application4"
								  }
								})
								:Do(function(_,data)
									self.applications["Test Application4"] = data.params.application.appID
								end)

								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession4:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession4:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession4:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.3.5

		-----------------------------------------------------------------------------------------

			--Begin Test case Precondition.9.3.6
			--Description: Register App5 for precondition
					function Test:Pre_PassengerDevice_App5()
						self.mobileSession5:StartService(7)
						:Do(function()
								local CorIdRegister = self.mobileSession5:SendRPC("RegisterAppInterface",
								{
								  syncMsgVersion =
								  {
									majorVersion = 3,
									minorVersion = 0
								  },
								  appName = "Test Application5",
								  isMediaApplication = true,
								  languageDesired = 'EN-US',
								  hmiDisplayLanguageDesired = 'EN-US',
								  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
								  appID = "5"
								})

								EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
								{
								  application =
								  {
									appName = "Test Application5"
								  }
								})
								:Do(function(_,data)
									self.applications["Test Application5"] = data.params.application.appID
								end)

								--SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
								self.mobileSession5:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

								--mobile side: Expect OnPermissionsChange notification for Passenger's device
								self.mobileSession5:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

								--check OnHMIStatus with deviceRank = "PASSENGER"
								self.mobileSession5:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
								:Timeout(3000)

							end)
						end
			--End Test case Precondition.9.3.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.3.7
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time, asking permission)
				function Test:SetInterior_App1FrontRADIO()
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
			--End Test case CommonRequestCheck.9.3.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.3.8
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (same zone, same moduleType)
				function Test:SetInterior_App2FrontRADIO()
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
					end)

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.3.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.3.9
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_App3FrontRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession2:SendRPC("GetInteriorVehicleData",
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

					self.mobileSession2:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.3.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.3.10
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_App4FrontRADIO()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession3:SendRPC("ButtonPress",
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
									appID = self.applications["Test Application3"],
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

					self.mobileSession3:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.3.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.3.11
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_App5LeftRADIO_DifferentZone()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession4:SendRPC("GetInteriorVehicleData",
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
									appID = self.applications["Test Application4"],
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

					self.mobileSession4:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.3.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.3.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_App6LeftRADIO_DifferentZone()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession5:SendRPC("SetInteriorVehicleData",
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
									appID = self.applications["Test Application5"],
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

					self.mobileSession5:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.3.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.3.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_App1LeftCLIMATE()
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.3.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.3.12
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_App2LeftCLIMATE()
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

					self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.3.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.3.13
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_App3LeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession2:SendRPC("GetInteriorVehicleData",
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
									appID = self.applications["Test Application2"],
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

					self.mobileSession2:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.3.13

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.9.3.14
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_App4LeftCLIMATE()
					--mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					local cid = self.mobileSession3:SendRPC("ButtonPress",
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
									appID = self.applications["Test Application3"],
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

					self.mobileSession3:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.9.3.14

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.9.3


--=================================================END TEST CASES 9==========================================================--







--=================================================BEGIN TEST CASES 10==========================================================--
	--Begin Test suit CommonRequestCheck.10 for Req.#10

	--Description: 10. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
						--and the permission for this app&<interiorZone>&<moduleType> was denied either by the driver or by timeout or erroneous HMI's response
						--RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).


	--Begin Test case CommonRequestCheck.10.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1393

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time)
				function Test:ButtonPress_DriverAllowFrontRADIO_DriverDenied()
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
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.1.2
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time)
				function Test:ButtonPress_DriverAllowFrontRADIO_Error()
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
								:Times(0)
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.1.3
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_DriverAllowFrontRADIO_TimeOut()
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
			--End Test case CommonRequestCheck.10.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.1.4
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time)
				function Test:ButtonPress_DriverAllowFrontRADIO_SUCCESS()
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

					--RSDL must respond with "resultCode: SUCCESS, success: true
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.10.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.1.5
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE_DriverDenied()
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

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
								:Times(0)
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.1.6
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE_Error()
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
							self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "Error", {allowed = true})

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
								:Times(0)
								:Do(function(_,data)
									--hmi side: sending Buttons.ButtonPress response
									self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
								end)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.1.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.1.7
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE_TimeOut()
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
															col = 0,
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
			--End Test case CommonRequestCheck.10.1.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.1.8
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE_Success()
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
			--End Test case CommonRequestCheck.10.1.8

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.10.1


	--Begin Test case CommonRequestCheck.10.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1393

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO_DriverDenied()
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

			--Begin Test case CommonRequestCheck.10.2.2
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO_Error()
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
			--End Test case CommonRequestCheck.10.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.3
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO_TimeOut()
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
							end

							RUN_AFTER(HMIResponse, 10000)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.10.2.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.4
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO_Sucess()
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
			--End Test case CommonRequestCheck.10.2.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.5
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO_DriverDenied()
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
			--End Test case CommonRequestCheck.10.2.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.6
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO_Error()
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
			--End Test case CommonRequestCheck.10.2.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.7
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO_TimeOut()
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
			--End Test case CommonRequestCheck.10.2.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.8
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO_Success()
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
			--End Test case CommonRequestCheck.10.2.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.9
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE_DriverDenied()
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
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.2.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.10
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE_Error()
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
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.2.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.11
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE_TimeOut()
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
							end

							RUN_AFTER(HMIResponse, 10000)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.10.2.11

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.2.12
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE_Success()
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
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.10.2.12

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.10.2


	--Begin Test case CommonRequestCheck.10.3
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1393

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO_DriverDenied()
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
			--End Test case CommonRequestCheck.10.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.2
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO_Error()
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
			--End Test case CommonRequestCheck.10.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.3
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO_TimeOut()
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
							end

							RUN_AFTER(HMIResponse, 10000)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.10.3.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.4
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO_Success()
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
			--End Test case CommonRequestCheck.10.3.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.5
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO_DriverDenied()
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
			--End Test case CommonRequestCheck.10.3.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.6
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO_Error()
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

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.3.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.7
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO_TimeOut()
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
			--End Test case CommonRequestCheck.10.3.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.8
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO_Success()
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
			--End Test case CommonRequestCheck.10.3.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.9
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_DriverAllowLeftCLIMATE_DriverDenied()
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
												temperatureUnit = "CELSIUS"
											}
										}
									})

								end)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.3.9

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.10
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_DriverAllowLeftCLIMATE_Error()
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
												temperatureUnit = "CELSIUS"
											}
										}
									})

								end)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
				end
			--End Test case CommonRequestCheck.10.3.10

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.11
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_DriverAllowLeftCLIMATE_TimeOut()
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
							end

							RUN_AFTER(HMIResponse, 10000)
					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
					:Timeout(11000)
				end
			--End Test case CommonRequestCheck.10.3.12

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.10.3.13
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_DriverAllowLeftCLIMATE_Success()
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.10.3.13

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.10.3

--=================================================END TEST CASES 10==========================================================--




--=================================================BEGIN TEST CASES 11==========================================================--
	--Begin Test suit CommonRequestCheck.11 for Req.#11

	--Description: 11. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
					--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
					--and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent
					--and RSDL has processed this (app's initial) RPC
					--and RSDL gets BC.OnExitApplication (USER_EXIT) for this application from HMI
					--RSDL must take off the driver's permissions from this application (that is, trigger a permission prompt upon this app's next controlling request)


	--Begin Test case CommonRequestCheck.11.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1448

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_DriverAllowFrontRADIO_Time1()
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
				end
			--End Test case CommonRequestCheck.11.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.1.2
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})

					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)

				end
			--End Test case CommonRequestCheck.11.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.1.3
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:ButtonPress_DriverAllowFrontRADIO_Time2()
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
				end
			--End Test case CommonRequestCheck.11.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.1.4
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE_Time1()
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
			--End Test case CommonRequestCheck.11.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.1.5
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})

					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)

				end
			--End Test case CommonRequestCheck.11.1.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.1.6
			--Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:ButtonPress_DriverAllowLeftCLIMATE_Time2()
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
			--End Test case CommonRequestCheck.11.1.6

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.11.1


	--Begin Test case CommonRequestCheck.11.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1448

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO_Time1()
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
			--End Test case CommonRequestCheck.11.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.2.2
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})

					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)

				end
			--End Test case CommonRequestCheck.11.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.2.3
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowFrontRADIO_Time2()
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
			--End Test case CommonRequestCheck.11.2.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO_Time1()
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
			--End Test case CommonRequestCheck.11.2.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.2.3
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})

					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)

				end
			--End Test case CommonRequestCheck.11.2.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.2.4
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:GetInterior_DriverAllowLeftRADIO_Time2()
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
			--End Test case CommonRequestCheck.11.2.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.2.5
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE_Time1()
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
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.11.2.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.2.6
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})

					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)

				end
			--End Test case CommonRequestCheck.11.2.6

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.2.7
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:GetInterior_DriverAllowLeftCLIMATE_Time2()
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
					end)

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.11.2.7

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.11.2


	--Begin Test case CommonRequestCheck.11.3
	--Description: 	For SetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1448

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO_Time1()
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
			--End Test case CommonRequestCheck.11.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.3.2
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})

					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)

				end
			--End Test case CommonRequestCheck.11.3.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.3.3
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowFrontRADIO_Time2()
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
			--End Test case CommonRequestCheck.11.3.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.3.4
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO_Time1()
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
			--End Test case CommonRequestCheck.11.3.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.3.5
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})

					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)

				end
			--End Test case CommonRequestCheck.11.3.5

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.3.6
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
				function Test:SetInterior_DriverAllowLeftRADIO_Time2()
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
			--End Test case CommonRequestCheck.11.3.6

		-----------------------------------------------------------------------------------------


			--Begin Test case CommonRequestCheck.11.3.7
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_DriverAllowLeftCLIMATE_Time1()
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.11.3.7

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.3.8
			--Description: From HMI trigger HMILevel to change. Press EXIT_Application button ( BC.OnExitApplication (USER_EXIT)).
				function Test:EXIT_Application()

					--hmi side: HMI send BC.OnExitApplication to Rsdl.
					self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})

					--mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
					EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
					:Timeout(5000)

				end
			--End Test case CommonRequestCheck.11.3.8

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.11.3.9
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
				function Test:SetInterior_DriverAllowLeftCLIMATE_Time2()
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

					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				end
			--End Test case CommonRequestCheck.11.3.9

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.11.3

--=================================================END TEST CASES 11==========================================================--





--=================================================BEGIN TEST CASES 12==========================================================--
	--Begin Test suit CommonRequestCheck.12 for Req.#12

	--Description: 12. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database omits this RPC name with <params> in <moduleType> of both "auto_allow" and "driver_allow" sub-sections of <interiorZone> section - RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application (that is, without asking a driver for permission).


	--Begin Test case CommonRequestCheck.12.1
	--Description: 	In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database omits this RPC name with <params> in <moduleType> of both "auto_allow" and "driver_allow" sub-sections of <interiorZone> section - RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application (that is, without asking a driver for permission).

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1561

		--Verification criteria:
				--In case RPC_1 is omitted in both "auto_allow" and "driver_allow" sections.
				--RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application (that is, without asking a driver for permission).

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.12.1.1
			--Description: application sends ButtonPress as Right Rare Passenger (col=1, row=1, level=0) and ModuleType = CLIMATE (DISALLOWED)
				function Test:ButtonPress_CLIMATE_DISALLOWED()
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
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
				end
			--End Test case CommonRequestCheck.12.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.12.1.2
			--Description: application sends GetInteriorVehicleData as Right Rare Passenger (col=1, row=1, level=0) and ModuleType = CLIMATE (DISALLOWED)
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
								col = 1,
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
										col = 0,
										levelspan = 1,
										level = 0
									}
					})
					:Times(0)


					--RSDL must respond with "resultCode: DISALLOWED, success: false, info: "The RPC is disallowed by vehicle settings" to this application
					EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED", info = "The RPC is disallowed by vehicle settings" })
				end
			--End Test case CommonRequestCheck.12.1.2

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.12.1.3
			--Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (DISSALLOWED)
				function Test:SetInterior_LeftRADIO_DISSALLOWED()
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
								col = 0,
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
								col = 0,
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
								state = "ACQUIRING"
							}
						}
					})
					local cid8 = self.mobileSession:SendRPC("SetInteriorVehicleData",
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
								hdChannel = 1,
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
								}
							}
						}
					})
					local cid9 = self.mobileSession:SendRPC("SetInteriorVehicleData",
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
								col = 0,
								colspan = 2,
								level = 0,
								levelspan = 1,
								row = 1,
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
			--End Test case CommonRequestCheck.12.1.3

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.12.1.4
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
					local cid3 = self.mobileSession:SendRPC("SetInteriorVehicleData",
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
			--End Test case CommonRequestCheck.12.1.4

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.12.1.5
			--Description: application sends SetInteriorVehicleData as Right Rare Passenger (col=1, row=1, level=0) and ModuleType = RADIO (DISSALLOWED)
				function Test:SetInterior_RightRADIO_DISSALLOWED()
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
			--End Test case CommonRequestCheck.12.1.5

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.12.1

--=================================================END TEST CASES 12==========================================================--




--=================================================BEGIN TEST CASES 13==========================================================--
	--Begin Test suit CommonRequestCheck.13 for Req.#13

	--Description: 13. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
						--and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
						--and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent
						--and RSDL has processed this (app's initial) RPC
						--and the same application sends a valid RPC with the different <interiorZone> and the same <moduleType> and params that exist in "driver_allow" sub-section
						--RSDL must send a new RC.GetInteriorVehicleDataConsent for this different <interiorZone> to the vehicle (HMI)


	--Begin Test case CommonRequestCheck.13.1
	--Description: 	For ButtonPress

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1564

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.13.1.1
			--Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time, asking driver's permission)
				function Test:ButtonPress_FrontRADIO()
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
				end
			--End Test case CommonRequestCheck.13.1.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.13.1.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (the second, asking new permission and HMI auto REJECTED)
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
										row = 1,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									}
					})
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.13.1.2

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.13.1


	--Begin Test case CommonRequestCheck.13.2
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1564

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.13.2.1
			--Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time, asking driver's permission)
				function Test:GetInterior_FrontRADIO()
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
			--End Test case CommonRequestCheck.13.2.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.13.2.2
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (the second, asking new permission and HMI auto REJECTED)
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
										row = 1,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									}
					})
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.13.2.2

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.13.2


	--Begin Test case CommonRequestCheck.13.3
	--Description: 	For GetInteriorVehicleData

		--Requirement/Diagrams id in jira:
				--REVSDL-966
				--TC: REVSDL-1564

		--Verification criteria:
				--In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.13.3.1
			--Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time, asking driver's permission)
				function Test:SetInterior_FrontRADIO()
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
			--End Test case CommonRequestCheck.13.3.1

		-----------------------------------------------------------------------------------------

			--Begin Test case CommonRequestCheck.13.3.3
			--Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (the second, asking new permission and HMI auto REJECTED)
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
										row = 1,
										rowspan = 2,
										col = 0,
										levelspan = 1,
										level = 0
									}
					})
					:Do(function(_,data)
						--hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
						self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

					end)

					--RSDL must respond with "resultCode: USER_DISALLOWED, success: false
					EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
				end
			--End Test case CommonRequestCheck.13.3.3

		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.13.3

--=================================================END TEST CASES 13==========================================================--





return Test