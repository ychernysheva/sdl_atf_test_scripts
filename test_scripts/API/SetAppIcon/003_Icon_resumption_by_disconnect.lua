---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0041-appicon-resumption.md
-- User story:TBD
-- Use case:TBD
--
-- Requirement summary:
-- TBD
--
-- Description:
-- In case:
-- 1) SDL, HMI are started.
-- 2) Mobile application is registered and sets custom icon via sending PutFile and valid SetAppIcon request.
-- 3) Mobile application is unregistered.
-- 4) Mobile app is re-registered.
-- SDL does:
-- 1) Respond with result code "SUCCESS" and "iconResumed" = true for RAI request.
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/SetAppIcon/commonIconResumed')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local iconValue = "icon.png"
local allParams = {
  requestParams = {
    syncFileName = iconValue
  },
  requestUiParams = {
    syncFileName = {
      imageType = "DYNAMIC",
      value = common.getPathToFileInStorage(iconValue)
    }
  }
}

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)

runner.Title("Test")
runner.Step("App registration with iconResumed = false", common.registerAppWOPTU, { 1, false })
runner.Step("Upload icon file", common.putFile)
runner.Step("SetAppIcon", common.setAppIcon, { allParams } )
runner.Step("Disconnect mobile app", common.closeConnection)
runner.Step("Connect mobile app", common.openConnection)
runner.Step("App registration with iconResumed = true", common.registerAppWOPTU, { 1, true, true })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
