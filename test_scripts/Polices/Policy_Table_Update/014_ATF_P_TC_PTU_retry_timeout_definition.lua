---------------------------------------------------------------------------------------------
-- Requirements summary:
-- PoliciesManager must use the values from "seconds_between_retries" section of 
-- Local PT as the values to provide in UpdateSDL request to notify SyncP manager to start PTU sequence. 
--
-- Description:
-- SDL should request PTU in case user requests PTU
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: EXTERNAL_PROPRIETARY" flag
-- 2. Performed steps
-- Application is registered.
-- PTU is requested.
--
-- Expected result:
-- Number and values of the "retry" elements are provided as appropriate elements in 
-- "seconds_between_retries" section of Local PT. 
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
-- commonFunctions:SDLForceStop()
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY", "EXTERNAL_PROPRIETARY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","EXTERNAL_PROPRIETARY")
commonSteps:DeleteLogsFileAndPolicyTable()
commonPreconditions:Connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp("connecttest_RAI.lua")

--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_RAI')
require('cardinalities')
require('user_modules/AppTypes')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:Precondition_remove_user_connecttest()
  os.execute( "rm -f ./user_modules/connecttest_RAI.lua" )
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:TestStep_ConnectMobile()
  self:connectMobile()
end

function Test:TestStep_StartNewSession()
  self.mobileSession = mobile_session.MobileSession( self, self.mobileConnection)
  self.mobileSession:StartService(7)
end

function Test:TestStep_PTS_Timeout_wait_response_PTU()
  local hmi_app_id = self.applications[config.application1.registerAppInterfaceParams.appName]
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application1.appName } })
  :Do(function(_,data)
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})

      testCasesForPolicyTableSnapshot:create_PTS(true, 
        {config.application1.registerAppInterfaceParams.appID},
        {config.deviceMAC},
        {hmi_app1_id})

      local seconds_between_retries_pts = testCasesForPolicyTableSnapshot.seconds_between_retries
      local seconds_between_retries_preloaded = {}

      for i = 1, #testCasesForPolicyTableSnapshot.preloaded_elements do
        local str_1 = testCasesForPolicyTableSnapshot.preloaded_elements[i].name
        local str_2 = "module_config.seconds_between_retries"
        if(string.sub(str_1,1,string.len(str_2)) == str_2) then
          seconds_between_retries_preloaded[#seconds_between_retries_preloaded + 1] =  testCasesForPolicyTableSnapshot.preloaded_elements[i]       
        end
      end

      if(#seconds_between_retries_preloaded ~= #seconds_between_retries_pts) then
        self:FailTestCase("Numbers of seconds_between_retries should be "..#seconds_between_retries_preloaded ..", real: "..#seconds_between_retries_pts)
      else
        for i = 1, #seconds_between_retries_preloaded do
          if(seconds_between_retries_preloaded[i].value ~= seconds_between_retries_pts[i].value) then
            self:FailTestCase("seconds_between_retries["..i.."] should be "..seconds_between_retries_preloaded[i].value ..", real: "..seconds_between_retries_pts[i].value)
          end
        end
      end
    end)
  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS"})
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test:Postcondition_Force_Stop_SDL()
  commonFunctions:SDLForceStop(self)
end

return Test
