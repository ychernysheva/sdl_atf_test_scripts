---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PTU] [GENIVI] PolicyTableUpdate is failed by any reason and "ForceProtectedService"=ON at .ini file
-- [PTU] [GENIVI] SDL must start PTU for any app except navi right after app successfully request to start first secure service
--
-- Description:
-- In case SDL starts PolicyTableUpdate in case of no "certificate" at "module_config" section at LocalPT
-- and PolicyTableUpdate is failed by any reason even after retry strategy
-- and "ForceProtectedService" is ON(0x07) at .ini file
-- and app sends StartService (<any_serviceType>, encypted=true) to SDL
-- SDL must respond StartService (NACK) to this mobile app
--
-- 1. Used preconditions:
-- RPC SetAudioStreamingIndicator is allowed by policy
-- ForceProtectedService is set to ON in .ini file
-- Media app exists in LP, no certificate in module_config
-- Register and activate application.
-- Send StartService(serviceType = 7 (RPC), RPCfunctionID = 48(SetAudioStreamingIndicator))
--  -> SDL should trigger PTU: SDL.OnStatusUpdate(UPDATE_NEEDED)
--  -> SDL should not respond to StartService_request
--  -> SDL should not process request to HMI
--
-- 2. Performed steps
-- 2.1. Wait PTU retry sequence to elapse.
-- 2.2. Send second StartService(serviceType = 7 (RPC), RPCfunctionID = 48(SetAudioStreamingIndicator))
--
-- Expected result:
-- 1. SDL must respond StartService (NACK) to this mobile app
-- 2. SDL must respond to second StartService (NACK) to this mobile app
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.application1.registerAppInterfaceParams.appHMIType = {"MEDIA"}
config.application1.registerAppInterfaceParams.isMediaApplication = true
--TODO(istoimenova): Should be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyCeritificates = require('user_modules/shared_testcases/testCasesForPolicyCeritificates')
local events = require('events')
local Event = events.Event

--[[ Local variables ]]
local time_wait = (60 + 61 + 62 + 62 + 62 + 62)*1000 + 10000 --10 sec tolerance
local time_ptu_finish = 0

--[[ General Precondition before ATF start ]]
commonPreconditions:BackupFile("smartDeviceLink.ini")
commonFunctions:write_parameter_to_smart_device_link_ini("ForceProtectedService", "0x07")
testCasesForPolicyCeritificates.update_preloaded_pt(config.application1.registerAppInterfaceParams.appID, false, {1,1,1,1,1})
testCasesForPolicyCeritificates.create_ptu_certificate_exist(false, true)
commonSteps:DeletePolicyTable()
commonSteps:DeleteLogsFiles()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_ActivateApp()
  commonSteps:ActivateAppInSpecificLevel(self, self.applications[config.application1.registerAppInterfaceParams.appName])
  EXPECT_NOTIFICATION("OnHMIStatus", {systemContext = "MAIN", hmiLevel = "FULL"})
end

function Test:Precondition_First_StartService()
  self.mobileSession.correlationId = self.mobileSession.correlationId + 1

  local msg = {
    serviceType = 7,
    frameInfo = 0,
    rpcType = 0,
    rpcFunctionId = 48,
    encryption = true,
    rpcCorrelationId = self.mobileSession.correlationId,
    payload = '{ "audioStreamingIndicator" : "PAUSE" }'
  }

  self.mobileSession:Send(msg)

  local startserviceEvent = Event()
  startserviceEvent.matches =
  function(_, data)
    return ( (data.serviceType == 7) and (data.frameInfo == 2 or data.frameInfo == 3) )
  end

  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", { status = "UPDATE_NEEDED" }, { status = "UPDATING" }):Times(2)
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
  :Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
    end)

  EXPECT_HMICALL("UI.SetAudioStreamingIndicator"):Times(0)
  self.mobileSession:ExpectEvent(startserviceEvent, "Service 7: RPC SetAudioStreamingIndicator"):Times(0)

  commonTestCases:DelayedExp(10000)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_PolicyTableUpdate_retry_sequence_elapse()
  print("Wait retry sequence to elapse")

  local startserviceEvent = Event()
  startserviceEvent.matches =
  function(_, data)
    return ( (data.serviceType == 7) and (data.frameInfo == 2 or data.frameInfo == 3) )
  end

  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate",
    {status="UPDATE_NEEDED"}, {status = "UPDATING"},
    {status="UPDATE_NEEDED"}, {status = "UPDATING"},
    {status="UPDATE_NEEDED"}, {status = "UPDATING"},
    {status="UPDATE_NEEDED"}, {status = "UPDATING"},
    {status="UPDATE_NEEDED"})
  :Times(9)
  :Timeout(time_wait)
  :Do(function(exp)
      if(exp == 9) then
        time_ptu_finish = timestamp()
      end
    end)

  self.mobileSession:ExpectEvent(startserviceEvent, "Service 7: StartServiceNACK")
  :ValidIf(function(_, data)
      local function verify_time_response()
        if (time_ptu_finish == 0) then
          commonFunctions:printError("Response of Service 7 is received before PTU retry sequence finish")
          return false
        else
          return true
        end
      end

      if data.frameInfo == 2 then
        commonFunctions:printError("Service 7: StartServiceACK is received")
        verify_time_response()
        return false
      elseif data.frameInfo == 3 then
        local result = verify_time_response()
        print("Service 7: Audio NACK")
        return (result and true)
      else
        verify_time_response()
        commonFunctions:printError("Service 7: StartServiceACK/NACK is not received at all.")
        return false
      end
    end)
  :Timeout(time_wait)

  commonTestCases:DelayedExp(time_wait)
end

function Test:TestStep_RPC_NACK()
  self.mobileSession.correlationId = self.mobileSession.correlationId + 1

  local msg = {
    serviceType = 7,
    frameInfo = 0,
    rpcType = 0,
    rpcFunctionId = 48,
    encryption = true,
    rpcCorrelationId = self.mobileSession.correlationId,
    payload = '{ "audioStreamingIndicator" : "PAUSE" }'
  }
  testCasesForPolicyCeritificates.start_service_NACK(self, msg, 7,"RPC")
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_Restore_files()
  os.execute( " rm -f files/ptu_certificate_exist.json" )
  commonPreconditions:RestoreFile("smartDeviceLink.ini")
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end

function Test.Postcondition_Stop()
  StopSDL()
end

return Test
