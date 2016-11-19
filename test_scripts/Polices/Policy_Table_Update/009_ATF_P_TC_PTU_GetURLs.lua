---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] Policy Manager responds on GetURLs from HMI
-- In case HMI sends GetURLs and at least one app is registered SDL must return only default url and url related to registered app
-- [HMI API] GetURLs request/response
--
-- Description:
-- SDL should request PTU in case user requests PTU
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: EXTERNAL_PROPRIETARY" flag
-- Application is registered.
-- No PTU is requested.
-- 2. Performed steps
-- User press button on HMI to request PTU.
-- HMI->SDL: SDL.GetURLs(service=0x07)
--
-- Expected result:
-- PTU is requested. PTS is created.
-- SDL.GetURLs({urls[] = registered_App1, default})
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
-- commonFunctions:SDLForceStop()
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY", "EXTERNAL_PROPRIETARY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","EXTERNAL_PROPRIETARY")
commonSteps:DeleteLogsFileAndPolicyTable()

--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
testCasesForPolicyTable:flow_PTU_SUCCEESS_EXTERNAL_PROPRIETARY()

-- Request PTU
testCasesForPolicyTable:trigger_PTU_user_request_update_from_HMI()

--[[ Test ]]
function Test:TC_PTU_GetURLs()
  local test_endpoint = 0
  local index_endpoint = 0
  local endpoints = {}
  local length_endpoints

  for i = 1, #testCasesForPolicyTableSnapshot.pts_endpoints do
    if (testCasesForPolicyTableSnapshot.pts_endpoints[i].service == "0x07") then
      endpoints[1] = { url = testCasesForPolicyTableSnapshot.pts_endpoints[i].value, appID = nil}
    end
  end

  if (#testCasesForPolicyTableSnapshot.pts_endpoints_apps > 0) then
    for i = 1, #testCasesForPolicyTableSnapshot.pts_endpoints_apps do
      length_endpoints = #endpoints
      endpoints[length_endpoints + 1] = { url = testCasesForPolicyTableSnapshot.pts_endpoints_apps[i].value, appID = testCasesForPolicyTableSnapshot.pts_endpoints_apps[i].app_id}
    end
  else
    endpoints[#endpoints + 1] = { url = "http://policies.telematics.ford.com/api/policies", appID = self.applications[config.application1.registerAppInterfaceParams.appName]}
  end

  local RequestId = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })

  EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetURLS", urls = endpoints} } )
end

return Test
