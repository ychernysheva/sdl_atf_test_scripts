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
-- 1) Mobile application sends AddSubMenu request to SDL with valid "menuIcon" parameter.
-- SDL does:
-- 1) Forward  UI.AddSubMenu request params to HMI.
-- 2) Respond with (resultCode: SUCCESS, success:true) to mobile application.
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/SubMenuIcon/commonSubMenuIcon')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local requestParams = {
	menuID = 1000,
	position = 500,
	menuName ="SubMenupositive",
	menuIcon = {
		imageType = "DYNAMIC",
		value = "icon.png"
	}
}

local requestUiParams = {
	menuID = requestParams.menuID,
	menuParams = {
		menuName = requestParams.menuName,
		position = requestParams.position
	},
	menuIcon = common.cloneTable(requestParams.menuIcon)
}
requestUiParams.menuIcon.value = common.getPathToFileInStorage("icon.png")

local function sendAddSubMenu()
	local corId = common.getMobileSession():SendRPC("AddSubMenu", requestParams)
	common.getHMIConnection():ExpectRequest("UI.AddSubMenu", requestUiParams)
	:Do(function(_, data)
		common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
	end)

  common.getMobileSession():ExpectResponse(corId, { success = true, resultCode = "SUCCESS"})
  common.getMobileSession():ExpectNotification("OnHashChange")
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerAppWOPTU)
runner.Step("Activate Application", common.activateApp)
runner.Step("Upload icon file", common.putFile)

runner.Title("Test")
runner.Step("MenuIcon with result code_SUCCESS ", sendAddSubMenu)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
