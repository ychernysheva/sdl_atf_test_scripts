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
-- 2) New app registers and send PerformInteraction with ‘FILE’ item in ‘initialPrompt’, ‘helpPrompt’,
-- ‘timeoutPrompt’ parameters
-- SDL does:
-- 1) Send VR.PerformInteraction request to HMI with ‘FILE’ item in ‘initialPrompt’, ‘helpPrompt’,
-- ‘timeoutPrompt’ parameters
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/TTSChunks/common')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
local function createInteractionChoiceSet()
  local params = {
    interactionChoiceSetID = 100,
    choiceSet = {
      {
        choiceID = 111,
        menuName = "Choice111",
        vrCommands = { "Choice111" }
      }
    }
  }
  local corId = common.getMobileSession():SendRPC("CreateInteractionChoiceSet", params)
  common.getHMIConnection():ExpectRequest("VR.AddCommand")
  :Do(function(_, data)
      common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  common.getMobileSession():ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
end

local function sendPerformInteraction()
  local params = {
    initialText = "StartPerformInteraction",
    interactionMode = "VR_ONLY",
    interactionChoiceSetIDList = { 100 },
    initialPrompt = {
      { type = common.type, text = "pathToFile1" }
    },
    helpPrompt = {
      { type = common.type, text = "pathToFile2" }
    },
    timeoutPrompt = {
      { type = common.type, text = "pathToFile3" }
    }
  }
  local corId = common.getMobileSession():SendRPC("PerformInteraction", params)
  common.getHMIConnection():ExpectRequest("UI.PerformInteraction")
  :Do(function(_, data)
      common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  common.getHMIConnection():ExpectRequest("VR.PerformInteraction", {
    initialPrompt = params.initialPrompt,
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
runner.Step("Create InteractionChoiceSet", createInteractionChoiceSet)

runner.Title("Test")
runner.Step("Send PerformInteraction", sendPerformInteraction)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
