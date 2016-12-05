-- UNREADY:
--Test:TestStep_PoliciesManager_changes_UP_TO_DATE
--should be applicable for PROPRIETARY flag as well
--function testCasesForPolicyTable.flow_PTU_SUCCEESS_PROPRIETARY should be added to testCasesForPolicyTable

---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] OnStatusUpdate trigger
-- c) UP_TO_DATE VC
-- [HMI API] OnStatusUpdate
-- [HMI API] OnReceivedPolicyUpdate notification
--
-- Description:
--PoliciesManager must change the status to “UP_TO_DATE” and notify HMI with
--OnStatusUpdate("UP_TO_DATE") right after successful validation of received PTU .
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: PROPRIETARY" flag
-- Application is registered.
-- PTU is requested.
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- SDL->HMI:SDL.PolicyUpdate(file, timeout, retry[])
-- HMI -> SDL: SDL.GetURLs (<service>)
-- HMI->SDL: BasicCommunication.OnSystemRequest ('url', requestType:PROPRIETARY)
-- SDL->app: OnSystemRequest ('url', requestType:PROPRIETARY, fileType="JSON")
-- app->SDL: SystemRequest(requestType=PROPRIETARY)
-- SDL->HMI: SystemRequest(requestType=PROPRIETARY, fileName)
-- HMI->SDL: SystemRequest(SUCCESS)
-- 2. Performed steps
-- HMI->SDL: OnReceivedPolicyUpdate(policy_file) according to data dictionary
--
-- Expected result:
-- SDL->HMI: OnStatusUpdate(UP_TO_DATE)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_PoliciesManager_changes_UP_TO_DATE()
  testCasesForPolicyTable:flow_PTU_SUCCEESS_PROPRIETARY(self)

  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {}):Times(0)
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate",{}):Times(0)
  commonTestCases:DelayedExp(60*1000)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
Test["StopSDL"] = function()
  StopSDL()
end
