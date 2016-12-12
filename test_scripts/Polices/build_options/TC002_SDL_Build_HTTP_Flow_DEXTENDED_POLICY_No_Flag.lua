---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] Support of "http" flow of Policy Table Update
--
-- Description:
-- In case SDL is built with -DEXTENDED_POLICY: HTTP" flag SDL must support 
--"http" (normal) PolicyTableUpdate flow 

-- 1. Performed steps
-- Build SDL with flag above
--
-- Expected result:
-- SDL is successfully built
-- The flag -DEXTENDED_POLICY: is set to HTTP
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

function Test:TestStep_HTTP_Flow_AfterBuild ()
  testCasesForPolicyTable.flow_PTU_SUCCEESS_HTTP (self)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test:Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop(self)
end

return Test
