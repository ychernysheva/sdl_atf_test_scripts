---------------------------------------------------------------------------------------------------
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary:
-- [SDL_RC] TBD
--
-- Description: SDL shall send OnRCStatus notifications to rc registered apps
-- by allocation module via SetInteriorVehicleData
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/RC/OnRCStatus/commonOnRCStatus')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local freeModules = common.getModules()
local allocatedModules = {}

--[[ Local Functions ]]
local function setVehicleData(pModuleType)
	local pModuleStatus = common.setModuleStatus(freeModules, allocatedModules, pModuleType)
  common.rpcAllowed(pModuleType, 1, "SetInteriorVehicleData")
	common.getMobileSession(1):ExpectNotification("OnRCStatus", pModuleStatus)
	common.getMobileSession(2):ExpectNotification("OnRCStatus", pModuleStatus)
	EXPECT_HMINOTIFICATION("RC.OnRCStatus", pModuleStatus)
	:Times(2)
	:ValidIf(common.validateHMIAppIds)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("Register RC application 1", common.registerRCApplication, { 1 })
runner.Step("Activate App 1", common.activateApp, { 1 })
runner.Step("Register RC application 2", common.registerRCApplication, { 2 })

runner.Title("Test")
for _, mod in pairs(common.getModules()) do
	runner.Step("SetInteriorVehicleData " .. mod, setVehicleData, { mod })
end

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
