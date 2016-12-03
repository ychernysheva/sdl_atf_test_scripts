---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [Policies] <app id> policies and "default_hmi" validation
--
-- Description:
--     Validation of "default_hmi" sub-section in "<app id>" section if <app id> policies assigned to the application.
--     Checking correct "default_hmi" value - BACKGROUND.
--     1. Used preconditions:
--      SDL and HMI are running
--      Delete logs file and policy table
--      Register app2
--      Activate app2
--
--     2. Performed steps
--      Perform PTU
--
-- Expected result:
--     PoliciesManager must validate "default_hmi" sub-section in "<app id>" and treat it as valid -> PTU valid
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--[ToDo: should be removed when fixed: "ATF does not stop HB timers by closing session and connection"
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_Register_app()
  self.mobileSession2 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartService(7)
  :Do(function()
  local correlationId = self.mobileSession2:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
  :Do(function(_,data)
  self.HMIAppID2 = data.params.application.appID
  end)
  self.mobileSession2:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
  self.mobileSession2:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
  end)
end

function Test:Precondition_Activate_app()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID =  self.HMIAppID2 })
  EXPECT_HMIRESPONSE(RequestId,{})
  :Do(function(_,data)
  if data.result.isSDLAllowed ~= true then
    local RequestIdGetMes = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
    {language = "EN-US", messageCodes = {"DataConsent"}})
    EXPECT_HMIRESPONSE(RequestIdGetMes)
    :Do(function()
    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
    {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
    EXPECT_HMICALL("BasicCommunication.ActivateApp")
    :Do(function()
    self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
    end)
    :Times(AtLeast(1))
    end)
  end
  end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Validate_default_hmi_upon_PTU()
  local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
  {
    fileName = "PolicyTableUpdate",
    requestType = "PROPRIETARY",
    appID = self.HMIAppID2
  },
  "files/PTU_AppIDDefaultHMI.json")
  local systemRequestId
  EXPECT_HMICALL("BasicCommunication.SystemRequest")
  :Do(function(_,data)
  systemRequestId = data.id
  self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
  {
    policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
  })
  local function to_run()
    self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
    self.mobileSession:ExpectResponse(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
  end
  RUN_AFTER(to_run, 500)
  --PTU should be valid:
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UP_TO_DATE"})
  :Timeout(500)
  end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_SDLStop()
  StopSDL()
end