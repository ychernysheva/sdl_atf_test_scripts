---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0037-Expand-Mobile-putfile-RPC.md
-- User story:TBD
-- Use case:TBD
--
-- Requirement summary:
-- TBD
--
-- Description:
-- In case:
-- 1. App registers first time, permissions are from preloaded_pt
-- SDL does:
-- 1. send empty array in requestSubType, requetsType in OnAppRegistered and UpdateAppList during registration
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/Expanded_proprietary_data_exchange/commonDataExchange')
local json = require('modules/json')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local applicationsParams = {
  {
    appName = common.getConfigAppParams(1).appName,
    requestSubType = json.EMPTY_ARRAY,
    requestType = json.EMPTY_ARRAY
  }
}

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)

runner.Title("Test")
runner.Step("Empty array in requestSubType in UpdateAppList and OnAppRegistered by app registration",
	common.registerAppWOPTU, { 1, json.EMPTY_ARRAY, applicationsParams })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
