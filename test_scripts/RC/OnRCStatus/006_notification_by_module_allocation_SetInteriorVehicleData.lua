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
local function setVehicleData(pModuleType)
	local pModuleStatus = commonOnRCStatus.SetModuleStatus(freeModules, allocatedModules, pModuleType)
	local SettableModuleControlData = commonOnRCStatus.getSettableModuleControlData(pModuleType)
	local cid = commonOnRCStatus.getMobileSession(1):SendRPC("SetInteriorVehicleData", {
		moduleData = SettableModuleControlData
	})
	EXPECT_HMICALL("RC.SetInteriorVehicleData",	{
		appID = commonOnRCStatus.getHMIAppId(),
		moduleData = SettableModuleControlData
	})
	:Do(function(_, data)
		commonOnRCStatus.getHMIconnection():SendResponse(data.id, data.method, "SUCCESS", {
			moduleData = SettableModuleControlData
		})
	end)
	commonOnRCStatus.getMobileSession(1):ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
	commonOnRCStatus.getMobileSession(1):ExpectNotification("OnRCStatus", pModuleStatus)
	EXPECT_HMINOTIFICATION("RC.OnRCStatus", pModuleStatus)
  :ValidIf(commonOnRCStatus.validateHMIAppIds)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonOnRCStatus.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonOnRCStatus.start)
runner.Step("RAI, PTU", commonOnRCStatus.RegisterRCapplication)
runner.Step("Activate App", commonOnRCStatus.ActivateApp)

runner.Title("Test")
for _, mod in pairs(commonOnRCStatus.getModules()) do
	runner.Step("SetInteriorVehicleData " .. mod, setVehicleData, { mod })
end

runner.Title("Postconditions")
runner.Step("Stop SDL", commonOnRCStatus.postconditions)
