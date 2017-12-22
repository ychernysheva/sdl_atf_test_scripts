---------------------------------------------------------------------------------------------------
-- Navigation common module
---------------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local mobile_session = require("mobile_session")
local json = require("modules/json")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local commonTestCases = require("user_modules/shared_testcases/commonTestCases")
local events = require("events")
local test = require("user_modules/dummy_connecttest")
local expectations = require('expectations')
local Expectation = expectations.Expectation
local constants = require('protocol_handler/ford_protocol_constants')
-- local util = require("atf.util")

local m = {}

--[[ Constants ]]
m.timeout = 2000
m.minTimeout = 500
m.appId1 = 1
m.appId2 = 2
m.frameInfo = constants.FRAME_INFO

--[[ Variables ]]
local ptuTable = {}
local hmiAppIds = {}

--[[ Functions ]]

--[[ @getPTUFromPTS: create policy table update table (PTU)
--! @parameters:
--! pTbl - table with policy table snapshot (PTS)
--! @return: table with PTU
--]]
local function getPTUFromPTS(pTbl)
  pTbl.policy_table.consumer_friendly_messages.messages = nil
  pTbl.policy_table.device_data = nil
  pTbl.policy_table.module_meta = nil
  pTbl.policy_table.usage_and_error_counts = nil
  pTbl.policy_table.functional_groupings["DataConsent-2"].rpcs = json.null
  pTbl.policy_table.module_config.preloaded_pt = nil
  pTbl.policy_table.module_config.preloaded_date = nil
end

--[[ @jsonFileToTable: convert .json file to table
--! @parameters:
--! pFileName - file name
--! @return: table
--]]
local function jsonFileToTable(pFileName)
  local f = io.open(pFileName, "r")
  local content = f:read("*all")
  f:close()
  return json.decode(content)
end

--[[ @tableToJsonFile: convert table to .json file
--! @parameters:
--! pTbl - table
--! pFileName - file name
--]]
local function tableToJsonFile(pTbl, pFileName)
  local f = io.open(pFileName, "w")
  f:write(json.encode(pTbl))
  f:close()
end

--[[ @updatePTU: update PTU table with additional functional group for Navigation RPCs
--! @parameters:
--! pTbl - PTU table
--! pAppId - application number (1, 2, etc.)
--]]
function m.updatePTU(pTbl, pAppId)
  pTbl.policy_table.app_policies[m.getAppID(pAppId)] = {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE",
    groups = { "Base-4", "Location-1" }
  }
end

--[[ @ptu: perform policy table update
--! @parameters:
--! pAppId - application number (1, 2, etc.)
--! pPTUpdateFunc - additional function for update
--]]
local function ptu(pPTUpdateFunc, pAppId)
  if not pAppId then pAppId = 1 end
  local pts_file_name = commonFunctions:read_parameter_from_smart_device_link_ini("SystemFilesPath") .. "/"
    .. commonFunctions:read_parameter_from_smart_device_link_ini("PathToSnapshot")
  local ptu_file_name = os.tmpname()
  local requestId = test.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(requestId)
  :Do(function()
      test.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
        { requestType = "PROPRIETARY", fileName = pts_file_name })
      getPTUFromPTS(ptuTable)

      m.updatePTU(ptuTable, pAppId)

      if pPTUpdateFunc then
        pPTUpdateFunc(ptuTable)
      end

      tableToJsonFile(ptuTable, ptu_file_name)

      local event = events.Event()
      event.matches = function(e1, e2) return e1 == e2 end
      EXPECT_EVENT(event, "PTU event")

      local function getAppsCount()
        local count = 0
        for _ in pairs(hmiAppIds) do
          count = count + 1
        end
        return count
      end
      for id = 1, getAppsCount() do
        local mobileSession = m.getMobileSession(id)
        mobileSession:ExpectNotification("OnSystemRequest", { requestType = "PROPRIETARY" })
        :Do(function()
            print("App ".. id .. " was used for PTU")
            RAISE_EVENT(event, event, "PTU event")
            local corIdSystemRequest = mobileSession:SendRPC("SystemRequest",
              { requestType = "PROPRIETARY" }, ptu_file_name)
            EXPECT_HMICALL("BasicCommunication.SystemRequest")
            :Do(function(_, d3)
                test.hmiConnection:SendResponse(d3.id, "BasicCommunication.SystemRequest", "SUCCESS", { })
                test.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate", { policyfile = d3.params.fileName })
              end)
            mobileSession:ExpectResponse(corIdSystemRequest, { success = true, resultCode = "SUCCESS" })
            :Do(function() os.remove(ptu_file_name) end)
          end)
        :Times(AtMost(1))
      end
    end)
