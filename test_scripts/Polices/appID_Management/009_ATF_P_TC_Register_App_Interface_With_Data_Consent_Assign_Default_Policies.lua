------------- --------------------------------------------------------------------------------
-- Requirement summary:
--     [RegisterAppInterface] With data consent, assign "default" policies to the application
--     which appID does not exist in LocalPT
--
-- Description:
--     SDL should assign "default" permissions in case the application registers
--     (sends RegisterAppInterface request) with the appID that does not exist in Local Policy Table,
--     and Data Consent has been received for the device this application registers from.
--
-- Preconditions:
--     1. appID="123_xyz" and "456_abc" are not registered to SDL yet
--     2. Register new application with appID="456_abc"
--     3. Activate appID="456_abc" in order to get consent device
-- Steps:
--     1. Register new application with appID="123_xyz"
--     2. Send "Alert" RPC in order to verify that "default" permissions are assigned
--        This RPC is allowed.
--     3.Verify RPC's respond status
--
-- Expected result:
--     Status of response: sucess = true, resultCode = "SUCCESS"
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
  local mobileSession = require("mobile_session")
  local testCasesForPolicyAppIdManagament = require("user_modules/shared_testcases/testCasesForPolicyAppIdManagament")
  local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
  local commonSteps = require("user_modules/shared_testcases/commonSteps")
  local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ General Precondition before ATF start ]]
  testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTERNAL_PROPRIETARY")
  commonFunctions:SDLForceStop()
  commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
  Test = require("connecttest")
  require("user_modules/AppTypes")

--[[ Local Functions ]]
  local function verifyRPC(mob_session, status, code)
    local corId = mob_session:SendRPC("Alert",
      {
        alertText1 = "alertText1",
        duration = 3000,
        playTone = false
      })
    mob_session:ExpectResponse(corId, {sucess = status, resultCode = code })
  end

--[[ Preconditions ]]
  commonFunctions:newTestCasesGroup("Preconditions")
  function Test:StartNewSession()
    self.mobileSession2 = mobileSession.MobileSession(self, self.mobileConnection)
    self.mobileSession2:StartService(7)
  end

--[[ Test ]]
  commonFunctions:newTestCasesGroup("Test")
  function Test:RegisterNewApp()
    config.application2.registerAppInterfaceParams.appName = "ABC Application"
    config.application2.registerAppInterfaceParams.appID = "456_abc"
    testCasesForPolicyAppIdManagament:registerApp(self, self.mobileSession2, config.application2)
  end

  function Test:ActivateApp()
    testCasesForPolicyAppIdManagament:activateApp(self, self.mobileSession2)
  end

  function Test:StartNewSession()
    self.mobileSession3 = mobileSession.MobileSession(self, self.mobileConnection)
    self.mobileSession3:StartService(7)
  end

    function Test:RegisterNewApp()
    config.application3.registerAppInterfaceParams.appName = "Media Application"
    config.application3.registerAppInterfaceParams.appID = "123_xyz"
    testCasesForPolicyAppIdManagament:registerApp(self, self.mobileSession3, config.application3)
  end

  function Test:VerifyRPC()
    verifyRPC(self.mobileSession3, true, "SUCCESS")
  end

return Test