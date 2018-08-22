---------------------------------------------------------------------------------------------------
-- User story: Smoke
-- Use case: SubscribeButton
-- Item: Happy path
--
-- Requirement summary:
-- [SubscribeButton] SUCCESS: getting SUCCESS:SubscribeButton()
--
-- Description:
-- Mobile application sends valid SubscribeButton request and gets SubscribeButton "SUCCESS" response from SDL

-- Pre-conditions:
-- a. HMI and SDL are started
-- b. appID is registered and activated on SDL
-- c. appID is currently in Background, Full or Limited HMI level

-- Steps:
-- appID requests SubscribeButton with valid parameters

-- Expected:
-- SDL validates parameters of the request
-- SDL checks if Buttons interface is available on HMI
-- SDL checks if SubscribeButton is allowed by Policies
-- SDL checks if all parameters are allowed by Policies
-- SDL sends the Buttons notificaton to HMI
-- SDL responds with (resultCode: SUCCESS, success:true) to mobile application
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonSmoke = require('test_scripts/Smoke/commonSmoke')

config.application1.registerAppInterfaceParams.syncMsgVersion = {
  majorVersion = 4,
  minorVersion = 5
}

--[[ Local Functions ]]
local function subscribeButtonSuccess(pButName, self)
  local cid = self.mobileSession1:SendRPC("SubscribeButton", { buttonName = pButName })
  local appIDvalue = commonSmoke.getHMIAppId()
  EXPECT_HMINOTIFICATION("Buttons.OnButtonSubscription", { appID = appIDvalue, name = pButName, isSubscribed = true })
  self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
  self.mobileSession1:ExpectNotification("OnHashChange")
end

local function subscribeButtonInvalidData(pButName, self)
  local cid = self.mobileSession1:SendRPC("SubscribeButton", { buttonName = pButName })
  EXPECT_HMINOTIFICATION("Buttons.OnButtonSubscription")
  :Times(0)
  self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "INVALID_DATA" })
  self.mobileSession1:ExpectNotification("OnHashChange")
  :Times(0)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonSmoke.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonSmoke.start)
runner.Step("RAI", commonSmoke.registerApp)
runner.Step("Activate App", commonSmoke.activateApp)

runner.Title("Test")

runner.Step("SubscribeButton " .. "OK" .. " Positive Case", subscribeButtonSuccess, { "OK" })

runner.Step("SubscribeButton " .. "PLAY_PAUSE" .. " Invalid Data Case", subscribeButtonInvalidData, { "PLAY_PAUSE" })

runner.Title("Postconditions")
runner.Step("Stop SDL", commonSmoke.postconditions)