end

--[[ @allowSDL: sequence that allows SDL functionality
--! @parameters:
--]]
local function allowSDL()
  test.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
    { allowed = true, source = "GUI", device = { id = config.deviceMAC, name = "127.0.0.1" } })
end

local function registerStartSecureServiceFunc(pMobSession)
  function pMobSession.mobile_session_impl.control_services:StartSecureService(pServiceId)
    local msg = {
      serviceType = pServiceId,
      frameInfo = constants.FRAME_INFO.START_SERVICE,
      sessionId = self.session.sessionId.get(),
      encryption = true
    }
    self:Send(msg)
  end
  function pMobSession.mobile_session_impl:StartSecureService(pServiceId)
    if not self.isSecuredSession then
      self.security:registerSessionSecurity()
      self.security:prepareToHandshake()
    end
    return self.control_services:StartSecureService(pServiceId)
  end
end

local function registerExpectServiceEventFunc(pMobSession)
  function pMobSession.mobile_session_impl.control_services:ExpectControlMessage(pServiceId, pData)
    local event = events.Event()
    event.matches = function(_, data)
    return data.frameType == constants.FRAME_TYPE.CONTROL_FRAME and
      data.serviceType == pServiceId and
      (pServiceId == constants.SERVICE_TYPE.RPC or data.sessionId == self.session.sessionId.get()) and
      (data.frameInfo == constants.FRAME_INFO.START_SERVICE_ACK or
        data.frameInfo == constants.FRAME_INFO.START_SERVICE_NACK)
    end
    local ret = self.session:ExpectEvent(event, "StartService")
    :ValidIf(function(_, data)
        if data.encryption ~= pData.encryption then
          return false, "Expected 'encryption' flag is '" .. tostring(pData.encryption)
            .. "', actual is '" .. tostring(data.encryption) .. "'"
        end
        return true
      end)
    :ValidIf(function(_, data)
        if data.frameInfo ~= pData.frameInfo then
          return false, "Expected 'frameInfo' is '" .. tostring(pData.frameInfo)
            .. "', actual is '" .. tostring(data.frameInfo) .. "'"
        end
        return true
      end)
    return ret
  end
  function pMobSession.mobile_session_impl:ExpectControlMessage(pServiceId, pData)
    local ret = self.control_services:ExpectControlMessage(pServiceId, pData)
    :Do(function(exp, data)
        if exp.status ~= expectations.FAILED and data.encryption == true then
          self.security:registerSecureService(pServiceId)
        end
      end)
    return ret
  end
  function pMobSession:ExpectControlMessage(pServiceId, pData)
    return self.mobile_session_impl:ExpectControlMessage(pServiceId, pData)
  end
  function pMobSession.mobile_session_impl.control_services:ExpectHandshakeMessage()
    -- if not self.session.isSecuredSession then
      local handshakeEvent = events.Event()
      local handShakeExp
      handshakeEvent.matches = function(_,data)
          return data.frameType ~= constants.FRAME_TYPE.CONTROL_FRAME
            and data.serviceType == constants.SERVICE_TYPE.CONTROL
            and data.sessionId == self.session.sessionId.get()
            and data.rpcType == constants.BINARY_RPC_TYPE.NOTIFICATION
            and data.rpcFunctionId == constants.BINARY_RPC_FUNCTION_ID.HANDSHAKE
        end
      handShakeExp = self.session:ExpectEvent(handshakeEvent, "Handshake internal")
      :Do(function(_, data)
        local binData = data.binaryData
          local dataToSend = self.session.security:performHandshake(binData)
          if dataToSend then
            local handshakeMessage = {
              frameInfo = 0,
              serviceType = constants.SERVICE_TYPE.CONTROL,
              encryption = false,
              rpcType = constants.BINARY_RPC_TYPE.NOTIFICATION,
              rpcFunctionId = constants.BINARY_RPC_FUNCTION_ID.HANDSHAKE,
              rpcCorrelationId = data.rpcCorrelationId,
              binaryData = dataToSend
            }
            self.session:Send(handshakeMessage)
          end
          -- if self.session.security:isHandshakeFinished() then
          --   self.session.test:RemoveExpectation(handShakeExp)
          -- end
        end)
    -- end
    return handShakeExp
  end
  function pMobSession:ExpectHandshakeMessage(service)
    local event = events.Event()
    event.matches = function(e1, e2) return e1 == e2 end
    local ret = pMobSession:ExpectEvent(event, "Handshake")
    self.mobile_session_impl.control_services:ExpectHandshakeMessage(service)
    :Do(function(e)
        local isHandshakeFinished = self.mobile_session_impl.control_services.session.security:isHandshakeFinished()
        -- print(e.occurences, isHandshakeFinished)
        if isHandshakeFinished then
          event_dispatcher:RaiseEvent(test.mobileConnection, event)
        end
      end)
    :Times(AnyNumber())
    return ret
  end
