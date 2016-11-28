---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies]: OnAllowSDLFunctionality with 'allowed=false' and with 'device' param from HMI
--
-- Description:
-- 1. Preconditions: App is registered, device is consented
-- 2. Steps: send SDL.OnAllowSDLFunctionality with 'allowed=false' and with 'device' to HMI
--
-- Expected result:
-- The User sais "NO" for data consent prompt:
-- HMI->SDL: SDL.OnAllowSDLFunctionality (allowed: false, device, source)
-- PoliciesManager updates "user_consent_records" -> "device". sub-section.
-- SDL->HMI: BasicCommunication.ActivateApp ('level': NONE)
-- app stays in NONE level on HMI.
-- HMI->SDL: BasicCommunication.ActivateApp_response
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')

--[[ Local variables ]]
local ServerAddress = commonFunctions:read_parameter_from_smart_device_link_ini("ServerAddress")

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:TestStep_RegisterApp_allowed_false_without_device()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})

  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,_)

      local RequestId1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
      --hmi side: expect SDL.GetUserFriendlyMessage message response
      EXPECT_HMIRESPONSE( RequestId1, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
      :Do(function(_,_)
          self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
            {allowed = false, source = "GUI", device = {id = config.deviceMAC, name = ServerAddress, isSDLAllowed = false}})
        end)
    end)

  EXPECT_HMICALL("BasicCommunication.ActivateApp")
  --TODO(istoimenova): Update when "What is expected response of BC.ActivateApp when user doesn't consent device?" is resolved.
  :Do(function(_,data) self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {}) end)

  --Due to sdl_snapshot is not created default hmi_level of pre_DataConsent can't be read. Will be assumed as NONE.
  EXPECT_NOTIFICATION("OnHMIStatus", {}):Times(0)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test:Postcondition_Force_Stop_SDL()
  commonFunctions:SDLForceStop(self)
end

return Test