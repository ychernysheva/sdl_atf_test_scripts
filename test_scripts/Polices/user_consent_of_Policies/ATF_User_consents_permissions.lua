--UNREADY
--Preconditions in header should be updated
--Register app interface function should be corrected, currently OnHmiStatus is not received
---------------------------------------------------------------------------------------------
-- Requirement summary: 
--    	[Policies]: User-consent "YES"
--
-- Description: 
--     SDL gets user consent information from HMI
--     1. Used preconditions:	
--			
--
--     2. Performed steps
--		   
--
-- Expected result:
--  	SDL must notify an application about the current permissions active on HMI via onPermissionsChange() notification
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
Test = require('user_modules/connecttest_resumption')
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local Preconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
require('user_modules/AppTypes')

--[[ General Settings for configuration ]]
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Precondition_CloseConnection()
	self.mobileConnection:Close()
	commonTestCases:DelayedExp(3000)	
end

Preconditions:BackupFile("sdl_preloaded_pt.json")
testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/DeviceConsentedAndAppPermissionsForConsent_preloaded_pt.json")

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

function Test:Precondition_RegisterApp()
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

function Test:User_consent_on_activate_app()
	local RequestIdActivateApp = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID})
	EXPECT_HMIRESPONSE(RequestIdActivateApp, {result= {code = 0, method = "SDL.ActivateApp", isPermissionsConsentNeeded = true, isSDLAllowed = true, priority = "NONE"}})
	:Do(function(_,data)
		if data.result.isPermissionsConsentNeeded == true then
			local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", { appID = self.HMIAppID })
			EXPECT_HMIRESPONSE(RequestIdListOfPermissions,{result = {code = 0, method = "SDL.GetListOfPermissions", allowedFunctions = {{name = "Location-1"}, {name = "DrivingCharacteristics-3"}}}})
			:Do(function()
				local ReqIDGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"allowedFunctions"}})
				EXPECT_HMIRESPONSE(ReqIDGetUserFriendlyMessage)
				:Do(function()
					self.hmiConnection:SendNotification("SDL.OnAppPermissionsConsent", {})		
				end)
			end)
		else
			commonFunctions:userPrint(31, "Wrong SDL bahavior: there are app permissions for consent, isPermissionsConsentNeeded should be true")
			return false	
		end
	end)
	EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
	EXPECT_NOTIFICATION("OnPermissionsChange")
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
    commonFunctions:SDLForceStop()
end

function Test.Restore_PreloadedPT()
	testCasesForPolicyTable:Restore_preloaded_pt()
end
