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
local commonOnRCStatus = require('test_scripts/RC/OnRCStatus/commonOnRCStatus')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local ModulesStatus = {
	freeModules = {{ moduleType = "RADIO" }},
	allocatedModules = {{ moduleType = "CLIMATE" }}
}

--[[ Local Functions ]]
local function AlocateModule(pModuleType, pAppId)
  commonOnRCStatus.rpcAllowed(pModuleType, pAppId, "SetInteriorVehicleData")
  commonOnRCStatus.getMobileSession(1):ExpectNotification("OnRCStatus", ModulesStatus)
  commonOnRCStatus.getMobileSession(2):ExpectNotification("OnRCStatus", ModulesStatus)
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :Times(2)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonOnRCStatus.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonOnRCStatus.start)
runner.Step("RAI, PTU App1", commonOnRCStatus.RegisterRCapplication, { 1 })
runner.Step("RAI, PTU App2", commonOnRCStatus.RegisterRCapplication, { 2 })
runner.Step("Activate App1", commonOnRCStatus.ActivateApp)

runner.Title("Test")
runner.Step("App1 allocates module CLIMATE", AlocateModule, { "CLIMATE", 1 })
runner.Step("Activate App2", commonOnRCStatus.ActivateApp, { 2 })
runner.Step("App2 allocates module CLIMATE", AlocateModule, { "CLIMATE", 2 })

runner.Title("Postconditions")
runner.Step("Stop SDL", commonOnRCStatus.postconditions)
