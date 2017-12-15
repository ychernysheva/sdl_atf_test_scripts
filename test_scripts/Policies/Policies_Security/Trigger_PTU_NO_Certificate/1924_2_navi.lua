---------------------------------------------------------------------------------------------------
-- TBA
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/Policies/Policies_Security/Trigger_PTU_NO_Certificate/common')
local runner = require('user_modules/script_runner')

--[[ Local Variables ]]
local serviceId = 7
local appHMIType = "NAVIGATION"

--[[ General configuration parameters ]]
config.application1.registerAppInterfaceParams.appHMIType = { appHMIType }

--[[ Local Functions ]]
local function ptUpdate(pTbl)
  pTbl.policy_table.app_policies[common.getAppID()].AppHMIType = { appHMIType }
end

local function startServiceSecured()
  common.getMobileSession():StartSecureService(serviceId)
  common.getMobileSession():ExpectControlMessage(serviceId, {
    frameInfo = common.frameInfo.START_SERVICE_NACK,
    encryption = false
  })

  common.getHMIConnection():ExpectNotification("SDL.OnStatusUpdate",
    { status = "UPDATE_NEEDED" }, { status = "UPDATING" })
  :Times(0)
  common.getHMIConnection():ExpectRequest("BasicCommunication.PolicyUpdate")
  :Times(0)

  common.delayedExp()
end

--[[ Scenario ]]
runner.IncludeSelf(false)
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("Register App", common.registerApp)
runner.Step("PolicyTableUpdate without certificate", common.PolicyTableUpdate, { ptUpdate })

runner.Title("Test")

runner.Step("StartService Secured, PTU not started, NACK", startServiceSecured)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
