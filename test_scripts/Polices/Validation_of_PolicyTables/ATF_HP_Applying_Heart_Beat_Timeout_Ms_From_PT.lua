---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] "pre_DataConsent" policies and " heart_beat_timeout_ms" value
--
-- Description:
-- In case the "pre_DataConsent" policies are assigned to the application, PoliciesManager must apply 'heart_beat_timeout_ms' parameter:
-- 1) in case 'heart_beat_timeout_ms' parameter is presented, SDL must change the applied value of HeartBeatTimeout to the one from Policies 'heart_beat_timeout_ms' parameter
-- 2) in case 'heart_beat_timeout_ms' parameter is not presented -> SDL must use the value of HeartBeatTimeout from .ini file
--
-- 1. Used preconditions:
-- a) Set SDL in first life cycle state
-- b) Set HeartBeatTimeout = 7000 in .ini file
-- c) Register app, activate, consent device and update policy where heart_beat_timeout_ms = 2000 for pre_DataConsent section
-- d) Send OnAllowSDLFunctionality allowed = false to assign pre_DataConsent permission to app
-- 2. Performed steps
-- a) Check heartBeat time sent from SDL
--
-- Expected result:
-- a) SDL send HB with time specified in pre_DataConsent section (2000 ms)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')

--[[ Local Variables ]]
local HBTime

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')
local events = require('events')
local constants = require('protocol_handler/ford_protocol_constants')

--[[ Local Functions ]]
function DelayedExp(time)
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  :Timeout(time+1000)
  RUN_AFTER(function()
      RAISE_EVENT(event, event)
      end, time)
end

local function BackupIniFile()
os.execute('cp ' .. config.pathToSDL .. 'smartDeviceLink.ini' .. ' ' .. config.pathToSDL .. 'backup_smartDeviceLink.ini')
end

local function RestoreIniFile()
os.execute('rm ' .. config.pathToSDL .. 'smartDeviceLink.ini')
os.execute('cp ' .. config.pathToSDL .. 'backup_smartDeviceLink.ini' .. ' ' .. config.pathToSDL .. 'smartDeviceLink.ini')
end

--[[ Preconditions ]]
function Test:Precondition_StopSDL()
StopSDL()
end

function Test:Precondition_DeleteLogsAndPolicyTable()
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()
end

function Test:Precondition_Backup_Ini_File()
BackupIniFile()
end

function Test:Precondition_SetAppDirectoryQuotaInIniFile()
commonFunctions:SetValuesInIniFile("HeartBeatTimeout = 7000", "HeartBeatTimeout", "7000")
end

function Test:Precondition_StartSDL_FirstLifeCycle()
config.defaultProtocolVersion = 3
StartSDL(config.pathToSDL, config.ExitOnCrash)
end

function Test:Precondition_InitHMI_FirstLifeCycle()
self:initHMI()
end

function Test:Precondition_InitHMI_onReady_FirstLifeCycle()
self:initHMI_onReady()
end

function Test:Precondition_ConnectMobile_FirstLifeCycle()
self:connectMobile()
end

function Test:Precondition_StartSession()
self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
self.mobileSession:StartService(7)
end

function Test:Precondition_Restore_Ini_File()
RestoreIniFile()
end

function Test:Precondition_Register_Activate_Consent_App_And_Update_Policy_With_heart_beat_timeout_ms_Param()
local CorIdRAI = self.mobileSession:SendRPC("RegisterAppInterface",
  {
    syncMsgVersion =
    {
      majorVersion = 3,
      minorVersion = 0
    },
    appName = "SPT",
    isMediaApplication = true,
    languageDesired = "EN-US",
    hmiDisplayLanguageDesired = "EN-US",
    appID = "1234567",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  })
EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered",
  {
    application =
    {
      appName = "SPT",
      policyAppID = "1234567",
      isMediaApplication = true,
      hmiDisplayLanguageDesired = "EN-US",
      deviceInfo =
      {
        name = "127.0.0.1",
        id = config.deviceMAC,
        transportType = "WIFI",
        isSDLAllowed = false
      }
    }
  })
:Do(function(_,data)
    local RequestIdActivateApp = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = data.params.application.appID})
    EXPECT_HMIRESPONSE(RequestIdActivateApp, {result = {code = 0, isSDLAllowed = false}, method = "SDL.ActivateApp"})
    :Do(function(_,_)
        local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
        EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
        :Do(function(_,_)
            self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
            EXPECT_HMICALL("BasicCommunication.ActivateApp")
            :Do(function(_,data1)
                self.hmiConnection:SendResponse(data1.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
              end)
          end)
      end)
  end)
EXPECT_RESPONSE(CorIdRAI, { success = true, resultCode = "SUCCESS"})
EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
:Do(function(_,_)
    local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
    EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
    :Do(function()
        self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",{requestType = "PROPRIETARY", fileName = "filename"})
        EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
        :Do(function()
            local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {fileName = "PolicyTableUpdate", requestType = "PROPRIETARY"}, "files/ptu_heart_beat_timeout_ms_app_1234567.json")
            local systemRequestId
            EXPECT_HMICALL("BasicCommunication.SystemRequest")
            :Do(function(_,data)
                systemRequestId = data.id
                self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
                  {
                    policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
                  })
                local function to_run()
                  self.hmiConnection:SendResponse(systemRequestId, "BasicCommunication.SystemRequest", "SUCCESS", {})
                  self.mobileSession:ExpectResponse(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
                end
                RUN_AFTER(to_run, 200)
                EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UP_TO_DATE"}):Timeout(500)
              end)
          end)
      end)
  end)
end

function Test:Precondition_OnAllowSDLFunctionality_From_HMI_To_Assign_pre_DataConsent_For_app()
self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = false, source = "GUI"})
EXPECT_NOTIFICATION("OnPermissionsChange", {})
DelayedExp(500)
end

--[[ Test ]]
function Test:TestStep_Get_HeartBeat_Time()
local function getHB()
  local TimeDelta = 0
  self.mobileSession.sendHeartbeatToSDL = false
  self.mobileSession.answerHeartbeatFromSDL = false
  local event = events.Event()
  event.matches = function(_, data)
    return data.frameType == 0 and
    (data.serviceType == 0) and
    (data.frameInfo == 0) --HeartBeat
  end

  self.mobileSession:ExpectEvent(event, "Heartbeat")
  :ValidIf(function()
      self.mobileSession:Send(
        { frameType = constants.FRAME_TYPE.CONTROL_FRAME,
          serviceType = constants.SERVICE_TYPE.CONTROL,
          frameInfo = constants.FRAME_INFO.HEARTBEAT_ACK
        })
      if TimeDelta ~= 0 then
        TimeDelta = os.time() - TimeDelta
        HBTime = TimeDelta
      else
        TimeDelta = os.time()
      end
      return true

      end):Times(AnyNumber())
    DelayedExp(15000)
  end
  getHB()

end

function Test:TestStep_Check_HB_Time()
  -- Send request to bind ValidIf for HB time validation
  self.mobileSession:SendRPC("UnregisterAppInterface", {})
  EXPECT_RESPONSE("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})
  :ValidIf(function()
      if HBTime == 2 then
        return true
      else
        print("Wrong HearBeat time! Expected: 2s, Actual: " .. HBTime .. "s")
        return false
      end
    end)
end

--[[ Postcondition ]]
function Test:Postcondition_StopSDL()
  StopSDL()
end
