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
local commonOnRCStatus = require('test_scripts/RC/OnRCStatus/commonOnRCStatus')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local freeModules = commonOnRCStatus.getModules()
local allocatedModules = { }

local NotifParams = {
  freeModules = commonOnRCStatus.ModulesArray(commonOnRCStatus.getModules()),
  allocatedModules = { }
}

--[[ Local Functions ]]
local function AlocateModule(pModuleType)
  local ModulesStatus = commonOnRCStatus.SetModuleStatus(freeModules, allocatedModules, pModuleType)
  commonOnRCStatus.rpcAllowed(pModuleType, 1, "SetInteriorVehicleData")
  commonOnRCStatus.getMobileSession(1):ExpectNotification("OnRCStatus", ModulesStatus)
  commonOnRCStatus.getMobileSession(2):ExpectNotification("OnRCStatus", ModulesStatus)
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :Times(2)
  :ValidIf(commonOnRCStatus.validateHMIAppIds)
end

local function Unregistration()
  commonOnRCStatus.unregisterApp()
  commonOnRCStatus.getMobileSession(2):ExpectNotification("OnRCStatus", NotifParams)
  commonOnRCStatus.getMobileSession(1):ExpectNotification("OnRCStatus", NotifParams)
  :Times(0)
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", NotifParams)
  :ValidIf(commonOnRCStatus.validateHMIAppIds)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonOnRCStatus.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonOnRCStatus.start)
runner.Step("First app registration", commonOnRCStatus.RegisterRCapplication, { 1 })
runner.Step("Second app registration", commonOnRCStatus.RegisterRCapplication, { 2 })
runner.Step("Activate first app", commonOnRCStatus.ActivateApp)
runner.Step("Allocating module CLIMATE", AlocateModule, { "CLIMATE" })

runner.Title("Test")
runner.Step("OnRCStatus by app unregistration", Unregistration)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonOnRCStatus.postconditions)
