---------------------------------------------------------------------------------------------------
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary:
-- [SDL_RC] TBD
--
-- Description: SDL shall send OnRCStatus notifications to all registered mobile applications and the HMI
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonOnRCStatus = require('test_scripts/RC/OnRCStatus/commonOnRCStatus')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonOnRCStatus.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonOnRCStatus.start)

runner.Title("Test")
runner.Step("OnRCStatus notification by app registration", commonOnRCStatus.RegisterRCapplication, { 1 })
runner.Step("OnRCStatus notification by registration 2nd app", commonOnRCStatus.RegisterRCapplication, { 2 })

runner.Title("Postconditions")
runner.Step("Stop SDL", commonOnRCStatus.postconditions)
