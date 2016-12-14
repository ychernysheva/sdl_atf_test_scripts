---------------------------------------------------------------------------------------------
-- HTTP flow
-- Requirements summary:
-- [PolicyTableUpdate] PTU validation rules
--
-- Description:
-- After Base-64 decoding, SDL must validate the Policy Table Update according to
-- S13j_Applink_Policy_Table_Data_Dictionary_040.xlsx rules: "required" fields must be present,
-- "optional" may be present but not obligatory, "ommited" - accepted to be present in PTU (PTU won't be rejected if the fields with option "ommited" exists)
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- Application is registered
-- PTU is requested
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- SDL->MOB: OnSystemRequest()
-- SDL->HMI: SDL.OnStatusUpdate(UPDATING)
-- 2. Performed steps
-- app->SDL:SystemRequest(requestType=HTTP), policy_file: all sections in data dictionary + optional + omit
--
-- Expected result:
-- SDL->HMI: OnStatusUpdate(UP_TO_DATE)
-- SDL stops timeout started by OnSystemRequest. No other OnSystemRequest messages are received.
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
local json = require("modules/json")

--[[ Local Variables ]]
local sequence = { }
local app_id = config.application1.registerAppInterfaceParams.appID
local f_name = os.tmpname()
local ptu
local actual_request_type
local actual_num_of_system_request = 0

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

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("PROPRIETARY")
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")
config.defaultProtocolVersion = 2

--[[ Specific Notifications ]]
EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
:Do(function(_, d)
    log("SDL->HMI: SDL.OnStatusUpdate()", d.params.status)
  end)
:Times(AnyNumber())
:Pin()

function Test:RegisterNotification()
  self.mobileSession:ExpectNotification("OnSystemRequest")
  :Do(function(_, d)
      log("SDL->MOB: OnSystemRequest()", d.payload.requestType, d.payload.url)
      ptu = json.decode(d.binaryData)
      actual_request_type = d.payload.requestType
      actual_num_of_system_request = actual_num_of_system_request + 1
    end)
  :Times(AnyNumber())
  :Pin()
end

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

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
  -- optional fields
  ptu.policy_table.module_config.vehicle_make = "Vehicle_Make"
  ptu.policy_table.module_config.vehicle_model = "Vehicle_Model"
  ptu.policy_table.module_config.vehicle_year = "2000"
  ptu.policy_table.app_policies[app_id].memory_kb = 1024
  ptu.policy_table.app_policies[app_id].heart_beat_timeout_ms = 5000
end

function Test.StorePTSInFile()
  local f = io.open(f_name, "w")
  f:write(json.encode(ptu))
  f:close()
end

function Test:Update_LPT()
  local corId = self.mobileSession:SendRPC("SystemRequest", { requestType = "HTTP", fileName = "PolicyTableUpdate" }, f_name)
  EXPECT_RESPONSE(corId, { success = true, resultCode = "SUCCESS" })
end

function Test.Test_ShowSequence()
  show_log()
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test:Validate_OnSystemRequest_Type()
  local expected_request_type = "HTTP"
  if expected_request_type ~= actual_request_type then
    local msg = table.concat({
        "\nExpected OnSystemRequest() type is '", expected_request_type,
        "'\nActual: '", actual_request_type, "'"})
    self:FailTestCase(msg)
  end
end

function Test:Validate_OnSystemRequest_Quantity()
  local expected_num_of_system_request = 1
  if expected_num_of_system_request ~= actual_num_of_system_request then
    local msg = table.concat({
        "\nExpected number of OnSystemRequest() notifications is '", expected_num_of_system_request,
        "'\nActual: '", actual_num_of_system_request, "'"})
    self:FailTestCase(msg)
  end
end

function Test.Clean()
  os.remove(f_name)
end

function Test.Postconditions_StopSDL()
  StopSDL()
end

return Test
