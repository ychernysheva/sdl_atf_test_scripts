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
-- switch ATF to use 3rd version (with HeartBeat) of SDL protocol
config.defaultProtocolVersion = 3
-- define default application is Media one
config.application1.registerAppInterfaceParams.isMediaApplication = true

-- [[Local variables]]
-- define parameters for 1st application
local default_app_params = config.application1.registerAppInterfaceParams
-- define parameters for 2nd application
local default_app_params2 = config.application2.registerAppInterfaceParams

--[[ Local Functions ]]

--[[ @updateINIFile: update parameters in SDL .ini file
--! @parameters: none
--! @return: none
--]]
local function updateINIFile()
  -- backup .ini file
  common.backupINIFile()
  -- change the value of 'HeartBeatTimeout' parameter
  commonFunctions:write_parameter_to_smart_device_link_ini("HeartBeatTimeout", 5000)
end

--[[ @Start_Session_And_Register_App: create mobile session, start RPC service and register 1st mobile application
--! @parameters: none
--! self - test object which will be provided automatically by runner module
--! @return: none
--]]
local function Start_Session_And_Register_App(self)
  -- create 1st mobile session
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  -- define parameters for heartbeat: 1st application shouldn't sent heartbeat neither as answer on heartbeat messages
  -- from SDL
  self.mobileSession.sendHeartbeatToSDL = false
  self.mobileSession.answerHeartbeatFromSDL = false
  self.mobileSession.ignoreSDLHeartBeatACK = false
  -- start RPC service
  self.mobileSession:StartRPC()
  :Do(function()
      -- send 'RegisterAppInterface' RPC with defined parameters for mobile application
      -- and return correlation identifier
      local correlation_id = self.mobileSession:SendRPC("RegisterAppInterface", default_app_params)
      -- register expectation of 'BC.OnAppRegistered' notification on HMI connection
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {
        application = { appName = default_app_params.appName }
      })
      :Do(function(_,data)
          -- save HMI application Id into 'hmi_app_id' variable: it will be required in next steps
          default_app_params.hmi_app_id = data.params.application.appID
        end)
      -- register expectation of response for 'RegisterAppInterface' request with appropriate correlation id
      -- on Mobile connection
      self.mobileSession:ExpectResponse(correlation_id, { success = true, resultCode = "SUCCESS" })
      -- register expectation of 'OnHMIStatus' notification on Mobile connection
      -- it's expected that value of 'hmiLevel' parameter will be 'NONE'
      self.mobileSession:ExpectNotification("OnHMIStatus", {
        hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"
      })
      -- register expectation of 'OnPermissionsChange' notification on Mobile connection
      self.mobileSession:ExpectNotification("OnPermissionsChange", {})
    end)
end

--[[ @Register_Second_App_With_HeartBeat: create mobile session, start RPC service and register 2nd mobile application
--! @parameters: none
--! self - test object which will be provided automatically by runner module
--! @return: none
--]]
local function Register_Second_App_With_HeartBeat(self)
  -- create 2nd mobile session
  self.mobileSession1 = mobile_session.MobileSession(self, self.mobileConnection)
  -- define parameters for heartbeat: 2nd application shouldn't sent heartbeat, but should answer on heartbeat messages
  -- from SDL
  self.mobileSession1.sendHeartbeatToSDL = false
  self.mobileSession1.answerHeartbeatFromSDL = true
  self.mobileSession1.ignoreSDLHeartBeatACK = false
  self.mobileSession1:StartRPC()
  :Do(function()
      -- send 'RegisterAppInterface' RPC with defined parameters for mobile application
      -- and return correlation identifier
      local correlation_id = self.mobileSession1:SendRPC("RegisterAppInterface", default_app_params2)
      -- register expectation of 'BC.OnAppRegistered' notification on HMI connection
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {
        application = { appName = default_app_params2.appName }
      })
      -- register expectation of response for 'RegisterAppInterface' request with appropriate correlation id
      -- on Mobile connection
      self.mobileSession1:ExpectResponse(correlation_id, { success = true, resultCode = "SUCCESS" })
      -- register expectation of 'OnHMIStatus' notification on Mobile connection
      -- it's expected that value of 'hmiLevel' parameter will be 'NONE'
      self.mobileSession1:ExpectNotification("OnHMIStatus", {
        hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"
      })
      -- register expectation of 'OnPermissionsChange' notification on Mobile connection
      self.mobileSession1:ExpectNotification("OnPermissionsChange", {})
    end)
end

--[[ @Wait_15_seconds_And_Verify_OnAppUnregistered: wait 15 sec and check if 1st application is unregistered
--! due to heartbeat timeout
--! @parameters: none
--! self - test object which will be provided automatically by runner module
--! @return: none
--]]
local function Wait_15_seconds_And_Verify_OnAppUnregistered(self)
  -- register expectation of 'BC.OnAppUnregistered' notification on HMI connection
  -- it's expected that 1st application is unregistered with 'unexpectedDisconnect' = true
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {
    appID = default_app_params.hmi_app_id, unexpectedDisconnect =  true
  })
  -- increase default timeout for wait from 10s to 15s
  -- this is required in order to heartbeat timeout of SDL is run out
  -- and SDL is able to close session for 1st application
  :Timeout(15000)
  :Do(function()
      -- stop heartbeat (if it was started previously)
      self.mobileSession:StopHeartbeat()
    end)
end

--[[ @Verify_That_Second_App_Still_Registered: verify that 2nd application is still registered
--! @parameters: none
--! self - test object which will be provided automatically by runner module
--! @return: none
--]]
local function Verify_That_Second_App_Still_Registered(self)
  -- send 'RegisterAppInterface' RCP with defined parameters
  local cor_id = self.mobileSession1:SendRPC("RegisterAppInterface", default_app_params2)
  -- register expectation that response will be unsuccessful with appropriate resultCode
  -- meaning session for 2nd application is still alive
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
