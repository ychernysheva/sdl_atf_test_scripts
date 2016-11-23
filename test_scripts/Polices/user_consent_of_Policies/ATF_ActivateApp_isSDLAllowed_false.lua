---------------------------------------------------------------------------------------------
-- Requirement summary: 
--    [Policies] SDL.ActivateApp from HMI, the device this app is running on is unconsented
--
-- Description: 
--     SDL receives request for app activation from HMI and the device the app is running on is unconsented by the User
--     1. Used preconditions:
--			Close current connection
-- 			Overwrite preloaded Policy Table to ensure device is not preconsented
-- 			Connect device
-- 			Register application
--
--     2. Performed steps
--		    Activate application 
--
-- Expected result:
--     PoliciesManager must respond with 1)"isSDLAllowed:false", 2) "device" param containing the device`s name and ID previously sent by SDL via UpdateDeviceList
--     in the response to HMI without consent request 
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local Preconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
require('user_modules/AppTypes')

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Precondition_CloseConnection()
	self.mobileConnection:Close()
	commonTestCases:DelayedExp(3000)
		
end

Preconditions:BackupFile("sdl_preloaded_pt.json")
testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/DeviceNotConsented_preloadedPT.json")

function Test:Precondition_ConnectDevice()
	commonTestCases:DelayedExp(2000)
	self:connectMobile()
	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
					{
						deviceList = {
							{
								id = config.deviceMAC,
								isSDLAllowed = true,
								name = "127.0.0.1",
								transportType = "WIFI"
							}
						}
					}
	):Do(function(_,data)
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)
	:Times(AtLeast(1))
end

function Test:Precondition_RegisterApp1()
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

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:ActivateApp_isSDLAllowed_false()
	local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})
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
				:Times(AtLeast(1)) 
			end)
		end
	end)
	EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN", audioStreamingState = "AUDIBLE"})	
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
						
function Test:Postcondition_SDLForceStop()
	commonFunctions:SDLForceStop()
end										
function Test:Postcondition_RestorePreloadedPT()										
	testCasesForPolicyTable:Restore_preloaded_pt()
end
