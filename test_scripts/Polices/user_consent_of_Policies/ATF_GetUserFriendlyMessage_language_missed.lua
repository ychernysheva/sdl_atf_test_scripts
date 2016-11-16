---------------------------------------------------------------------------------------------
-- Description: 
--     HMI requests a language for a particular prompt via GetUserFriendlyMessage and the language("JA-JP") is not present in policy table
--     1. Used preconditions:	
--			Unregister default application
-- 			Register application 
--			Activate application
--
--     2. Performed steps
--		    Perform PTU with nickname not from policy table
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
local mobile_session = require('mobile_session')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Unregister_default_app() 
	local CorIdUAI = self.mobileSession:SendRPC("UnregisterAppInterface",{}) 
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications["SyncProxyTester"], unexpectedDisconnect = false})
	EXPECT_RESPONSE(CorIdUAI, { success = true, resultCode = "SUCCESS"})
	:Timeout(2000) 
end

function Test:Register_app()
	commonTestCases:DelayedExp(3000)
	self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
	self.mobileSession:StartService(7)
	:Do(function()
		local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
		:Do(function(_,data)
			self.HMIAppID = data.params.application.appID
		end)
		self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
		self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	end)
end

function Test:Activate_app()
	local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID})
	EXPECT_HMIRESPONSE(RequestId)
		:Do(function(_,data)
			if data.result.isSDLAllowed ~= true then
				local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
				EXPECT_HMIRESPONSE(RequestId)
				:Do(function(_,data)
					self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
					EXPECT_HMICALL("BasicCommunication.ActivateApp")
					:Do(function(_,data)
						self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
					end)
					:Times(AnyNumber())
				end)
			end
		end)
	EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
commonFunctions:userPrint(34, "Test is intended to check that english is returned on GetUserFriendlyMessage")

function Test:GetUserFriendlyMessage_JA_JP_missed_in_PT()
	local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
	EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
	:Do(function(_,data)
		self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
			{
				requestType = "PROPRIETARY",
				fileName = "filename"
			}
		)
		EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
		:Do(function(_,data)
			local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
				{
					fileName = "PolicyTableUpdate",
					requestType = "PROPRIETARY"
				}, "files/PTU_AppWithWrongNickname.json")
			local systemRequestId
			EXPECT_HMICALL("BasicCommunication.SystemRequest")
			:Do(function(_,data)
				systemRequestId = data.id
				self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
				{
					policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
			})
			function to_run()
				self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
			end			
			RUN_AFTER(to_run, 500)
		end)
		EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged", {appID = self.HMIAppID, appUnauthorized =  true, priority = "EMERGENCY"})
		:Do(function(_,data)
			local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "JA-JP", messageCodes = {"AppUnauthorized"}})
			EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{
				line1 = "Not Authorized",
				messageCode = "AppUnauthorized",
				ttsString = "This version of %appName% is not authorized and will not work with SYNC."}}}
			})
			:Do(function(_,data)
				print("SDL.GetUserFriendlyMessage is received")			
			end)
		end)
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.HMIAppID, unexpectedDisconnect =  false})
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = "APP_UNAUTHORIZED"})
		EXPECT_HMICALL("BasicCommunication.UpdateAppList")
		:Do(function(_, data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { })
		end)
		:ValidIf (function(_,data)
			for _, app in pairs(data.params.applications) do
				if app.appID == self.HMIAppID then
					commonFunctions:printError(" Application is not removed on AppsList ")
				return false
				end
			end
			return true
		end)
		self.mobileSession:ExpectResponse(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
		end)
	end)
end	

--[[ Postconditions ]]
commonFunctions:SDLForceStop()
