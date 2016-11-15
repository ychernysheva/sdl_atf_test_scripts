---------------------------------------------------------------------------------------------
-- Requirement summary: 
--     [OnAppInterfaceUnregistered] "APP_UNAUTHORIZED" in case of failed nickname validation after updated policies
-- Description: 
--     In case the application with "appName" is successfully registered to SDL
--     and the updated policies do not have this "appName" in this app's specific policies
--     (= "nicknames" filed in "<appID>" section of "app_policies")
--     SDL must send OnAppInterfaceUnregistered (APP_UNAUTHORIZED) to such application.
-- 
-- Test:
--     1. Preconditions:
--        - Update Policy Table by assigning for "0000001" application additional nickname = "App1"
--        - Create new mobile session and register "app_new" with nickname = "App1"
--        - Default policies will be used for "app_new"
--     2. Steps:
--        - Update Policy Table by adding "New Application" nickname for "app_new"
--     3. Expected result:
--        - Response OnAppInterfaceUnregistered has the following data: success = true, reason = "APP_UNAUTHORIZED"
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]  
  local Common = require("user_modules/shared_testcases/Policy_app_ID_Management_Common")
  local MobileSession = require("mobile_session")

--[[ General Settings for configuration ]]
  Test = require("connecttest") 
  
--[[ Preconditions ]]  
  function Test:Pre_UpdatePolicy()
    Common:UpdatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_1.json")
  end

  function Test:Pre_StartNewSession()
    self.mobileSession2 = MobileSession.MobileSession(self, self.mobileConnection)
    self.mobileSession2:StartService(7)
  end

--[[ Test ]]
  function Test:Pre_RegisterNewApp()  
    local registerAppInterfaceParams =
      {
        syncMsgVersion =
        {
          majorVersion = 3,
          minorVersion = 0
        },
        appName = "App1",
        isMediaApplication = true,
        languageDesired = 'EN-US',
        hmiDisplayLanguageDesired = 'EN-US',
        appHMIType = { "NAVIGATION" },
        appID = "app_new",
        deviceInfo =
        {
          os = "Android",
          carrier = "Megafon",
          firmwareRev = "Name: Linux, Version: 3.4.0-perf",
          osVersion = "4.4.2",
          maxNumberRFCOMMPorts = 1
        }
      }   
    
    local corId = self.mobileSession2:SendRPC("RegisterAppInterface", registerAppInterfaceParams)    
    
    EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", { status = "UPDATE_NEEDED" })    
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = "App1" }})
    self.mobileSession2:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })    
    EXPECT_HMINOTIFICATION("BasicCommunication.PolicyUpdate")    
  end
  
  function Test:Test_UpdatePolicy()    
    Common:UpdatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_2.json")
    self.mobileSession2:ExpectNotification("OnAppInterfaceUnregistered", { reason = "APP_UNAUTHORIZED"})
  end

  --[[ Postconditions ]]
  function Test:Post()
  end

return Test	