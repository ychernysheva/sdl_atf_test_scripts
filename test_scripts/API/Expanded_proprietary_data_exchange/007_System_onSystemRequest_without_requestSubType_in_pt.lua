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
-- 1. PTU is performed without requestSubType
-- 2. SDL receives SystemRequest and onSystemRequest with requestSubType value
-- SDL does:
-- 1. send OnAppPermissionChanged without requestSubType parameter to HMI during update
-- 2. respond disallowed to SystemRequest request and not resend onSystemRequest to mobile application
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
  requestSubType = "someValue",
  fileName = "action.png"
}

local requestSubTypeArray = { "TYPE1", "TYPE2", "TYPE3" }

--[[ Local Functions ]]
local function ptuFuncRPC(tbl)
  tbl.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID].requestSubType = requestSubTypeArray
end

local function ptuFuncWithoutRequestSubType(tbl)
  tbl.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID].requestSubType = nil
end

local function policyUpdate()
  common.policyTableUpdate(ptuFuncWithoutRequestSubType)
  EXPECT_HMICALL("SDL.OnAppPermissionChanged", {
    appID = common.getConfigAppParams().appID,
  })
  :ValidIf(function(_, data)
	  if data.params.requestSubType then
      return false, "SDL.OnAppPermissionChanged notification contains unexpected requestSubType parameter"
	  end
	  return true
  end)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerApp)
runner.Step("Policy table update", common.policyTableUpdate, {ptuFuncRPC})

runner.Title("Test")
runner.Step("PTU without requestSubType", policyUpdate)
runner.Step("SystemRequest with requestSubType", common.unsuccessSystemRequest,
  {params, usedFile})
runner.Step("onSystemRequest with requestSubType", common.unsuccessOnSystemRequest,
  {params})

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
