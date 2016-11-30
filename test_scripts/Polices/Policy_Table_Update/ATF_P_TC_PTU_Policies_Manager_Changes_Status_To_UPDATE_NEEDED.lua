---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PolicyTableUpdate] PoliciesManager changes status to “UPDATE_NEEDED”
--
-- Description:
-- PoliciesManager must change the status to “UPDATE_NEEDED” and notify HMI with
-- OnStatusUpdate(“UPDATE_NEEDED”) in case the timeout taken from "timeout_after_x_seconds" field
-- of LocalPT or "timeout between retries" is expired before PoliciesManager receives SystemRequest
-- with PTU from mobile application.
--
-- Preconditions:
-- 1. Register new app
-- 2. Activate app
-- Steps:
-- 1. Start PTU sequence
-- 2. Verify that SDL.OnStatusUpdate status changed: UPDATE_NEEDED -> UPDATING
-- 3. Sleep right after HMI->SDL: BC.SystemRequest for about 70 sec.
-- 4. Verify that SDL.OnStatusUpdate status changed: UPDATING -> UPDATE_NEEDED
--
-- Expected result:
-- Status of SDL.OnStatusUpdate notification changed: UPDATING -> UPDATE_NEEDED
--
-- TODO: Reduce value of timeout_after_x_seconds parameter in LPT in order to make test faster
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ Local Variables ]]
local expectedResult = { "UPDATE_NEEDED", "UPDATING", "UPDATE_NEEDED" }
local actualResult = { }
local sequence = { }

--[[ Local Functions ]]
local function log(item)
  sequence[#sequence + 1] = item
end

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTERNAL_PROPRIETARY")
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")

--[[ Specific Notifications ]]
EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
:Do(function(_, d)
    log("SDL->HMI: SDL.OnStatusUpdate(" .. d.params.status .. ")")
    table.insert(actualResult, d.params.status)
  end)
:Times(AnyNumber())
:Pin()

EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
:Do(function(_, _)
    log("SDL->HMI: BC.PolicyUpdate")
  end)
:Times(AnyNumber())
:Pin()

EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
:Do(function(_, d)
    log("SDL->HMI: BC.OnAppRegistered('".. d.params.application.appName .. "')")
  end)
:Times(AnyNumber())
:Pin()

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:ActivateApp()
  local requestId1 = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"] })
  EXPECT_HMIRESPONSE(requestId1)
  :Do(function(_, data1)
      if data1.result.isSDLAllowed ~= true then
        local requestId2 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
          { language = "EN-US", messageCodes = { "DataConsent" } })
        EXPECT_HMIRESPONSE(requestId2)
        :Do(function(_, _)
            self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
              { allowed = true, source = "GUI", device = { id = config.deviceMAC, name = "127.0.0.1" } })
            EXPECT_HMICALL("BasicCommunication.ActivateApp")
            :Do(function(_, data2)
                self.hmiConnection:SendResponse(data2.id,"BasicCommunication.ActivateApp", "SUCCESS", { })
              end)
            :Times(1)
          end)
      end
    end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:StartPTU()
  local policy_file_name = "PolicyTableUpdate"
  local file = "files/jsons/Policies/Policy_Table_Update/ptu_19169.json"
  local requestId = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  log("HMI->SDL: SDL.GetURLS")
  EXPECT_HMIRESPONSE(requestId)
  :Do(function(_, _)
      log("SDL->HMI: SDL.GetURLS")
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest", { requestType = "PROPRIETARY", fileName = "PolicyTableUpdate" })
      log("HMI->SDL: BC.OnSystemRequest")
      EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "PROPRIETARY"})
      :Do(function(_, _)
          log("SDL->MOB: OnSystemRequest")
          local corIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {requestType = "PROPRIETARY", fileName = policy_file_name}, file)
          log("MOB->SDL: SystemRequest")
          EXPECT_HMICALL("BasicCommunication.SystemRequest")
          :Do(function(_, data)
              log("SDL->HMI: BC.SystemRequest")
              self.hmiConnection:SendResponse(data.id, "BasicCommunication.SystemRequest", "SUCCESS", {})
              log("HMI->SDL: BC.SystemRequest")
            end)
          EXPECT_RESPONSE(corIdSystemRequest, { success = true, resultCode = "SUCCESS"})
        end)
    end)
end

for i = 1, 13 do
  Test["Waiting " .. i*5 .. " sec"] = function(self)
    os.execute("sleep 5")
  end
end

function Test:ShowSequence()
  print("--- Sequence -------------------------------------")
  for k, v in pairs(sequence) do
    print(k .. ": " .. v)
  end
  print("--------------------------------------------------")
end

function Test:ValidateResult()
  EXPECT_ANY()
  :ValidIf(function(_, _)
      for k, v in pairs(expectedResult) do
        if v ~= actualResult[k] then
          return false, "Expected status of OnStatusUpdate() on occurance: " .. k .. " is: '" .. v .. "', got: '" .. tostring(actualResult[k]) .. "'"
        end
      end
      return true
    end)
  :Times(1)
end

return Test
