--  Requirement summary:
--  [RegisterAppInterface] SUCCESS
--  [RegisterAppInterface] RegisterAppInterface and HMILevel
--
--  Description:
--  Check that it is able to register 5 sessions within 1 phisycal connection.
--  Sessions have to be added one by one.
--
--  1. Used precondition
--  SDL, HMI are running on system.
--  Mobile device is connected to system.
--  1 session is added, 1 app is registered. 
--
--  2. Performed steps
--  Add 2 session
--  appID_2->RegisterAppInterface(params)
--  Add 3 session
--  appID_3->RegisterAppInterface(params)
--  Add 4 session
--  appID_4->RegisterAppInterface(params)
--  Add 5 session
--  appID_5->RegisterAppInterface(params)
--
--  Expected behavior:
--  1. SDL successfully registers all four applications and notifies HMI and mobile 
--     SDL->HMI: OnAppRegistered(params)
--     SDL->appID: SUCCESS, success:"true":RegisterAppInterface() 
--  3. SDL assignes HMILevel after application registering:
--     SDL->appID: OnHMIStatus(HMlLevel, audioStreamingState, systemContext)

-- [[ Required Shared Libraries ]]
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local mobile_session = require('mobile_session')

--[[ General Settings for configuration ]]
Test = require('user_modules/dummy_connecttest')
require('cardinalities')
require('user_modules/AppTypes')

-- [[Local variables]]
local default_app_params2 = config.application2.registerAppInterfaceParams
local default_app_params3 = config.application3.registerAppInterfaceParams
local default_app_params4 = config.application4.registerAppInterfaceParams
local default_app_params5 = config.application5.registerAppInterfaceParams

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
commonSteps:DeletePolicyTable()
commonSteps:DeleteLogsFiles()

function Test:Start_SDL_With_One_Activated_App()
  self:runSDL()
  commonFunctions:waitForSDLStart(self):Do(function()
    self:initHMI():Do(function()
      commonFunctions:userPrint(35, "HMI initialized")
      self:initHMI_onReady():Do(function ()
        commonFunctions:userPrint(35, "HMI is ready")
        self:connectMobile():Do(function ()
          commonFunctions:userPrint(35, "Mobile Connected")
          self:startSession():Do(function ()
            commonFunctions:userPrint(35, "1st App is successfully registered")
          end)
        end)
      end)
    end)
  end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Check that it is able to register 5 sessions within 1 phisycal connection")

function Test:Start_Session2_And_Register_App_2()
  self.mobileSession2 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartRPC():Do(function()
    local correlation_id = self.mobileSession2:SendRPC("RegisterAppInterface", default_app_params2)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = default_app_params2.appName}})
    self.mobileSession2:ExpectResponse(correlation_id, {success = true, resultCode = "SUCCESS"})
    self.mobileSession2:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
    self.mobileSession2:ExpectNotification("OnPermissionsChange", {})  
  end)
end

function Test:Start_Session3_And_Register_App_3()
  self.mobileSession3 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession3:StartRPC():Do(function()
    local correlation_id = self.mobileSession3:SendRPC("RegisterAppInterface", default_app_params3)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = default_app_params3.appName}})
    self.mobileSession3:ExpectResponse(correlation_id, {success = true, resultCode = "SUCCESS"})
    self.mobileSession3:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
    self.mobileSession3:ExpectNotification("OnPermissionsChange", {})  
  end)
end

function Test:Start_Session4_And_Register_App_4()
  self.mobileSession4 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession4:StartRPC():Do(function()
    local correlation_id = self.mobileSession4:SendRPC("RegisterAppInterface", default_app_params4)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = default_app_params4.appName}})
    self.mobileSession4:ExpectResponse(correlation_id, {success = true, resultCode = "SUCCESS"})
    self.mobileSession4:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
    self.mobileSession4:ExpectNotification("OnPermissionsChange", {})  
  end)
end

function Test:Start_Session5_And_Register_App_5()
  self.mobileSession5 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession5:StartRPC():Do(function()
    local correlation_id = self.mobileSession5:SendRPC("RegisterAppInterface", default_app_params5)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = default_app_params5.appName}})
    self.mobileSession5:ExpectResponse(correlation_id, {success = true, resultCode = "SUCCESS"})
    self.mobileSession5:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
    self.mobileSession5:ExpectNotification("OnPermissionsChange", {})  
  end)
end

-- [[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postcondition")
function Test.Stop_SDL()
  StopSDL()
end

return Test