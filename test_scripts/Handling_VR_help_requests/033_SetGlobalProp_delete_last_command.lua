---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0122-New_rules_for_providing_VRHelpItems_VRHelpTitle.md
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary: TBD
--
-- Description:
-- In case:
-- 1. Mobile application sets 30 commands in requests #1, #2, #3
-- 2. Mobile application sets 10 commands in requests #4 and #5
-- 3. Mobile application removes commands
-- SDL does:
-- 1. send SetGlobalProperties with full list of command values for vrHelp and helpPrompt parameters for 30 VR commands
-- after processing request #1, #2, #3
-- 2. not send SetGlobalProperties after processing requests #4, #5
-- 3. not send SetGlobalProperties when commands from request #4 and #5 were removed
-- 4. send SetGlobalProperties with full list of command values for vrHelp and helpPrompt parameters for 30 VR commands
-- after removing commands from requests #1, #2
-- 5. send SetGlobalProperties with empty array for helpPrompt parameter and omitted vrHelp parameter
-- after removing commands from requests #3
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/Handling_VR_help_requests/commonVRhelp')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local function getVRCommandsList(pCmdId, pN)
  local out = {}
  for _ = 1, pN do
    table.insert(out, "Command_" .. pCmdId .. "_" .. pN)
  end
  return out
end

local params1 = common.getAddCommandParams(1)
params1.vrCommands = getVRCommandsList(1, 10)

local params2 = common.getAddCommandParams(2)
params2.vrCommands = getVRCommandsList(2, 10)

local params3 = common.getAddCommandParams(3)
params3.vrCommands = getVRCommandsList(3, 10)

local params4 = common.getAddCommandParams(4)
params4.vrCommands = getVRCommandsList(4, 5)

local params5 = common.getAddCommandParams(5)
params5.vrCommands = getVRCommandsList(5, 5)


local function deleteLastCommand(pN)
  common.deleteCommand({ cmdID = pN }, true)
  local requestUiParams = {
    vrHelpTitle = common.getConfigAppParams().appName
  }
  EXPECT_HMICALL("UI.SetGlobalProperties", requestUiParams)
  :Do(function(_,data)
    common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  :ValidIf(function(_, data)
      if data.params.vrHelp ~= nil then
        return false, "'vrHelp' is not expected"
      end
      return true
    end)
  local requestTtsParams = {
    helpPrompt = {}
  }
  EXPECT_HMICALL("TTS.SetGlobalProperties", requestTtsParams)
  :Do(function(_,data)
    common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
  end)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerAppWOPTU)
runner.Step("App activation", common.activateApp)

runner.Title("Test")
runner.Step("SetGlobalProperties from SDL after added cmd_id 1 with 10 commands", common.addCommandWithSetGP,
  { nil, params1 })
runner.Step("SetGlobalProperties from SDL after added cmd_id 2 with 10 commands", common.addCommandWithSetGP,
  { nil, params2 })
runner.Step("SetGlobalProperties from SDL after added cmd_id 3 with 10 commands", common.addCommandWithSetGP,
  { nil, params3 })

runner.Step("Absence SetGlobalProperties from SDL after adding cmd_id 4 with 5 commands", common.addCommandWithoutSetGP,
  { nil, params4 })
runner.Step("Absence SetGlobalProperties from SDL after adding cmd_id 5 with 5 commands", common.addCommandWithoutSetGP,
  { nil, params5 })

runner.Step("No SetGlobalProperties from SDL after deleted cmd_id 4", common.deleteCommandWithoutSetGP, { 4 })
runner.Step("No SetGlobalProperties from SDL after deleted cmd_id 5", common.deleteCommandWithoutSetGP, { 5 })

runner.Step("SetGlobalProperties from SDL after deleted cmd_id 1", common.deleteCommandWithSetGP, { 1 })
runner.Step("SetGlobalProperties from SDL after deleted cmd_id 2", common.deleteCommandWithSetGP, { 2 })
runner.Step("SetGlobalProperties from SDL after deleted cmd_id 3", deleteLastCommand, { 3 })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
