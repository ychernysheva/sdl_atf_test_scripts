---------------------------------------------------------------------------------------------
-- Requirement summary: 
--     [ChangeRegistration]: DISALLOWED in case app sends appName non-existing in app-specific policies
-- Description: 
--     In case app_specific policies are assigned to app
--     AND this app sends ChangeRegistration request with "appName" that does not exist in "nicknames" field in PolicyTable
--     SDL must respond with (DISALLOWED, success:false) to this application (not unregister it).
--
-- Test:
--     1. Preconditions:
--        - Assign for app2 specific policies with nickname = "Test Application"
--     2. Steps
--        - Send ChangeRegistration request with appName = "fghj"
--     3. Expected result:
--        - Response has the following data: success = false, resultCode = "DISALLOWED"
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
  local Common = require("user_modules/shared_testcases/Policy_app_ID_Management_Common")

--[[ General Settings for configuration ]]
  Test = require("connecttest")   

--[[ Preconditions ]]
  function Test:Pre()
    Common:UpdatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_1.json")
  end

--[[ Test ]]  
  function Test:Test()    
    local corId = self.mobileSession:SendRPC("ChangeRegistration", { 
      language = "EN-US",
      hmiDisplayLanguage = "EN-US",
      appName = "fghj" 
      })
    
    self.mobileSession:ExpectResponse(corId, { success = false, resultCode = "DISALLOWED" })
  end

--[[ Postconditions ]]
  function Test:Post()
  end

return Test 