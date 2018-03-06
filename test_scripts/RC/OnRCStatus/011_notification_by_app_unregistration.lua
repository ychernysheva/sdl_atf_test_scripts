---------------------------------------------------------------------------------------------------
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary:
-- [SDL_RC] TBD
--
-- Description: SDL shall send OnRCStatus notifications to registered mobile application and to the HMI by
-- app unregistration with allocated module.
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/RC/OnRCStatus/commonOnRCStatus')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local freeModules = common.getModules()
local allocatedModules = { }

local NotifParams = {
  freeModules = common.getModulesArray(common.getModules()),
  allocatedModules = { }
}

--[[ Local Functions ]]
local function alocateModule(pModuleType)
  local ModulesStatus = common.setModuleStatus(freeModules, allocatedModules, pModuleType)
  common.rpcAllowed(pModuleType, 1, "SetInteriorVehicleData")
  common.getMobileSession(1):ExpectNotification("OnRCStatus", ModulesStatus)
  common.getMobileSession(2):ExpectNotification("OnRCStatus", ModulesStatus)
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :Times(2)
  :ValidIf(common.validateHMIAppIds)
end

local function unregistration()
  common.unregisterApp()
  common.getMobileSession(2):ExpectNotification("OnRCStatus", NotifParams)
  common.getMobileSession(1):ExpectNotification("OnRCStatus", NotifParams)
  :Times(0)
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", NotifParams)
  :ValidIf(common.validateHMIAppIds)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("Register RC application 1", common.registerRCApplication, { 1 })
runner.Step("Register RC application 2", common.registerRCApplication, { 2 })
runner.Step("Activate App 1", common.activateApp)
runner.Step("Allocating module CLIMATE", alocateModule, { "CLIMATE" })

runner.Title("Test")
runner.Step("OnRCStatus by app unregistration", unregistration)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
