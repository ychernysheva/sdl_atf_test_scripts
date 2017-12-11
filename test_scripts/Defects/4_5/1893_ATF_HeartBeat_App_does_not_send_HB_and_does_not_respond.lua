----------------------------------------------------------------------------------------------------
-- Script verifies issue https://github.com/SmartDeviceLink/sdl_core/issues/1893
-- Flow: PROPRIETARY
----------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require("user_modules/script_runner")
local common = require("test_scripts/Defects/4_5/commonDefects")
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local mobile_session = require('mobile_session')

--[[ General Precondition before ATF start ]]
config.defaultProtocolVersion = 3
config.application1.registerAppInterfaceParams.isMediaApplication = true

-- [[Local variables]]
local default_app_params = config.application1.registerAppInterfaceParams
local default_app_params2 = config.application2.registerAppInterfaceParams

--[[ Local Functions ]]
local function updateINIFile()
  common.backupINIFile()
  commonFunctions:write_parameter_to_smart_device_link_ini("HeartBeatTimeout", 5000)
end

local function Start_Session_And_Register_App(self)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession.sendHeartbeatToSDL = false
  self.mobileSession.answerHeartbeatFromSDL = false
  self.mobileSession.ignoreSDLHeartBeatACK = false
  self.mobileSession:StartRPC()
  :Do(function()
      local correlation_id = self.mobileSession:SendRPC("RegisterAppInterface", default_app_params)
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {
        application = { appName = default_app_params.appName }
      })
      :Do(function(_,data)
          default_app_params.hmi_app_id = data.params.application.appID
        end)
      self.mobileSession:ExpectResponse(correlation_id, { success = true, resultCode = "SUCCESS" })
      self.mobileSession:ExpectNotification("OnHMIStatus", {
        hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"
      })
      self.mobileSession:ExpectNotification("OnPermissionsChange", {})
    end)
end

local function Register_Second_App_With_HeartBeat(self)
  self.mobileSession1 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession1.sendHeartbeatToSDL = false
  self.mobileSession1.answerHeartbeatFromSDL = true
  self.mobileSession1.ignoreSDLHeartBeatACK = false
  self.mobileSession1:StartRPC()
  :Do(function()
      local correlation_id = self.mobileSession1:SendRPC("RegisterAppInterface", default_app_params2)
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {
        application = { appName = default_app_params2.appName }
      })
      self.mobileSession1:ExpectResponse(correlation_id, { success = true, resultCode = "SUCCESS" })
      self.mobileSession1:ExpectNotification("OnHMIStatus", {
        hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"
      })
      self.mobileSession1:ExpectNotification("OnPermissionsChange", {})
    end)
end

local function Wait_15_seconds_And_Verify_OnAppUnregistered(self)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {
    appID = default_app_params.hmi_app_id, unexpectedDisconnect =  true
  })
  :Timeout(15000)
  :Do(function()
      self.mobileSession:StopHeartbeat()
    end)
end

local function Verify_That_Second_App_Still_Registered(self)
  local cor_id = self.mobileSession1:SendRPC("RegisterAppInterface", default_app_params2)
  self.mobileSession1:ExpectResponse(cor_id, { success = false, resultCode = "APPLICATION_REGISTERED_ALREADY"})
end

-- [[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Update INI file", updateINIFile)
runner.Step("Start SDL, HMI, connect Mobile", common.start)
runner.Step("SDL Configuration", common.printSDLConfig)

runner.Title("Test")
runner.Step("Start_Session_And_Register_App", Start_Session_And_Register_App)
runner.Step("Register_Second_App_With_HeartBeat", Register_Second_App_With_HeartBeat)
runner.Step("Wait_15_seconds_And_Verify_OnAppUnregistered", Wait_15_seconds_And_Verify_OnAppUnregistered)
runner.Step("Verify_That_Second_App_Still_Registered", Verify_That_Second_App_Still_Registered)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
runner.Step("Restore INI file", common.restoreINIFile)
