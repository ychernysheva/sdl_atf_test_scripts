-- UNREADY: 
--function flow_PTU_SUCCEESS_HTTP - needs to be added to testCasesForPolicyTable
--function Test.TestStep_MergePTU - should merge PTU with Local PT
--function Test.TestStep_CheckDefaultSection - should check that "default section" was updated and 
--reassign updated "default (456) policies" from Policies Manger to application
---------------------------------------------------------------------------------------------
-- Requirement summary:
-- SDL must re-assign "default" policies to app in case "default" 
--policies was updated via PolicyTable update
--
-- Description:
-- PoliciesManager must: re-assign updated "default" policies to this app
-- In case Policies Manager assigns the "default" policies to app AND the value of "default" policies was updated in case of PolicyTable update
-- 1. Used preconditions:
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- <default> (123) section is available in PT.
-- 2. Performed steps:
-- Send RegisterAppInterface(params) from mobile to SDL
-- Registration is succesful and appID_1 is assigned to app.
-- Default (123) policies also assigned.
-- SDL sends SUCCESS:RegisterAppInterface to mobile for this app_ID.
-- SDL sends to HMI OnAppRegistered. 
-- PTU is triggered and Policy Table Snapshot is created.
-- SDL sends to SDL sends to mobile BC.OnSystemRequest
-- Mobile app gets updated PT from backend and sends SystemRequest to SDL
-- SDL sends to mobile app SUCCESS:SystemRequest 
-- Expected result:
-- PTU validation is successful and it is merged with Local PT
-- SDL checks the values of "default" section that is now updated to (456)
-- Polcy Manager reassigns the updated "default" (456) policies to mobile app
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--ToDo: Should be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_SUCCESSFUL_PTU()
  testCasesForPolicyTable:flow_PTU_SUCCEESS_HTTP(self)
end

function Test.TestStep_MergePTU ()
  return false
end 

function Test.TestStep_CheckDefaultSection ()
  return false
end 


--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Stop()
  StopSDL()
end

return Test