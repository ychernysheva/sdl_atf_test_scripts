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
-- 1. PTU is performed with empty array in requestSubType
-- 2. SDL receives SystemRequest and onSystemRequest with requestSubType after ptu
-- SDL does:
-- 1. send OnAppPermissionChanged( requestSubType = [] ) to HMI during update
-- 2. successful process SystemRequest and resend onSystemRequest
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/Expanded_proprietary_data_exchange/commonDataExchange')
local json = require('modules/json')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local usedFile = "./files/action.png"
local params = {
  requestType = "OEM_SPECIFIC",
  requestSubType = "SomeSubType",
  fileName = "action.png"
}

--[[ Local Functions ]]
local function ptuFuncRPC(tbl)
  tbl.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID].requestSubType = json.EMPTY_ARRAY
end

local function policyUpdate()
  common.policyTableUpdate(ptuFuncRPC)
  EXPECT_HMICALL("SDL.OnAppPermissionChanged", {
	appID = common.getConfigAppParams().appID,
	requestSubType = json.EMPTY_ARRAY
  })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerApp)

runner.Title("Test")
runner.Step("PTU with empty json in requestSubType section", policyUpdate)
runner.Step("SystemRequest with request type OEM_SPECIFIC and requestSubType", common.systemRequest,
  {params, usedFile})
runner.Step("onSystemRequest with request type OEM_SPECIFIC and with requestSubType", common.onSystemRequest,
  {params})

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
