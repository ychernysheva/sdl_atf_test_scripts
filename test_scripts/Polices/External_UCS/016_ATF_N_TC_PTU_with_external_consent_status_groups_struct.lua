---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] External UCS: PTU with "external_consent_status_groups" struct
--
-- Description:
-- In case:
-- SDL receives PolicyTableUpdate with "external_consent_status_groups:
-- [<functional_grouping>: <Boolean>]” -> of "device_data" -> "<device identifier>"
-- -> "user_consent_records" -> "<app id>" section
-- SDL must:
-- a. consider this PTU as invalid
-- b. do not merge this invalid PTU to LocalPT.
--
-- Preconditions:
-- 1. Modify PreloadedPT by adding 'disallowed_by_external_consent_entities_on' section
--
-- Steps:
-- 1. Register app
-- 2. Send SDL.OnAppPermissionConsent (change ON -> OFF)
-- 3. Activate app
-- 4. Perform PTU
-- 5. Verify status of update
--
-- Expected result:
-- PTU fails with UPDATE_NEEDED status
--
-- Note: Script is designed for EXTERNAL_PROPRIETARY flow
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.defaultProtocolVersion = 2

--[[ Required Shared Libraries ]]
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local json = require("modules/json")
local testCasesForExternalUCS = require('user_modules/shared_testcases/testCasesForExternalUCS')

--[[ Local variables ]]
local appId = config.application1.registerAppInterfaceParams.appID
local grpId = "Location-1"
local checkedStatus = "UPDATE_NEEDED"

--[[ Local Functions ]]
local function replaceSDLPreloadedPtFile()
  local preloadedFile = commonPreconditions:GetPathToSDL() ..
  commonFunctions:read_parameter_from_smart_device_link_ini("PreloadedPT")
  local preloadedTable = testCasesForExternalUCS.createTableFromJsonFile(preloadedFile)
  preloadedTable.policy_table.functional_groupings["DataConsent-2"].rpcs = json.null
  --
  preloadedTable.policy_table.app_policies[appId] = {
    default_hmi = "NONE",
    keep_context = false,
    priority = "NONE",
    steal_focus = false,
    groups = {
      "Base-4", grpId
    }
  }
  preloadedTable.policy_table.functional_groupings[grpId].disallowed_by_external_consent_entities_on = {
    {
      entityID = 128,
      entityType = 0
    }
  }
  testCasesForExternalUCS.createJsonFileFromTable(preloadedTable, preloadedFile)
end

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()
commonPreconditions:BackupFile("sdl_preloaded_pt.json")
replaceSDLPreloadedPtFile()
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

function Test:SendExternalConsent()
  self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent", { source = "GUI",
      externalConsentStatus = {
        { entityType = 0, entityID = 128, status = "OFF" }
    } })
end

function Test:ActivateApp()
  testCasesForExternalUCS.activateApp(self, 1, checkedStatus)
end

function Test:CheckStatus_UPDATE_NEEDED()
  local reqId = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")
  EXPECT_HMIRESPONSE(reqId, { status = checkedStatus })
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.StopSDL()
  StopSDL()
end

function Test.Postcondition_RestorePreloadedFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end

return Test
