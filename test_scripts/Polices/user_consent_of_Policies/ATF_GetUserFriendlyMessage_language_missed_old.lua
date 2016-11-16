---------------------------------------------------------------------------------------------
-- Description: 
--     HMI requests a language for a particular prompt via GetUserFriendlyMessage and the language("JA-JP") is not present in policy table
--     1. Used preconditions:
-- 			Build SDL with (EXTERNAL_PROPRIETARY flag)	
--			Unregister default application
-- 			Register application with SK_SK language
--
--     2. Performed steps
--		    Activate application 
--
-- Requirement summary: 
--    [Policies] language of the message requested doesn't exist in LocalPT
--
-- Expected result:
--     English ("en-us") prompt must be returned to HMI
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('mobile_session')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
require('user_modules/AppTypes')

local function DelayedExp(time)
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  :Timeout(time+1000)
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, time)
end

-- Activation of application
function ActivationApp(self, appId)

	--hmi side: sending SDL.ActivateApp request
  	local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = appId})

  	--hmi side: expect SDL.ActivateApp response
	EXPECT_HMIRESPONSE(RequestId)
		:Do(function(_,data)
			--In case when app is not allowed, it is needed to allow app
	    	if
	        	data.result.isSDLAllowed ~= true then

	        		--hmi side: sending SDL.GetUserFriendlyMessage request
	            	local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
								        {language = "EN-US", messageCodes = {"DataConsent"}})

	            	--hmi side: expect SDL.GetUserFriendlyMessage response
    			  	--TODO: Update after resolving APPLINK-16094 EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
						EXPECT_HMIRESPONSE(RequestId)
						:Do(function(_,data)

		    			    --hmi side: send request SDL.OnAllowSDLFunctionality
		    			    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
		    			    	{allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

		    			    --hmi side: expect BasicCommunication.ActivateApp request
				            EXPECT_HMICALL("BasicCommunication.ActivateApp")
				            	:Do(function(_,data)

				            		--hmi side: sending BasicCommunication.ActivateApp response
						          	self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

						        end)
						        :Times(2)
		              	end)
		    else 
		    	-- hmi side: expect of absence BasicCommunication.ActivateApp
		    	EXPECT_HMICALL("BasicCommunication.ActivateApp")
		    	:Times(0)
			end
	      end)

	DelayedExp(500)

end

--[[ Preconditions ]]
--[TODO: add function for building SDL with (EXTERNAL_PROPRIETARY flag)
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Unregister_default_app() 
	local CorIdUAI = self.mobileSession:SendRPC("UnregisterAppInterface",{}) 
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications["SyncProxyTester"], unexpectedDisconnect = false})
	EXPECT_RESPONSE(CorIdUAI, { success = true, resultCode = "SUCCESS"})
	:Timeout(2000) 
end

function Test:Register_app_SK_SK() 
	local CorIdRAI = self.mobileSession:SendRPC("RegisterAppInterface",
	{
		syncMsgVersion = 
		{ 
			majorVersion = 2,
			minorVersion = 2
		}, 
		appName ="TestApp",
		isMediaApplication = true,
		languageDesired ="SK-SK",
		hmiDisplayLanguageDesired ="SK-SK",
		appID ="111"
	})
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
	{
		application = 
		{
			appName = "TestApp",
			policyAppID = "111",
			hmiDisplayLanguageDesired ="SK-SK",
			isMediaApplication = AppMediaType
		}
	})
	EXPECT_RESPONSE(CorIdRAI, { success = true, resultCode = "WRONG_LANGUAGE"})
	:Timeout(2000)
	EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
end

function Test:Activate_application()
	ActivationApp(self, self.applications["TestApp"])
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
commonFunctions:userPrint(34, "Test is intended to check that english is returned on GetUserFriendlyMessage")

function Test:GetUserFriendlyMessage_english_on_ActivateApp()
	local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = CorIdRAI })
	EXPECT_HMIRESPONSE(RequestId, {result = { code = 0, device = { id = config.deviceMAC, name = "127.0.0.1" }, isAppPermissionsRevoked = false, isAppRevoked = false, isSDLAllowed = false, isPermissionsConsentNeeded = true, method ="SDL.ActivateApp", priority ="NONE"}})
	:Do(function(_,data)
		--Consent for device is needed
		if data.result.isSDLAllowed ~= false then
			commonFunctions:userPrint(31, "Error: wrong behavior of SDL - device needs to be consented on HMI")
		else
			local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
			{language = "EN-US", messageCodes = {"DataConsent"}})
			EXPECT_HMIRESPONSE(RequestId)
			:Do(function(_,data)
				self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
				{allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})	
				EXPECT_HMICALL("BasicCommunication.ActivateApp")
				:Do(function(_,data)
					self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
				end)
				:Times(2)
			end)
		end
	end)
	EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN", audioStreamingState = "AUDIBLE"})	
end

function Test:GetUserFriendlyMessage_English()
	--hmi side: sending SDL.GetUserFriendlyMessage request
	local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "JA-JP", messageCodes = {"AppUnauthorized"}})
	--hmi side: expect SDL.GetUserFriendlyMessage response
	EXPECT_HMIRESPONSE(RequestId, { result = { messages = {{messageCode = "AppUnauthorized"}}, method = "SDL.GetUserFriendlyMessage"}})

end

--[[ Postconditions ]]
commonFunctions:SDLForceStop()


  
