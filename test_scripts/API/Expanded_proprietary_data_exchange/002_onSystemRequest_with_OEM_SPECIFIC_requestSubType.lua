---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0083-Expandable-design-for-proprietary-data-exchange.md
-- User story:TBD
-- Use case:TBD
--
-- Requirement summary:
-- TBD
--
-- Description:
-- In case: HMI sends OnSystemRequest only with requestType = "OEM_SPECIFIC" or with
-- requestType = "OEM_SPECIFIC" and requestSubType
-- SDL does: resend notification with received parameters to mobile application
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/Expanded_proprietary_data_exchange/commonDataExchange')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local params = {
  requestType = "OEM_SPECIFIC",
  requestSubType = "SomeSubType",
  fileName = "action.png"
}

local paramsWithoutSubType = {
  requestType = "OEM_SPECIFIC",
  fileName = "action.png"
}

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerApp)

runner.Title("Test")
runner.Step("onSystemRequest with request type OEM_SPECIFIC", common.onSystemRequest, {paramsWithoutSubType})
runner.Step("onSystemRequest with request type OEM_SPECIFIC and with requestSubType", common.onSystemRequest, {params})

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
