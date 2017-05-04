---------------------------------------------------------------------------------------------
-- HTTP flow
-- Requirement summary:
-- [PolicyTableUpdate] PTU unsuccessful even after Retry strategy - initiate PTU the next ignition cycle
--
-- Description:
-- In case the policy table exchange is unsuccessful after the retry strategy is completed,
-- the Policy Manager must initiate the new PT exchange sequence upon the next ignition on.
--
-- Preconditions
-- 1. Update LPT by shorten retry cycle
-- 2. LPT is updated -> SDL.OnStatusUpdate(UP_TO_DATE)
-- Steps:
-- 1. Register new app -> PTU sequence started
-- 2. PTU retry sequence failed -> last status of SDL.OnStatusUpdate(UPDATE_NEEDED)
-- 3. IGN_OFF
-- 4. IGN_ON
-- 5. Register app -> PTU sequence started
-- 6. Verify first status of SDL.OnStatusUpdate()
-- 7. Verify that PTS is created
--
-- Expected result:
-- 6. Status: UPDATE_NEEDED
-- 7. PTS is created
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local mobileSession = require("mobile_session")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local commonPreconditions = require("user_modules/shared_testcases/commonPreconditions")
local json = require("modules/json")

--[[ Local Variables ]]
local system_file_path = commonFunctions:read_parameter_from_smart_device_link_ini("SystemFilesPath")
local ptu
local ptu_file = os.tmpname()
local sequence = { }
local attempts_1 = { 30, 31, 62, 93, 124, 155 }

local attempts_2 = { 30 }--, 31, 62, 93, 124, 155 }
--local r_expected_1_status = { "UPDATE_NEEDED", "UPDATING"}
local r_expected_1_status = { "UPDATE_NEEDED", "UPDATING", -- trigger PTU, start t0
  "UPDATE_NEEDED", "UPDATING", -- elapsed to, start t1
  "UPDATE_NEEDED", "UPDATING", -- elapsed t1, start t2
  "UPDATE_NEEDED", "UPDATING", -- elapsed t2, start t3
  "UPDATE_NEEDED", "UPDATING", -- elapsed t3, start t4
  "UPDATE_NEEDED", "UPDATING", -- elapsed t4, start t5
  "UPDATE_NEEDED"
}

local r_expected_2_status = { "UPDATE_NEEDED", "UPDATING", -- trigger PTU, start t0
  "UPDATE_NEEDED", "UPDATING" -- elapsed to, start t1
}
local r_actual_sequence = { }
local r_actual_1_status = { }

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

local function check_file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local function update_ptu()
  if(ptu == nil) then
    local config_path = commonPreconditions:GetPathToSDL()
    local pathToFile = config_path .. 'sdl_preloaded_pt.json'

    local file = io.open(pathToFile, "r")
    local json_data = file:read("*all")
    file:close()

    ptu = json.decode(json_data)
  end

  ptu.policy_table.device_data = nil
  ptu.policy_table.usage_and_error_counts = nil
  ptu.policy_table.app_policies["0000001"] = { keep_context = false, steal_focus = false, priority = "NONE", default_hmi = "NONE" }
  ptu.policy_table.app_policies["0000001"]["groups"] = { "Base-4", "Base-6" }
  ptu.policy_table.functional_groupings["DataConsent-2"].rpcs = json.null
  -- updating parameters in order to speed up the process
  ptu.policy_table.module_config.seconds_between_retries = { 1, 1, 1, 1, 1 }
  ptu.policy_table.module_config.timeout_after_x_seconds = 30
end

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")
config.defaultProtocolVersion = 2

--[[ Specific Notifications ]]
function Test:RegisterNotification()
  self.mobileSession:ExpectNotification("OnSystemRequest")
  :Do(function(_, d)
      print("SDL->MOB: OnSystemRequest()", d.payload.requestType)
      ptu = json.decode(d.binaryData)
    end)
  :Times(AtLeast(1))
  :Pin()
end

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:ValidatePTS()
  if(ptu == nil) then
    self:FailTestCase("Binary data is empty. Preloaded file will be used.")
  else
    if ptu.policy_table.consumer_friendly_messages.messages then
      self:FailTestCase("Expected absence of 'consumer_friendly_messages.messages' section in PTS")
    end
  end
end

function Test.UpdatePTS()
  update_ptu()
end

function Test.StorePTSInFile()
  local f = io.open(ptu_file, "w")
  f:write(json.encode(ptu))
  f:close()
end

function Test:Update_LPT()
  local corId = self.mobileSession:SendRPC("SystemRequest", { requestType = "HTTP", fileName = "PolicyTableUpdate" }, ptu_file)
  EXPECT_RESPONSE(corId, { success = true, resultCode = "SUCCESS" })
end

