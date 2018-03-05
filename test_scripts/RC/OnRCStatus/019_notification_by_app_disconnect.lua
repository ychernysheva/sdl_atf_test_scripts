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
local commonOnRCStatus = require('test_scripts/RC/OnRCStatus/commonOnRCStatus')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local freeModules = commonOnRCStatus.getModules()
local allocatedModules = {}

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

local function CloseSession()
	local ModulesStatus = commonOnRCStatus.SetModuleStatusByDeallocation(freeModules, allocatedModules, "CLIMATE")
	commonOnRCStatus.closeSession(1)
	commonOnRCStatus.getMobileSession(2):ExpectNotification("OnRCStatus", ModulesStatus)
	EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :ValidIf(commonOnRCStatus.validateHMIAppIds)
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
		{ appID = commonOnRCStatus.getHMIAppId(), unexpectedDisconnect = true })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonOnRCStatus.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonOnRCStatus.start)
runner.Step("RAI, PTU", commonOnRCStatus.RegisterRCapplication, { 1 })
runner.Step("Activate App", commonOnRCStatus.ActivateApp, { 1 })
runner.Step("RAI, PTU for second app", commonOnRCStatus.RegisterRCapplication, { 2 })
runner.Step("Allocation of module CLIMATE", AlocateModule, { "CLIMATE" })

runner.Title("Test")
runner.Step("OnRCStatus by application disconnect", CloseSession)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonOnRCStatus.postconditions)
