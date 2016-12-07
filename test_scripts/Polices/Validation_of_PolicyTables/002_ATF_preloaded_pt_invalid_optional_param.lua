---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PreloadedPT] At least one optional param has invalid type
--
-- Description:
-- Behavior of SDL during start SDL with Preloaded PT file with one optional parameter that has invalid type
-- 1. Used preconditions:
-- Delete files and policy table from previous ignition cycle if any
-- Do not start default SDL
-- 2. Performed steps:
-- Create PreloadedPolicyTable file with one optional parameter that has invalid type
-- Start SDL
--
-- Expected result:
-- PolicyManager shut SDL down
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
Test = require('connecttest')
local config = require('config')
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForPolicySDLErrorsStops = require('user_modules/shared_testcases/testCasesForPolicySDLErrorsStops')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Precondition_StopSDL()
  StopSDL(self)
end

testCasesForPolicyTable:Backup_preloaded_pt()

function Test:Precondition()
  commonSteps:DeletePolicyTable(self)
  testCasesForPolicySDLErrorsStops.updatePreloadedPT("data.policy_table.module_config", {certificate = {"HGLJGBB5570BJ89"}})
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:StartSdl()
  StartSDL(config.pathToSDL, false, self)
end

function Test:TestStep_checkSdlShutdown()
  local result = testCasesForPolicySDLErrorsStops:CheckSDLShutdown(self)
  if (result == true) then
    self:FailTestCase("Error: SDL should stop.")
  else
    print("SDL is running with required parameter with invalid type in preloaded_pt.json")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

testCasesForPolicyTable:Restore_preloaded_pt()

function Test:Postconditions_StopSDL()
  StopSDL(self)
end

return Test
