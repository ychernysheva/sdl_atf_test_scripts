-- Requirements summary:
-- [PolicyTableUpdate][GENIVI] PoliciesManager changes status to “UPDATE_NEEDED”
--
-- Description:
-- PoliciesManager must change the status to “UPDATE_NEEDED” and notify HMI with OnStatusUpdate(“UPDATE_NEEDED”)
-- in case the timeout taken from "timeout_after_x_seconds" field of LocalPT or "timeout between retries"
-- is expired before PoliciesManager receives SystemRequest with PTU from mobile application.
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- Connect mobile phone over WiFi.
-- 2. Performed steps
-- Register new application to trigger PTU
-- SDL-> <app ID> ->OnSystemRequest(params, url, )
-- Timeout expires
--
-- Expected result:
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')

--[[ Local variables ]]
local ts_on_system_request = nil
local ts_on_status_update = nil

local r_expected_timeout = 60
local attempts = (r_expected_timeout / 5) + 1

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()

config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Specific Notifications ]]
function Test:RegisterNotification()
  self.mobileSession:ExpectNotification("OnSystemRequest")
  :Do(function(_, d)
      if d.payload.requestType == "HTTP" and not ts_on_system_request then
        ts_on_system_request = os.time()
      end
    end)
  :Times(AtLeast(1))
  :Pin()
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
  :Do(function(_, d)
      if d.params.status == "UPDATE_NEEDED" and not ts_on_status_update then
        ts_on_status_update = os.time()
      end
    end)
  :Times(AnyNumber())
  :Pin()
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

for i = 1, attempts do
  Test["Waiting " .. i * 5 .. " sec"] = function()
    os.execute("sleep 5")
  end
end

function Test:ValidateResult()
  print("TS for OnSystemRequest: " .. tostring(ts_on_system_request))
  print("TS for SDL.OnStatusUpdate: " .. tostring(ts_on_status_update))
  if not ts_on_system_request then
    self:FailTestCase("Expected OnSystemRequest request was not sent")
  end
  if not ts_on_status_update then
    self:FailTestCase("Expected SDL.OnStatusUpdate(UPDATE_NEEDED) notification was not sent")
  end
  local r_actual_timeout = ts_on_status_update - ts_on_system_request
  print("Expected: " .. r_expected_timeout)
  print("Actual: " .. r_actual_timeout)
  -- tolerance 2 sec.
  if (r_actual_timeout < r_expected_timeout - 2) or (r_actual_timeout > r_expected_timeout + 2) then
    local msg = "\nExpected timeout '" .. r_expected_timeout .. "', actual '" .. r_actual_timeout .. "'"
    self:FailTestCase(msg)
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Stop()
  StopSDL()
end

return Test
