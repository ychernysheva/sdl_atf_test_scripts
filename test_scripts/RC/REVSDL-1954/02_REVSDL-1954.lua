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
config.application1.registerAppInterfaceParams.appID = "8675311"

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

os.execute("ifconfig lo:1 192.168.100.199")

---------------------------------------------------------------------------------------------
--ID for app that duplicates name
local ID

--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice

--groups_PrimaryRC Group
local arrayGroups_PrimaryRC = revsdl.arrayGroups_PrimaryRC()
--groups_nonPrimaryRC Group
local arrayGroups_nonPrimaryRC = revsdl.arrayGroups_nonPrimaryRC()



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
		self,
		self.mobileConnection2,
		config.application1.registerAppInterfaceParams
	)
  event_dispatcher:AddConnection(self.mobileConnection2)
  self.mobileSession21:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection2:Connect()
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
				self,
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
				self,
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


function Test:PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end