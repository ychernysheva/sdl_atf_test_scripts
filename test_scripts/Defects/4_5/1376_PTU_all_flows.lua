---------------------------------------------------------------------------------------------
-- Script verifies PTU sequence
-- Supported PROPRIETARY, EXTERNAL_PROPRIETARY and HTTP flows
---------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local mobile_session = require("mobile_session")
local json = require("modules/json")
local atf_logger = require("atf_logger")
local sdl = require("SDL")
local commonSteps = require("user_modules/shared_testcases/commonSteps")

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.defaultProtocolVersion = 2

--[[ Local Variables ]]
local flowType = {
  PROPRIETARY = 1,
  EXTERNAL_PROPRIETARY = 2,
  HTTP = 3
}

--[[ Local Functions ]]
local function preconditions()
  commonFunctions:SDLForceStop()
  commonSteps:DeletePolicyTable()
  commonSteps:DeleteLogsFiles()
end

local function allowSDL(self)
  self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
    { allowed = true, source = "GUI", device = { id = config.deviceMAC, name = "127.0.0.1" } })
end

local function start(self)
  self:runSDL()
  commonFunctions:waitForSDLStart(self)
  :Do(function()
      self:initHMI(self)
      :Do(function()
          commonFunctions:userPrint(35, "HMI initialized")
          self:initHMI_onReady()
          :Do(function()
              commonFunctions:userPrint(35, "HMI is ready")
              self:connectMobile()
              :Do(function()
                  commonFunctions:userPrint(35, "Mobile connected")
                  allowSDL(self)
                end)
            end)
        end)
    end)
end

local function log(...)
  local str = "[" .. atf_logger.formated_time(true) .. "]"
  for i, p in pairs({...}) do
    local delimiter = "\t"
    if i == 1 then delimiter = " " end
    str = str .. delimiter .. p
  end
  commonFunctions:userPrint(35, str)
end

local function ptsToTable(pts_f)
  local f = io.open(pts_f, "r")
  local content = f:read("*all")
  f:close()
  return json.decode(content)
end

local function getPTUFromPTS(ptu)
  ptu.policy_table.consumer_friendly_messages.messages = nil
  ptu.policy_table.device_data = nil
  ptu.policy_table.module_meta = nil
  ptu.policy_table.usage_and_error_counts = nil
  ptu.policy_table.functional_groupings["DataConsent-2"].rpcs = json.null
  ptu.policy_table.module_config.preloaded_pt = nil
  ptu.policy_table.module_config.preloaded_date = nil
  --
  ptu.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID] = {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE"
  }
  ptu.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID]["groups"] = {
    "Base-4", "Base-6"
  }
end

local function storePTUInFile(ptu, ptu_file_name)
  local f = io.open(ptu_file_name, "w")
  f:write(json.encode(ptu))
  f:close()
end

local function checkIfPTSIsSentAsBinary(bin_data, pFlow)
  local pt = nil
  if flowType[pFlow] == flowType.PROPRIETARY then
    pt = json.decode(bin_data).HTTPRequest.body
  elseif flowType[pFlow] == flowType.EXTERNAL_PROPRIETARY or flowType[pFlow] == flowType.HTTP then
    pt = bin_data
  end
  pt = json.decode(pt)
  if not pt.policy_table then
    commonFunctions:userPrint(31, "PTS was not sent to Mobile in payload of OnSystemRequest")
  end
end

local function ptuProprietary(ptu_table, self, pFlow)
  local pts_file_name = commonFunctions:read_parameter_from_smart_device_link_ini("SystemFilesPath") .. "/"
  .. commonFunctions:read_parameter_from_smart_device_link_ini("PathToSnapshot")
  local ptu_file_name = os.tmpname()
  local requestId = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  log("HMI->SDL: RQ: SDL.GetURLS")
  EXPECT_HMIRESPONSE(requestId)
  :Do(function()
      log("SDL->HMI: RS: SDL.GetURLS")
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
        { requestType = "PROPRIETARY", fileName = pts_file_name })
      log("HMI->SDL: N: BC.OnSystemRequest")
      getPTUFromPTS(ptu_table)
      storePTUInFile(ptu_table, ptu_file_name)
      self.mobileSession:ExpectNotification("OnSystemRequest", { requestType = "PROPRIETARY" })
      :Do(function(_, d)
          checkIfPTSIsSentAsBinary(d.binaryData, pFlow)
          log("SDL->MOB: N: OnSystemRequest")
          local corIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
            { requestType = "PROPRIETARY" }, ptu_file_name)
          log("MOB->SDL: RQ: SystemRequest")
          EXPECT_HMICALL("BasicCommunication.SystemRequest")
          :Do(function(_, dd)
              log("SDL->HMI: RQ: BC.SystemRequest")
              self.hmiConnection:SendResponse(dd.id, dd.method, "SUCCESS", { })
              log("HMI->SDL: RS: SUCCESS: BC.SystemRequest")
              self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
                { policyfile = dd.params.fileName })
              log("HMI->SDL: N: SDL.OnReceivedPolicyUpdate")
            end)
          self.mobileSession:ExpectResponse(corIdSystemRequest, { success = true, resultCode = "SUCCESS"})
          :Do(function() os.remove(ptu_file_name) end)
          log("SDL->MOB: RS: SUCCESS: SystemRequest")
        end)
    end)
