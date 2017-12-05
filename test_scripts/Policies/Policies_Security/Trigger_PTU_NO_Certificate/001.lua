---------------------------------------------------------------------------------------------------
-- User story: https://github.com/smartdevicelink/sdl_requirements/issues/9
-- Use case: https://github.com/smartdevicelink/sdl_requirements/blob/master/detailed_docs/button_press_emulation.md
-- Item: Use Case 1: Main Flow
--
-- Requirement summary:
-- [SDL_RC] Button press event emulation
--
-- Description:
-- In case:
-- 1) Application is registered with REMOTE_CONTROL appHMIType
-- 2) and sends valid ButtonPress RPC with valid parameters
-- SDL must:
-- 1) Transfer this request to HMI
-- 2) Respond with <result_code> received from HMI
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/Policies/Policies_Security/Trigger_PTU_NO_Certificate/common')
local runner = require('user_modules/script_runner')
-- local commonFunctions = require("user_modules/shared_testcases/commonFunctions")

--[[ General configuration parameters ]]
config.application1.registerAppInterfaceParams.appHMIType = { "NAVIGATION" }

--[[ Local Variables ]]
local serviceId = 7

--[[ Local Functions ]]
local function ptUpdate(pTbl)
  local filePath = "./files/Security/client_credential.pem"
  local crt = common.readFile(filePath)
  pTbl.policy_table.module_config.certificate = crt
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

local function addCommandSecured()
  local params = {
    cmdID = 1,
    menuParams = {
      position = 1,
      menuName = "Command_1"
    }
  }
  local cid = common.getMobileSession():SendEncryptedRPC("AddCommand", params)
  common.getHMIConnection():ExpectRequest("UI.AddCommand", params)
  :Do(function(_, data)
      common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", { })
    end)
  common.getMobileSession():ExpectEncryptedResponse(cid, { success = true, resultCode = "SUCCESS" })
  common.getMobileSession():ExpectEncryptedNotification("OnHashChange")
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)

runner.Title("Test")

runner.Step("Register App", common.registerApp)
runner.Step("Activate App", common.activateApp)

runner.Step("StartService Secured NACK", startServiceSecured, { {
  frameInfo = common.frameInfo.START_SERVICE_NACK,
  encryption = false } })

runner.Step("PolicyTableUpdate with certificate", common.PolicyTableUpdate, { ptUpdate })

runner.Step("StartService Secured ACK", startServiceSecured, { {
  frameInfo = common.frameInfo.START_SERVICE_ACK,
  encryption = true } })

runner.Step("AddCommand Secured", addCommandSecured)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
