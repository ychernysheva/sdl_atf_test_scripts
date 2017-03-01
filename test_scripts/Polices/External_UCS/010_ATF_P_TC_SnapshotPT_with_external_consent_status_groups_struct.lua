---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] External UCS: SnapshotPT without "external_consent_status_groups" param
--
-- Description:
-- In case:
-- SDL Policies database contains "external_consent_status_groups:
-- [<functional_grouping>: <Boolean>]” param-> in "device_data" -> "<device identifier>"
-- -> "user_consent_records" -> "<app id>" section,
-- and SDL is triggered to create a SnapshotPolicyTable
-- SDL must:
-- add this "external_consent_status_groups: [<functional_grouping>: <Boolean>]” field
-- in the corresponding "appID" section -> in the SnapshotPolicyTable.
--
-- Preconditions:
-- 1. Modify PreloadedPT by adding 'disallowed_by_external_consent_entities_on' section
--
-- Steps:
-- 1. Register app
-- 2. Send SDL.OnAppPermissionConsent (change ON -> OFF)
-- 3. Activate app
-- 4. Verify PTSnapshot
--
-- Expected result:
-- Section "external_consent_status_groups" is added for app section
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
  local checkedSection = "external_consent_status_groups"

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
    testCasesForExternalUCS.activateApp(self, 1)
    testCasesForExternalUCS.policyUpdate(self, 1)
  end

  function Test:CheckPTS()
    local s = testCasesForExternalUCS.pts.policy_table.device_data[config.deviceMAC]
      .user_consent_records[appId][checkedSection]
    if s == nil then
      self:FailTestCase("Section '" .. checkedSection .. "' was not found in PTS")
    else
      print("Section '".. checkedSection .. "' exists in PTS")
      print(" => OK")
    end
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
