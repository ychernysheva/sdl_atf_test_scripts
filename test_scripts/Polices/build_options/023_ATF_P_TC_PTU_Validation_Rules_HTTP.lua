-- UNREADY: 
--function Test:TestStep_PTU_validation_rules
--should be applicable for HTTP flag as well

---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] PTU validation rules
-- [HMI API] OnStatusUpdate
-- [HMI API] OnReceivedPolicyUpdate notification
--
-- Description:
-- After Base-64 decoding, SDL must validate the Policy Table Update according to
-- S13j_Applink_Policy_Table_Data_Dictionary_040.xlsx rules: "required" fields must be present, 
-- "optional" may be present but not obligatory, "ommited" - accepted to be present in PTU (PTU won't be rejected if the fields with option "ommited" exists)
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- Application is registered.
-- PTU is requested.
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- SDL->HMI:SDL.PolicyUpdate(file, timeout, retry[])
-- HMI -> SDL: SDL.GetURLs (<service>)
-- HMI->SDL: BasicCommunication.OnSystemRequest ('url', requestType:HTTP, appID="default")
-- SDL->app: OnSystemRequest ('url', requestType:HTTP, fileType="JSON", appID)
-- app->SDL: SystemRequest(requestType=HTTP)
-- HMI->SDL: SystemRequest(SUCCESS)
-- SDL->HMI: SDL.OnStatusUpdate(UPDATING)
-- 2. Performed steps
-- HMI->SDL: OnReceivedPolicyUpdate(policy_file): policy_file all sections in data dictionary + omit
--
-- Expected result:
-- SDL->HMI: OnStatusUpdate(UP_TO_DATE)
-- SDL stops timeout started by OnSystemRequest. No other OnSystemRequest messages are received.
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--local testCasesForPolicyTableUpdateFile = require('user_modules/shared_testcases/testCasesForPolicyTableUpdateFile')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:TestStep_PTU_validation_rules()
  local is_test_fail = false
  local endpoints = {}
  local hmi_app_id = self.applications[config.application1.registerAppInterfaceParams.appName]
  print("hmi_app_id = " ..hmi_app_id)

  for i = 1, #testCasesForPolicyTableSnapshot.pts_endpoints do
    if (testCasesForPolicyTableSnapshot.pts_endpoints[i].service == "0x07") then
      endpoints[#endpoints + 1] = { url = testCasesForPolicyTableSnapshot.pts_endpoints[i].value, appID = nil}
    end

    if (testCasesForPolicyTableSnapshot.pts_endpoints[i].service == "app1") then
      endpoints[#endpoints + 1] = {
        url = testCasesForPolicyTableSnapshot.pts_endpoints[i].value,
        appID = testCasesForPolicyTableSnapshot.pts_endpoints[i].appID}
    end
  end

  local RequestId_GetUrls = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestId_GetUrls,{result = {code = 0, method = "SDL.GetURLS", urls = endpoints} } )
  :Do(function(_,_)

      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",{ fileName = "PolicyTableUpdate", requestType = "HTTP", url = endpoints[1].url})
      EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "HTTP", fileType = "JSON", url = endpoints[1].url,appID = config.application1.registerAppInterfaceParams.appID })
      :Do(function(_,_)
          local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {requestType = "HTTP", fileName = "PolicyTableUpdate"}, "files/jsons/Policies/PTU_ValidationRules/valid_PTU_all_sections.json")

          EXPECT_HMICALL("BasicCommunication.SystemRequest",{
              requestType = "HTTP",
              fileName = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate",
              appID = hmi_app_id})
          :Do(function(_,_data1)
              self.hmiConnection:SendResponse(_data1.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
              self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
                { policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"})

              EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UP_TO_DATE"})
            end)

          EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
        end)
    end)

  if(is_test_fail == true) then
    self:FailTestCase("Test is FAILED. See prints.")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test:Postcondition_Force_Stop_SDL()
  commonFunctions:SDLForceStop(self)
end

return Test
