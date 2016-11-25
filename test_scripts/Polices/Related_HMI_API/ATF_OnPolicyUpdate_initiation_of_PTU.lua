---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies]: SDL.OnPolicyUpdate initiation of PTU
-- [HMI API] SDL.OnPolicyUpdate notification 
--
-- Description:
-- 1. Used preconditions: SDL and HMI are running, Device connected to SDL is consented by the User, App is running on this device, and registerd on SDL
-- 2. Performed steps: HMI->SDL: SDL.OnPolicyUpdate
--
-- Expected result:
-- SDL->HMI: BasicCommunication.PolicyUpdate
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
 
--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForPolicyTableSnapshot = require ('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')
local policyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY", "EXTERNAL_PROPRIETARY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","EXTERNAL_PROPRIETARY")
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

--ToDo(VVVakulenko): shall be substitiuted to StopSDL when issue: "SDL doesn't stop at execution ATF function StopSDL()" is fixed
function Test.Precondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end
  
function Test.Precondition_StartSDL()
  StartSDL(config.pathToSDL, config.ExitOnCrash)
end

function Test:Precondtion_initHMI()
  self:initHMI()
end

function Test:Precondtion_initHMI_onReady()
  self:initHMI_onReady()
end

function Test:Precondtion_initHMI_onReady()
  self:connectMobile()
end

function Test:Precondtion_CreateSession()
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
end

function Test:Precondition_Activate_and_Consent_App()
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

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test.TestStep_Send_OnPolicyUpdate_from_HMI()
self.hmiConnection:SendNotification("SDL.OnPolicyUpdate",{})
EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
 :Do(function(_,data)
    local hmi_appId = data.params.application.appID
      testCasesForPolicyTableSnapshot:create_PTS(true, {
        config.application.registerAppInterfaceParams.appID,
        },
        {config.deviceMAC},
        {hmi_appId}
      )

    local timeout_after_x_seconds = testCasesForPolicyTableSnapshot:get_data_from_PTS("timeout_after_x_seconds")
    local seconds_between_retry = testCasesForPolicyTableSnapshot:get_data_from_PTS("seconds_between_retry")
      EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
        {
          file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate",
          timeout = timeout_after_x_seconds,
          retry = seconds_between_retry
        })
      :Do(function(_,data)
          self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
       end)
	local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
	EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
	:Do(function(_,data)
       self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
end

--[[ Postconditions ]]
--commonFunctions:newTestCasesGroup("Postconditions")

function Test:Postcondition_Force_Stop_SDL()
  commonFunctions:SDLForceStop(self)
end

function Test:Postcondition_restore_preloaded()
  policyTable:Restore_preloaded_pt(self)
end

return Test