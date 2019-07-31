---------------------------------------------------------------------------------------------------
-- User story: Smoke
-- Use case: Navigation SubscribeButton
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
-- d. appID is a navigation type app

-- Steps:
-- appID requests Navigation SubscribeButton with valid parameters

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

--[[ Local Variables ]]
local buttonName = {
  "NAV_CENTER_LOCATION",
  "NAV_ZOOM_IN",
  "NAV_ZOOM_OUT",
  "NAV_PAN_UP",
  "NAV_PAN_UP_RIGHT",
  "NAV_PAN_RIGHT",
  "NAV_PAN_DOWN_RIGHT",
  "NAV_PAN_DOWN",
  "NAV_PAN_DOWN_LEFT",
  "NAV_PAN_LEFT",
  "NAV_PAN_UP_LEFT",
  "NAV_TILT_TOGGLE",
  "NAV_ROTATE_CLOCKWISE",
  "NAV_ROTATE_COUNTERCLOCKWISE",
  "NAV_HEADING_TOGGLE"
}

--[[ Local Functions ]]
local function subscribeButton(pButName, self)
  local cid = self.mobileSession1:SendRPC("SubscribeButton", { buttonName = pButName })
  local appIDvalue = commonSmoke.getHMIAppId()
  EXPECT_HMINOTIFICATION("Buttons.OnButtonSubscription", { appID = appIDvalue, name = pButName, isSubscribed = true })
  self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
  self.mobileSession1:ExpectNotification("OnHashChange")
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonSmoke.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonSmoke.start)
runner.Step("RAI", commonSmoke.registerApp)
runner.Step("Activate App", commonSmoke.activateApp)

runner.Title("Test")
for _, v in pairs(buttonName) do
  runner.Step("SubscribeButton " .. v .. " Positive Case", subscribeButton, { v })
end

runner.Title("Postconditions")
runner.Step("Stop SDL", commonSmoke.postconditions)
