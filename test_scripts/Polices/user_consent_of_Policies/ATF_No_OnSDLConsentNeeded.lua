---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate]: SDL must NOT send OnSDLConsentNeeded to HMI in case PTU was triggered manually and no concented devices were found
--
-- Description:
-- PTU is triggered by user, SDL generates PoliciesSnapshot and one unconsented device with registered app is found
-- 1. Used preconditions
--     SDL is built with "-DEXTENDED_POLICY: EXTERNAL_PROPRIETARY" flag
-- 2. Performed steps
--    User presses button on HMI to request PTU ->
--      HMI -> SDL: SDL.UpdateSDL_request
--      SDL -> HMI: SDL.UpdateSDL_response(UPDATE_NEEDED)
--      SDL generates Policies Snapshot
--      SDL check that there no consented devices connected (one un-consented devices connected - isSDLAllowed = false)
--    
-- Expected result:
--    SDL must NOT send the PoliciesSnapshot over OnSystemRequest to any of the apps,
--    SDL must NOT send the OnSDLConsentNeeded to HMI
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
require('user_modules/AppTypes')
local mobile_session = require('mobile_session')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local commonTestCases = require ('user_modules/shared_testcases/commonTestCases')
local Preconditions = require ('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require ('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:CloseConnection()
  self.mobileConnection:Close()
  commonTestCases:DelayedExp(3000)  
end

Preconditions:BackupFile("sdl_preloaded_pt.json")
testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/GroupsForApp_preloaded_pt.json")

function Test:ConnectDevice()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
          {
            deviceList = {
              {
                id = config.deviceMAC,
                isSDLAllowed = false,
                name = "127.0.0.1",
                transportType = "WIFI"
              }
            }
          }
  ):Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  :Times(AtLeast(1))
end

function Test:RegisterApp()
  commonTestCases:DelayedExp(3000)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
    local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
    :Do(function(_,data)
      self.HMIAppID = data.params.application.appID
    end)
    self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
    self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
  end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep1_PTU_requested_through_HMI()
  self.hmiConnection:SendNotification("SDL.UpdateSDL", {} )
  EXPECT_HMINOTIFICATION("SDL.UpdateSDL", {status = "UPDATE_NEEDED"})
    testCasesForPolicyTableSnapshot:verify_PTS(true,
      {config.application1.registerAppInterfaceParams.appID},
      {config.deviceMAC},
      {self.HMIAppID})
    local timeout_after_x_seconds = testCasesForPolicyTableSnapshot:get_data_from_PTS("module_config.timeout_after_x_seconds")
    local seconds_between_retries = {}
    for i = 1, #testCasesForPolicyTableSnapshot.pts_seconds_between_retries do
      seconds_between_retries[i] = testCasesForPolicyTableSnapshot.pts_seconds_between_retries[i].value
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
    {
      file = "/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json",
      timeout = timeout_after_x_seconds,
      retry = seconds_between_retries
    })
    :Do(function(_,data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
     end)
      EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
      :Times(0)
      EXPECT_HMINOTIFICATION("SDL.OnSDLConsentNeeded", {})
      :Times(0)
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test:Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop(self)
end
