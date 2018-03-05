---------------------------------------------------------------------------------------------------
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary:
-- [SDL_RC] TBD
--
-- Description: SDL shall send OnRCStatus notifications to all registered mobile applications and the HMI
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonOnRCStatus = require('test_scripts/RC/OnRCStatus/commonOnRCStatus')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local params = {freeModules = commonOnRCStatus.ModulesArray({ "CLIMATE", "RADIO" }), allocatedModules = { }}
local usedHMIAppId

--[[ Local Functions ]]
local function register1stApp()
	commonOnRCStatus.RegisterRCapplication()
end

local function register2ndApp()
	commonOnRCStatus.rai_n(2)
	commonOnRCStatus.getMobileSession(2):ExpectNotification("OnRCStatus", params)
	commonOnRCStatus.getMobileSession(1):ExpectNotification("OnRCStatus", params)
	EXPECT_HMINOTIFICATION("RC.OnRCStatus", params)
	:Times(2)
	:ValidIf(function(exp, data)
			local hmiAppId = {
			  [1] = commonOnRCStatus.getHMIAppId(1),
			  [2] = commonOnRCStatus.getHMIAppId(2)
		  }
			local appId = data.params.appID
			if exp.occurences == 1 and (appId == hmiAppId[1] or appId == hmiAppId[2]) then
				usedHMIAppId = appId
				return true
			elseif exp.occurences == 2 and appId ~= usedHMIAppId and (appId == hmiAppId[1] or appId == hmiAppId[2]) then
				return true
			end
			return false,
				"Expected appID: [" .. commonOnRCStatus.getHMIAppId(1) .. ", " .. commonOnRCStatus.getHMIAppId(2) .. "], "
				.. "actual: " .. tostring(data.params.appID)
		end)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonOnRCStatus.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonOnRCStatus.start)

runner.Title("Test")
runner.Step("OnRCStatus notification by app registration", register1stApp)
runner.Step("OnRCStatus notification by registration 2nd app", register2ndApp)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonOnRCStatus.postconditions)
