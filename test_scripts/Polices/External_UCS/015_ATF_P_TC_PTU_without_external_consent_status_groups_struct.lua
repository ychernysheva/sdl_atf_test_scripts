---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] External UCS: PTU without "external_consent_status_groups" struct
--
-- Description:
-- In case:
-- SDL receives PolicyTableUpdate without "external_consent_status_groups:
-- [<functional_grouping>: <Boolean>]” -> of "device_data" -> "<device identifier>"
-- -> "user_consent_records" -> "<app id>" section
-- SDL must:
-- a. consider this PTU as valid (with the pre-conditions of all other valid PTU content)
-- b. do not create this "external_consent_status_groups" field of the corresponding "appID" section
-- in the Policies database.
--
-- Preconditions:
-- 1. Start SDL (make sure 'external_consent_status_groups' section is omitted in PreloadedPT)
--
-- Steps:
-- 1. Register app
-- 2. Activate app
-- 3. Perform PTU
-- 4. Verify status of update
--
-- Expected result:
-- PTU finished successfully with UP_TO_DATE status
--
-- Note: Script is designed for EXTERNAL_PROPRIETARY flow
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.defaultProtocolVersion = 2

--[[ Required Shared Libraries ]]
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForExternalUCS = require('user_modules/shared_testcases/testCasesForExternalUCS')

--[[ Local variables ]]
local checkedStatus = "UP_TO_DATE"

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()
testCasesForExternalUCS.removePTS()

--[[ General Settings for configuration ]]
Test = require("user_modules/connecttest_resumption")
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:ConnectMobile()
  self:connectMobile()
end

function Test:StartSession()
  testCasesForExternalUCS.startSession(self, 1)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:RAI()
  testCasesForExternalUCS.registerApp(self, 1)
end

function Test:ActivateApp()
  testCasesForExternalUCS.activateApp(self, 1, checkedStatus)
end

function Test:CheckStatus_UP_TO_DATE()
  local reqId = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")
  EXPECT_HMIRESPONSE(reqId, { status = checkedStatus })
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.StopSDL()
  StopSDL()
end

return Test
