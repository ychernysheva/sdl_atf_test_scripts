---------------------------------------------------------------------------------------------
-- Description: 
--     SDL should request in case of failed retry strategy during previour IGN_ON
--     1. Used preconditions
--       SDL is built with "-DEXTENDED_POLICY: EXTERNAL_PROPRIETARY" flag
--       Connect mobile phone over WiFi. 
--       Register new application.
--       Successful PTU. Device is consented.
--       Register new application.
--       PTU is requested.
--       IGN OFF
--     2. Performed steps
--       IGN ON.
--       Connect device. Application is registered.
--
-- Requirements summary: 
--     [PolicyTableUpdate] Policy Table Update in case of failed retry strategy during previour IGN_ON (SDL.PolicyUpdate)
--     [HMI API] PolicyUpdate request/response
--
-- Expected result:
--     PTU is requested. PTS is created.
--     SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]  
  local commonSteps = require('user_modules/shared_testcases/commonSteps')
  local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
  local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
  
--[[ General Precondition before ATF start ]]
  -- commonFunctions:SDLForceStop() 
  testCasesForPolicyTable:Update_PolicyFlag("ENABLE_EXTENDED_POLICY", "OFF")
  testCasesForPolicyTable:CheckPolicyFlagAfterBuild("ENABLE_EXTENDED_POLICY","OFF")
  commonSteps:DeleteLogsFileAndPolicyTable()
 
  --ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
  config.defaultProtocolVersion = 2
  
--[[ General Settings for configuration ]]
  Test = require('connecttest')
  require('cardinalities')
  require('user_modules/AppTypes')
  local mobile_session = require('mobile_session')
 

--[[ Preconditions ]]
  testCasesForPolicyTable:flow_PTU_SUCCEESS_EXTERNAL_PROPRIETARY()

--[[ Test ]]
  --ToDo: Function should be debugged! Runtime error!
  --commonFunctions:newTestCasesGroup("Preconditions")

  function Test:Precondition_StartNewSession()
    self.mobileSession1 = mobile_session.MobileSession(self, self.mobileConnection)
    self.mobileSession1:StartService(7)
  end

  function Test:Precondition_RegisterNewApplication()
    local correlationId = self.mobileSession1:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
    
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application2.appName } })
    :Do(function(_,data)
      self.applications[config.application2.registerAppInterfaceParams.appName] = data.params.application.appID

      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})

      testCasesForPolicyTable:create_PTS(true)
      local timeout_after_x_seconds = testCasesForPolicyTable:get_data_from_PTS("timeout_after_x_seconds")
      local seconds_between_retry = testCasesForPolicyTable:get_data_from_PTS("seconds_between_retry")

      EXPECT_HMICALL("BasicCommunication.PolicyUpdate", 
        {
          file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate", 
          timeout = timeout_after_x_seconds,
          retry = seconds_between_retry 
        })
      :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
    end)   
    self.mobileSession1:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS"})
  end

  function Test:Precondition_Suspend()
    self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "SUSPEND" })
    
    -- hmi side: expect OnSDLPersistenceComplete notification
    EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
  end

  function Test:Precondition_IGNITION_OFF()
    StopSDL()

    self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "IGNITION_OFF" })

    EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")

    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
    :Times(2)
  end

  function Test:Precondtion_StartSDL()
    StartSDL(config.pathToSDL, config.ExitOnCrash)
  end

  function Test:Precondtion_initHMI()
    self:initHMI()
  end

  function Test:Precondtion_initHMI_onReady()
    self:initHMI_onReady()
  end

  function Test:Precondtion_initHMI_onReady()
    self:connectMobile()
  end

  function Test:Precondtion_CreateSession()
    self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
    self.mobileSession:StartService(7)
  end

  --commonFunctions:newTestCasesGroup("TC_PTU_AppID_NotListed_PT_DeviceConsented")
  function Test:TestStep_PTU_NotSuccessful_AppID_ListedPT_NewIgnCycle()
    local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
    
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application1.appName } })
    :Do(function(_,data)

      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})

      testCasesForPolicyTable:create_PTS(true)
      local timeout_after_x_seconds = testCasesForPolicyTable:get_data_from_PTS("timeout_after_x_seconds")
      local seconds_between_retry = testCasesForPolicyTable:get_data_from_PTS("seconds_between_retry")
      
      EXPECT_HMICALL("BasicCommunication.PolicyUpdate", 
        {
          file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate", 
          timeout = timeout_after_x_seconds, 
          retry = seconds_between_retry 
        })
      :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
      end)
    end)   

    self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS"})
  end

return Test	