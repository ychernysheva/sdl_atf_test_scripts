---------------------------------------------------------------------------------------------
-- Description:
-- SDL should request PTU in case user requests PTU
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: EXTERNAL_PROPRIETARY" flag
-- Application is registered.
-- No PTU is requested.
-- 2. Performed steps
-- User requests PTU.
-- HMI->SDL: SDL.OnPolicyUpdate
--
-- Requirements summary:
-- [Policies]: SDL.OnPolicyUpdate initiation of PTU
-- [HMI API] SDL.OnPolicyUpdate notification
-- [HMI API] PolicyUpdate request/response
--
-- Expected result:
-- PTU is requested. PTS is created.
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- SDL->HMI: BasicCommunication.PolicyUpdate
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("ENABLE_EXTENDED_POLICY", "OFF")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("ENABLE_EXTENDED_POLICY","OFF")
commonSteps:DeleteLogsFileAndPolicyTable()
--TODD(istoimenova): Should be removed when issue "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
testCasesForPolicyTable:flow_PTU_SUCCEESS_EXTERNAL_PROPRIETARY()

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:TestStep_User_requests_PTU()
  self.hmiConnection:SendNotification("SDL.OnPolicyUpdate", {} )

  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
  testCasesForPolicyTable:create_PTS(true, 
    {config.application1.registerAppInterfaceParams.appID}, 
    {config.deviceMAC} )
  
  local timeout_after_x_seconds = testCasesForPolicyTable:get_data_from_PTS("module_config.timeout_after_x_seconds")
  local seconds_between_retry = {}
  for i = 1, #testCasesForPolicyTable.seconds_between_retries do
    seconds_between_retry[i] = testCasesForPolicyTable.seconds_between_retries[i].value
  end

  EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
    {
      file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate",
      timeout = timeout_after_x_seconds,
      retry = seconds_between_retry
    })
  :Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
    end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test:Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop(self)
end

return Test
