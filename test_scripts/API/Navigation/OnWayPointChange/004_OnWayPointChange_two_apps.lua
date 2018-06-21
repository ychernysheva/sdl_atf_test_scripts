---------------------------------------------------------------------------------------------------
-- User story: https://github.com/smartdevicelink/sdl_requirements/issues/28
-- Use case: https://github.com/smartdevicelink/sdl_requirements/blob/master/detailed_docs/embedded_navi/Notification_about_changes_to_Destination_or_Waypoints.md
-- Item: Use Case 1: Alternative flow 1
--
-- Requirement summary:
-- [OnWayPointChange] As a mobile application I want to be able to be notified on changes
-- to Destination or Waypoints based on my subscription
--
-- Description:
-- In case:
-- 1) One application requested to unsubscribe from receiving notifications on destination & waypoints changes
--    (other mobile applications remain subscribed)
--    Any change in destination or waypoints is registered on HMI (user set new route, canselled the route,
--    arrived at destination point or crossed a waypoint)
-- 2) HMI sends the notification about changes to SDL

-- SDL must:
-- 1) SDL does not transfer the notification to unsubscribed mobile application
--    SDL transfers the notification to subscribed mobile applications
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/Navigation/commonNavigation')

--[[ Local Variables ]]
local notification = {
  wayPoints = {
    {
      coordinate =
      {
        latitudeDegrees = 1.1,
        longitudeDegrees = 1.1
      },
      locationName = "Hotel",
      addressLines =
      {
        "Hotel Bora",
        "Hotel 5 stars"
      },
      locationDescription = "VIP Hotel",
      phoneNumber = "Phone39300434",
      locationImage =
      {
        value ="icon.png",
        imageType ="DYNAMIC",
      },
      searchAddress =
      {
        countryName = "countryName",
        countryCode = "countryCode",
        postalCode = "postalCode",
        administrativeArea = "administrativeArea",
        subAdministrativeArea = "subAdministrativeArea",
        locality = "locality",
        subLocality = "subLocality",
        thoroughfare = "thoroughfare",
        subThoroughfare = "subThoroughfare"
      }
    }
  }
}

--[[ Local Functions ]]
local function onWayPointChangeToBothApps(self)
  self.hmiConnection:SendNotification("Navigation.OnWayPointChange", notification)
  self.mobileSession1:ExpectNotification("OnWayPointChange", notification)
  self.mobileSession2:ExpectNotification("OnWayPointChange", notification)
end

local function onWayPointChangeToOneApp(self)
  self.hmiConnection:SendNotification("Navigation.OnWayPointChange", notification)
  self.mobileSession1:ExpectNotification("OnWayPointChange", notification)
  self.mobileSession2:ExpectNotification("OnWayPointChange"):Times(0)
  common:DelayedExp()
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)

for i = 1, 2 do
  runner.Step("RAI, PTU " .. i, common.registerAppWithPTU, { i })
  runner.Step("Activate App " .. i, common.activateApp, { i })
  runner.Step("Subscribe OnWayPointChange App " .. i, common.subscribeWayPoints, { i })
end

runner.Title("Test")
runner.Step("OnWayPointChange to both apps", onWayPointChangeToBothApps)
runner.Step("Second app unsubscribe OnWayPointChange", common.unsubscribeWayPoints, { common.appId2 })
runner.Step("OnWayPointChange to one app", onWayPointChangeToOneApp)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)