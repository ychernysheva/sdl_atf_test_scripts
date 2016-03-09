Test = require('user_modules/connecttest_sdl_4_0_valid_json')
require('cardinalities')
local events = require('events')
local mobile_session = require('user_modules/mobile_session_sdl4_0_valid_json')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local config = require('config')
local msg = 
        {
          serviceType      = 7,
          frameInfo        = 0,
          rpcType          = 2,
          rpcFunctionId    = 32768,
          rpcCorrelationId = 0,
          payload          = '{"hmiLevel" :"FULL", "audioStreamingState" : "AUDIBLE", "systemContext" : "MAIN"}'
        }

local registeredApp = {}
local lengthOfBodyString = 1024
local timeoutValue = 60 --Value from preload_policy: timeout_after_x_seconds

---------------------------------------------------------------------------------------------
--------------------------------------- Common functions ------------------------------------
---------------------------------------------------------------------------------------------

local function UnregisterAppInterface_Success(sessionName, iappName) 

	--mobile side: UnregisterAppInterface request 
	local CorIdURAI = sessionName:SendRPC("UnregisterAppInterface", {})

	--hmi side: expected  BasicCommunication.OnAppUnregistered
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[iappName], unexpectedDisconnect = false})

	--mobile side: UnregisterAppInterface response 
	sessionName:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

end

local function StartSession(sessionName)
	sessionName = mobile_session.MobileSession(
	self.expectations_list,
	self.mobileConnection)
end

local function AppRegistration(self, sessionName , iappName , iappID, isMediaFlag)
	sessionName:StartService(7)
	:Do(function()
		local CorIdRegister = sessionName:SendRPC("RegisterAppInterface",
		{
		syncMsgVersion =
		{
		majorVersion = 3,
		minorVersion = 0
		},
		appName = iappName,
		isMediaApplication = isMediaFlag,
		languageDesired = 'EN-US',
		hmiDisplayLanguageDesired = 'EN-US',
		appHMIType = { "DEFAULT" },
		appID = iappID
	})

		EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
		{
			application = 
			{
				appName = iappName
			}
		})
		:Do(function(_,data)
			self.applications[iappName] = data.params.application.appID
		end)

		sessionName:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
		:Timeout(2000)
		:Do(function(_,data)
			table.insert (registeredApp, {session = sessionName, appName = iappName})

			--mobile side: Sending OnHMIStatus hmiLevel = "FULL"
			sessionName:Send(msg)

			--mobile side: OnSystemRequest notification 
			sessionName:ExpectNotification("OnSystemRequest", {requestType = "QUERY_APPS"})
		end)
	end)
end

local function DelayedExp(time)
	local event = events.Event()
	event.matches = function(self, e) return self == e end
	EXPECT_EVENT(event, "Delayed event")
	:Timeout(time + 1000)
	RUN_AFTER(function()
			  RAISE_EVENT(event, event)
			end, time)
end

-----------------------------------------------------------------------------------------

