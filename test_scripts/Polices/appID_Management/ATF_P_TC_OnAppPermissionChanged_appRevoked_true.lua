---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [OnAppPermissionChanged]: appRevoked:true
--
-- Description:
-- In case the app is currently registered and in any
-- HMILevel and in result of PTU gets "null" policies,
-- SDL must send OnAppPermissionChanged (appRevoked: true) to HMI
--
-- Used preconditions:
-- appID="123abc" is registered to SDL
-- any PolicyTableUpdate trigger happens
--
-- Performed steps:
-- PTU is valid -> application with appID=123abc gets "null" policy
--
-- Expected result:
-- SDL -> HMI: OnAppPermissionChanged (<appID>, appRevoked=true, params)
--
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
  local Common = require("user_modules/shared_testcases/testCasesForPolicyAppIdManagament")
  local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
  local commonSteps = require("user_modules/shared_testcases/commonSteps")

-- TODO (dtrunov): Should be removed when issue: "ATF does not stop HB timers by closing session and connection is fixed"
  config.defaultProtocolVersion = 2

  commonFunctions:SDLForceStop()
  commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
  Test = require("connecttest")
  require("user_modules/AppTypes")
  local mobile_session = require("mobile_session")

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:UpdatePolicy()
  Common:updatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_23511_1.json")
end

  function Test:Pre_StartNewSession()
    self.mobileSession2 = mobile_session.MobileSession(self, self.mobileConnection)
    self.mobileSession2:StartService(7)
  end


  function Test:RegisterNewApp()
    config.application1.registerAppInterfaceParams.appName = "App_test"
    config.application1.registerAppInterfaceParams.appID = "123abc"
    Common:registerApp(self, self.mobileSession2, config.application1)
  end

  --[[ Test ]]
  commonFunctions:newTestCasesGroup("Test")
  function Test:PerformPTU_Check_OnAppPermissionChanged()
    EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
    Common:updatePolicyTable(self, "files/jsons/Policies/appID_Management/ptu_23511.json")
    EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged", { appRevoked = true })
  end

--[[ Postconditions ]]
 commonFunctions:newTestCasesGroup("Postconditions")
 function Test:Postcondition_SDLForceStop()
   commonFunctions:SDLForceStop(self)
 end

return Test