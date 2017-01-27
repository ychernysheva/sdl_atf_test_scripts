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

--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice
--NonPrimaryNotification Group
local arrayGroups_nonPrimaryRCNotification = revsdl.arrayGroups_nonPrimaryRCNotification()
--groups_PrimaryRC Group
local arrayGroups_PrimaryRC = revsdl.arrayGroups_PrimaryRC()
--groups_nonPrimaryRC Group
local arrayGroups_nonPrimaryRC = revsdl.arrayGroups_nonPrimaryRC()




--======================================REVSDL-1702========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1702: SetInteriorVehicleData: conditions to return----------------------
----------------------------------READ_ONLY resultCode---------------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--

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
