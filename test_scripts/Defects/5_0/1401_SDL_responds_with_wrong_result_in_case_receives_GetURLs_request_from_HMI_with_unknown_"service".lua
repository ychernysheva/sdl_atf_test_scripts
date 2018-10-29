---------------------------------------------------------------------------------------------------
-- User story: https://github.com/SmartDeviceLink/sdl_core/issues/1401
--
-- Description:
-- SDL responds with wrong result in case receives GetURLs request from HMI with unknown "service"
--
-- Preconditions:
-- 1) Core and HMI started
-- 2) "Endpoint" table in Policy DB has next records for 0x07 service: 
--    7 | http://test.api.policies | default
-- 3) App is registered on HMI
--
-- Steps:
-- 1) On HMI click Settings button -> Request GetUrls
-- 2) Enter service id "25"
-- 3) Send GetUrls request -> GetURLs(service 25) is sent to SDL
--
-- Expected: 
-- In case SDL receives GetURLs request from HMI AND is not defined in "endpoint" table, 
-- SDL must repond with SUCCESS result code and without "urls" param
-- 
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('user_modules/sequences/actions')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
local function testGetURLsRequest()
	local requestId = common.getHMIConnection():SendRequest("SDL.GetURLS", { service = 25 })
	common.getHMIConnection():ExpectResponse(requestId, {result = {code = 0, method = "SDL.GetURLS"}})
	:ValidIf(function(_, data)
		if data.result.urls == nil then 
			return true
		else
			return false, "'GetURLs' response should not contain 'urls' param"
		end
	end)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)

runner.Title("Test")
runner.Step("Send GetURLs request", testGetURLsRequest)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