--Begin Test case 1
	--Description: This test is intended to check header for "OnSystemRequest (QUERY_APPS)
		--Requirement id in JAMA or JIRA: 	
			--APPLINK-11386, SDLAQ-CRS-3018

		--Verification criteria: 
			--When sending "OnSystemRequest (QUERY_APPS)" to mobile app, SDL must add a header of the following type:
			--In case SDL4.0-enabled app registers with SDL and notifies SDL that it is currently in foreground via OnHMIStatus(FULL) notification, SDL must send OnSystemRequest(QUERY_APPS) to this application
			
			function Test:Precondition_RegistrationApp()
				self.mobileSession:StartService(7)
				:Do(function()
					local CorIdRegister = self.mobileSession:SendRPC("RegisterAppInterface", 
					{
						syncMsgVersion =
						{
							majorVersion = 4,
							minorVersion = 2
						},
						appName = "Test Application",
						isMediaApplication = true,
						languageDesired = 'EN-US',
						hmiDisplayLanguageDesired = 'EN-US',
						appHMIType = { "NAVIGATION" },
						appID = "8675308",
					})

					EXPECT_HMICALL("BasicCommunication.OnAppRegistered", 
					{
						application = 
						{
							appName = "Test Application"
						}
					})
					:Do(function(_,data)
						local appId = data.params.application.appID
						self.appId = appId
					end)

					self.mobileSession:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS"})
					:Timeout(2000)

					self.mobileSession:ExpectNotification("OnHMIStatus", 
									  { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"})
					:Timeout(2000)

					DelayedExp(1000)
				end)
			end

			function Test:SystemRequestQueryApps()

				self.mobileSession:Send(msg)

				--mobile side: OnSystemRequest notification 
				EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "QUERY_APPS", {
																						HTTPRequest= {
																								headers= {
																									ContentType= "application/json",
																									ConnectTimeout= timeoutValue,
																									DoOutput= true,
																									DoInput= true,
																									UseCaches= false,
																									RequestMethod= "GET",
																									ReadTimeout= ,
																									InstanceFollowRedirects= false,
																									charset= "utf-8",
																									Content_Length= lengthOfBodyString
																								}		
																							}
																					}})
				:Do(function()
					local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
						{
						  requestType = "QUERY_APPS", 
						  fileName = "jsonfile1"
						},
						"files/jsons/correctJSONLaunchApp.json")

						--mobile side: SystemRequest response
						self.mobileSession:ExpectResponse(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
						:Timeout(2000) 
					end)

				--hmi side: BasicCommunication.UpdateAppList
				EXPECT_HMICALL("BasicCommunication.UpdateAppList",
				  {
					applications = {
					 {
						appID = self.applications["Test Application"],
						appName = "Test Application",
						appType = { "NAVIGATION" },
						deviceName = "127.0.0.1",
						hmiDisplayLanguageDesired = "EN-US",
						isMediaApplication = false
					 },
					 {
						appID = self.applications["Awesome Music App"],
						appName = "Awesome Music App",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App"
						  }
						},
						vrSynonyms = {"Awesome Music App"}
					 },
					 {
						appID = self.applications["Awesome Music App LowerBound"],
						appName = "Awesome Music App LowerBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App LowerBound"
						  }
						},
						vrSynonyms = {"Awesome Music App LowerBound"}
					 },
					 {
						appID = self.applications["Awesome Music App UpperBound"],
						appName = "Awesome Music App UpperBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App UpperBound"
						  }
						},
						vrSynonyms = {"Awesome Music App UpperBound"}
					 },
					 {
						appID = self.applications["Rock music App"],
						appName = "Rock music App",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Rock music App"
						  }
						},
						vrSynonyms = {"Rock music App"}
					 },
					 {
						appID = self.applications["Rock music App LowerBound"],
						appName = "Rock music App LowerBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Rock music App LowerBound"
						  }
						},
						vrSynonyms = {"Rock music App LowerBound"}
					 },
					 {
						appID = self.applications["Rock music App UpperBound"],
						appName = "Rock music App UpperBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Rock music App UpperBound"
						  }
						},
						vrSynonyms = {"Rock music App UpperBound"}
					 }
				  }
				  })
				:ValidIf(function(_,data)
				  if #data.params.applications == 3 then
					return true
					else 
					  print(" \27[36m Application array in BasicCommunication.UpdateAppList contains "..tostring(#data.params.applications)..", expected 3 \27[0m")
					  return false
					end
				end)
				:Do(function(_,data) 
					--hmi side: sending SDL.ActivateApp
					local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})

					--hmi side: expect SDL.ActivateApp response
					EXPECT_HMIRESPONSE(RequestId)

					--mobile side: expect OnHMIStatus on mobile side
					self.mobileSession1:ExpectNotification("OnHMIStatus", { hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})

					--mobile side: expect OnSystemRequest on mobile side
					EXPECT_NOTIFICATION("OnSystemRequest")
					:Times(0)
					
					DelayedExp(1000)
				end)
		  end
--End Test case 1

