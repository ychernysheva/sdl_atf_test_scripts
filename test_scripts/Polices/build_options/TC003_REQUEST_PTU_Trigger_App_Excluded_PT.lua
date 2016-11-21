---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] Request PTU - an app registered is not listed in local PT

-- Description:
-- SDL should request PTU in case new application is registered and is not listed in PT
-- 1. Used preconditions
-- SDL is built with "EXTENDED_POLICY: HTTP" flag
-- Connect mobile phone over WiFi.
-- Register new application.
-- Successful PTU.
-- 2. Performed steps
-- Register new application
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
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonPreconditions = require ('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY","HTTP")
--testCasesForPolicyTable:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","HTTP")
commonSteps:DeleteLogsFileAndPolicyTable()
commonPreconditions:Connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp("connecttest_RAI.lua")

--TODO(mmihaylova-banska): Should be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_RAI')
require('cardinalities')
require('user_modules/AppTypes')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
function Test:Precondition_remove_user_connecttest()
  os.execute( "rm -f ./user_modules/connecttest_RAI.lua" )
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("TC_Request_PTU_AppID_Excluded_PT")

function Test:TestStep_StartNewSession()
  self.mobileSession1 = mobile_session.MobileSession( self, self.mobileConnection)
  self.mobileSession1:StartService(7)
end

--TODO(mmihaylova-banska): Function still not implemented
function Test:TestStep_PTU_AppID_NotListed_PT()
  local correlationId = self.mobileSession1:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)

  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application2.appName } })
  :Do(function(_,data)
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})

      testCasesForPolicyTable:create_PTS(true)

      local timeout_after_x_seconds = testCasesForPolicyTable:get_data_from_PTS("timeout_after_x_seconds")
      local seconds_between_retry = testCasesForPolicyTable:get_data_from_PTS("seconds_between_retry")
      EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
        {
          file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate",
          timeout = timeout_after_x_seconds,
          retry = seconds_between_retry
        })
      :Do(function(_,data)
          self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
        end)
    end)
  self.mobileSession1:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS"})

end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test:Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop(self)
end

return Test

