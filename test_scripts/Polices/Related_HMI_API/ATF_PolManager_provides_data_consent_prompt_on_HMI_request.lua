--UNREADY
-- shiuld be modified
---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies]: PoliciesManager must provide data consent prompt from the policy table upon request from HMI
-- [HMI API] SDL.GetUserFriendlyMessage request/response
--
-- Description:
-- 1. Precondition: SDL is started
-- 2. Steps: HMI->SDL: SDL.GetUserFriendlyMessage_request {messageCodes, language} 
--
-- Expected result:
--    1.1. 'messageCodes' is an array of strings that represent the names of sub-sections of "consumer_friendly_messages" section in PT where SDL takes the data from (for example, "StatusNeeded", "StatusPending", "StatusUpToDate").
--    1.2. 'language' - optional param, represents the language HMI needs the data in.
--    2. SDL->HMI: SDL.GetUserFriendlyMessage_response {messages}:
--      2.1. 'messages' is an array, each element of which contains the following params:
--        2.1.1. 'messageCode' - is the name of sub-section of PT from the request
--        2.1.2. 'ttsString' - is the value that SDL takes from PT ("tts" field from 'messageCode' subsection of "consumer_friendly_messages" section). SDL does not provide this param IN CASE the corresponding value does not exist in PT.
--        2.1.3. 'label' - is the value that SDL takes from PT ("label" field from 'messageCode' subsection of "consumer_friendly_messages" section). SDL omits this param IN CASE the corresponding value does not exist in PT.
--        2.1.4. 'line1' - is the value that SDL takes from PT ("line1" field from 'messageCode' subsection of "consumer_friendly_messages" section). SDL omits this param IN CASE the corresponding value does not exist in PT.
--        2.1.5. 'line2' - is the value that SDL takes from PT ("line2" field from 'messageCode' subsection of "consumer_friendly_messages" section). SDL omits this param IN CASE the corresponding value does not exist in PT.
--        2.1.6. 'textBody' - is the value that SDL takes from PT ("textBody" field from 'messageCode' subsection of "consumer_friendly_messages" section). SDL omits this param IN CASE the corresponding value does not exist in PT.
-- HMI->SDL: SDL.GetUserFriendlyMessage ("messageCodes": "AppPermissions")
-- SDL->HMI: SDL.GetUserFriendlyMessage ("messages":
-- {messageCode: "AppPermissions", ttsString: "%appName% is requesting the use of the following ....", line1: "Grant Requested", line2: "Permission(s)?"} ring: "%appName% is requesting the use of the following ....", line1: "Grant Requested", line2: "Permission(s)?"})
---------------------------------------------------------------------------------------------
 
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
 
--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

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
 
--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_ActivateApp()
  local request_id = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = data.params.application.appID})
  EXPECT_HMIRESPONSE(request_id)
  :Do(function(_,data)
    if data.result.isSDLAllowed ~= true then
      local request_id1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
      {language = "EN-US", messageCodes = {"DataConsent"}})
      --ToDo(vvvakulenko): Update after resolving APPLINK-16094 EXPECT_HMIRESPONSE(request_id1,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
      EXPECT_HMIRESPONSE(request_id1)
      :Do(function()
      self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
      {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
      EXPECT_HMICALL("BasicCommunication.ActivateApp")
      :Do(function()
      self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
          end)
      :Times(2)
     end)
   end
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN" }) 
end
 
--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test:Postcondition_Force_Stop_SDL()
  commonFunctions:SDLForceStop(self)
end

return Test