-----------------------------------------------------------------------------------------

--Begin Test case 2
	--Description: This test is intended to check SDL must validate params of json file received from mobile app via SystemRequest
		--Requirement id in JAMA or JIRA: 	
			--APPLINK-15443

		--Verification criteria: 
			--[[
				1. 	In case SDL4.0-enabled app sends SystemRequest (QUERY_APPS) with json file to SDL AND the "default" section of this json file is empty -> SDL must:
				1.1. 	log the corresponding error internally
				1.2. 	respond INVALID_DATA to this mobile app
						 
				2. 	In case SDL4.0-enabled app sends SystemRequest(QUERY_APPS) with json file to SDL AND at least one of params (please, see the list with params below) at this json file is out of bounds -> SDL must:
				2.1. 	log the corresponding error internally
				2.2. 	respond INVALID_DATA to this mobile app
						 
				3. 	In case SDL4.0-enabled app sends SystemRequest(QUERY_APPS) with json file to SDL AND at least one of params (please, see the list with params below) at this json file has invalid type -> SDL must:
				3.1. 	log the corresponding error internally
				3.2. 	respond INVALID_DATA to this mobile app
			--]]
	--Begin Test case 2.1
	--Description: Verify default struct in json file in case app sends SystemRequest (QUERY_APPS)
		function Test:SystemRequestQueryApps_DefaultCheck()
			self.mobileSession:Send(msg)

			--mobile side: OnSystemRequest notification 
			EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "QUERY_APPS", {
																					HTTPRequest= {
																							headers= {
																								ContentType= "application/json",
																								ConnectTimeout= timeoutValue,
																								DoOutput= true,
																								DoInput= true,
																								UseCaches= false,
																								RequestMethod= "GET",
																								ReadTimeout= ,
																								InstanceFollowRedirects= false,
																								charset= "utf-8",
																								Content_Length= lengthOfBodyString
																							}		
																						}
																				}})
			:Do(function()
				local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
					{
					  requestType = "QUERY_APPS", 
					  fileName = "jsonfile1"
					},
					"files/jsons/JSONAppIDVerification.json")

					--mobile side: SystemRequest response
					self.mobileSession:ExpectResponse(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
					:Timeout(2000) 
				end)

			--hmi side: BasicCommunication.UpdateAppList
			EXPECT_HMICALL("BasicCommunication.UpdateAppList",
			{
				applications = {
					{
						appID = self.applications["Test Application"],
						appName = "Test Application",
						appType = { "NAVIGATION" },
						deviceName = "127.0.0.1",
						hmiDisplayLanguageDesired = "EN-US",
						isMediaApplication = false
					}
				}
			})
			:ValidIf(function(_,data)
				if #data.params.applications == 1 then
					return true
				else 
					print(" \27[36m Application array in BasicCommunication.UpdateAppList contains "..tostring(#data.params.applications)..", expected 1 \27[0m")
					return false
				end
			end)
			:Do(function(_,data) 
				--hmi side: sending SDL.ActivateApp
				local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})

				--hmi side: expect SDL.ActivateApp response
				EXPECT_HMIRESPONSE(RequestId)

				--mobile side: expect OnHMIStatus on mobile side
				self.mobileSession1:ExpectNotification("OnHMIStatus", { hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})

				--mobile side: expect OnSystemRequest on mobile side
				EXPECT_NOTIFICATION("OnSystemRequest")
				:Times(0)

				DelayedExp(1000)
			end)
		end
	--End Test case 2.1
	
	-----------------------------------------------------------------------------------------
	
	--Begin Test case 2.2
	--Description: Verify appID in json file in case app sends SystemRequest (QUERY_APPS)
		function Test:SystemRequestQueryApps_appIDCheck()
			self.mobileSession:Send(msg)

			--mobile side: OnSystemRequest notification 
			EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "QUERY_APPS", {
																					HTTPRequest= {
																							headers= {
																								ContentType= "application/json",
																								ConnectTimeout= timeoutValue,
																								DoOutput= true,
																								DoInput= true,
																								UseCaches= false,
																								RequestMethod= "GET",
																								ReadTimeout= ,
																								InstanceFollowRedirects= false,
																								charset= "utf-8",
																								Content_Length= lengthOfBodyString
																							}		
																						}
																				}})
			:Do(function()
				local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
					{
					  requestType = "QUERY_APPS", 
					  fileName = "jsonfile1"
					},
					"files/jsons/JSONAppIDVerification.json")

					--mobile side: SystemRequest response
					self.mobileSession:ExpectResponse(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
					:Timeout(2000) 
				end)

			--hmi side: BasicCommunication.UpdateAppList
			EXPECT_HMICALL("BasicCommunication.UpdateAppList",
			{
				applications = {
					{
						appID = self.applications["Test Application"],
						appName = "Test Application",
						appType = { "NAVIGATION" },
						deviceName = "127.0.0.1",
						hmiDisplayLanguageDesired = "EN-US",
						isMediaApplication = false
					},
					{
						appID = self.applications["AppID LowerBound"],
						appName = "AppID LowerBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App"
						  }
						},
						vrSynonyms = {"Awesome Music App"}
					},
					{
						appID = self.applications["AppID UpperBound"],
						appName = "AppID UpperBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App LowerBound"
						  }
						},
						vrSynonyms = {"Awesome Music App LowerBound"}
					}
				}
			})
			:ValidIf(function(_,data)
				if #data.params.applications == 3 then
					return true
				else 
					print(" \27[36m Application array in BasicCommunication.UpdateAppList contains "..tostring(#data.params.applications)..", expected 3 \27[0m")
					return false
				end
			end)
		end
	--End Test case 2.2
	
	-----------------------------------------------------------------------------------------
	
	--Begin Test case 2.3
	--Description: Verify name in json file in case app sends SystemRequest (QUERY_APPS)		
		function Test:SystemRequestQueryApps_NameCheck()
			self.mobileSession:Send(msg)

			--mobile side: OnSystemRequest notification 
			EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "QUERY_APPS", {
																					HTTPRequest= {
																							headers= {
																								ContentType= "application/json",
																								ConnectTimeout= timeoutValue,
																								DoOutput= true,
																								DoInput= true,
																								UseCaches= false,
																								RequestMethod= "GET",
																								ReadTimeout= ,
																								InstanceFollowRedirects= false,
																								charset= "utf-8",
																								Content_Length= lengthOfBodyString
																							}		
																						}
																				}})
			:Do(function()
				local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
					{
					  requestType = "QUERY_APPS", 
					  fileName = "jsonfile1"
					},
					"files/jsons/JSONNameVerification.json")

					--mobile side: SystemRequest response
					self.mobileSession:ExpectResponse(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
					:Timeout(2000) 
				end)

			--hmi side: BasicCommunication.UpdateAppList
			EXPECT_HMICALL("BasicCommunication.UpdateAppList",
			{
				applications = {
					{
						appID = self.applications["Test Application"],
						appName = "Test Application",
						appType = { "NAVIGATION" },
						deviceName = "127.0.0.1",
						hmiDisplayLanguageDesired = "EN-US",
						isMediaApplication = false
					},
					{
						appID = self.applications["A"],
						appName = "A",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App"
						  }
						},
						vrSynonyms = {"Awesome Music App"}
					},
					{
						appID = self.applications["AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"],
						appName = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App LowerBound"
						  }
						},
						vrSynonyms = {"Awesome Music App LowerBound"}
					}
				}
			})
			:ValidIf(function(_,data)
				if #data.params.applications == 3 then
					return true
				else 
					print(" \27[36m Application array in BasicCommunication.UpdateAppList contains "..tostring(#data.params.applications)..", expected 3 \27[0m")
					return false
				end
			end)
		end
	--End Test case 2.3	
	
	-----------------------------------------------------------------------------------------
		
	--Begin Test case 2.4
	--Description: Verify packageName in json file in case app sends SystemRequest (QUERY_APPS)		
		function Test:SystemRequestQueryApps_PackageNameCheck()
			self.mobileSession:Send(msg)

			--mobile side: OnSystemRequest notification 
			EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "QUERY_APPS", {
																					HTTPRequest= {
																							headers= {
																								ContentType= "application/json",
																								ConnectTimeout= timeoutValue,
																								DoOutput= true,
																								DoInput= true,
																								UseCaches= false,
																								RequestMethod= "GET",
																								ReadTimeout= ,
																								InstanceFollowRedirects= false,
																								charset= "utf-8",
																								Content_Length= lengthOfBodyString
																							}		
																						}
																				}})
			:Do(function()
				local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
					{
					  requestType = "QUERY_APPS", 
					  fileName = "jsonfile1"
					},
					"files/jsons/JSONPackageNameVerification.json")

					--mobile side: SystemRequest response
					self.mobileSession:ExpectResponse(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
					:Timeout(2000) 
				end)

			--hmi side: BasicCommunication.UpdateAppList
			EXPECT_HMICALL("BasicCommunication.UpdateAppList",
			{
				applications = {
					{
						appID = self.applications["Test Application"],
						appName = "Test Application",
						appType = { "NAVIGATION" },
						deviceName = "127.0.0.1",
						hmiDisplayLanguageDesired = "EN-US",
						isMediaApplication = false
					},
					{
						appID = self.applications["PackageName LowerBound"],
						appName = "PackageName LowerBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App"
						  }
						},
						vrSynonyms = {"Awesome Music App"}
					},
					{
						appID = self.applications["PackageName UpperBound"],
						appName = "PackageName UpperBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App LowerBound"
						  }
						},
						vrSynonyms = {"Awesome Music App LowerBound"}
					}
				}
			})
			:ValidIf(function(_,data)
				if #data.params.applications == 3 then
					return true
				else 
					print(" \27[36m Application array in BasicCommunication.UpdateAppList contains "..tostring(#data.params.applications)..", expected 3 \27[0m")
					return false
				end
			end)
		end	
	--End Test case 2.4
	
	-----------------------------------------------------------------------------------------
	
	--Begin Test case 2.5
	--Description: Verify urlScheme in json file in case app sends SystemRequest (QUERY_APPS)		
		function Test:SystemRequestQueryApps_UrlSchemeCheck()
			self.mobileSession:Send(msg)

			--mobile side: OnSystemRequest notification 
			EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "QUERY_APPS", {
																					HTTPRequest= {
																							headers= {
																								ContentType= "application/json",
																								ConnectTimeout= timeoutValue,
																								DoOutput= true,
																								DoInput= true,
																								UseCaches= false,
																								RequestMethod= "GET",
																								ReadTimeout= ,
																								InstanceFollowRedirects= false,
																								charset= "utf-8",
																								Content_Length= lengthOfBodyString
																							}		
																						}
																				}})
			:Do(function()
				local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
					{
					  requestType = "QUERY_APPS", 
					  fileName = "jsonfile1"
					},
					"files/jsons/JSONUrlSchemeVerification.json")

					--mobile side: SystemRequest response
					self.mobileSession:ExpectResponse(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
					:Timeout(2000) 
				end)

			--hmi side: BasicCommunication.UpdateAppList
			EXPECT_HMICALL("BasicCommunication.UpdateAppList",
			{
				applications = {
					{
						appID = self.applications["Test Application"],
						appName = "Test Application",
						appType = { "NAVIGATION" },
						deviceName = "127.0.0.1",
						hmiDisplayLanguageDesired = "EN-US",
						isMediaApplication = false
					},
					{
						appID = self.applications["urlScheme LowerBound"],
						appName = "urlScheme LowerBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App"
						  }
						},
						vrSynonyms = {"Awesome Music App"}
					},
					{
						appID = self.applications["urlScheme UpperBound"],
						appName = "urlScheme UpperBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Awesome Music App LowerBound"
						  }
						},
						vrSynonyms = {"Awesome Music App LowerBound"}
					}
				}
			})
			:ValidIf(function(_,data)
				if #data.params.applications == 3 then
					return true
				else 
					print(" \27[36m Application array in BasicCommunication.UpdateAppList contains "..tostring(#data.params.applications)..", expected 3 \27[0m")
					return false
				end
			end)
		end	
	--End Test case 2.5	
	
	-----------------------------------------------------------------------------------------
	
	--Begin Test case 2.6
	--Description: Verify languages in json file in case app sends SystemRequest (QUERY_APPS)		
		function Test:SystemRequestQueryApps_LanguagesCheck()
			self.mobileSession:Send(msg)

			--mobile side: OnSystemRequest notification 
			EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "QUERY_APPS", {
																					HTTPRequest= {
																							headers= {
																								ContentType= "application/json",
																								ConnectTimeout= timeoutValue,
																								DoOutput= true,
																								DoInput= true,
																								UseCaches= false,
																								RequestMethod= "GET",
																								ReadTimeout= ,
																								InstanceFollowRedirects= false,
																								charset= "utf-8",
																								Content_Length= lengthOfBodyString
																							}		
																						}
																				}})
			:Do(function()
				local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
					{
					  requestType = "QUERY_APPS", 
					  fileName = "jsonfile1"
					},
					"files/jsons/JSONLanguagesVerification.json")

					--mobile side: SystemRequest response
					self.mobileSession:ExpectResponse(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
					:Timeout(2000) 
				end)

			--hmi side: BasicCommunication.UpdateAppList
			EXPECT_HMICALL("BasicCommunication.UpdateAppList",
			{
				applications = {
					{
						appID = self.applications["Test Application"],
						appName = "Test Application",
						appType = { "NAVIGATION" },
						deviceName = "127.0.0.1",
						hmiDisplayLanguageDesired = "EN-US",
						isMediaApplication = false
					},
					{
						appID = self.applications["Awesome Music App"],
						appName = "Awesome Music App",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "Rap music App tts name default"
						  }
						},
						vrSynonyms = {"Rap music App 1 default", "Rap music App 2 default"}
					},
					{
						appID = self.applications["languages Array LowerBound"],
						appName = "languages Array LowerBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "languages Array LowerBound tts"
						  }
						},
						vrSynonyms = {"languages Array LowerBound App 1", "languages Array LowerBound App 2"}
					},
					{
						appID = self.applications["languages All Available"],
						appName = "languages All Available",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "All available default"
						  }
						},
						vrSynonyms = {"All available App 1 default", "All available App 2 default"}
					},
					{
						appID = self.applications["languages Array UpperBound"],
						appName = "languages Array UpperBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "languages upperbound default"
						  }
						},
						vrSynonyms = {"Rap musik App 1 DE",
							"Rap musik App 2 DE",
							"Rap musik App 3 DE",
							"Rap musik App 4 DE",
							"Rap musik App 5 DE",
							"Rap musik App 6 DE",
							"Rap musik App 7 DE",
							"Rap musik App 8 DE",
							"Rap musik App 9 DE",
							"Rap musik App 10 DE",
							"Rap musik App 11 DE",
							"Rap musik App 12 DE",
							"Rap musik App 13 DE",
							"Rap musik App 14 DE",
							"Rap musik App 15 DE",
							"Rap musik App 16 DE",
							"Rap musik App 17 DE",
							"Rap musik App 18 DE",
							"Rap musik App 19 DE",
							"Rap musik App 20 DE",
							"Rap musik App 21 DE",
							"Rap musik App 22 DE",
							"Rap musik App 23 DE",
							"Rap musik App 24 DE",
							"Rap musik App 25 DE",
							"Rap musik App 26 DE",
							"Rap musik App 27 DE",
							"Rap musik App 28 DE",
							"Rap musik App 29 DE",
							"Rap musik App 30 DE",
							"Rap musik App 31 DE",
							"Rap musik App 32 DE",
							"Rap musik App 33 DE",
							"Rap musik App 34 DE",
							"Rap musik App 35 DE",
							"Rap musik App 36 DE",
							"Rap musik App 37 DE",
							"Rap musik App 38 DE",
							"Rap musik App 39 DE",
							"Rap musik App 40 DE",
							"Rap musik App 41 DE",
							"Rap musik App 42 DE",
							"Rap musik App 43 DE",
							"Rap musik App 44 DE",
							"Rap musik App 45 DE",
							"Rap musik App 46 DE",
							"Rap musik App 47 DE",
							"Rap musik App 48 DE",
							"Rap musik App 49 DE",
							"Rap musik App 50 DE",
							"Rap musik App 51 DE",
							"Rap musik App 52 DE",
							"Rap musik App 53 DE",
							"Rap musik App 54 DE",
							"Rap musik App 55 DE",
							"Rap musik App 56 DE",
							"Rap musik App 57 DE",
							"Rap musik App 58 DE",
							"Rap musik App 59 DE",
							"Rap musik App 60 DE",
							"Rap musik App 61 DE",
							"Rap musik App 62 DE",
							"Rap musik App 63 DE",
							"Rap musik App 64 DE",
							"Rap musik App 65 DE",
							"Rap musik App 66 DE",
							"Rap musik App 67 DE",
							"Rap musik App 68 DE",
							"Rap musik App 69 DE",
							"Rap musik App 70 DE",
							"Rap musik App 71 DE",
							"Rap musik App 72 DE",
							"Rap musik App 73 DE",
							"Rap musik App 74 DE",
							"Rap musik App 75 DE",
							"Rap musik App 76 DE",
							"Rap musik App 77 DE",
							"Rap musik App 78 DE",
							"Rap musik App 79 DE",
							"Rap musik App 80 DE",
							"Rap musik App 81 DE",
							"Rap musik App 82 DE",
							"Rap musik App 83 DE",
							"Rap musik App 84 DE",
							"Rap musik App 85 DE",
							"Rap musik App 86 DE",
							"Rap musik App 87 DE",
							"Rap musik App 88 DE",
							"Rap musik App 89 DE",
							"Rap musik App 90 DE",
							"Rap musik App 91 DE",
							"Rap musik App 92 DE",
							"Rap musik App 93 DE",
							"Rap musik App 94 DE",
							"Rap musik App 95 DE",
							"Rap musik App 96 DE",
							"Rap musik App 97 DE",
							"Rap musik App 98 DE",
							"Rap musik App 99 DE",
							"Rap musik App 100 DE"}
					},
					{
						appID = self.applications["languages ttsName LowerBound"],
						appName = "languages ttsName LowerBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "A"
						  }
						},
						vrSynonyms = {"languages ttsName LowerBound vr"}
					},
					{
						appID = self.applications["languages ttsName UpperBound"],
						appName = "languages ttsName UpperBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
						  }
						},
						vrSynonyms = {"languages ttsName UpperBound vr"}
					},
					{
						appID = self.applications["languages vrSynonyms Array LowerBound"],
						appName = "languages vrSynonyms Array LowerBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "languages vrSynonyms Array LowerBound tts"
						  }
						},
						vrSynonyms = {"languages vrSynonyms Array LowerBound vr"}
					},
					{
						appID = self.applications["languages vrSynonyms Array UpperBound"],
						appName = "languages vrSynonyms Array UpperBound",
						deviceName = "127.0.0.1",
						greyOut = false,
						ttsName = {
						  {
							type = "TEXT",
							text = "languages vrSynonyms Array UpperBound tts"
						  }
						},
						vrSynonyms = {"languages vrSynonyms Array LowerBound vr"}
					}
				}
			})
			:ValidIf(function(_,data)
				if #data.params.applications == 9 then
					return true
				else 
					print(" \27[36m Application array in BasicCommunication.UpdateAppList contains "..tostring(#data.params.applications)..", expected 9 \27[0m")
					return false
				end
			end)
		end	
	--End Test case 2.6	
--End Test case 2
