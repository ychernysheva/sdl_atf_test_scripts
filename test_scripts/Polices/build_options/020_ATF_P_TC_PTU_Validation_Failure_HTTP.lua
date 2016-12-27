---------------------------------------------------------------------------------------------
-- HTTP flow
-- Requirements summary:
-- [PolicyTableUpdate] PTU validation failure
--
-- Description:
-- In case PTU validation fails, SDL must log the error locally and discard the policy table update
-- with No notification of Cloud about invalid data and
-- notify HMI with OnPolicyUpdate(UPDATE_NEEDED) .
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- Application is registered.
-- PTU is requested
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- SDL->MOB: OnSystemRequest()
-- SDL->HMI: SDL.OnStatusUpdate(UPDATING)
-- 2. Performed steps
-- MOB->SDL: SystemRequest(policy_file): policy_file with missing mandatory seconds_between_retries
--
-- Expected result:
-- SDL->HMI: OnStatusUpdate(UPDATE_NEEDED)
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local json = require("modules/json")

--[[ Local Variables ]]
local sequence = { }
local app_id = config.application1.registerAppInterfaceParams.appID
local f_name = os.tmpname()
local ptu
local policy_file_name = "PolicyTableUpdate"
local policy_file_path = commonFunctions:read_parameter_from_smart_device_link_ini("SystemFilesPath")
local r_expected = { "UPDATE_NEEDED", "UPDATING", "UPDATE_NEEDED", "UPDATING" }
local r_actual = { }

--[[ Local Functions ]]
local function timestamp()
  local f = io.popen("date +%H:%M:%S.%3N")
  local o = f:read("*all")
  f:close()
  return (o:gsub("\n", ""))
end

local function log(event, ...)
  table.insert(sequence, { ts = timestamp(), e = event, p = {...} })
end

local function show_log()
  print("--- Sequence -------------------------------------")
  for k, v in pairs(sequence) do
    local s = k .. ": " .. v.ts .. ": " .. v.e
    for _, val in pairs(v.p) do
      if val then s = s .. ": " .. val end
    end
    print(s)
  end
  print("--------------------------------------------------")
end

local function check_file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
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
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")
config.defaultProtocolVersion = 2

EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
:Do(function(_, d)
    log("SDL->HMI: N: SDL.OnStatusUpdate", d.params.status)
    table.insert(r_actual, d.params.status)
  end)
:Times(AnyNumber())
:Pin()

function Test:RegisterNotification()
  self.mobileSession:ExpectNotification("OnSystemRequest")
  :Do(function(_, d)
      ptu = json.decode(d.binaryData)
    end)
  :Times(AtLeast(1))
  :Pin()
end

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test.DeletePTUFile()
  if check_file_exists(policy_file_path .. "/" .. policy_file_name) then
    os.remove(policy_file_path .. "/" .. policy_file_name)
    print("Policy file is removed")
  end
end

function Test:ValidatePTS()
  if ptu.policy_table.consumer_friendly_messages.messages then
    self:FailTestCase("Expected absence of 'consumer_friendly_messages.messages' section in PTS")
  end
end

function Test.UpdatePTS()
  ptu.policy_table.device_data = nil
  ptu.policy_table.usage_and_error_counts = nil
  ptu.policy_table.app_policies[app_id] = { keep_context = false, steal_focus = false, priority = "NONE", default_hmi = "NONE" }
  ptu.policy_table.app_policies[app_id]["groups"] = { "Base-4", "Base-6" }
  ptu.policy_table.functional_groupings["DataConsent-2"].rpcs = json.null
  -- remove mandatory field
  ptu.policy_table.module_config.seconds_between_retries = nil
end

function Test.StorePTSInFile()
  local f = io.open(f_name, "w")
  f:write(json.encode(ptu))
  f:close()
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Update_LPT()
  -- clean_table(r_actual)
  local corId = self.mobileSession:SendRPC("SystemRequest", { requestType = "HTTP", fileName = policy_file_name }, f_name)
  log("MOB->SDL: SystemRequest")

  EXPECT_RESPONSE(corId, { success = true, resultCode = "SUCCESS" })
  :Do(function(_, _)
      log("SUCCESS: SystemRequest()")
    end)
end

function Test.Test_ShowSequence()
  show_log()
end

function Test:ValidateResult()
  if not is_table_equal(r_actual, r_expected) then
    local msg = table.concat({
        "\nExpected sequence:\n", commonFunctions:convertTableToString(r_expected, 1),
        "\nActual:\n", commonFunctions:convertTableToString(r_actual, 1) })
    self:FailTestCase(msg)
  end
end

function Test:Validate_LogFile()
  local log_file = "SmartDeviceLinkCore.log"
  local log_path = table.concat({ config.pathToSDL, "/", log_file })
  local exp_msg = "Errors: policy_table.policy_table.module_config.seconds_between_retries: object is not initialized"
  if not commonFunctions:read_specific_message(log_path, exp_msg) then
    local msg = table.concat({ "Expected error message was not found in ", log_file })
    self:FailTestCase(msg)
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Clean()
  os.remove(f_name)
end

function Test.Postconditions_StopSDL()
  StopSDL()
end

return Test
