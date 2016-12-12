---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] OnStatusUpdate(UPDATE_NEEDED) on new PTU request
-- [HMI API] OnStatusUpdate
-- [HMI API] UpdateSDL request/response
--
-- Description:
-- PoliciesManager must notify HMI via SDL.OnStatusUpdate(UPDATE_NEEDED) on any PTU trigger.
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- Connect mobile phone over WiFi.
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
local testCasesForPolicyTableSnapshot = require ('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()
--TODO: Should be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_OnStatusUpdate_UPDATE_NEEDED_new_PTU_request()
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application1.appName } })
  :Do(function(_,data)
      local hmi_app_id = data.params.application.appID
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})

      testCasesForPolicyTableSnapshot:verify_PTS(true,
        {config.application1.registerAppInterfaceParams.appID},
        {config.deviceMAC},
        {hmi_app_id})

      local timeout_after_x_seconds = testCasesForPolicyTableSnapshot:get_data_from_PTS("module_config.timeout_after_x_seconds")
      local seconds_between_retry = {}
      for i = 1, #testCasesForPolicyTableSnapshot.seconds_between_retries do
        seconds_between_retry[i] = testCasesForPolicyTableSnapshot.seconds_between_retries[i].value
      end
      EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
        {
          file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate",
          timeout = timeout_after_x_seconds,
          retry = seconds_between_retry
        })
      :Do(function(_,_data1)
          self.hmiConnection:SendResponse(_data1.id, _data1.method, "SUCCESS", {})
        end)
    end)

  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS"})
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_Stop_SDL()
  StopSDL()
end

return Test
