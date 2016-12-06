--UNREADY
--1. OnSystemRequest with SnapshotPT (= binary data) should be sent over "Bulk" Service (15) to mobile app per APPLINK-7099.
--2. SDL starts "timeout_after_x_seconds" right after sending OnSystemRequest out to mobile app per APPLINK-18179
-- But I have "timeout_after_x_seconds" nil value....
----------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PTU-Proprietary] Transfer OnSystemRequest from HMI to mobile app
--
-- Description:
-- 1. Used preconditions: SDL is built with "DEXTENDED_POLICY: PRORPIETARY" flag. Trigger for PTU occurs
-- 2. Performed steps:
-- SDL->HMI: BasicCommunication.OnSystemRequest (<path to UpdatedPT>, PROPRIETARY, params)
-- HMI->SDL: "OnSystemRequest"
-- Expected result:
-- SDL-> MOB: OnSystemRequest", {requestType = "PROPRIETARY" })
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
--local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')
--local commonTestCases = require('user_modules/shared_testcases/commonTestCases')

--[[ Local Variables ]]
local systemFilesPath = "/tmp/fs/mp/images/ivsu_cache"

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:TestStep_PROPRIETARY_PTU()
  -- local timeout_after_x_seconds = testCasesForPolicyTableSnapshot:get_data_from_PTS("timeout_after_x_seconds")
  -- local seconds_between_retry = testCasesForPolicyTableSnapshot:get_data_from_PTS("seconds_between_retry")
  local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {url = "http://policies.telematics.ford.com/api/policies"}}})
  :Do(function(_,_)
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
        {
          requestType = "PROPRIETARY",
          url = "http://policies.telematics.ford.com/api/policies",
          appID = self.applications ["Test Application"],
          fileName = "sdl_snapshot.json"
        },
        systemFilesPath
      )
    end)
  EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "PROPRIETARY" })
  --SDL start timeout--
  -- local time_wait = (timeout_pts*seconds_between_retries[1]*1000 + 10000)
  -- commonTestCases:DelayedExp(time_wait) -- tolerance 10 sec
end
--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
Test["StopSDL"] = function()
  StopSDL()
end
