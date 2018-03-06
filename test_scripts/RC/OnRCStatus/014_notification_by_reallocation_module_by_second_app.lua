---------------------------------------------------------------------------------------------------
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary:
-- [SDL_RC] TBD
--
-- Description: SDL shall send OnRCStatus notifications to rc registered apps and to HMI
-- in case app2 tries allocate allocated module by app1
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/RC/OnRCStatus/commonOnRCStatus')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local pModuleStatus = common.setModuleStatus(common.getAllModules(), { }, "CLIMATE")

--[[ Local Functions ]]
local function alocateModule(pModuleType, pAppId)
  common.rpcAllowed(pModuleType, pAppId, "SetInteriorVehicleData")
  common.validateOnRCStatusForApp(1, pModuleStatus)
  common.validateOnRCStatusForApp(2, pModuleStatus)
	common.validateOnRCStatusForHMI(2, pModuleStatus)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("Register RC application 1", common.registerRCApplication, { 1 })
runner.Step("Register RC application 2", common.registerRCApplication, { 2 })
runner.Step("Activate App 1", common.activateApp)

runner.Title("Test")
runner.Step("App1 allocates module CLIMATE", alocateModule, { "CLIMATE", 1 })
runner.Step("Activate App 2", common.activateApp, { 2 })
runner.Step("App2 allocates module CLIMATE", alocateModule, { "CLIMATE", 2 })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
