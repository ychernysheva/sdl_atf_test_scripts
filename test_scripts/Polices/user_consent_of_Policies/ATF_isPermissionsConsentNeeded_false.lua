---------------------------------------------------------------------------------------------
-- Requirement summary: 
--    [Policies] SDL.ActivateApp from HMI and 'isPermissionsConsentNeeded' parameter in the response
--
-- Description: 
--     SDL receives request for app activation from HMI and LocalPT contains permission that don't require User`s consent
--     1. Used preconditions:
--		Delete SDL log file and policy table
-- 			
--     2. Performed steps
-- 		Activate with default permissions
--
-- Expected result:
--      On receiving SDL.ActivateApp PoliciesManager must respond with "isPermissionsConsentNeeded:false" to HMI, consent for custom permissions is not appeared
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:IsPermissionsConsentNeeded_false_on_app_activation()
	local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})
	EXPECT_HMIRESPONSE(RequestId,{ result = { code = 0, method = "SDL.ActivateApp", isPermissionsConsentNeeded = false, isSDLAllowed = true, priority ="NONE" }})
	:Do(function(_,data)
		if data.result.isPermissionsConsentNeeded ~= false then
			commonFunctions:userPrint(31, "Wrong SDL behavior: isPermissionsConsentNeeded should be false for app with default permissions")
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
