--UNREADY
-- it is not clear how to implement SELECT on local PT

---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies]: User consent storage in LocalPT (OnAppPermissionConsent without appID)
-- [HMI API] OnAppPermissionConsent notification
--
-- Description:
-- 1. Used preconditions: 
--   SDL and HMI are running
--   <Device> is connected to SDL and consented by the User, <App> is running on that device.
--   <App> is registered with SDL and is present in HMI list of registered aps.
--   Local PT has permissions for <App> that require User`s consent
-- 2. Performed steps: Activate App
--
-- Expected result:
--   1. HMI->SDL: SDL.ActivateApp {appID}
--   2. SDL->HMI: SDL.ActivateApp_response{isPermissionsConsentNeeded: true, params}
--   3. HMI->SDL: GetUserFriendlyMessage{params},
--   4. SDL->HMI: GetUserFriendlyMessage_response{params}
--   5. HMI->SDL: GetListOfPermissions{appID}
--   6. SDL->HMI: GetListOfPermissions_response{}
--   7. HMI: display the 'app permissions consent' message.
--   8. The User allows or disallows definite permissions.
--   9. HMI->SDL: OnAppPermissionConsent {params}
--   10. PoliciesManager: update "<appID>" subsection of "user_consent_records" subsection of "<device_identifier>" section of "device_data" section in Local PT
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
 
--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ Local Functions ]]
-- local function getFunctionGroupsName()  
--   local sql_select = "sqlite3 " .. tostring(SDLStoragePath) .. "policy.sqlite \"SELECT functional_group.name FROM app_group JOIN functional_group ON app_group.functional_group_id = functional_group.id WHERE app_group.application_id in ('0000001', '0000002')\""
--     local handle = assert( io.popen( sql_select , 'r'))
--     sql_output = handle:read( '*l' )   
--     local ret_value = tonumber(sql_output)    
--     if (ret_value == nil) then
--        commonTestCases:FailTestCase("device id can't be read")
--     else 
--       return ret_value
--     end
-- end

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY", "EXTERNAL_PROPRIETARY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","EXTERNAL_PROPRIETARY")
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_CloseConnection()
  self.mobileConnection:Close()
  commonTestCases:DelayedExp(3000)	
end

commonPreconditions:BackupFile("sdl_preloaded_pt.json")

testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/PTU_ForOnAppPermissionConsent.json")

function Test:Precondition_ConnectDevice()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
	{deviceList = {
					{
					 id = config.deviceMAC,
					 isSDLAllowed = true,
					 name = "127.0.0.1",
					 transportType = "WIFI"
					}
				   }})
    :Do(function(_,data)
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

function Test:TestStep_User_consent_on_activate_app()
  local request_id_activate_app = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID})
  EXPECT_HMIRESPONSE(request_id_activate_app, {result= {code = 0, method = "SDL.ActivateApp", isPermissionsConsentNeeded = true, isSDLAllowed = true, priority = "NONE"}})
  :Do(function(_,data)
    if data.result.isPermissionsConsentNeeded == true then
	  local request_id_list_of_permissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", { appID = self.HMIAppID })
	  -- ToDo(VVVakulenko): update after resolving APPLINK-16094
	  --EXPECT_HMIRESPONSE(request_id_list_of_permissions,{result = {code = 0, method = "SDL.GetListOfPermissions", allowedFunctions = {{name = "Base-4"}, {name = "DrivingCharacteristics-3"}}}})
	  EXPECT_HMIRESPONSE(request_id_list_of_permissions)
	  :Do(function()
	    local request_id_get_user_friendly_message = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"allowedFunctions"}})
		EXPECT_HMIRESPONSE(request_id_get_user_friendly_message)
		:Do(function(_,_)
		  self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent", {appID =  self.applications["Test Application"], consentedFunctions = {{ allowed = true, name = "DrivingCharacteristics-3"}}, source = "GUI"})		
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

function Test.TestStep_check_LocalPT_for_updates()
   return true
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end

function Test.Postcondition_Restore_PreloadedPT()
  testCasesForPolicyTable:Restore_preloaded_pt()
end

return Test