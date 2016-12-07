---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] "pre_DataConsent", "default" and <app id> policies and "'memory_kb'" validation
--
-- Description:
-- In case the "pre_DataConsent" or "default" or <app id> policies are assigned to the application, and "memory_kb" section exists and is not empty,
-- PoliciesManager must ignore the memory constraints in PT defined in "memory_kb" and apply the value "AppDirectoryQuota" from smartDeviceLink.ini file.
-- 1. Used preconditions:
-- a) Set SDL in first life cycle state
-- b) Set AppDirectoryQuota = 15000000 in .ini file
-- c) Register app, activate, consent device and update policy where memory_kb = 5000 for this app
-- 2. Performed steps
-- a) Send PutFile with file 8414449 bytes
-- b) Send one more time this file
--
-- Expected result:
-- a) PutFile SUCCESS resultCode - memory_kb parameter is ignored for app
-- b) PutFile OUT_OF_MEMORY resultCode - AppDirectoryQuota applies for app
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ Local Functions ]]
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

function Test:SetAppDirectoryQuotaInIniFile()
  commonFunctions:SetValuesInIniFile("AppDirectoryQuota = 104857600", "AppDirectoryQuota", "2000000")
end

function Test:Precondition_StartSDL_FirstLifeCycle()
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

function Test:Precondition_Register_Activate_Consent_App_And_Update_Policy_With_memory_kb_Param()
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
              local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {fileName = "PolicyTableUpdate", requestType = "PROPRIETARY"}, "files/ptu_memory_kb_app_1234567.json")
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
                  RUN_AFTER(to_run, 800)
                  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UP_TO_DATE"}):Timeout(500)
                end)
            end)
        end)
    end)
end

--[[ Test ]]
function Test:TestStep_Send_PutFile_Bigger_Than_memory_kb_SUCCESS()
  local cid = self.mobileSession:SendRPC("PutFile", {syncFileName ="1166384_bytes_audio.mp3", fileType ="AUDIO_MP3"}, "files/MP3_1140kb.mp3")
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" }):Timeout(15000)
end

function Test:TestStep_Send_PutFile_Bigger_Than_AppDirectoryQuota_OUT_OF_MEMORY()
  local cid = self.mobileSession:SendRPC("PutFile", {syncFileName ="1166384_bytes_audio_2.mp3", fileType ="AUDIO_MP3"}, "files/MP3_1140kb.mp3")
  EXPECT_RESPONSE(cid, { success = false, resultCode = "OUT_OF_MEMORY" }):Timeout(15000)
end

--[[ Postcondition ]]
function Test:Postcondition_StopSDL()
  StopSDL()
end
