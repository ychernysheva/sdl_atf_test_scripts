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
-- Preconditions:
-- 1) Clear environment
-- 2) SDL started, HMI and mobile session connected
-- 3) Registered and activated app
-- 5) PTU
--
-- Steps:
-- 1) send mobile RPC "ShowConstantTBT" without "distanceToManeuver" param
--    and recieve resultCode = "INVALID_DATA"
-- 2) send mobile RPC "ShowConstantTBT" without "distanceToManeuverScale" param
--    and recieve resultCode = "INVALID_DATA"
-- 3) send mobile RPC "ShowConstantTBT" with "distanceToManeuver" and 
--    "distanceToManeuverScale" params and recieve resultCode = "SUCCESS"
--
-- Expected:
-- Params "distanceToManeuver" and "distanceToManeuverScale" of the mobile RPC "ShowConstantTBT" 
-- should be mandatory 
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('user_modules/sequences/actions')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
local function ptuFunc(tbl)
	tbl.policy_table.app_policies["0000001"].groups = {"Base-4", "Navigation-1"}
end

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
runner.Step("PTU", common.policyTableUpdate, { ptuFunc })

runner.Title("Test")
runner.Step("Negative check mandatory parameter distanceToManeuver", checkShowConstantTBT, {{
	 	distanceToManeuverScale = 100.2
	}, {success = false, resultCode = "INVALID_DATA"}})
runner.Step("Negative check mandatory parameter distanceToManeuverScale", checkShowConstantTBT, {{
		distanceToManeuver = 50.1,
	}, {success = false, resultCode = "INVALID_DATA"}})
runner.Step("Positive case for ShowConstantTBT", checkShowConstantTBT, {{
		distanceToManeuver = 50.1,
	 	distanceToManeuverScale = 100.2
	}, {success = true, resultCode = "SUCCESS"}})

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)