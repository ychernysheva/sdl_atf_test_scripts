---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [GeneralResultCodes] INVALID_DATA wrong characters
-- [Mobile API] PerformAudioPassThru request/response
-- [HMI_API] [MOBILE_API] The "audioPassThruIcon" param at "ImageFieldName" struct
--
-- Description:
-- In case the request comes with 'whitespace'-as-the-only-symbol(s) 
-- at any "String" type parameter in the request structure, SDL must respond with resultCode 
-- "INVALID_DATA" and success:"false" value.
--
-- 1. Used preconditions
-- 1.1. Request is sent with audioPassThruIcon that contains only whitespaces in value 
-- and is with type STATIC, all other params used in PerformAudioPassThru_request 
-- are present and within bounds 
--
-- 2. Performed steps
-- Send PerformAudioPassThru (audioPassThruIcon contains only whitespaces, other params) from mobile to SDL and check:
--
-- Expected result:
-- SDL sends PerformAudioPassThru (IVALID_DATA, success:false) to mobile app

---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonPostconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPerformAudioPassThru = require('user_modules/shared_testcases/testCasesForPerformAudioPassThru')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
config.defaultProtocolVersion = 2

testCasesForPolicyTable:precondition_updatePolicy_AllowFunctionInHmiLeves({"BACKGROUND", "FULL", "LIMITED"},"PerformAudioPassThru")

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

commonSteps:PutFile("Precondition_PutFile_With_Icon", "icon.png")

function Test:Precondition_Check_audioPassThruIcon_Existence()
  testCasesForPerformAudioPassThru.Check_audioPassThruIcon_Existence(self, "icon.png")
end

function Test:Precondition_ActivateApp()
  testCasesForPerformAudioPassThru:ActivateAppDiffPolicyFlag(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_All_Params_audioPassThruIcon_Whitespaces_STATIC()
  local CorIdPerformAudioPassThruAppParVD= self.mobileSession:SendRPC("PerformAudioPassThru",
    {
      initialPrompt = {{text = "Makeyourchoice",type = "TEXT"}},
      audioPassThruDisplayText1 = "DisplayText1",
      audioPassThruDisplayText2 = "DisplayText2",
      samplingRate = "16KHZ",
      maxDuration = 2000,
      bitsPerSample = "8_BIT",
      audioType = "PCM",
      muteAudio = true, 
      audioPassThruIcon =
      { 
        value = "       ",
        imageType = "STATIC"
      }      
    })

  EXPECT_HMICALL("TTS.Speak"):Times(0)

  EXPECT_HMICALL("UI.PerformAudioPassThru"):Times(0)
  
  self.mobileSession:ExpectResponse(CorIdPerformAudioPassThruAppParVD, {success = false, resultCode = "INVALID_DATA"})
  commonTestCases:DelayedExp(10000)
  EXPECT_NOTIFICATION("OnHashChange"):Times(0)

end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_Restore_preloaded_pt_File()
  commonPostconditions:RestoreFile("sdl_preloaded_pt.json")
end

function Test.Postcondition_Stop_SDL()
  StopSDL()
end

return Test