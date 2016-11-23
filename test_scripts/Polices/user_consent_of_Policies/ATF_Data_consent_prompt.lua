---------------------------------------------------------------------------------------------
-- Requirement summary: 
--    [Policies]: PoliciesManager must provide data consent prompt from the policy table upon request from HMI
--
-- Description: 
--     HMI requests from SDL user friendly message for data consent
--     1. Used preconditions:    
--            Unregister default application
--            Register application 
--
--     2. Performed steps
--            Activate application
--
-- Expected result:
--      PoliciesManager must provide user prompt/message from the policy table ("messages" under “consumer_friendly_messages”,
--      sub-sections of <message code> section which name corresponds to the value of messageCodes param of
--      SDL.GetUserFriendlyMessage request
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Precondition_Unregister_default_app() 
    local CorIdUAI = self.mobileSession:SendRPC("UnregisterAppInterface",{}) 
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications["SyncProxyTester"], unexpectedDisconnect = false})
    EXPECT_RESPONSE(CorIdUAI, { success = true, resultCode = "SUCCESS"})
    :Timeout(2000) 
end

function Test:Precondition_Register_app()
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

function Test:GetUserFriendlyMessage_data_consent_prompt()
    local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID})
    EXPECT_HMIRESPONSE(RequestId)
        :Do(function(_,data)
            if data.result.isSDLAllowed ~= true then
                local ReqIDGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
                EXPECT_HMIRESPONSE(ReqIDGetUserFriendlyMessage, { result = { code = 0, messages = {{ messageCode = "DataConsent"}}, method = "SDL.GetUserFriendlyMessage"}})
            end
        end)
    EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
end

--[[ Postconditions ]]
 commonFunctions:newTestCasesGroup("Postconditions")
 
function Test:Postcondition_SDLForceStop()
    commonFunctions:SDLForceStop()
end    