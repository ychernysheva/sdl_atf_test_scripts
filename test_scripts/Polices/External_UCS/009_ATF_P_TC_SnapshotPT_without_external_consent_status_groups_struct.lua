---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] External UCS: SnapshotPT without "external_consent_status_groups" param
--
-- Description:
-- In case:
-- SDL Policies database omits "external_consent_status_groups:
-- [<functional_grouping>: <Boolean>]” param-> in "device_data" -> "<device identifier>"
-- -> "user_consent_records" -> "<app id>" section,
-- and SDL is triggered to create a SnapshotPolicyTable
-- SDL must:
-- omit this "external_consent_status_groups: [<functional_grouping>: <Boolean>]” field
-- in the corresponding "<functional grouping>" -> in the SnapshotPolicyTable.
--
-- Preconditions:
-- 1. Start SDL (make sure 'external_consent_status_groups' section is omitted in PreloadedPT)
--
-- Steps:
-- 1. Register app
-- 2. Activate app
-- 3. Verify PTSnapshot
--
-- Expected result:
-- Section "external_consent_status_groups" is omitted
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
  config.defaultProtocolVersion = 2

--[[ Required Shared Libraries ]]
  local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
  local commonSteps = require('user_modules/shared_testcases/commonSteps')
  local testCasesForExternalUCS = require('user_modules/shared_testcases/testCasesForExternalUCS')

--[[ Local variables ]]
  local checkedSection = "external_consent_status_groups"

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
    testCasesForExternalUCS.activateApp(self, 1)
    testCasesForExternalUCS.policyUpdate(self, 1)
  end

  function Test:CheckPTS()
    local s = testCasesForExternalUCS.pts.policy_table.device_data[config.deviceMAC]
      .user_consent_records.device[checkedSection]
    if s ~= nil then
      self:FailTestCase("Section '" .. checkedSection .. "' was found in PTS")
    else
      print("Section '".. checkedSection .. "' doesn't exist in PTS")
      print(" => OK")
    end
  end

--[[ Postconditions ]]
  commonFunctions:newTestCasesGroup("Postconditions")

  function Test.StopSDL()
    StopSDL()
  end

return Test
