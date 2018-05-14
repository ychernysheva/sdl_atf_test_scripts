---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0014-adding-audio-file-playback-to-ttschunk.md
-- User story:TBD
-- Use case:TBD
--
-- Requirement summary:
-- TBD
--
-- Description:
-- In case:
-- 1) HMI provides ‘FILE’ item in ‘speechCapabilities’ parameter of ‘TTS.GetCapabilities’ response
-- 2) New app registers and send ChangeRegistration with ‘FILE’ item in ‘ttsName’ parameter
-- SDL does:
-- 1) Send TTS.ChangeRegistration request to HMI with ‘FILE’ item in ‘ttsName’ parameter
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/TTSChunks/common')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
local function sendChangeRegistration()
  local params = {
    language = "EN-US",
    hmiDisplayLanguage = "EN-US",
    ttsName = {
      { type = common.type, text = "pathToFile" }
    }
  }
  local corId = common.getMobileSession():SendRPC("ChangeRegistration", params)
  common.getHMIConnection():ExpectRequest("UI.ChangeRegistration")
  :Do(function(_, data)
      common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  common.getHMIConnection():ExpectRequest("VR.ChangeRegistration")
  :Do(function(_, data)
      common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  common.getHMIConnection():ExpectRequest("TTS.ChangeRegistration", { ttsName = params.ttsName })
  :Do(function(_, data)
      common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  common.getMobileSession():ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, init HMI, connect Mobile", common.start)
runner.Step("Register App", common.registerApp)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
runner.Step("Send ChangeRegistration", sendChangeRegistration)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
