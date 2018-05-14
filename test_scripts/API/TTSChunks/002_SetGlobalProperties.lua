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
-- 2) New app registers and send SetGlobalProperties with ‘FILE’ item in ‘helpPrompt’, ‘timeoutPrompt’ parameters
-- SDL does:
-- 1) Send TTS.SetGlobalProperties request to HMI with ‘FILE’ item in ‘helpPrompt’, ‘timeoutPrompt’ parameters
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/TTSChunks/common')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
local function sendSetGlobalProperties()
  local params = {
    helpPrompt = {
      { type = common.type, text = "pathToFile1" }
    },
    timeoutPrompt = {
      { type = common.type, text = "pathToFile2" }
    }
  }
  local corId = common.getMobileSession():SendRPC("SetGlobalProperties", params)
  common.getHMIConnection():ExpectRequest("UI.SetGlobalProperties")
  :Do(function(_, data)
      common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  common.getHMIConnection():ExpectRequest("TTS.SetGlobalProperties", {
    helpPrompt = params.helpPrompt,
    timeoutPrompt = params.timeoutPrompt
  })
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
runner.Step("Send SetGlobalProperties", sendSetGlobalProperties)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
