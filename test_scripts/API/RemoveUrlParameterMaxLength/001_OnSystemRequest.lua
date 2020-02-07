---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0200-Removing-URL-Param-Max-Length.md
--
-- Description: Check processing of OnSystemRequest notification with different length of url
--
-- In case:
-- 1. HMI sends OnSystemRequest notification with out of lower bound value in url parameter
-- SDL does:
-- - ignore notification and not send it to mobile app
-- 2. HMI sends OnSystemRequest notification with in bound value in url parameter
-- SDL does:
-- - send notification with received url to mobile app
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('user_modules/sequences/actions')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false
config.defaultProtocolVersion = 2

--[[ Local Variables ]]
local expected = 1
local notExpected = 0
local outOfMinLength = ""
local minlength = "u"
local longString = string.rep("u", 100000)

--[[ Local Functions ]]
local function OnSystemRequest(pUrlValue, pTimes)
  common.hmi.getConnection():SendNotification("BasicCommunication.OnSystemRequest",
        { requestType = "ICON_URL", fileName = "fileName", url = pUrlValue })
  common.mobile.getSession():ExpectNotification("OnSystemRequest", { requestType = "ICON_URL", url = pUrlValue })
  :Times(pTimes)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI", common.registerApp)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")

runner.Step("OnSystemRequest url outOfMinLength", OnSystemRequest, { outOfMinLength, notExpected } )
runner.Step("OnSystemRequest url minlength", OnSystemRequest, { minlength, expected } )
runner.Step("OnSystemRequest url longString", OnSystemRequest, { longString, expected } )

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)

