---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PolicyTableUpdate] PTU merge into Local Policy Table
--
-- Description:
-- On successful validation of PTU, SDL must replace the following sections of the Local Policy Table with the corresponding sections from PTU:
-- - module_config,
-- - functional_groupings,
-- - app_policies
--
-- Preconditions
-- 1. LPT has non empty 'module_config', 'functional_groupings', 'app_policies' sections
-- 2. Register new app
-- 3. Activate app
-- Steps:
-- 1. Perform PTU with specific data in 'module_config', 'functional_groupings', 'app_policies' sections
-- 2. After PTU is finished verify data in mentioned sections
--
-- Expected result:
-- Previous version of sections in LPT are replaced by a new ones
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local json = require("modules/json")
local mobileSession = require("mobile_session")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ Local Variables ]]
local policy_file_path = commonFunctions:read_parameter_from_smart_device_link_ini("SystemFilesPath")
local policy_file_name = "PolicyTableUpdate"
local ptu_file = "files/jsons/Policies/Policy_Table_Update/ptu_18190.json"
local sequence = { }

--[[ Local Functions ]]
local function log(item)
  table.insert(sequence, item)
end

local function json_to_table(file)
  local f = io.open(file, "r")
  if f == nil then error("File not found") end
  local ptString = f:read("*all")
  f:close()
  return json.decode(ptString)
end

local function is_table_equal(t1, t2)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then return false end
  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
  for k1, v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not is_table_equal(v1, v2) then return false end
  end
  for k2, v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not is_table_equal(v1, v2) then return false end
  end
  return true
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
:Do(function(_, _)
    log("SDL->HMI: BC.OnAppRegistered")
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

function Test:PTU()

  local requestId = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  log("HMI->SDL: SDL.GetURLS")
  EXPECT_HMIRESPONSE(requestId)
  :Do(function(_, _)
      log("SDL->HMI: SDL.GetURLS")
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest", {requestType = "PROPRIETARY", fileName = policy_file_name})
      log("HMI->SDL: BC.OnSystemRequest")
      EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "PROPRIETARY"})
      :Do(function(_, _)
          log("SDL->MOB: OnSystemRequest")
          local corIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {requestType = "PROPRIETARY", fileName = policy_file_name}, ptu_file)
          log("MOB->SDL: SystemRequest")
          EXPECT_HMICALL("BasicCommunication.SystemRequest")
          :Do(function(_, data)
              log("SDL->HMI: BC.SystemRequest")
              self.hmiConnection:SendResponse(data.id, "BasicCommunication.SystemRequest", "SUCCESS", {})
              log("HMI->SDL: BC.SystemRequest")
              self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate", {policyfile = policy_file_path .. "/" .. policy_file_name})
              log("HMI->SDL: SDL.OnReceivedPolicyUpdate")
            end)
          EXPECT_RESPONSE(corIdSystemRequest, { success = true, resultCode = "SUCCESS"})
          :Do(function(_, _)
              log("SDL->MOB: SystemRequest")
              requestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"StatusUpToDate"}})
              log("HMI->SDL: SDL.GetUserFriendlyMessage")
              EXPECT_HMIRESPONSE(requestId)
              log("SDL->HMI: SDL.GetUserFriendlyMessage")
            end)
        end)
    end)
end

function Test:StartNewMobileSession()
  self.mobileSession2 = mobileSession.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartService(7)
end

function Test:RegisterNewApp()
  EXPECT_HMICALL("BasicCommunication.UpdateAppList")
  :Do(function(_, d)
      self.hmiConnection:SendResponse(d.id, d.method, "SUCCESS", { })
      self.applications = { }
      for _, app in pairs(d.params.applications) do
        self.applications[app.appName] = app.appID
      end
    end)
  local corId = self.mobileSession2:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
  self.mobileSession2:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
end

function Test.ShowSequence()
  print("--- Sequence -------------------------------------")
  for k, v in pairs(sequence) do
    print(k .. ": " .. v)
  end
  print("--------------------------------------------------")
end

function Test:ValidateResult()
  self.mobileSession:ExpectAny()
  :ValidIf(function(_, _)
      local pts = json_to_table(policy_file_path .. "/sdl_snapshot.json")
      local ptu = json_to_table(ptu_file)
      -- Reconcile expected vs actual
      ptu.policy_table.module_config.preloaded_pt = false
      pts.policy_table.app_policies["0000002"] = nil
      -- Compare
      if not is_table_equal(ptu.policy_table.functional_groupings, pts.policy_table.functional_groupings) then
        return false, "Diffs in functional_groupings\nExpected:\n" .. commonFunctions:convertTableToString(ptu.policy_table.functional_groupings, 1) .. "\nActual:\n" .. commonFunctions:convertTableToString(pts.policy_table.functional_groupings, 1)
      end
      if not is_table_equal(ptu.policy_table.module_config, pts.policy_table.module_config) then
        return false, "Diffs in module_config\nExpected:\n" .. commonFunctions:convertTableToString(ptu.policy_table.module_config, 1) .. "\nActual:\n" .. commonFunctions:convertTableToString(pts.policy_table.module_config, 1)
      end
      -- Section app_policies verified for '0000001' app only
      if not is_table_equal(ptu.policy_table.app_policies["0000001"], pts.policy_table.app_policies["0000001"]) then
        return false, "Diffs in app_policies\nExpected:\n" .. commonFunctions:convertTableToString(ptu.policy_table.app_policies["0000001"], 1) .. "\nActual:\n" .. commonFunctions:convertTableToString(pts.policy_table.app_policies["0000001"], 1)
      end
      return true
    end)
  :Times(1)
end

return Test
