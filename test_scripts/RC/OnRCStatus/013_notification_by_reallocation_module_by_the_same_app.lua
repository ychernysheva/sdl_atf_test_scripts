---------------------------------------------------------------------------------------------------
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary:
-- [SDL_RC] TBD
--
-- Description: SDL shall not send OnRCStatus notifications to rc registered app and HMI
-- in case application tries allocate already allocated module
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
local function alocateModuleWithoutNot(pModuleType)
	common.rpcAllowed(pModuleType, 1, "SetInteriorVehicleData")
	common.getMobileSession(1):ExpectNotification("OnRCStatus")
	:Times(0)
	EXPECT_HMINOTIFICATION("RC.OnRCStatus")
	:Times(0)
end

local function alocateModule(pModuleType)
  local ModulesStatus = common.setModuleStatus(freeModules, allocatedModules, pModuleType)
  common.rpcAllowed(pModuleType, 1, "SetInteriorVehicleData")
  common.getMobileSession(1):ExpectNotification("OnRCStatus", ModulesStatus)
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :ValidIf(common.validateHMIAppIds)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("Register RC application", common.registerRCApplication)
runner.Step("Activate App", common.activateApp)
runner.Step("Allocate module CLIMATE", alocateModule, { "CLIMATE" })

runner.Title("Test")
runner.Step("App allocates module CLIMATE one more time", alocateModuleWithoutNot, { "CLIMATE" })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
