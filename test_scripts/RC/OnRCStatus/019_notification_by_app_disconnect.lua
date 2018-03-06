---------------------------------------------------------------------------------------------------
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary:
-- [SDL_RC] TBD
--
-- Description: SDL shall send OnRCStatus notifications to rc registered app
-- in case application deallocates module by unexpected disconnect
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
local function alocateModule(pModuleType)
  local ModulesStatus = common.setModuleStatus(freeModules, allocatedModules, pModuleType)
  common.rpcAllowed(pModuleType, 1, "SetInteriorVehicleData")
  common.getMobileSession(1):ExpectNotification("OnRCStatus", ModulesStatus)
  common.getMobileSession(2):ExpectNotification("OnRCStatus", ModulesStatus)
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :Times(2)
  :ValidIf(common.validateHMIAppIds)
end

local function closeSession()
	local ModulesStatus = common.setModuleStatusByDeallocation(freeModules, allocatedModules, "CLIMATE")
	common.closeSession(1)
	common.getMobileSession(2):ExpectNotification("OnRCStatus", ModulesStatus)
	EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :ValidIf(common.validateHMIAppIds)
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
		{ appID = common.getHMIAppId(), unexpectedDisconnect = true })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("Register RC application 1", common.registerRCApplication, { 1 })
runner.Step("Activate App 1", common.activateApp, { 1 })
runner.Step("Register RC application 2", common.registerRCApplication, { 2 })
runner.Step("Allocation of module CLIMATE", alocateModule, { "CLIMATE" })

runner.Title("Test")
runner.Step("OnRCStatus by application disconnect", closeSession)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
