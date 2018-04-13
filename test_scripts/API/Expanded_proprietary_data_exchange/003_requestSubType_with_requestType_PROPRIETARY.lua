---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0037-Expand-Mobile-putfile-RPC.md
-- User story:TBD
-- Use case:TBD
--
-- Requirement summary:
-- TBD
--
-- Description:
-- In case: SystemRequest and onSystemRequest with PROPRIETARY requestType contains requestSubType paramter during policy table update
-- SDL does: ignore received requestSubType and process received messages as usual
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/Expanded_proprietary_data_exchange/commonDataExchange')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerApp)

runner.Title("Test")
runner.Step("onSystemRequest and SystemRequest with requestSubType in policy flow", common.policyTableUpdate,
  { nil, nil, "SomeSubType" })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
