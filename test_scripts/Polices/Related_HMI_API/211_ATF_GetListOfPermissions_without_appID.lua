---------------------------------------------------------------------------------------------
-- Description:
-- 1. Preconditions: SDL and HMI are running. Local PT contains in "appID_1" section: "groupName_11", "groupName_12" groups;
-- and in "appID_2" section: "groupName_21", "groupName_22" groups;
-- 2. Performed steps: 1. Send SDL.GetListOfPermissions {appID_1}, From HMI: SDL->HMI: GetListOfPermissions {allowedFunctions:
--
-- Requirement summary:
-- GetListOfPermissions without appID
-- [HMI API] GetListOfPermissions request/response
--
-- Expected result:
-- On getting SDL.GetListOfPermissions without appID parameter, PoliciesManager must respond with the list of <groupName>s
-- that have the field "user_consent_prompt" in corresponding <functional grouping> and are assigned to the currently registered applications (section "<appID>" -> "groups")
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ Local Functions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_TriggerDeviceConsent()
  testCasesForPolicyTable:trigger_getting_device_consent(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

function Test:Precondition_flow_SUCCEESS_EXTERNAL_PROPRIETARY()
  local SystemFilesPath = commonFunctions:read_parameter_from_smart_device_link_ini("SystemFilesPath")--"/tmp/fs/mp/images/ivsu_cache/"

  local RequestId_GetUrls = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestId_GetUrls,{result = {code = 0, method = "SDL.GetURLS" } } )
  :Do(function(_,_)
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
        { requestType = "PROPRIETARY", fileName = "PolicyTableUpdate"})
      EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "PROPRIETARY"})
      :Do(function(_,_)

          EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate",
            {status = "UPDATING"}, {status = "UP_TO_DATE"}):Times(2)

          local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {requestType = "PROPRIETARY", fileName = "PolicyTableUpdate", appID = config.application1.registerAppInterfaceParams.appID}, "files/jsons/Policy/Related_HMI_API/OnAppPermissionConsent.json")
          EXPECT_HMICALL("BasicCommunication.SystemRequest",{ requestType = "PROPRIETARY", fileName = SystemFilesPath.."/PolicyTableUpdate" })
          :Do(function(_,_data1)
              self.hmiConnection:SendResponse(_data1.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
              self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate", { policyfile = SystemFilesPath.."/PolicyTableUpdate"})
            end)
          EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
        end)
    end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:TestStep_GetListOfPermissions_without_appID()
  local RequestIdGetListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions",{})--, {appID = self.applications[config.application1.registerAppInterfaceParams.appName]})

  EXPECT_HMIRESPONSE(RequestIdGetListOfPermissions)
  :Do(function(_,data)
      local groups = {}
      if #data.result.allowedFunctions > 0 then
        for i = 1, #data.result.allowedFunctions do
          groups[i] = data.result.allowedFunctions[i]
        end
      end

      self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent", { consentedFunctions = groups, source = "GUI"})
      EXPECT_NOTIFICATION("OnPermissionsChange")
    end)
end

function Test:TestStep_trigger_user_request_update_from_HMI()
  testCasesForPolicyTable:trigger_user_request_update_from_HMI(self)
end

function Test:TestStep_checkPermissionsOfGroups()
  local is_test_fail = false
  testCasesForPolicyTableSnapshot:extract_pts({self.applications[config.application1.registerAppInterfaceParams.appName]})
  local app_consent_location = testCasesForPolicyTableSnapshot:get_data_from_PTS("device_data."..config.deviceMAC..".user_consent_records."..config.application1.registerAppInterfaceParams.appID..".consent_groups.Location")
  local app_consent_notifications = testCasesForPolicyTableSnapshot:get_data_from_PTS("device_data."..config.deviceMAC..".user_consent_records."..config.application1.registerAppInterfaceParams.appID..".consent_groups.Notifications")
  local app_consent_Base4 = testCasesForPolicyTableSnapshot:get_data_from_PTS("device_data."..config.deviceMAC..".user_consent_records."..config.application1.registerAppInterfaceParams.appID..".consent_groups.Base-4")

  -- print("app_consent_location" ..tostring(app_consent_location))
  -- print("app_consent_notifications" ..tostring(app_consent_notifications))
  -- print("app_consent_Base4" ..tostring(app_consent_Base4))

  if(app_consent_location ~= true) then
    commonFunctions:printError("Error: consent_groups.Location function for appID should be true")
    is_test_fail = true
  end

  if(app_consent_notifications ~= true) then
    commonFunctions:printError("Error: consent_groups.Notifications function for appID should be true")
    is_test_fail = true
  end

  if(app_consent_Base4 ~= false) then
    commonFunctions:printError("Error: consent_groups.Notifications function for appID should be false")
    is_test_fail = true
  end

  if(is_test_fail == true) then
    self:FailTestCase("Test is FAILED. See prints.")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
testCasesForPolicyTable:Restore_preloaded_pt()
function Test.Postcondition_StopSDL()
  StopSDL()
end

return Test
