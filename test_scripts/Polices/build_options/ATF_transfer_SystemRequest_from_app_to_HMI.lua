-- UNREADY
-- function flow_PTU_SUCCEESS_EXTERNAL_PROPRIETARY should be added to testCasesForPolicyTable
---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PTU-Proprietary] Transfer SystemRequest from mobile app to HMI
--
-- Description:
-- 1. Used preconditions: SDL is built with "DEXTENDED_POLICY: ON" flag. Trigger for PTU occurs
-- 2. Performed steps:
-- MOB->SDL: SystemRequest(PROPRIETARY, filename)
-- SDL->HMI: BasicCommunication.SystemRequest (PROPRIETARY, filename, appID)
--
-- Expected result:
-- SDL must send BasicCommunication.SystemRequest (<path to UpdatedPT>, PROPRIETARY, params) to HMI
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY", "EXTERNAL_PROPRIETARY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","EXTERNAL_PROPRIETARY")
commonSteps:DeleteLogsFileAndPolicyTable()
commonFunctions:SDLForceStop()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_Activate_App_And_Consent_Device_To_Start_PTU()
local request_id = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.applications["Test Application"]})
EXPECT_HMIRESPONSE(request_id, { result = { code = 0, isSDLAllowed = true}, method = "SDL.ActivateApp"})
:Do(function(_,_)
  local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
  EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
  :Do(function(_,_)
    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
    EXPECT_HMICALL("BasicCommunication.ActivateApp")
    :Do(function(_,data)
      self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
      EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
      end)
    EXPECT_NOTIFICATION("OnPermissionsChange", {})
    end)
  end)
end

function Test:Precondition_Update_Policy()
-- ToDO(VVVakulenko): update after function flow_PTU_SUCCEESS_EXTERNAL_PROPRIETARY should be added to testCasesForPolicyTable
  testCasesForPolicyTable:flow_PTU_SUCCEESS_EXTERNAL_PROPRIETARY(self)

  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {}):Times(0)
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate",{}):Times(0)
  commonTestCases:DelayedExp(60000)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test.TestStep_Check_That_PTU_Is_Triggered()
  EXPECT_HMICALL("SDL.PolicyUpdate")
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"}):Timeout(500)
end

function Test:TestStep_Update_Policy()
local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
:Do(function()
  self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest", {requestType = "PROPRIETARY", fileName = "filename"})
    EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
    :Do(function()
      local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
         fileName = "PolicyTableUpdate",
         requestType = "PROPRIETARY"
        }, "files/sdl_preloaded_pt.json")
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
      end
      RUN_AFTER(to_run, 800)
      self.mobileSession:ExpectResponse(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
      EXPECT_NOTIFICATION("OnPermissionsChange", {})
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UP_TO_DATE"})
      end)
    end)
  end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_ForceStopSDL()
  commonFunctions:SDLForceStop()
end

return Test