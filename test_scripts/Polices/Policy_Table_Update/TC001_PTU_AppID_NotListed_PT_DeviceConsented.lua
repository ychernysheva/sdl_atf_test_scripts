---------------------------------------------------------------------------------------------
-- Description: 
--     SDL should request PTU in case new application is registered and is not listed in PT
--     and device is consented.
--     1. Used preconditions
--       SDL is built with "-DEXTENDED_POLICY: EXTERNAL_PROPRIETARY" flag
--       Connect mobile phone over WiFi. 
--       Register new application.
--       Successful PTU. Device is consented.
--     2. Performed steps
--       Register new application
--
-- Requirements summary: 
--     [PolicyTableUpdate] Request PTU - an app registered is not listed in PT (device consented)
--
-- Expected result:
--     PTU is requested. PTS is created.
--     SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
--     SDL->HMI: BasicCommunication.PolicyUpdate
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]  
  local commonSteps = require('user_modules/shared_testcases/commonSteps')
  local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
  local commonPreconditions = require ('user_modules/shared_testcases/commonPreconditions')
  local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
  
--[[ General Precondition before ATF start ]]
  -- commonFunctions:SDLForceStop() 
  testCasesForPolicyTable:Update_PolicyFlag("ENABLE_EXTENDED_POLICY", "OFF")
  testCasesForPolicyTable:CheckPolicyFlagAfterBuild("ENABLE_EXTENDED_POLICY","OFF")
  commonSteps:DeleteLogsFileAndPolicyTable()
  commonPreconditions:Connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp("connecttest_RAI.lua")
 
  --ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
  config.defaultProtocolVersion = 2
  
--[[ General Settings for configuration ]]
  Test = require('user_modules/connecttest_RAI')
  require('cardinalities')
  require('user_modules/AppTypes')
  local mobile_session = require('mobile_session')
 
--[[ Preconditions ]]
  function Test:Precondition_remove_user_connecttest()
    os.execute( "rm -f ./user_modules/connecttest_RAI.lua" )
  end

--[[ Test ]]
  --ToDo: Function should be debugged! Runtime error!
  --commonFunctions:newTestCasesGroup("TC_PTU_AppID_NotListed_PT_DeviceConsented")
  function Test:TestStep_ConnectMobile()
    self:connectMobile()
  end

  function Test:TestStep_StartNewSession()
    self.mobileSession = mobile_session.MobileSession( self, self.mobileConnection)
    self.mobileSession:StartService(7)
  end

  function Test:TestStep_PTU_AppID_NotListed_PT()
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