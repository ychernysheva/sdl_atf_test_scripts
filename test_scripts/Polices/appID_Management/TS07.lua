------------- --------------------------------------------------------------------------------
-- Requirement summary: 
--     [RegisterAppInterface] Assign existing policies to the application which appID exists in LocalPT 
-- Description: 
--     In case the application registers (sends RegisterAppInterface request) with the appID 
--     that exists in Local Policy Table, PoliciesManager must apply the existing 
--     in "<appID>" from "app_policies" section of Local PT permissions to this application.
--
-- Test:
--     1. Preconditions:
--        - Assign for "xyz" specific permissions in policies
--     2. Steps:
--        - Create new mobile session and register "xyz" application
--     3. Expected result:
--        - Application "xyz" successfully registered: success = true, resultCode = "SUCCESS"
--        - OnPermissionsChange notification has the following data: success = true, resultCode = "SUCCESS"
--        - Appropriate specific permissions has been assigned:
--           - Default: { "FULL", "LIMITED", "BACKGROUND" } --> Specific: { "FULL", "LIMITED" }
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]  
  local Common = require("user_modules/shared_testcases/Policy_app_ID_Management_Common")
  local MobileSession = require("mobile_session")
  local CommonFunctions = require("user_modules/shared_testcases/commonFunctions")

--[[ General Settings for configuration ]]
  Test = require("connecttest") 

--[[ Local helpers ]]
  local function isTableContains(t, sv)
    for _, v in pairs(t) do
      if v == sv then
        return true
      end
    end
    return false
  end

  local function isTablesEqual(t1, t2)    
    local fl1 = true
    local fl2 = true
    for _, v in pairs(t1) do
      if not isTableContains(t2, v) then
        fl1 = false
      end
    end    
    for _, v in pairs(t2) do
      if not isTableContains(t1, v) then
        fl2 = false
      end
    end
    if fl1 and fl2 then 
      return true
    end    
    return false 
  end

  local function getHMIPermissions(t, rpc)
    for _, v in pairs(t.payload.permissionItem) do      
      if v.rpcName == rpc then
        return v.hmiPermissions.allowed
      end
    end
  end

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
        appName = "Media Application",
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
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = "Media Application" }})
    self.mobileSession2:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
    self.mobileSession2:ExpectNotification("OnPermissionsChange")
    :ValidIf(function(_, data) 
      local expectedPermissions = { "FULL", "LIMITED" }
      local actualPermissions = getHMIPermissions(data, "OnCommand")
      if not isTablesEqual(expectedPermissions, actualPermissions) then
        CommonFunctions:userPrint(31, "Expected:")        
        CommonFunctions:printTable(expectedPermissions)
        CommonFunctions:userPrint(31, "Actual:")        
        CommonFunctions:printTable(actualPermissions)
        return false
      end
      return true
    end)
  end

  --[[ Postconditions ]]
  function Test:Post()
  end



return Test	