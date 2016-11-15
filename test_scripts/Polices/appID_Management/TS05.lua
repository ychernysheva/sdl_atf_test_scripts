---------------------------------------------------------------------------------------------
-- Requirement summary: 
--     [RegisterAppInterface] Case-insensitivity of appName
-- Description: 
--     SDL must be case-insensetive when comparing the value of "appName" 
--     received within RegisterAppInterface against the value(s) of "nicknames" section 
--     for the corresponding appID provided by the application.
-- 
-- Test:
--     1. Preconditions:
--        - Assign for app2 specific policies with nickname = "MediaApp"
--     2. Steps
--        - Register app2 with appName = "MediAAPP"
--     3. Expected result:
--        - Response has the following data: success = true, resultCode = "SUCCESS"
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
  function Test:Test()  
    local registerAppInterfaceParams =
      {
        syncMsgVersion =
        {
          majorVersion = 3,
          minorVersion = 0
        },
        appName = "MediAAPP",
        isMediaApplication = true,
        languageDesired = 'EN-US',
        hmiDisplayLanguageDesired = 'EN-US',
        appHMIType = { "NAVIGATION" },
        appID = "xyz",
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
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = "MediAAPP" }})
    self.mobileSession2:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
  end

--[[ Postconditions ]]
  function Test:Post()
  end

return Test	