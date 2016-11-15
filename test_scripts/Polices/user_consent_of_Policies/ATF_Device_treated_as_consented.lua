---------------------------------------------------------------------------------------------
-- Description: 
--     Condition for device to be consented
--     1. Used preconditions:
-- 			Close current connection
-- 			Overwrite preloaded policy table to have group both listed in 'device' and 'preconsented_groups' sub-sections of 'app_policies' section
-- 			Connect device for the first time
-- 			Register app running on this device
--     2. Performed steps
-- 			Activate app: HMI->SDL: SDL.ActivateApp => Policies Manager treats the device as consented => no consent popup appears => SDL->HMI: SDL.ActivateApp(isSDLAllowed: true, params)
--
-- Requirement summary: 
--    [Policies] Treating the device as consented 
--
-- Expected result:
--     Policies Manager must treat the device as consented If "device" sub-section of "app_policies" has its group listed in "preconsented_groups".
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local Preconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:CloseConnection()
	self.mobileConnection:Close()
	commonTestCases:DelayedExp(3000)
		
end

Preconditions:BackupFile("sdl_preloaded_pt.json")

testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/DeviceGroupInPreconsented_preloadedPT.json")

function Test:ConnectDevice()
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

function Test:RegisterApplication()
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

commonFunctions:userPrint(34, "Test is intended to check condition for device to be consented")

function Test:TreatDeviceAsConsented()	
	local Input_AppId
	Input_AppId = self.applications[config.application1.registerAppInterfaceParams.appName]
	local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = Input_AppId}) --hmi side: sending SDL.ActivateApp 
	EXPECT_HMICALL("SDL.ActivateApp", {isSDLAllowed = true, config.deviceMAC})
	EXPECT_HMIRESPONSE(RequestId)
	EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
end

--[[ Postconditions ]]
commonFunctions:SDLForceStop()

testCasesForPolicyTable:Restore_preloaded_pt()