-- --[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:StartNewMobileSession()
  self.mobileSession2 = mobileSession.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartService(7)
end

function Test:RegisterEvents()
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
  :Do(function(_, d)
      print("SDL->HMI: SDL.OnStatusUpdate", d.params.status)
      log("SDL->HMI: SDL.OnStatusUpdate", d.params.status)
      table.insert(r_actual_sequence, d.params.status)
    end)
  :Times(AnyNumber())
  :Pin()

  self.mobileSession:ExpectNotification("OnSystemRequest", { requestType = "HTTP" })
  :Do(function(_,data)
      print("SDL->MOB1: OnSystemRequest, requestType: " .. data.payload.requestType)
      log("SDL->MOB1: OnSystemRequest, requestType: " .. data.payload.requestType)
    end)
  :Times(AnyNumber())
  :Pin()

  self.mobileSession2:ExpectNotification("OnSystemRequest", { requestType = "HTTP" })
  :Do(function(_,data)
      print("SDL->MOB2: OnSystemRequest, requestType: " .. data.payload.requestType)
      log("SDL->MOB2: OnSystemRequest, requestType: " .. data.payload.requestType)
    end)
  :Times(AnyNumber())
  :Pin()
end

function Test:RegisterApp_2()
  EXPECT_HMICALL("BasicCommunication.UpdateAppList")
  :Do(function(_, d)
      self.hmiConnection:SendResponse(d.id, d.method, "SUCCESS", { })
      self.applications = { }
      for _, app in pairs(d.params.applications) do
        self.applications[app.appName] = app.appID
      end
    end)
  :Times(Between(1,2))

  local corId = self.mobileSession2:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
  log("MOB2->SDL: RegisterAppInterface")
  self.mobileSession2:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
  :Do(function(_,data)
      log("SDL->MOB2: " .. data.payload.resultCode .. ": RegisterAppInterface")
    end)
end

for cycles = 1, #attempts_1 do
  Test["Starting waiting t" .. (cycles - 1) .. " [" .. attempts_1[cycles] .. "] sec"] = function() end

  for i = 1, (attempts_1[cycles]/5) do
    Test["Waiting " .. i * 5 .. " sec"] = function()
      os.execute("sleep 5")
    end
  end

  function Test.FinishCycle()
    --r_actual_2_status = r_actual_sequence[1]
    log("--- retry " .. (cycles - 1) .. " finished ---")
  end

end

function Test.FinishCycle_1()
  r_actual_1_status = r_actual_sequence--[#r_actual_sequence]
  log("--- 1st retry sequence finished ---")
  r_actual_sequence = { }
end

function Test:Ignition_Off()
  log("-----------------------")
  log("IGNITION OFF")
  StopSDL()
  self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "IGNITION_OFF" })
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
  :Times(2)
end

function Test.CleanData()
  os.remove(config.pathToSDL .. "/app_info.dat") -- in order to skip resumption
  os.remove(system_file_path .. "/sdl_snapshot.json")
  if not check_file_exists(system_file_path .. "/sdl_snapshot.json") then
    print("PTS is removed")
  end
end

function Test:RunSDL()
  log("IGNITION ON")
  log("-----------------------")
  self:runSDL()
end

function Test:InitHMI()
  self:initHMI()
end

function Test:InitHMI_onReady()
  self:initHMI_onReady()
end

function Test:ConnectMobile()
  self:connectMobile()
end

function Test:StartMobileSession_1()
  self.mobileSession = mobileSession.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
end

function Test:StartMobileSession_2()
  self.mobileSession2 = mobileSession.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartService(7)
end

function Test:RegisterEvents()
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
  :Do(function(_, d)
      log("SDL->HMI: SDL.OnStatusUpdate", d.params.status)
      table.insert(r_actual_sequence, d.params.status)
    end)
  :Times(AnyNumber())
  :Pin()

  self.mobileSession:ExpectNotification("OnSystemRequest", { requestType = "HTTP" })
  :Do(function(_,data)
      log("SDL->MOB1: OnSystemRequest, requestType: " .. data.payload.requestType)
    end)
  :Times(AnyNumber())
  :Pin()

  self.mobileSession2:ExpectNotification("OnSystemRequest", { requestType = "HTTP" })
  :Do(function(_,data)
      log("SDL->MOB2: OnSystemRequest, requestType: " .. data.payload.requestType)
    end)
  :Times(AnyNumber())
  :Pin()
end

function Test:RegisterApp_2()
  EXPECT_HMICALL("BasicCommunication.UpdateAppList")
  :Do(function(_, d)
      self.hmiConnection:SendResponse(d.id, d.method, "SUCCESS", { })
      self.applications = { }
      for _, app in pairs(d.params.applications) do
        self.applications[app.appName] = app.appID
      end
    end)
  :Times(Between(1,2))

  local corId = self.mobileSession2:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
  log("MOB2->SDL: RegisterAppInterface")
  self.mobileSession2:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
  :Do(function(_,data)
      log("SDL->MOB2: " .. data.payload.resultCode .. ": RegisterAppInterface")
    end)
end

for cycles = 1, #attempts_2 do
  Test["Starting waiting t" .. (cycles - 1) .. " [" .. attempts_2[cycles] .. "] sec"] = function() end

  for i = 1, (attempts_2[cycles]/5) do
    Test["Waiting " .. i * 5 .. " sec"] = function()
      os.execute("sleep 5")
    end
  end

end
function Test.FinishCycle()
  log("--- 2nd retry sequence (2 cycles) finished---")
end

function Test.ShowSequence()
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

function Test:ValidateStatuses_1()

  local msg = "\nFor the 1st retry cycle last status of OnStatusUpdate()" ..
  "\nExpected: " .. commonFunctions:convertTableToString(r_expected_1_status, 1) ..
  "\nActual: " .. commonFunctions:convertTableToString(r_actual_1_status, 1)

  if ( commonFunctions:is_table_equal(r_expected_1_status, r_actual_1_status) == false) then
    self:FailTestCase(msg)
  end
end
commonFunctions:convertTableToString(r_actual_sequence, 1)
function Test:ValidateStatuses_2()
  local msg = "\nFor the retry cycle first status of OnStatusUpdate()" ..
  "\nExpected: " .. commonFunctions:convertTableToString(r_expected_2_status, 1) ..
  "\nActual: " .. commonFunctions:convertTableToString(r_actual_sequence, 1)

  if ( commonFunctions:is_table_equal(r_expected_2_status, r_actual_sequence) == false) then
    self:FailTestCase(msg)
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Clean()
  os.remove(ptu_file)
end

function Test.Postconditions_StopSDL()
  StopSDL()
end

return Test
