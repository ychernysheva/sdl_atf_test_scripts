---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies]: User-consent "YES"
--
-- Description:
-- SDL gets user consent information from HMI
-- 1. Used preconditions:
-- Delete log files and policy table from previous cycle
-- Close current connection
-- Backup preloaded PT
-- Overwrite preloaded with specific groups for app
-- Connect device
-- Register app
--
-- 2. Performed steps
-- Activate app
--
-- Expected result:
-- SDL must notify an application about the current permissions active on HMI via onPermissionsChange() notification
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()
testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/GroupsForApp_preloaded_pt.json")

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:IsPermissionsConsentNeeded_false_on_app_activation()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
  EXPECT_HMIRESPONSE(RequestId,{ result = { code = 0, method = "SDL.ActivateApp", isPermissionsConsentNeeded = true, isSDLAllowed = false}})
  :Do(function(_,data)
      if (data.result.isPermissionsConsentNeeded == true) then
        local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
        EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage, { result = { code = 0, messages = {{ messageCode = "DataConsent"}}, method = "SDL.GetUserFriendlyMessage"}})

        local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", { appID = self.HMIAppID })
        EXPECT_HMIRESPONSE(RequestIdListOfPermissions,{result = {code = 0, method = "SDL.GetListOfPermissions", allowedFunctions = {{ name = "Location-1"}, { name = "DrivingCharacteristics-3"}}}})
        :Do(function()
            local ReqIDGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"allowedFunctions"}})
            EXPECT_HMIRESPONSE(ReqIDGetUserFriendlyMessage)
            :Do(function()
                self.hmiConnection:SendNotification("SDL.OnAppPermissionsConsent", {})

                --TODO(istoimenova): Unclear how to check HMI state.
              end)
          end)
      end
    end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
testCasesForPolicyTable:Restore_preloaded_pt()
function Test.Postcondition_Stop()
  StopSDL()
end

return Test
