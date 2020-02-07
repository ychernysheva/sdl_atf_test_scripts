---------------------------------------------------------------------------------------------------
-- Issue: https://github.com/SmartDeviceLink/sdl_core/issues/1924
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/Defects/4_5/Trigger_PTU_NO_Certificate/common')
local runner = require('user_modules/script_runner')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local serviceId = 7
local appHMIType = "DEFAULT"

--[[ General configuration parameters ]]
config.application1.registerAppInterfaceParams.appHMIType = { appHMIType }

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("Register App", common.registerApp)
runner.Step("PolicyTableUpdate without certificate", common.policyTableUpdate, { common.ptUpdateWOcert })

runner.Title("Test")

runner.Step("StartService Secured, PTU without certificate, NACK, no Handshake",
  common.startServiceSecured, { serviceId, common.nackData, common.ptUpdateWOcert })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
