---------------------------------------------------------------------------------------------
--ATF version: 2.2
--Last update date: 18/Dec/2015
--Author: Ta Thanh Dong
---------------------------------------------------------------------------------------------
Test = require('user_modules/OnAppRegistered_connecttest')
local mobile_session = require('mobile_session')
require('cardinalities')
local events = require('events')
---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
SDLConfigurations = require('user_modules/shared_testcases/SmartDeviceLinkConfigurations')
require('user_modules/AppTypes')

local AppIconsFolder = SDLConfigurations:GetValue("AppIconsFolder")
local AppStorageFolder = SDLConfigurations:GetValue("AppStorageFolder")



local function userPrint( color, message)
  print ("\27[" .. tostring(color) .. "m " .. tostring(message) .. " \27[0m")
end

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------
	
	commonSteps:DeleteLogsFileAndPolicyTable()

	--TODO: Remove print after resolving APPLINK-16052
	userPrint( 33, "Because of ATF defect APPLINK-16052 check of deviceInfo params in BC.OnAppRegistered is commented.")
	userPrint( 33, "Expected result is under clarification. Absence of icon in actual results are not defect for now (APPLINK-17869).")
	
----------------------------------------------------------------------------------------------
--SDLAQ-TC-1364: TC_OnAppRegistered_02 (genivi_only)
--APPLINK-18436: 05[P][MAN]_TC_SDL_sends_optional_icon_in_OnAppRegistered_during_RAI	
--Verification criteria: Check that SDL sends optional icon parameter in OnAppRegistered notification
----------------------------------------------------------------------------------------------
--Note: 
	--Copy file https://adc.luxoft.com/svn/APPLINK/doc/technical/testing/manual_test_cases/SDL4.0/QUERRY_jsons/query_app_response.json to "/files/jsons/QUERRY_jsons/query_app_response.json"
	--TODO: update after resolving APPLINK-16052
	--TODO: Update when APPLINK-16050 is closed
	--TODO: Blocked issue APPLINK-18865. Script will be debugged when this issue is closed
