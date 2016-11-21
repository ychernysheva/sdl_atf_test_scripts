---------------------------------------------------------------------------------------------
-- Requirement summary:
--     [ChangeRegistration]: appRevoked:true
-- Description:
-- <appID> application is assigned with specific policies (for example, appID = 123abc->
-- "app_policies" -> "123abc" : { <specific policies> }
-- Steps:
-- 1. any PolicyTableUpdate trigger happens
-- 2. PTU is valid -> <appID> gets "null" policy
-- Expected:
-- SDL -> HMI: OnAppPermissionChanged (<appID>, appRevoked=true, params)
--
-- Test:
--     1. Preconditions:
--        Start SDL
--
--     2. Steps
--        Register application with policy id 123abc
--        Perform PTU with structure "123abc": null
--
--     3. Expected result:
--        SDL -> HMI: OnAppPermissionChanged (<appID>, appRevoked=true, params)
--
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
  local Common = require("user_modules/shared_testcases/testCasesForPolicyAppIdManagament")

--[[ General Settings for configuration ]]
  Test = require("connecttest")
  local mobile_session = require("mobile_session")

  function Test:Pre_StartNewSession()
    self.mobileSession2 = mobile_session.MobileSession(self, self.mobileConnection)
    self.mobileSession2:StartService(7)
  end

--[[ Test ]]
  function Test:RegisterNewApp_PerformPTU_Check_OnAppPermissionChanged()
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
        appID = "123abc",
        deviceInfo =
        {
          os = "Android",
          carrier = "Megafon",
          firmwareRev = "Name: Linux, Version: 3.4.0-perf",
          osVersion = "4.4.2",
          maxNumberRFCOMMPorts = 1
        }
      }

    self.mobileSession2:SendRPC("RegisterAppInterface", registerAppInterfaceParams)
    Common:update_policy_table(self, "files/jsons/Policies/appID_Management/ptu_23511.json")
    EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged", { appRevoked = true })
  end
return Test