end

local function ptuHttp(ptu_table, self)
  local policy_file_name = "PolicyTableUpdate"
  local ptu_file_name = os.tmpname()
  getPTUFromPTS(ptu_table)
  storePTUInFile(ptu_table, ptu_file_name)
  local corId = self.mobileSession:SendRPC("SystemRequest",
    { requestType = "HTTP", fileName = policy_file_name }, ptu_file_name)
  log("MOB->SDL: RQ: SystemRequest")
  self.mobileSession:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
  :Do(function()
      log("SDL->MOB: RS: SUCCESS: SystemRequest")
    end)
  os.remove(ptu_file_name)
end

local function expOnStatusUpdate()
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate",
    { status = "UPDATE_NEEDED" }, { status = "UPDATING" }, {status = "UP_TO_DATE" })
  :Do(function(_, d)
      log("SDL->HMI: N: SDL.OnStatusUpdate", d.params.status)
    end)
  :Times(3)
end

local function failInCaseIncorrectPTU(pRequestName, self)
  self:FailTestCase(pRequestName .. " was sent more than once (PTU update was incorrect)")
end

local function raiPTU(self)
  expOnStatusUpdate() -- temp solution due to issue in SDL:
  -- SDL.OnStatusUpdate(UPDATE_NEEDED) notification is sent before BC.OnAppRegistered (EXTERNAL_PROPRIETARY flow)

  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
      local corId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
      log("MOB->SDL: RQ: RegisterAppInterface")
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered",
        { application = { appName = config.application1.registerAppInterfaceParams.appName } })
      :Do(function()
          log("SDL->HMI: N: BC.OnAppRegistered")
          if sdl.buildOptions.extendedPolicy == "PROPRIETARY"
          or sdl.buildOptions.extendedPolicy == "EXTERNAL_PROPRIETARY" then
            EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
            :Do(function(e, d)
                if e.occurences == 1 then -- SDL send BC.PolicyUpdate more than once if PTU update was incorrect
                  log("SDL->HMI: RQ: BC.PolicyUpdate")
                  local ptu_table = ptsToTable(d.params.file)
                  self.hmiConnection:SendResponse(d.id, d.method, "SUCCESS", { })
                  log("HMI->SDL: RS: BC.PolicyUpdate")
                  ptuProprietary(ptu_table, self, sdl.buildOptions.extendedPolicy)
                else
                  failInCaseIncorrectPTU("BC.PolicyUpdate", self)
                end
              end)
          elseif sdl.buildOptions.extendedPolicy == "HTTP" then
            self.mobileSession:ExpectNotification("OnSystemRequest")
            :Do(function(e, d)
                log("SDL->MOB: N: OnSystemRequest", e.occurences, d.payload.requestType)
                if d.payload.requestType == "HTTP" then
                  if e.occurences <= 2 then -- SDL send OnSystemRequest more than once if PTU update was incorrect
                    checkIfPTSIsSentAsBinary(d.binaryData, sdl.buildOptions.extendedPolicy)
                    if d.binaryData then
                      local ptu_table = json.decode(d.binaryData)
                      ptuHttp(ptu_table, self)
                    end
                  else
                    failInCaseIncorrectPTU("OnSystemRequest", self)
                  end
                end
              end)
            :Times(2)
          end
        end)
      self.mobileSession:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
      :Do(function()
          log("SDL->MOB: RS: RegisterAppInterface")
          self.mobileSession:ExpectNotification("OnHMIStatus",
            { hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN" })
          :Do(function(_, d)
              log("SDL->MOB: N: OnHMIStatus", d.payload.hmiLevel)
            end)
          self.mobileSession:ExpectNotification("OnPermissionsChange")
          :Do(function()
              log("SDL->MOB: N: OnPermissionsChange")
            end)
          :Times(2)
        end)
    end)
end

local function checkPTUStatus(self)
  local reqId = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")
  log("HMI->SDL: RQ: SDL.GetStatusUpdate")
  EXPECT_HMIRESPONSE(reqId, { result = { status = "UP_TO_DATE" }})
  :Do(function(_, d)
      log("HMI->SDL: RS: SDL.GetStatusUpdate", tostring(d.result.status))
    end)
end

local function printSDLConfig()
  commonFunctions:printTable(sdl.buildOptions)
end

local function postconditions()
  StopSDL()
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", preconditions)
runner.Step("Start SDL, HMI, connect Mobile", start)
runner.Step("SDL Configuration", printSDLConfig)

runner.Title("Test")
runner.Step("RAI, PTU", raiPTU)
runner.Step("Check Status", checkPTUStatus)

runner.Title("Postconditions")
runner.Step("Stop SDL", postconditions)