----------------------------------------------------------------------------------------------
	local function TC_OnAppRegistered_02()
		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup("Test case: TC_OnAppRegistered_02/05[P][MAN]_TC_SDL_sends_optional_icon_in_OnAppRegistered_during_RAI")
		
		--Step 1: Precondition:
		function Test:Precondition_Unregister_Application()
			
			local cid = self.mobileSession:SendRPC("UnregisterAppInterface",{})

			EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
			:Timeout(2000)
		end 	

		
		-- Step 2: Open SyncProxyTesterAlice, specify next parameters: protocol version 1,4; AppName: Awesome Music App; AppID: 853426; "Set app icon after registration" is checked, all other paramerters leave by default, click OK
		-- Expected result: SyncProxyTester sends RegisterAppInterface request. SDL sends to HMI OnAppRegistered notification "icon" should be absent due to no icon is provided for the App. After successful registration SPTAlice sends PutFile and SetAppIcon setting the icon for the App. 

		function Test:RegisterAppInterface_Verify_OnAppRegistered_icon() 

		
			--mobile side: RegisterAppInterface request 
			local CorIdRAI = self.mobileSession:SendRPC("RegisterAppInterface", 
																				{
																					syncMsgVersion =
																					{
																					  majorVersion = 3,
																					  minorVersion = 0
																					},
																					appName = "Awesome Music App",
																					isMediaApplication = true,
																					languageDesired = "EN-US",
																					hmiDisplayLanguageDesired = "EN-US",
																					appHMIType = { "DEFAULT" },
																					appID = "853426",
																					deviceInfo =
																					{
																					  os = "Android",
																					  carrier = "Megafon",
																					  firmwareRev = "Name: Linux, Version: 3.4.0-perf",
																					  osVersion = "4.4.2",
																					  maxNumberRFCOMMPorts = 1
																					}
																				})
			

			--hmi side: expected  BasicCommunication.OnAppRegistered
			EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
			{
				application = 
				{
					appName = "Awesome Music App",
					policyAppID = "853426",
					isMediaApplication = true,					
					hmiDisplayLanguageDesired = "EN-US",
					appType = { "DEFAULT" }
				}
			})
			:ValidIf(function(_,data)
				--verify OnAppRegistered notification does not contan "icon" parameter
				if data.params.application.icon == nil then
					return true
				else 				
					commonFunctions:printError(" OnAppRegistered notification came with icon parameter ")
					return false
				end
			end)		

			--mobile side: RegisterAppInterface response 
			EXPECT_RESPONSE(CorIdRAI, { success = true, resultCode = "SUCCESS"})
			
			EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
			EXPECT_NOTIFICATION("OnPermissionsChange", {})

		end

		-- Put file and set appIcon
		commonSteps:PutFile("PutFile_icon", "icon.png")
		
		function Test:SetAppIcon()
				
			local storagePath = config.pathToSDL .. AppStorageFolder .. "/853426".. "_" .. config.deviceMAC.. "/"
		
			--mobile side: sending SetAppIcon request
			local cid = self.mobileSession:SendRPC("SetAppIcon",{ syncFileName = "icon.png" })

			--hmi side: expect UI.SetAppIcon request
			EXPECT_HMICALL("UI.SetAppIcon",
			{
				syncFileName = 
				{
					imageType = "DYNAMIC",
					value = storagePath .. "icon.png"
				}				
			})
			:Do(function(_,data)
				--hmi side: sending UI.SetAppIcon response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
			
			--mobile side: expect SetAppIcon response
			EXPECT_RESPONSE(cid, { resultCode = "SUCCESS", success = true })		
		end
		
		
		-- Step 3: Open SyncProxyTester, specify next parameters: protocol version 1,4; heartbeat unchecked; Media checked; AppName: SPT; AppID: 1234567; all other paramerters leave by default, click OK
		-- Expected result: SyncProxyTester sends RegisterAppInterface request. SDL sends to HMI OnAppRegistered notification, where application parameter contains: appName: SPT; deviceName: from UpdateDeviceList notification to HMI; appID: 1234567; device ID = hash of "usb_serial"(in case of USB connection) or hash of "device's MAC address" (in case of BlueTooth or WiFi connection), TransportType: "USB_AOA" or "USB_IOS" or "BLUETOOTH" or "WIFI"; isMediaApplicatin: true. Among other parameters there should be "icon" with path to Awesome Music App icon. After successfull registration SPT sends OnHMIStatus notification to SDL that SPT is current App on phone. SDL sends OnSystemRequest(QUERRY_APPS), SPT replay with json. SDL sends to HMI UpdateAppList with all Apps - current + from json
		
		function Test:AddSession2_Protocol4()

			self.mobileSession2 = mobile_session.MobileSession(self,self.mobileConnection)
			self.mobileSession2.version = 4
			self.mobileSession2:StartService(7)
			
		end	
		
		function Test:RegisterAppInterface_App2_And_Verify_OnAppRegistered_policyAppID() 


			
			--mobile side: RegisterAppInterface request 
			local CorIdRAI = self.mobileSession2:SendRPC("RegisterAppInterface", {
																					syncMsgVersion =
																					{
																					  majorVersion = 3,
																					  minorVersion = 0
																					},
																					appName = "SPT",
																					isMediaApplication = true,
																					languageDesired = 'EN-US',
																					hmiDisplayLanguageDesired = 'EN-US',
																					appHMIType = { "DEFAULT" },
																					appID = "1234567",
																					deviceInfo =
																					{
																					  os = "Android",
																					  carrier = "Megafon",
																					  firmwareRev = "Name: Linux, Version: 3.4.0-perf",
																					  osVersion = "4.4.2",
																					  maxNumberRFCOMMPorts = 1
																					}
																				})
			
			--mobile side: expect OnSystemRequest notification and send SystemRequest
			self.mobileSession2:ExpectNotification("OnSystemRequest", 	
														{requestType = "LOCK_SCREEN_ICON_URL"},
														{requestType = "QUERRY_APPS", fileType = "BINARY"})
			:Times(2)
			:Do(function(exp,data)
				if data.payload.requestType == "QUERRY_APPS" then
					--mobile side: sending SystemRequest request 
					local CorIdSystemRequest = self.mobileSession2:SendRPC("SystemRequest",
						{
							fileName = "queryAppsResponse",
							requestType = "QUERRY_APPS"
						},
					"./files/jsons/QUERRY_jsons/query_app_response.json")
				end
				
			end)
			
			
			--hmi side: expected  BasicCommunication.OnAppRegistered
			EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
			{
				application = 
				{
					appName = "SPT",
					policyAppID = "1234567",
					--[=[TODO: update after resolving APPLINK-16052
					deviceInfo = 
					{
						name = "127.0.0.1",
						id = config.deviceMAC,
						transportType = "WIFI",
						isSDLAllowed = true
					},]=]	
					isMediaApplication = true,
					icon = config.pathToSDL .. AppIconsFolder .."/853426"
									
				}
			})
			:ValidIf(function(_,data)
				if data.params.application.appID == nil or type(data.params.application.appID) ~= "number" then
					commonFunctions:printError(" OnAppRegistered notification came with appID parameter is nil or not a number ")
					return false
				else 			
					self.applications["SPT"] = data.params.application.appID
					return true
				end
			end)		
			
			--mobile side: RegisterAppInterface response 
			self.mobileSession2:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
			
			self.mobileSession2:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
			:Do(function(_, data)
				--mobile side: send HMI level notification to SDL
				local msg = 
					{
					  serviceType      = 7,
					  frameInfo        = 0,
					  rpcType          = 2,
					  rpcFunctionId    = 32768,
					  rpcCorrelationId = 0,
					  payload          = '{"hmiLevel" :"FULL", "audioStreamingState" : "NOT_AUDIBLE", "systemContext" : "MAIN"}'
					}

				self.mobileSession2:Send(msg)
			end)
			
			--mobile side: expect OnPermissionsChange notification
			self.mobileSession2:ExpectNotification("OnPermissionsChange", {})
			
			EXPECT_HMICALL("BasicCommunication.UpdateAppList", {applications = {
																					{appName = "SPT"},
																					{appName = "Awesome Music App", greyOut = false,icon = config.pathToSDL .. AppIconsFolder .. "/853426"},
																					{appName = "SPTAlice", greyOut = false,icon = config.pathToSDL ..AppIconsFolder  .. "/1461058790"}}
																})
																					

		end
		
			
	end

	TC_OnAppRegistered_02()



	function Test:Postcondition_StopSDL_IfItIsStillRunning()
		print("----------------------------------------------------------------------------------------------")
		StopSDL()
	end


return Test
