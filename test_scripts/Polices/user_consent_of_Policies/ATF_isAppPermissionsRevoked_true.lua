---------------------------------------------------------------------------------------------
-- Description: 
--     SDL receives request for app activation from HMI and LocalPT contains revoked permission for the named application
--     1. Used preconditions:
--			Delete SDL log file and policy table
--			Close current connection
--			Make backup copy of preloaded PT
--			Overwrite preloaded PT adding list of groups for specific app
--			Connect device
--			Register app
--   		Revoke app group by PTU
-- 			
--     2. Performed steps
-- 			Activate app
--
-- Requirement summary: 
--    [Policies] SDL.ActivateApp from HMI and 'isAppPermissionsRevoked' parameter in the response
--
-- Expected result:
--      PoliciesManager must respond with "isAppPermissionRevoked:true" and "AppRevokedPermissions" param containing the list of revoked permissions to HMI
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
testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/GroupsForApp_preloaded_pt.json")

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

function Test:RegisterApp1()
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

function Test:PTU_revoke_app_group()
	local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
	EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
	:Do(function()
		self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
			{
				requestType = "PROPRIETARY",
				fileName = "filename"
			}
		)
		EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
		:Do(function()
			local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
				{
					fileName = "PolicyTableUpdate",
					requestType = "PROPRIETARY"
				}, "files/PTU_AppRevokedGroup.json")
			local systemRequestId
			EXPECT_HMICALL("BasicCommunication.SystemRequest")
			:Do(function(_,data)
				systemRequestId = data.id
				self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
				{
					policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
			})
		local function to_run()
			self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
		end			
		RUN_AFTER(to_run, 500)
		end)
		EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged", {appID = self.HMIAppID, isAppPermissionsRevoked = true,  appRevokedPermissions = {"Navigation-1"}})
		:Do(function()
			local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", { appID = self.HMIAppID })
			EXPECT_HMIRESPONSE(RequestIdListOfPermissions)
			:Do(function()
				local ReqIDGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"Navigation-1"}})
				EXPECT_HMIRESPONSE(ReqIDGetUserFriendlyMessage, { result = { code = 0, messages = {{ messageCode = "Navigation-1"}}, method = "SDL.GetUserFriendlyMessage"}})
			end)
			self.mobileSession:ExpectResponse(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
			end)
		end)
	end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
commonFunctions:userPrint(34, "Test is intended to check that Policies Manager responds isAppPermissionRevoked:true for revoked app permissions")

function Test:Activate_app_isAppPermissionRevoked_true()
	local RequestIdActivateAppAgain = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID })
	EXPECT_HMIRESPONSE(RequestIdActivateAppAgain, { result = { code = 0, method = "SDL.ActivateApp", isAppPermissionsRevoked = true, isAppRevoked = false, priority = "NONE"}})
	:Do(function(_,data)
		if data.result.isAppPermissionRevoked ~= true then
			commonFunctions:userPrint(31, "Wrong SDL behavior: isAppPermissionRevoked should be false for app with revoked group")	
			return false
		else
		    commonFunctions:userPrint(33, "isAppPermissionRevoked is true for app with revoked group - expected behavior")	
		end	
	end)	
end

--[[ Postconditions ]]
commonFunctions:SDLForceStop()
testCasesForPolicyTable:Restore_preloaded_pt()