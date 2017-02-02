local commonPreconditions = require("user_modules/shared_testcases/commonPreconditions")
commonPreconditions:BackupFile("sdl_preloaded_pt.json")
commonPreconditions:ReplaceFile("sdl_preloaded_pt.json", "./test_scripts/RC/TestData/sdl_preloaded_pt.json")

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

--======================================REVSDL-1827========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1827: Policies: "equipment" permissions must be checked-----------------
-------------------------- against location provided from HMI--------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--



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

function Test:PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end