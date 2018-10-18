---------------------------------------------------------------------------------------------------
-- User story: https://github.com/SmartDeviceLink/sdl_core/issues/1846 
--
-- Description:
-- Mismatch for mandatory parameter between MOBILE_API and HMI_API
--
-- There is a mismatch for the mandatory parameter between the MOBILE_API and the HMI_API for the 
-- following parameters:
--     distanceToManeuver
--     distanceToManeuverScale
-- The MOBILE_API is reflecting that these parameters are not mandatory, whereas the HMI_API 
-- reflects that they are mandatory.
-- 
-- WARNING: you should include "Navigation-1" group in "sdl_preloaded_pt.json" file before run 
-- this test!
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('user_modules/sequences/actions')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
local function checkShowConstantTBT(pParams, pResultTable)
	local cid = common.getMobileSession():SendRPC("ShowConstantTBT", pParams)
	common.getMobileSession():ExpectResponse(cid, pResultTable)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI", common.registerApp)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
runner.Step("Negative check mandatory parameter distanceToManeuver", checkShowConstantTBT, {{
		appID = common.getHMIAppId(1),
		--distanceToManeuver = 50.1,
	 	distanceToManeuverScale = 100.2
	}, {success = false, resultCode = "INVALID_DATA"}})
runner.Step("Negative check mandatory parameter distanceToManeuverScale", checkShowConstantTBT, {{
		appID = common.getHMIAppId(1),
		distanceToManeuver = 50.1,
	 	--distanceToManeuverScale = 100.2
	}, {success = false, resultCode = "INVALID_DATA"}})
runner.Step("Positive case for ShowConstantTBT", checkShowConstantTBT, {{
		appID = common.getHMIAppId(1),
		distanceToManeuver = 50.1,
	 	distanceToManeuverScale = 100.2
	}, {success = true, resultCode = "SUCCESS"}})

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
