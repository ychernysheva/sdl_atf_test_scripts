---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0122-New_rules_for_providing_VRHelpItems_VRHelpTitle.md
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary: TBD
--
-- Description:
-- In case:
-- 1. Mobile application sets 30 command one by one
-- 2.Mobile application deletes 10 command one by one
-- 3. Mobile application sets 10 commands one by one
-- 4. Mobile app adds 31th command
-- SDL does:
-- 1. send SetGlobalProperties  with update for vrHelp and helpPrompt parameters after each added and deleted command
-- 2. not send SetGlobalProperties after added 31th command
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/Handling_VR_help_requests/commonVRhelp')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerAppWOPTU)
runner.Step("App activation", common.activateApp)

runner.Title("Test")
runner.Title("Add 30 commands")
for i = 1, 30 do
  runner.Step("SetGlobalProperties from SDL after added command " ..i, common.addCommandWithSetGP, { i })
end
runner.Title("Delete 10 commands")
for i = 1, 10 do
  runner.Step("SetGlobalProperties from SDL after deleted command " ..i, common.deleteCommandWithSetGP, { i })
end
runner.Title("Add 10 commands")
for i = 31, 40 do
  runner.Step("SetGlobalProperties from SDL after added command " ..i, common.addCommandWithSetGP, { i })
end
runner.Step("Absence SetGlobalProperties from SDL after adding 31 command", common.addCommandWithoutSetGP, { 41 })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
