---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] PoliciesManager changes status to “UPDATING”
-- [HMI API] OnStatusUpdate
--
-- Description:
-- PoliciesManager must change the status to “UPDATING” and notify HMI with
-- OnStatusUpdate("UPDATING") right after SnapshotPT is sent out to to mobile
-- app via OnSystemRequest() RPC.
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- Application is registered.
-- PTU is requested.
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- 2. Performed steps
-- SDL->app: OnSystemRequest ('url', requestType:HTTP, fileType="JSON", appID)
--
-- Expected result:
-- SDL->HMI: SDL.OnStatusUpdate(UPDATING) right after SDL->app: OnSystemRequest
-- Note: SDL.OnStatusUpdate(UPDATING) may come before OnSystemRequest due to the fact that messages
-- to HMI and to app are sent asynchronously
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local mobile_session = require('mobile_session')

--[[ Local Variables ]]
local act_events = { }
local exp_events = { "BC.OnAppRegistered", "SDL.OnStatusUpdate(UPDATE_NEEDED)", "OnSystemRequest(HTTP)", "SDL.OnStatusUpdate(UPDATING)" }

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
commonSteps:DeletePolicyTable()
commonSteps:DeleteLogsFiles()

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_Connect_device()
  self:connectMobile()
end

function Test:Precondition_StartSession()
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_PoliciesManager_changes_status_UPDATING()
  self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application1.registerAppInterfaceParams.appName } })
  :Do(function()
      table.insert(act_events, exp_events[1])
      EXPECT_NOTIFICATION("OnSystemRequest")
      :Do(function(e, d)
          if (e.occurences == 2) and (d.payload.requestType == "HTTP") then
            table.insert(act_events, exp_events[3])
          end
        end)
      :Times(2)
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
      :Do(function(_, d)
          table.insert(act_events, "SDL.OnStatusUpdate(" .. tostring(d.params.status) .. ")")
        end)
      :Times(2)
    end)
end

function Test:TestStep_CheckResult()
  local msg = "\nExpected sequence:\n"
  .. commonFunctions:convertTableToString(exp_events, 1)
  .. "\nActual sequence:\n"
  .. commonFunctions:convertTableToString(act_events, 1)
  if not (((act_events[3] == exp_events[3]) and (act_events[4] == exp_events[4])) or
    ((act_events[4] == exp_events[3]) and (act_events[3] == exp_events[4])))
  then
    self:FailTestCase(msg)
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_Stop_SDL()
  StopSDL()
end

return Test
