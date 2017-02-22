---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [GENIVI] [Policies] External UCS: informing HMI
-- [HMI API] GetListOfPermissions request/response
-- [HMI API] ExternalConsentStatus struct & EntityStatus enum
-- [Policies] [External UCS] SDL informs HMI about <externalConsentStatus> via GetListOfPermissions response
--
-- Description:
-- For Genivi applicable ONLY for 'EXTERNAL_PROPRIETARY' Polcies
-- Upon GetListOfPermissions_request, SDL must inform "externalConsentStatus" setting to HMI
--
-- 1. Used preconditions
-- SDL is built with External_Proprietary flag
-- SDL and HMI are running
-- Application is registered and activated
-- PTU has passed successfully
-- HMI sends <externalConsentStatus> to SDl via OnAppPermissionConsent ( all params present and within bounds, EntityStatus = 'ON')
-- SDL stores internally the received <externalConsentStatus>
--
-- 2. Performed steps
-- HMI sends to SDL GetListOfPermissions (appID)
--
-- Expected result:
-- SDL sends do HMI <externalConsentStatus> received from HMI
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()
testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/jsons/Policies/Related_HMI_API/OnAppPermissionConsent.json")

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_trigger_getting_device_consent()
  testCasesForPolicyTable:trigger_getting_device_consent(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

function Test:Precondition_PTU_and_OnAppPermissionConsent_AllParams_Valid()
  testCasesForPolicyTable:flow_SUCCEESS_EXTERNAL_PROPRIETARY(self)
  EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged",{ appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
  :Do(function(_,data)
      if (data.result.appPermissionsConsentNeeded == true) then
        local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", {appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
        EXPECT_HMIRESPONSE(RequestIdListOfPermissions,{result = {code = 0, method = "SDL.GetListOfPermissions",
              -- allowed: If ommited - no information about User Consent is yet found for app.
              allowedFunctions = {
                { name = "Location", id = 156072572},
                { name = "Notifications", id = 1809526495}
              },
              externalConsentStatus = {
                {entityType = 13, entityID = 113, status = "ON"}
              }
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
                    externalConsentStatus = {
                      {entityType = 13, entityID = 113, status = "ON"}
                    },
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

function Test:TestStep_GetListofPermissions()
  local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", {appID = self.applications[config.application1.registerAppInterfaceParams.appName]})

  EXPECT_HMIRESPONSE(RequestIdListOfPermissions,{code = "0",
      allowedFunctions = {
        { name = "Location", id = 156072572, allowed = true},
        { name = "Notifications", id = 1809526495, allowed = true}
      },
      externalConsentStatus = {
        {entityType = 13, entityID = 113, status = "ON"}
      }
    })
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_Restore_preloaded_file()
  os.execute( " rm -f SetAudioStreamingIndicator_group1.json" )
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end

function Test.Postcondition_Stop()
  StopSDL()
end

return Test