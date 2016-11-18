---------------------------------------------------------------------------------------------
-- Requirements summary: 
--     [PolicyTableUpdate] Support of "http" flow of Policy Table Update
--
-- Description: 
-- SDL should be successfully built "-DEXTENDED_POLICY: OFF" flag
-- 1. Performed steps
-- Build SDL 
--
-- Expected result:
-- SDL is successfully built
-- The flag -DEXTENDED_POLICY has no value
-- PTU passes successfully 

---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
--local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonPreconditions = require ('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
  
--[[ General Precondition before ATF start ]]
-- commonFunctions:SDLForceStop()
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("ENABLE_EXTENDED_POLICY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("ENABLE_EXTENDED_POLICY")
commonSteps:DeleteLogsFileAndPolicyTable()
commonPreconditions:Connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp("connecttest_RAI.lua")
 
  --ToDo (mmihaylova-banska): Should be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
  config.defaultProtocolVersion = 2
  
--[[ General Settings for configuration ]]
  Test = require('connecttest')
  require('cardinalities')
  require('user_modules/AppTypes')
  --local mobile_session = require('mobile_session')
 
--[[ Test ]]
 --ToDo: Function should be debugged! Runtime error!
 --commonFunctions:newTestCasesGroup("TC_PTU_HTTP_FLOW") 
  function Test:HTTP_Flow_AfterBuild ()
   testCasesForPolicyTable:flow_PTU_SUCCEESS_EXTERNAL_HTTP (self)
  end

  
--[[ Postconditions ]]
 --ToDo: Function should be debugged! Runtime error!
-- commonFunctions:newTestCasesGroup("Postconditions")
-- function Test:Postcondition_SDLForceStop()
--   commonFunctions:SDLForceStop(self)
-- end

return Test	