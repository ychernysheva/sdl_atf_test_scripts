---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] Policy Manager sends PTS to HMI by providing the file location,
-- timeout and the array of timeouts for retry sequence
--
-- Description:
-- SDL should request PTU in case getting device consent
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: EXTERNAL_PROPRIETARY" flag
-- 2. Performed steps
-- Application is registered. Getting device consent
-- PTU is requested.
--
-- Expected result:
-- SDL->HMI:SDL.PolicyUpdate(file, timeout, retry[])
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

--[[ Test ]]
function Test:TestStep_PolicyManager_sends_PTS_to_HMI()
  local hmi_app_id = self.applications[config.application1.registerAppInterfaceParams.appName]
  local ServerAddress = commonFunctions:read_parameter_from_smart_device_link_ini("ServerAddress")

  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,_)
      local RequestId1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})

      EXPECT_HMIRESPONSE( RequestId1, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
      :Do(function(_,_)

          self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
            {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = ServerAddress, isSDLAllowed = true}})

          testCasesForPolicyTableSnapshot:verify_PTS(true,
            {config.application1.registerAppInterfaceParams.appID},
            {config.deviceMAC},
            {hmi_app_id})

          local timeout_after_x_seconds = testCasesForPolicyTableSnapshot:get_data_from_PTS("module_config.timeout_after_x_seconds")
          local seconds_between_retries = {}
          for i = 1, #testCasesForPolicyTableSnapshot.pts_seconds_between_retries do
            seconds_between_retries[i] = testCasesForPolicyTableSnapshot.pts_seconds_between_retries[i].value
          end
          local SystemFilesPath = commonFunctions:read_parameter_from_smart_device_link_ini("SystemFilesPath")
          local file_pts = SystemFilesPath.."/sdl_snapshot.json"

          EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
            {
              file = file_pts,
              timeout = timeout_after_x_seconds,
              retry = seconds_between_retries
            })
          :Do(function(_,data)
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
            end)
        end)
    end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_Stop()
  StopSDL()
end

return Test
