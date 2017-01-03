---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PolicyTableUpdate] PoliciesManager changes status to "UPDATING"
-- [HMI API] OnStatusUpdate
--
-- Description:
-- SDL is built with "-DEXTENDED_POLICY: PROPRIETARY" flag
-- PoliciesManager must change the status to "UPDATING" and notify HMI with OnStatusUpdate("UPDATING")
-- right after SnapshotPT is sent out to to mobile app via OnSystemRequest() RPC.
--
-- Steps:
-- 1. Register new app
-- 2. Trigger PTU
-- 3. SDL->HMI: Verify step of SDL.OnStatusUpdate(UPDATING) notification in PTU sequence
--
-- Expected result:
-- SDL.OnStatusUpdate(UPDATING) notification is send right after SDL->MOB: OnSystemRequest
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local testCasesForPolicyTable = require("user_modules/shared_testcases/testCasesForPolicyTable")

--[[ Local Variables ]]
local r_actual = { }

--[[ Local Functions ]]
local function get_id_by_val(t, v)
  for i = 1, #t do
    if (t[i] == v) then return i end
  end
  return nil
end

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()
testCasesForPolicyTable.Delete_Policy_table_snapshot()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")

-- [[ Notifications ]]
EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
:Do(function()
    table.insert(r_actual, "BC.PolicyUpdate")
  end)
:Times(AnyNumber())
:Pin()

EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate",{ status = "UPDATING" })
:Do(function(_, d)
    table.insert(r_actual, "SDL.OnStatusUpdate: " .. d.params.status)
  end)
:Times(AnyNumber())
:Pin()

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:TestStep_CheckMessagesSequence()
  local RequestId_GetUrls = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  table.insert(r_actual, "SDL.GetURLS: request")
  EXPECT_HMIRESPONSE(RequestId_GetUrls)
  :Do(function()
      table.insert(r_actual, "SDL.GetURLS: response")
      EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
      :Do(function()
          table.insert(r_actual, "OnSystemRequest")
        end)
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest", { requestType = "PROPRIETARY", fileName = "PolicyTableUpdate"})
      table.insert(r_actual, "BC.OnSystemRequest")
    end)
end

function Test:ValidateResult()
  commonFunctions:printTable(r_actual)
  local onSystemRequestId = get_id_by_val(r_actual, "OnSystemRequest")
  local onStatusUpdate = get_id_by_val(r_actual, "SDL.OnStatusUpdate: UPDATING")
  print("Id of 'OnSystemRequest': " .. onSystemRequestId)
  print("Id of 'SDL.OnStatusUpdate: UPDATING': " .. onStatusUpdate)
  if onStatusUpdate < onSystemRequestId then
    self:FailTestCase("Unexpected 'SDL.OnStatusUpdate: UPDATING' before 'OnSystemRequest'")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_StopSDL()
  StopSDL()
end

return Test
