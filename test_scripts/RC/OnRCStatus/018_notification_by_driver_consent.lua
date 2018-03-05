---------------------------------------------------------------------------------------------------
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary:
-- [SDL_RC] TBD
--
-- Description: SDL shall send OnRCStatus notifications to rc registered apps and to HMI
-- in case HMI sends SUCCESS resultCode to RC.GetInteriorVehicleDataConsent
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonOnRCStatus = require('test_scripts/RC/OnRCStatus/commonOnRCStatus')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local freeModules =  commonFunctions:cloneTable(commonOnRCStatus.modules)
local allocatedModules = {}

--[[ Local Functions ]]
local function AlocateModule(pModuleType)
  local ModulesStatus = commonOnRCStatus.SetModuleStatus(freeModules, allocatedModules, pModuleType)
  commonOnRCStatus.rpcAllowed(pModuleType, 1, "SetInteriorVehicleData")
  commonOnRCStatus.getMobileSession(1):ExpectNotification("OnRCStatus", ModulesStatus)
  commonOnRCStatus.getMobileSession(2):ExpectNotification("OnRCStatus", ModulesStatus)
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :Times(2)
end

local function SubscribeToModuleWithDriverConsent(pModuleType)
	local ModulesStatus = {
    freeModules = commonOnRCStatus.ModulesArray(freeModules),
    allocatedModules = commonOnRCStatus.ModulesArray(allocatedModules)
  }
	commonOnRCStatus.rpcAllowedWithConsent(pModuleType, 2, "SetInteriorVehicleData")
	commonOnRCStatus.getMobileSession(2):ExpectNotification("OnRCStatus",ModulesStatus)
	commonOnRCStatus.getMobileSession(1):ExpectNotification("OnRCStatus",ModulesStatus)
	EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :Times(2)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonOnRCStatus.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonOnRCStatus.start)
runner.Step("Set AccessMode ASK_DRIVER", commonOnRCStatus.defineRAMode, { true, "ASK_DRIVER" })
runner.Step("RAI, PTU App1", commonOnRCStatus.RegisterRCapplication, {1 })
runner.Step("Activate App1", commonOnRCStatus.ActivateApp, { 1 })
runner.Step("RAI, PTU App2", commonOnRCStatus.RegisterRCapplication, { 2 })
runner.Step("Activate App2", commonOnRCStatus.ActivateApp, { 2 })

runner.Title("Test")
runner.Step("Allocation of module by App1", AlocateModule, { "CLIMATE" })
runner.Step("Allocation of module by App2 with driver consent", SubscribeToModuleWithDriverConsent,
	{ "CLIMATE" })

runner.Title("Postconditions")
runner.Step("Stop SDL", commonOnRCStatus.postconditions)
