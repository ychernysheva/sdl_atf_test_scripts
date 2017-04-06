---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [UI Interface] SDL behavior in case HMI does not respond to UI.IsReady_request
-- [HMI_API] UI.IsReady
-- [MOBILE_API] SetAudioStreamingIndicator
-- [HMI_API] [MOBILE_API] AudioStreamingIndicator enum
-- [HMI_API] SetAudioStreamingIndicator
--
-- Description:
-- In case SDL does NOT receive UI.IsReady_response during <DefaultTimeout> from HMI
-- and mobile app sends SetAudioStreamingIndicator (any single UI-related RPC)
-- SDL must:
-- transfer this UI-related RPC to HMI
-- respond with <received_resultCode_from_HMI> to mobile app
--
-- 1. Used preconditions
-- structure hmi_result_code with HMI result codes, success = false
-- Allow SetAudioStreamingIndicator by policy
-- In InitHMI_OnReady HMI does not reply to UI.Isready
-- Register and activate media application.
--
-- 2. Performed steps
-- Send SetAudioStreamingIndicator(audioStreamingIndicator = "PAUSE")
-- HMI->SDL: UI.SetAudioStreamingIndicator(resultcode: hmi_result_code, info = "error message")
--
-- Expected result:
-- SDL->HMI: UI.SetAudioStreamingIndicator(audioStreamingIndicator = "PAUSE")
-- SDL->mobile: SetAudioStreamingIndicator_response(hmi_result_code, success:false, info = "error message")
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.application1.registerAppInterfaceParams.appHMIType = {"MEDIA"}
config.application1.registerAppInterfaceParams.isMediaApplication = true

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForUI_IsReady = require('user_modules/IsReady_Template/testCasesForUI_IsReady')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local mobile_session = require('mobile_session')


--[[ Local variables ]]
local hmi_result_code = {
	{ result_code = "UNSUPPORTED_REQUEST"},
	{ result_code = "DISALLOWED"},
	{ result_code = "USER_DISALLOWED"},
	{ result_code = "REJECTED"},
	{ result_code = "ABORTED"},
	{ result_code = "IGNORED"},
	{ result_code = "IN_USE"},
	--TODO(istoimenova): update when "Must SDL resend HMI resultCode hmi_apis::Common_Result::DATA_NOT_AVAILABLE to mobile app" is resolved
	--{ result_code = "VEHICLE_DATA_NOT_AVAILABLE"},
	{ result_code = "TIMED_OUT"},
	{ result_code = "INVALID_DATA"},
	{ result_code = "CHAR_LIMIT_EXCEEDED"},
	{ result_code = "INVALID_ID"},
	{ result_code = "DUPLICATE_NAME"},
	{ result_code = "APPLICATION_NOT_REGISTERED"},
	{ result_code = "OUT_OF_MEMORY"},
	{ result_code = "TOO_MANY_PENDING_REQUESTS"},
	{ result_code = "GENERIC_ERROR"},
	{ result_code = "TRUNCATED_DATA"}
}

--[[ General Precondition before ATF start ]]
testCasesForPolicyTable:precondition_updatePolicy_AllowFunctionInHmiLeves({"BACKGROUND", "FULL", "LIMITED"}, "SetAudioStreamingIndicator")
commonSteps:DeleteLogsFiles()

--TODO(istoimenova): shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_initHMI')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_InitHMI_OnReady()
	testCasesForUI_IsReady.InitHMI_onReady_without_UI_IsReady(self, 1)
	EXPECT_HMICALL("UI.IsReady")
	-- Do not send HMI response of UI.IsReady
end

function Test:Precondition_connectMobile()
	self:connectMobile()
end

function Test:Precondition_StartSession()
	self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
	self.mobileSession:StartService(7)
end

commonSteps:RegisterAppInterface("Precondition_RegisterAppInterface")

function Test:Precondition_ActivateApp()
  commonSteps:ActivateAppInSpecificLevel(self, self.applications[config.application1.registerAppInterfaceParams.appName])
  EXPECT_NOTIFICATION("OnHMIStatus", {systemContext = "MAIN", hmiLevel = "FULL"})
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

for i = 1, #hmi_result_code do
	Test["TestStep_SetAudioStreamingIndicator_"..hmi_result_code[i].result_code.."_audioStreamingIndicator_PAUSE"] = function(self)
	  local corr_id = self.mobileSession:SendRPC("SetAudioStreamingIndicator", { audioStreamingIndicator = "PAUSE" })

	  EXPECT_HMICALL("UI.SetAudioStreamingIndicator", { audioStreamingIndicator = "PAUSE" })
	  :Do(function(_,data)
			--TODO (istoimenova): If should be removed when "[ATF] ATF doesn't process code of HMI response VEHICLE_DATA_NOT_AVAILABLE in error message." is fixed.
	  	if(hmi_result_code[i].result_code == "VEHICLE_DATA_NOT_AVAILABLE") then 
	  		self.hmiConnection:Send('{"error":{"data":{"method":"UI.SetAudioStreamingIndicator"},"message":"error message","code":9},"jsonrpc":"2.0","id":'..tostring(data.id)..'}')
	  	else
	  		self.hmiConnection:SendError(data.id, data.method, hmi_result_code[i].result_code, "error message") 
	  	end
	  end)

	  EXPECT_RESPONSE(corr_id, { success = false, resultCode = hmi_result_code[i].result_code, info = "error message" })
	  EXPECT_NOTIFICATION("OnHashChange",{}):Times(0)
	end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_Restore_preloaded_pt()
	commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end

function Test.Postcondition_Stop()
  StopSDL()
end

return Test