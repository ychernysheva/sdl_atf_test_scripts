---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] PoliciesManager must initiate PTU in case getting 'device consent' from the user
--
-- Description:
-- SDL should request PTU in case gets 'device consent' from the user
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: EXTERNAL_PROPRIETARY" flag
-- Connect mobile phone.
-- Register new application.
-- 2. Performed steps
-- Activate application.
-- User consent device
--
-- Expected result:
-- PTU is requested. PTS is created.
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:TestStep_PTU_DeviceConsent_from_User()
  local is_test_failed = false
  local ServerAddress = commonFunctions:read_parameter_from_smart_device_link_ini("ServerAddress")
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})

  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,_)
      local hmi_app1_id = self.applications[config.application1.registerAppInterfaceParams.appName]
      --EXPECT_HMICALL("SDL.OnSDLConsentNeeded", { device = { name = ServerAddress, id = config.deviceMAC, isSDLAllowed = false } })

      local RequestId_GetUsrFrMsg = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})

      EXPECT_HMIRESPONSE( RequestId_GetUsrFrMsg, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
      :Do(function(_,_)
          self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
            {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = ServerAddress, isSDLAllowed = true}})

          EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", { status = "UPDATE_NEEDED" })

          testCasesForPolicyTableSnapshot:verify_PTS(true,
            {config.application1.registerAppInterfaceParams.appID},
            {config.deviceMAC},
            {hmi_app1_id})

          local timeout_after_x_seconds = testCasesForPolicyTableSnapshot:get_data_from_PTS("module_config.timeout_after_x_seconds")
          local seconds_between_retries = {}
          for i = 1, #testCasesForPolicyTableSnapshot.pts_seconds_between_retries do
            seconds_between_retries[i] = testCasesForPolicyTableSnapshot.pts_seconds_between_retries[i].value
          end
          EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
            {
              file = "/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json",
              timeout = timeout_after_x_seconds,
              retry = seconds_between_retries
            })
          :Do(function(_,data)
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
            end)

        end)

      EXPECT_HMICALL("BasicCommunication.ActivateApp")
      :Do(function(_,data)
          self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
          end):Times(1)
      end)
    EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})

    if(is_test_failed == true) then self:FailTestCase("Test is FAILED. See prints.") end
  end

  --[[ Postconditions ]]
  commonFunctions:newTestCasesGroup("Postconditions")
  function Test.Postcondition_Stop()
    StopSDL()
  end

  return Test
