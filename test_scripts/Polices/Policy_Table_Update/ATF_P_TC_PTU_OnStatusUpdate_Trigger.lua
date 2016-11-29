---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PolicyTableUpdate] OnStatusUpdate trigger
--
-- Description:
-- PoliciesManager must notify HMI via SDL.OnStatusUpdate notification right after one of the statuses
-- of UPDATING, UPDATE_NEEDED and UP_TO_DATE is changed from one to another.
--
-- Steps:
-- 1. Register new app1
-- 2. SDL->HMI: Verify status of SDL.OnStatusUpdate notification
-- 3. Trigger PTU
-- 4. Register new app2
--
-- Expected result:
-- Status changes in a wollowing way:
-- "UPDATE_NEEDED" -> "UPDATING" -> "UP_TO_DATE" -> "UPDATE_NEEDED" -> "UPDATING"
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local mobileSession = require("mobile_session")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ Local Variables ]]
local expectedResult = {"UPDATE_NEEDED", "UPDATING", "UP_TO_DATE", "UPDATE_NEEDED", "UPDATING"}
local actualResult = {}

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTERNAL_PROPRIETARY")
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")

--[[ Specific Notifications ]]

EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
:ValidIf(function(exp, data)
    print(exp.occurences .. ": " .. tostring(data.params.status))
    actualResult[exp.occurences] = data.params.status
  end)
:Times(AnyNumber())
:Pin()

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:PTU()
  local policy_file_path = "/tmp/fs/mp/images/ivsu_cache/"
  local policy_file_name = "PolicyTableUpdate"
  local file = "files/jsons/Policies/Policy_Table_Update/ptu_18707_1.json"
  local reqId = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")
  EXPECT_HMIRESPONSE(reqId, {status = "UPDATING"})
  local requestId = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(requestId, {result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
  self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest", {requestType = "PROPRIETARY", fileName = policy_file_name})
  EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
  :Do(function(_, _)
      local corIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {requestType = "PROPRIETARY", fileName = policy_file_name}, file)
      EXPECT_HMICALL("BasicCommunication.SystemRequest")
      :Do(function(_, data)
          self.hmiConnection:SendResponse(data.id, "BasicCommunication.SystemRequest", "SUCCESS", {})
          self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate", {policyfile = policy_file_path .. policy_file_name})
        end)
      EXPECT_RESPONSE(corIdSystemRequest, { success = true, resultCode = "SUCCESS"})
      :Do(function(_, _)
          requestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"StatusUpToDate"}})
          EXPECT_HMIRESPONSE(requestId)
        end)
    end)
end

function Test:StartNewSession()
  self.mobileSession2 = mobileSession.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartService(7)
end

function Test:RegisteNewApp()
  config.application2.registerAppInterfaceParams.appName = "App1"
  config.application2.registerAppInterfaceParams.appID = "123_abc"
  local corId = self.mobileSession2:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered",
    { application = { appName = config.application2.registerAppInterfaceParams.appName }})
  self.mobileSession2:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
end

function Test:ValidateResult()
  EXPECT_ANY()
  :ValidIf(function(_, _)
      for k in pairs(expectedResult) do
        if (actualResult[k] ~= expectedResult[k]) then
          return false
        end
      end
      return true
    end)
end

return Test
