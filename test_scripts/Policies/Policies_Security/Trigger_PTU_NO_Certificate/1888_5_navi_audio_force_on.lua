---------------------------------------------------------------------------------------------------
-- Issue: https://github.com/SmartDeviceLink/sdl_core/issues/1888
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/Policies/Policies_Security/Trigger_PTU_NO_Certificate/common')
local runner = require('user_modules/script_runner')

--[[ Local Variables ]]
local serviceId = 10
local appHMIType = "NAVIGATION"

--[[ General configuration parameters ]]
config.application1.registerAppInterfaceParams.appName = "server"
config.application1.registerAppInterfaceParams.appID = "SPT"
config.application1.registerAppInterfaceParams.appHMIType = { appHMIType }

--[[ Local Functions ]]
local function ptUpdate(pTbl)
  local filePath = "./files/Security/client_credential.pem"
  local crt = common.readFile(filePath)
  pTbl.policy_table.module_config.certificate = crt
  pTbl.policy_table.app_policies[common.getAppID()].AppHMIType = { appHMIType }
end

local function startServiceSecured(pData)
  common.getMobileSession():StartSecureService(serviceId)
  common.getMobileSession():ExpectControlMessage(serviceId, pData)

  local handshakeOccurences = 0
  if pData.encryption == true then handshakeOccurences = 1 end
  common.getMobileSession():ExpectHandshakeMessage()
  :Times(handshakeOccurences)

  common.delayedExp()
end

--[[ Scenario ]]
runner.SetParameters({ isSelfIncluded = false })
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Set ForceProtectedService ON", common.setForceProtectedServiceParam, { "0x0A" })
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)

runner.Title("Test")

runner.Step("Register App", common.registerApp)
runner.Step("Activate App", common.activateApp)

runner.Step("PolicyTableUpdate with certificate", common.policyTableUpdate, { ptUpdate })

runner.Step("StartService Secured ACK", startServiceSecured, { {
  frameInfo = common.frameInfo.START_SERVICE_ACK,
  encryption = true } })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
