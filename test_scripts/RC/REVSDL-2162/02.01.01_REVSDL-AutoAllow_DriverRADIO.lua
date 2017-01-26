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
					-- :Do(function(_,data)
					-- 	--hmi side: sending RC.GetInteriorVehicleDataCapabilities response
					-- 	self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
					-- 									interiorVehicleDataCapabilities = {
					-- 										{
					-- 											moduleZone = {
					-- 												colspan = 2,
					-- 												row = 2,
					-- 												rowspan = 2,
					-- 												col = 2,
					-- 												levelspan = 1,
					-- 												level = 0
					-- 											},
					-- 											moduleType = "RADIO"
					-- 										}
					-- 									}
					-- 	})
					-- end)

					-- --mobile side: expect SUCCESS response
					-- EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", interiorVehicleDataCapabilities = {
					-- 																			{
					-- 																				moduleZone = {
					-- 																					col = 2,
					-- 																					row = 2,
					-- 																					level = 0,
					-- 																					colspan = 2,
					-- 																					rowspan = 2,
					-- 																					levelspan = 1
					-- 																				},
					-- 																				moduleType = "RADIO"
					-- 																			}
					-- 																		}
					-- })
				end
			--End Test case CommonRequestCheck.2.1.1


		-----------------------------------------------------------------------------------------
	--End Test case CommonRequestCheck.2.2



return Test