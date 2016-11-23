
---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies]: SDL.GetUserFriendlyMessage ("language")
-- [HMI API] SDL.GetUserFriendlyMessage request/response
--
-- Description:
-- 1. Precondition: SDL is started, HMI is started, App is registered
-- 2. Steps: Activate App, in SDL.GetUserFriendlyMessage parameter "language" should be present
--
-- Expected result:
--    HMI->SDL: SDL.GetUserFriendlyMessage ("messageCodes": "AppPermissions")
--    SDL->HMI: SDL.GetUserFriendlyMessage ("messages": {messageCode: "AppPermissions", ttsString: "%appName% is requesting the use of the following ....", line1: "Grant Requested", line2: "Permission(s)?"})
---------------------------------------------------------------------------------------------
 
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
 
--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
require('user_modules/AppTypes')
 
--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY", "EXTERNAL_PROPRIETARY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","EXTERNAL_PROPRIETARY")
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('mobile_session')
 
--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
commonSteps:DeleteLogsFileAndPolicyTable()
 
--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_ActivateApp_with_Language_Message()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})
  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,data)
    if data.result.isSDLAllowed ~= true then
      local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "en-us", messageCodes = {"AppPermissions"}})
      --ToDo(vvvakulenko): Uncomment after resolving APPLINK-16094
      --EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage",
      --messages = {{line1 = "Grant Requested", line2 = "Permission(s)?", messageCode = "AppPermissions", textBody = "%appName% is requesting the use of the following vehicle information and permissions: %functionalGroupLabels%. \n\nIf you press yes, you agree that %vehicleMake% will not be liable for any damages or loss of privacy related to %appName%’s use of your data. You can change these permissions and hear detailed descriptions in the mobile apps settings menu."}}}})
      EXPECT_HMIRESPONSE(RequestId)
      :Do(function(_,data)
        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
        {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
        EXPECT_HMICALL("BasicCommunication.ActivateApp")
        :Do(function(_,data)
          self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
        end)
        :Times(2)
      end)
    end
  end)   
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
end
 
--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
commonFunctions:SDLForceStop()
 
return Test