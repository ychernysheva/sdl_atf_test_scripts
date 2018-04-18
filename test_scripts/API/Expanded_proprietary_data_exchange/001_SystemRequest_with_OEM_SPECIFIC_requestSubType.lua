---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0083-Expandable-design-for-proprietary-data-exchange.md
-- User story:TBD
-- Use case:TBD
--
-- Requirement summary:
-- TBD
--
-- Description:
-- In case: Mobile application sends SystemRequest only with requestType = "OEM_SPECIFIC" or with
-- requestType = "OEM_SPECIFIC" and requestSubType
-- SDL does: resend request with received parameters to HMI and successful process response from HMI
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/Expanded_proprietary_data_exchange/commonDataExchange')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local usedFile = "./files/action.png"
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
runner.Step("SystemRequest with request type OEM_SPECIFIC", common.systemRequest, {paramsWithoutSubType, usedFile})
runner.Step("SystemRequest with request type OEM_SPECIFIC and requestSubType", common.systemRequest, {params, usedFile})

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
