---------------------------------------------------------------------------------------------
-- Requirement summary: 
--     [RegisterAppInterface] DISALLOWED app`s nickname does not match ones listed in Policy Table
-- Description: 
--     PoliciesManager must disallow the app`s registration IN CASE the app`s nickname 
--     does not match those listed in Policy Table under the appID this app registers with.
--
-- Test:
--     1. Preconditions:
--        - Assign for app2 specific policies with nickname = "Media Application"
--     2. Steps:
--        - Register app2 with appName = "ABCD"
--     3. Expected result:
--        - Response has the following data: success = false, resultCode = "DISALLOWED"
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
        appName = "ABCD",
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
    self.mobileSession2:ExpectResponse(corId, { success = false, resultCode = "DISALLOWED" })    
  end

--[[ Postconditions ]]
  function Test:Post()  
  end

return Test	