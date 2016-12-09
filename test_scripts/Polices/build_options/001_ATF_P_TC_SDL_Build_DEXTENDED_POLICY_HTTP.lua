---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [GENIVI] [Policy] "HTTP" flow: SDL must be build with "-DEXTENDED_POLICY: HTTP"
--
-- Description:
-- To "switch on" the "HTTP" flow of PolicyTableUpdate feature
-- -> SDL should be built with _-DEXTENDED_POLICY: HTTP flag
-- 1. Performed steps
-- Build SDL with flag above
--
-- Expected result:
-- SDL is successfully built
-- The flag EXTENDED_POLICY is set to HTTP
-- PTU passes successfully

---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
--TODO(mmihaylova-banska): Function still not implemented
function Test:TestStep_HTTP_Flow_AfterBuild ()
  testCasesForPolicyTable:flow_PTU_SUCCEESS_HTTP (self)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_Stop_SDL()
  StopSDL()
end

return Test