end

function m.getAppID(pAppId)
  if not pAppId then pAppId = 1 end
  return config["application" .. pAppId].registerAppInterfaceParams.appID
end

--[[ @preconditions: precondition steps
--! @parameters: none
--]]
function m.preconditions()
  commonFunctions:SDLForceStop()
  commonSteps:DeletePolicyTable()
  commonSteps:DeleteLogsFiles()
end

--[[ @postconditions: postcondition steps
--! @parameters: none
--]]
function m.postconditions()
  StopSDL()
end

--[[ @activateApp: activate application
--! @parameters:
--! pAppId - application number (1, 2, etc.)
--]]
function m.activateApp(pAppId)
  if not pAppId then pAppId = 1 end
  local pHMIAppId = hmiAppIds[config["application" .. pAppId].registerAppInterfaceParams.appID]
  local mobSession = m.getMobileSession(pAppId)
  local requestId = test.hmiConnection:SendRequest("SDL.ActivateApp", { appID = pHMIAppId })
  EXPECT_HMIRESPONSE(requestId)
  mobSession:ExpectNotification("OnHMIStatus",
    { hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN" })
  commonTestCases:DelayedExp(m.minTimeout)
end

--[[ @getHMIAppId: get HMI application identifier
--! @parameters:
--! pAppId - application number (1, 2, etc.)
--! @return: application identifier
--]]
function m.getHMIAppId(pAppId)
  if not pAppId then pAppId = 1 end
  return hmiAppIds[config["application" .. pAppId].registerAppInterfaceParams.appID]
end

--[[ @getMobileSession: get mobile session
--! @parameters:
--! pAppId - application number (1, 2, etc.)
--! @return: mobile session
--]]
function m.getMobileSession(pAppId)
  if not pAppId then pAppId = 1 end
  local session
  if not test["mobileSession" .. pAppId] then
    session = mobile_session.MobileSession(test, test.mobileConnection)
    test["mobileSession" .. pAppId] = session
    registerStartSecureServiceFunc(session)
    registerExpectServiceEventFunc(session)
    if config.defaultProtocolVersion > 2 then
      session.activateHeartbeat = true
      session.sendHeartbeatToSDL = true
      session.answerHeartbeatFromSDL = true
      session.ignoreSDLHeartBeatACK = true
    end
  else
    session = test["mobileSession" .. pAppId]
  end
  return session
end

--[[ @registerAppWithPTU: register mobile application and perform PTU
--! @parameters:
--! pAppId - application number (1, 2, etc.)
--]]
function m.registerApp(pAppId)
  if not pAppId then pAppId = 1 end
  local mobSession = m.getMobileSession(pAppId)
  mobSession:StartService(7)
  :Do(function()
      local corId = mobSession:SendRPC("RegisterAppInterface",
        config["application" .. pAppId].registerAppInterfaceParams)
      test.hmiConnection:ExpectNotification("BasicCommunication.OnAppRegistered",
        { application = { appName = config["application" .. pAppId].registerAppInterfaceParams.appName } })
      :Do(function(_, d1)
          hmiAppIds[config["application" .. pAppId].registerAppInterfaceParams.appID] = d1.params.application.appID
          test.hmiConnection:ExpectNotification("SDL.OnStatusUpdate", { status = "UPDATE_NEEDED" }, { status = "UPDATING" })
          :Times(2)
          test.hmiConnection:ExpectRequest("BasicCommunication.PolicyUpdate")
          :Do(function(_, d2)
              test.hmiConnection:SendResponse(d2.id, d2.method, "SUCCESS", { })
              ptuTable = jsonFileToTable(d2.params.file)
            end)
        end)
      mobSession:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
      :Do(function()
          mobSession:ExpectNotification("OnHMIStatus",
            { hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN" })
          mobSession:ExpectNotification("OnPermissionsChange")
        end)
    end)
end

function m.registerAppWOPTU(pAppId)
  if not pAppId then pAppId = 1 end
  local mobSession = m.getMobileSession(pAppId)
  mobSession:StartService(7)
  :Do(function()
      local corId = mobSession:SendRPC("RegisterAppInterface",
        config["application" .. pAppId].registerAppInterfaceParams)
      test.hmiConnection:ExpectNotification("BasicCommunication.OnAppRegistered",
        { application = { appName = config["application" .. pAppId].registerAppInterfaceParams.appName } })
      :Do(function(_, d1)
          hmiAppIds[config["application" .. pAppId].registerAppInterfaceParams.appID] = d1.params.application.appID
        end)
      mobSession:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
      :Do(function()
          mobSession:ExpectNotification("OnHMIStatus",
            { hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN" })
          mobSession:ExpectNotification("OnPermissionsChange")
        end)
    end)
end

function m.PolicyTableUpdate(pPTUpdateFunc, pExpNotificationFunc, pAppId)
  if not pAppId then pAppId = 1 end
  if not pExpNotificationFunc then
    test.hmiConnection:ExpectNotification("SDL.OnStatusUpdate", { status = "UP_TO_DATE" })
  end
  -- m.getMobileSession(pAppId):ExpectNotification("OnPermissionsChange") -- SDL issue
  ptu(pPTUpdateFunc, pAppId)
end

--[[ @start: starting sequence: starting of SDL, initialization of HMI, connect mobile
--! @parameters:
--! pHMIParams - table with parameters for HMI initialization
--]]
function m.start(pHMIParams)
  test:runSDL()
  commonFunctions:waitForSDLStart(test)
  :Do(function()
      test:initHMI()
      :Do(function()
          commonFunctions:userPrint(35, "HMI initialized")
          test:initHMI_onReady(pHMIParams)
          :Do(function()
              commonFunctions:userPrint(35, "HMI is ready")
              test:connectMobile()
              :Do(function()
                  commonFunctions:userPrint(35, "Mobile connected")
                  allowSDL(test)
                end)
            end)
        end)
    end)
end

--[[ @DelayedExp: delay test step for default timeout
--! @parameters: none
--]]
function m.delayedExp(pTimeOut)
  if not pTimeOut then pTimeOut = m.timeout end
  commonTestCases:DelayedExp(pTimeOut)
end

function m.readFile(pPath)
    local open = io.open
    local file = open(pPath, "rb")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

function test.hmiConnection:ExpectRequest(name, ...)
  local event = events.Event()
  event.matches = function(_, data) return data.method == name end
  local args = table.pack(...)
  local ret = Expectation("HMI call " .. name, self)
  if #args > 0 then
    ret:ValidIf(function(e, data)
        local arguments
        if e.occurences > #args then
          arguments = args[#args]
        else
          arguments = args[e.occurences]
        end
        return compareValues(arguments, data.params, "params")
      end)
  end
  ret.event = event
  event_dispatcher:AddEvent(self, event, ret)
  test:AddExpectation(ret)
  return ret
end

function test.hmiConnection:ExpectNotification(name, ...)
  local event = events.Event()
  event.matches = function(_, data) return data.method == name end
  local args = table.pack(...)
  local ret = Expectation("HMI notification " .. name, self)
  if #args > 0 then
    ret:ValidIf(function(e, data)
        local arguments
        if e.occurences > #args then
          arguments = args[#args]
        else
          arguments = args[e.occurences]
        end
        test.notification_counter = test.notification_counter + 1
        return compareValues(arguments, data.params, "params")
      end)
  end
  ret.event = event
  event_dispatcher:AddEvent(self, event, ret)
  test:AddExpectation(ret)
  return ret
end

function m.getHMIConnection()
  return test.hmiConnection
end

function m.setForceProtectedServiceParam(pParamValue)
  local paramName = "ForceProtectedService"
  commonFunctions:SetValuesInIniFile(paramName .. "%s-=%s-[%d,A-Z,a-z]-%s-\n", paramName, pParamValue)
end

--[[ @protect: make table immutable
--! @parameters:
--! pTbl - mutable table
--! @return: immutable table
--]]
local function protect(pTbl)
  local mt = {
    __index = pTbl,
    __newindex = function(_, k, v)
      error("Attempting to change item " .. tostring(k) .. " to " .. tostring(v), 2)
    end
  }
  return setmetatable({}, mt)
end

return protect(m)
