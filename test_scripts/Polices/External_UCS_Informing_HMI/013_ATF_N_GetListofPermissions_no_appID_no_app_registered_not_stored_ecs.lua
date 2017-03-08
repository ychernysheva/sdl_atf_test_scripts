---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] [External UCS] SDL informs HMI about <externalConsentStatus> via GetListOfPermissions response
-- [HMI API] GetListOfPermissions request/response
-- [HMI API] ExternalConsentStatus struct & EntityStatus enum
--
-- Description:
-- For Genivi applicable ONLY for 'EXTERNAL_PROPRIETARY' Polcies
-- Upon GetListOfPermissions_request, SDL must inform "externalConsentStatus" setting to HMI
--
-- 1. Used preconditions
-- SDL is built with External_Proprietary flag
-- SDL and HMI are running
-- Application is registered and activated
-- PTU file is updated and application is assigned to functional groups: Base-4, user-consent groups: Location-1 and Notifications
-- PTU has passed successfully
-- HMI sends empty <externalConsentStatus> to SDl via OnAppPermissionConsent
--
-- 2. Performed steps
-- HMI sends to SDL GetListOfPermissions (non-existing appID, it does not match the appID of the registered application)
--
-- Expected result:
-- SDL invalidates the appID and cuts it off, the GetListOfPermissions request is treated as if sent without appID
-- SDL sends to HMI empty <externalConsentStatus> array
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_trigger_getting_device_consent()
  testCasesForPolicyTable:trigger_getting_device_consent(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

function Test:Precondition_PTU_and_OnAppPermissionConsent_Empty()
  local ptu_file_path = "files/jsons/Policies/Related_HMI_API/"
  local ptu_file = "OnAppPermissionConsent_ptu.json"

  testCasesForPolicyTable:flow_SUCCEESS_EXTERNAL_PROPRIETARY(self, nil, nil, nil, ptu_file_path, nil, ptu_file)

  EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged",{ appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
  :Do(function(_,data)
      if (data.params.appPermissionsConsentNeeded== true) then
        local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", {appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
        EXPECT_HMIRESPONSE(RequestIdListOfPermissions,{result = {code = 0, method = "SDL.GetListOfPermissions",
              -- allowed: If ommited - no information about User Consent is yet found for app.
              allowedFunctions = {
                { name = "Location", id = 156072572},
                { name = "Notifications", id = 1809526495}
              },
              externalConsentStatus = {}
            }
          })
        :Do(function()
            local ReqIDGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
              {language = "EN-US", messageCodes = {"AppPermissions"}})

            EXPECT_HMIRESPONSE(ReqIDGetUserFriendlyMessage,
              {result = {code = 0, messages = {{messageCode = "AppPermissions"}}, method = "SDL.GetUserFriendlyMessage"}})
            :Do(function(_,_)
                self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent",
                  {
                    appID = self.applications[config.application1.registerAppInterfaceParams.appName],
                    consentedFunctions = {
                      { allowed = true, id = 156072572, name = "Location"},
                      { allowed = true, id = 1809526495, name = "Notifications"}
                    },
                    externalConsentStatus = {},
                    source = "GUI"
                  })
                EXPECT_NOTIFICATION("OnPermissionsChange")
              end)
          end)
      else
        commonFunctions:userPrint(31, "Wrong SDL bahavior: there are app permissions for consent, isPermissionsConsentNeeded should be true")
        return false
      end
  end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_GetListofPermissions_appID_NotRegistred_AtAll_App_Empty_ecs()
  local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions")

  EXPECT_HMIRESPONSE(RequestIdListOfPermissions,{code = "0",
      allowedFunctions = {
        { name = "Location", id = 156072572, allowed = true},
        { name = "Notifications", id = 1809526495, allowed = true}
      },
      externalConsentStatus = {}
    })
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_Stop_SDL()

  StopSDL()
end

return Test
