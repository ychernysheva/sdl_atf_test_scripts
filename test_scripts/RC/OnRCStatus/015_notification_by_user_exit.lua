---------------------------------------------------------------------------------------------------
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary:
-- [SDL_RC] TBD
--
-- Description: SDL shall send OnRCStatus notifications to rc registered app
-- by allocation module via SetInteriorVehicleData
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
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :ValidIf(commonOnRCStatus.validateHMIAppIds)
end

local function userExit()
  local hmiAppId = commonOnRCStatus.getHMIAppId()
  commonOnRCStatus.getHMIconnection():SendNotification("BasicCommunication.OnExitApplication",
    { appID = hmiAppId, reason = "USER_EXIT" })
  commonOnRCStatus.getMobileSession(1):ExpectNotification("OnHMIStatus",
    { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
  local ModulesStatus = {
    freeModules = commonOnRCStatus.ModulesArray(freeModules),
    allocatedModules = commonOnRCStatus.ModulesArray(allocatedModules)
  }
  commonOnRCStatus.getMobileSession(1):ExpectNotification("OnRCStatus", ModulesStatus)
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", ModulesStatus)
  :ValidIf(commonOnRCStatus.validateHMIAppIds)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonOnRCStatus.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonOnRCStatus.start)
runner.Step("RAI, PTU", commonOnRCStatus.RegisterRCapplication)
runner.Step("Activate App", commonOnRCStatus.ActivateApp)
runner.Step("App allocates module CLIMATE ", AlocateModule, { "CLIMATE" })

runner.Title("Test")
runner.Step("OnRCStatus notification by user exit", userExit)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonOnRCStatus.postconditions)
