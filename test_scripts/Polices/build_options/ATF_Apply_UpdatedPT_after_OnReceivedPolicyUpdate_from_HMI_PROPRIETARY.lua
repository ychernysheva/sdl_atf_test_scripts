---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PTU-Proprietary] Transfer SystemRequest_response from HMI to mobile app
--
-- Description:
-- 1. Used preconditions: SDL is built with "DEXTENDED_POLICY: ON" flag. Trigger for PTU occurs
-- 2. Performed steps:
-- SDL->HMI: BasicCommunication.SystemRequest (<path to UpdatedPT>, PROPRIETARY, params)
-- HMI->SDL: BasicCommunication.SystemRequest (resultCode)
--
-- Expected result:
-- SDL->MOB: SystemRequest (result code from HMI response)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
local testCasesForPolicyTableSnapshot = require ('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')
local testCasesForPolicyTable = require ('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ Local Variables ]]
local systemFilesPath = "/tmp/fs/mp/images/ivsu_cache"

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY", "PROPRIETARY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","PROPRIETARY")
commonSteps:DeleteLogsFileAndPolicyTable()
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_Activate_App_And_Consent_Device_To_Start_PTU()
local request_id = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.applications["Test Application"]})
EXPECT_HMIRESPONSE(request_id, { result = { code = 0, isSDLAllowed = false}, method = "SDL.ActivateApp"})
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

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_PROPRIETARY_PTU()
  self.hmiConnection:SendNotification("SDL.OnPolicyUpdate",{})
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
  local timeout_after_x_seconds = testCasesForPolicyTableSnapshot:get_data_from_PTS("timeout_after_x_seconds")
  local seconds_between_retry = testCasesForPolicyTableSnapshot:get_data_from_PTS("seconds_between_retry")
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
    {
      file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate",
      timeout = timeout_after_x_seconds,
      retry = seconds_between_retry
    })
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATING"})
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
   end)
  self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest", { requestType = "PROPRIETARY", fileName = "ptu_file_name", appID = self.HMIappID })
  EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "PROPRIETARY"})

local cor_id_system_request = self.mobileSession:SendRPC("SystemRequest", {requestType = "PROPRIETARY", fileName = "ptu_file_name"})
  EXPECT_HMICALL("BasicCommunication.SystemRequest",{ requestType = "PROPRIETARY", fileName = systemFilesPath.."ptu_file_name", appID = self.HMIappID})
  :Do(function(_,_data1)
      self.hmiConnection:SendResponse(_data1.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)
  EXPECT_RESPONSE(cor_id_system_request, { success = true, resultCode = "SUCCESS"})
  -- HMI->SDL: SDL.OnReceivedPolicyUpdate(policyFile)
  self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate", {policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"})
  -- SDL validates and apply updated policies
  testCasesForPolicyTable.validate_PTU_policyfile()
  -- SDL->HMI: BC.OnStatusUpdate(UP_TO_DATE)
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", { status =  "UP_TO_DATE"})
end


--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_ForceStopSDL()
  commonFunctions:SDLForceStop()
end

return Test