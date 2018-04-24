---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0085-submenu-icon.md
-- User story:TBD
-- Use case:TBD
--
-- Requirement summary:
-- TBD
--
-- Description:
-- In case:
-- 1) Mobile application sends   AddSubMenu request to SDL with invalid "menuIcon" parameter.
-- SDL does:
-- 1) Respond with (resultCode: INVALID_DATA, success:false) to mobile application.
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/SubMenuIcon/commonSubMenuIcon')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]

local function sendsAddSubMenu_Invalid_Type()
	local params = {
		menuID = 1000,
		position = 500,
		menuName ="SubMenupositive",
		menuIcon = {
			imageType = "DYNAMIC",
			value = 123
		}
	}
	local corId = common.getMobileSession():SendRPC("AddSubMenu", params)
	common.getHMIConnection():ExpectRequest("UI.AddSubMenu", params.requestUiParams)
	:Times(0)
	common.getMobileSession():ExpectResponse(corId, { success = false, resultCode = "INVALID_DATA"})
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerAppWOPTU)
runner.Step("Activate Application", common.activateApp)
runner.Step("Upload icon file", common.putFile)

runner.Title("Test")
runner.Step("MenuIcon sets an invalid parameter type", sendsAddSubMenu_Invalid_Type)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
