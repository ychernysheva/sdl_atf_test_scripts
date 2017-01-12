---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PerformAudioPassThru] SDL must transfer request to HMI in case of valid "audioPassThruIcon" param
-- [HMI API] UI.PerformAudioPassThru request/response
-- [HMI API] TTS.Speak request/response
-- [Mobile API] PerformAudioPassThru request/response
-- [HMI_API] [MOBILE_API] The "audioPassThruIcon" param at "ImageFieldName" struct
--
-- Description:
-- In case mobile app sends PerformAudioPassThru_request to SDL with:
-- valid <audioPassThruIcon> parameter
-- and the requested <audioPassThruIcon> exists at app`s sandbox (see AppStorageFolder section)
-- as well as another related to request valid mandatory params
-- SDL must transfer UI.PerformAudioPassThru (<audioPassThruIcon>, other params)_request + Speak_request (depends on parameters provided by the app) to HMI
--1. Used preconditions
--1.1 All parameters are present and within bounds speech capabilities is sent with type = "PRE_RECORDED"
--1.2. AudioPassThruIcon exists at apps sub-directory of AppStorageFolder (value from ini file)
--2. Performed steps
-- Send PerformAudioPassThru (audioPassThruIcon, other params, ttsChunksType = "PRE_RECORDED") from mobile to SDL and check:
--2.1 SDL sends UI.PerformAudioPassThru (audioPassThruIcon, other params, ttsChunksType = "PRE_RECORDED") to HMI
--2.2 SDL sends TTS.Speak to HMI
--2.3 HMI sends UI.PerformAudioPassThru (SUCCESS) to SDL
--2.4 HMI sends TTS.Speak (UNSUPPORTED_RESOURCE) to SDL
-- Expected result:
-- SDL sends PerformAudioPassThru (WARNINGS) to mobile app

---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForPerformAudioPassThru = require('user_modules/shared_testcases/testCasesForPerformAudioPassThru')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable ()
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

commonSteps:PutFile("Precondition_PutFile_With_Icon","icon.png")

function Test:Precondition_Check_audioPassThruIcon_Existence()
  testCasesForPerformAudioPassThru:Check_audioPassThruIcon_Existence(self)
end

function Test:Precondition_ActivateApp()
  testCasesForPerformAudioPassThru:ActivateAppDiffPolicyFlag
  (self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:TestStep_PerformAudioPassThru_PRE_RECORDED_WARNINGS()
  testCasesForPerformAudioPassThru:PerformAudioPassThru_Diff_Speech_Capabilities (self, "PRE_RECORDED")
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_Stop_SDL()
  StopSDL()
end

return Test
