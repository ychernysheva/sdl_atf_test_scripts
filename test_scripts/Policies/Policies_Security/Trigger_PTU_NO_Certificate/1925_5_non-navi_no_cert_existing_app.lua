---------------------------------------------------------------------------------------------------
-- TBA
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/Policies/Policies_Security/Trigger_PTU_NO_Certificate/common')
local runner = require('user_modules/script_runner')

--[[ Local Variables ]]
local appHMIType = {
  [1] = "DEFAULT",
  [2] = "DEFAULT"
}

--[[ General configuration parameters ]]
config.application1.registerAppInterfaceParams.appHMIType = { appHMIType[1] }
config.application2.registerAppInterfaceParams.appHMIType = { appHMIType[2] }

--[[ Local Functions ]]
local function ptUpdate(pTbl)
  pTbl.policy_table.app_policies[common.getAppID(1)].AppHMIType = { appHMIType[1] }
end

local function registerApp(pAppId)
  common.getHMIConnection():ExpectNotification("SDL.OnStatusUpdate",
    { status = "UPDATE_NEEDED" }, { status = "UPDATING" })
  :Times(2)
  common.getHMIConnection():ExpectRequest("BasicCommunication.PolicyUpdate")
  common.registerAppWOPTU(pAppId)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("Register " .. appHMIType[1] .. " App", common.registerApp, { 1 })
runner.Step("PTU 1 finished", common.PolicyTableUpdate, { ptUpdate })

runner.Title("Test")
runner.Step("Register " .. appHMIType[2] .. " App, PTU started", registerApp, { 2 })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
