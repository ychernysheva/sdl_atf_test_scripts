---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [UI Interface] Conditions for SDL to respond 'UNSUPPORTED_RESOURCE, success:false' to mobile app
-- [HMI_API] UI.IsReady
-- [MOBILE_API] SetAudioStreamingIndicator
-- [HMI_API] [MOBILE_API] AudioStreamingIndicator enum
--
-- Description:
-- In case SDL receives UI.IsReady (<successfull_resultCode>, available=false) from HMI
-- and mobile app sends SetAudioStreamingIndicator (any single UI-related RPC)
-- SDL must:
-- respond "UNSUPPORTED_RESOURCE, success=false, info: UI is not supported by system" to mobile app
-- SDL must NOT transfer this UI-related RPC to HMI
--
-- 1. Used preconditions
-- Allow SetAudioStreamingIndicator by policy
-- In InitHMI_OnReady HMI replies to UI.Isready with available = false
-- Register and activate media application.
--
-- 2. Performed steps
-- Send SetAudioStreamingIndicator(audioStreamingIndicator = "PAUSE")
--
-- Expected result:
-- SDL->mob: SetAudioStreamingIndicator(success = false, resultCode = "UNSUPPORTED_RESOURCE", info =  "UI is not supported by system")
-- SDL should not send UI.SetAudioStreamingIndicator
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
	--testCasesForRAI.InitHMI_onReady_without_UI_GetCapabilities(self)
	testCasesForUI_IsReady.InitHMI_onReady_without_UI_IsReady(self, 0)
	EXPECT_HMICALL("UI.IsReady")
	:Do(function(_,data)
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { available = false })
	end)
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
  EXPECT_NOTIFICATION("OnHMIStatus", {systemContext = "MAIN", hmiLevel = "FULL", audible = ""})
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_SetAudioStreamingIndicator_UI_IsReady_available_false ()
  local corr_id = self.mobileSession:SendRPC("SetAudioStreamingIndicator", { audioStreamingIndicator = "PAUSE" })

	EXPECT_RESPONSE(corr_id, {success = false, resultCode = "UNSUPPORTED_RESOURCE", info =  "UI is not supported by system"})
	EXPECT_HMICALL("UI.SetAudioStreamingIndicator", {}):Times(0)
	EXPECT_NOTIFICATION("OnHashChange",{}):Times(0)
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