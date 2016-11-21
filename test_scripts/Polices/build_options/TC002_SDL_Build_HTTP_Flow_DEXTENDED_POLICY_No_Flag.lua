---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] Support of "http" flow of Policy Table Update
--
-- Description:
-- SDL should be successfully built with empty flag "EXTENDED_POLICY:"
-- 1. Performed steps
-- Build SDL
--
-- Expected result:
-- SDL is successfully built
-- The flag EXTENDED_POLICY: has no value set
-- PTU passes successfully
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY","")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","")

--TODO(mmihaylova-banska): Should be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
--TODO(mmihaylova-banska): Function still not implemented
function Test:TestStep_HTTP_Flow_AfterBuild ()
  testCasesForPolicyTable:flow_PTU_SUCCEESS_EXTERNAL_HTTP (self)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test:Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop(self)
end

return Test
