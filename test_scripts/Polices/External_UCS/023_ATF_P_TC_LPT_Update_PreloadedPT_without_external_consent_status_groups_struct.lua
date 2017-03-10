---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] External UCS: PreloadedPT without "external_consent_status_groups" struct
--
-- Description:
-- In case:
-- SDL uploads PreloadedPolicyTable without "external_consent_status_groups:
-- [<functional_grouping>: <Boolean>]" -> of "device_data" -> "<device identifier>"
-- -> "user_consent_records" -> "<app id>" section
-- SDL must:
-- a. consider this PreloadedPT as valid (with the pre-conditions of all other valid PreloadedPT content)
-- b. continue working as assigned.
--
-- Preconditions:
-- 1. Stop SDL (Ignition Off)
-- 2. Modify PreloadedPolicyTable (remove 'external_consent_status_groups' section)
-- 3. Initiate Local Policy Table update by setting 'preloaded_date' parameter
--
-- Steps:
-- 1. Start SDL (Ignition On)
-- 2. Check SDL status
--
-- Expected result:
-- Status = 0 (SDL is stopped)
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
local sdl = require('SDL')
local testCasesForExternalUCS = require('user_modules/shared_testcases/testCasesForExternalUCS')

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()
commonPreconditions:BackupFile("sdl_preloaded_pt.json")

--[[ General Settings for configuration ]]
Test = require("user_modules/connecttest_resumption")
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:CheckSDLStatus_1_RUNNING()
  testCasesForExternalUCS.checkSDLStatus(self, sdl.RUNNING)
end

function Test:ConnectMobile()
  self:connectMobile()
end

function Test:StartSession()
  testCasesForExternalUCS.startSession(self, 1)
end

function Test:RAI()
  testCasesForExternalUCS.registerApp(self, 1)
end

function Test:StopSDL_IGNITION_OFF()
  testCasesForExternalUCS.ignitionOff(self)
end

function Test:CheckSDLStatus_2_STOPPED()
  testCasesForExternalUCS.checkSDLStatus(self, sdl.STOPPED)
end

function Test.UpdatePreloadedPT()
  local updateFunc = function(preloadedTable)
    preloadedTable.policy_table.module_config.preloaded_date = os.date("%Y-%m-%d")
    preloadedTable.policy_table.device_data = {
      [config.deviceMAC] = {
        user_consent_records = {
          [config.application1.registerAppInterfaceParams.appID] = {
            external_consent_status_groups = nil
          }
        }
      }
    }
  end
  testCasesForExternalUCS.updatePreloadedPT(updateFunc)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test.StartSDL()
  StartSDL(config.pathToSDL, config.ExitOnCrash)
  os.execute("sleep 5")
end

function Test:CheckSDLStatus_3_RUNNING()
  testCasesForExternalUCS.checkSDLStatus(self, sdl.RUNNING)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.StopSDL()
  StopSDL()
end

function Test.RestorePreloadedFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end

return Test
