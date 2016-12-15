---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] Local Policy Table retry sequence start
-- [HMI API] OnStatusUpdate
--
-- Description:
-- In case PoliciesManager does not receive the Updated PT during time defined in
-- "timeout_after_x_seconds" section of Local PT, it must start the retry sequence.
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- Application is registered.
-- PTU is requested.
-- PTU to be received satisfies data dictionary requirements
-- PTU omits "consumer_friendly_messages" section
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- SDL->HMI:SDL.PolicyUpdate(file, timeout, retry[])
-- HMI -> SDL: SDL.GetURLs (<service>)
-- HMI->SDL: BasicCommunication.OnSystemRequest ('url', requestType:HTTP)
-- 2. Performed steps
-- SDL->app: OnSystemRequest ('url', requestType:HTTP, fileType="JSON")
-- Expected result:
--Timeout expires and retry sequence started
--SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)

---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local testCasesForPolicyTableSnapshot = require ('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()
--TODO: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_ChangeStatus_Update_Needed()
  local time_update_needed = {}
  local time_system_request = {}
  local endpoints = {}
  local is_test_fail = false
  local timeout_pts = testCasesForPolicyTableSnapshot:get_data_from_PTS("module_config.timeout_after_x_seconds")
  local seconds_between_retries = {}
  for i = 1, #testCasesForPolicyTableSnapshot.pts_seconds_between_retries do
    seconds_between_retries[i] = testCasesForPolicyTableSnapshot.pts_seconds_between_retries[i].value
  end
  local time_wait = (timeout_pts*seconds_between_retries[1]*1000)

  local function verify_retry_sequence()
    time_update_needed[#time_update_needed + 1] = timestamp()
    local time_1 = time_update_needed[#time_update_needed]
    local time_2 = time_system_request[#time_system_request]
    local timeout = (time_1 - time_2)
    if( ( timeout > (timeout_pts*1000 + 2000) ) or ( timeout < (timeout_pts*1000 - 2000) )) then
      is_test_fail = true
      commonFunctions:printError("ERROR: timeout for first retry sequence is not as expected: "..timeout_pts.."msec(5sec tolerance). real: "..timeout.."ms")
    else
      print("timeout is as expected: "..tostring(timeout_pts*1000).."ms. real: "..timeout)
    end
  end

  local RequestId_GetUrls = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestId_GetUrls,{result = {code = 0, method = "SDL.GetURLS", urls = endpoints} } )
  :Do(function(_,_)
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",{ requestType = "HTTP", fileName = "PolicyTableUpdate" })

      EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "HTTP", fileType = "JSON"}):Timeout(12000)
      :Do(function(_,_) time_system_request[#time_system_request + 1] = timestamp() end)
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATING"}, {status = "UPDATE_NEEDED"}):Times(2):Timeout(time_wait)
      :Do(function(_,data)
          if(data.params.status == "UPDATE_NEEDED" ) then
            --first retry sequence
            verify_retry_sequence()
          end
        end)
    end)

  commonTestCases:DelayedExp(time_wait)

  if(is_test_fail == true) then
    self:FailTestCase("Test is FAILED. See prints.")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_Stop_SDL()
  StopSDL()
end

return Test
