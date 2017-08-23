---------------------------------------------------------------------------------------------------
-- User story: https://github.com/smartdevicelink/sdl_requirements/issues/10
-- Use case: https://github.com/smartdevicelink/sdl_requirements/blob/master/detailed_docs/resource_allocation.md
-- Item: Use Case 3: Alternative Flow 3
--
-- Requirement summary:
-- [SDL_RC] Resource allocation based on access mode
--
-- Description:
-- In case:
-- SDL received OnAllowSDLFunctionality (deviceInfo (deviceID), allowed: FALSE)
--
-- SDL must:
-- 1) SDL assigns HMILevel NONE to all applications registered from deviceID signed in deviceInfo
-- 2) module_1 is not allocated to any application
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonRC = require('test_scripts/RC/commonRC')

--[[ Local Functions ]]
local function ptu_update_func(tbl)
  tbl.policy_table.app_policies[config.application2.registerAppInterfaceParams.appID] = commonRC.getRCAppConfig()
end

local function setSDLFunctionality(pAppIds, pAllowed, self)
	for _, pAppId in pairs(pAppIds) do
		local mobSession = commonRC.getMobileSession(self, pAppId)
		mobSession:ExpectNotification("OnHMIStatus",
			{ hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN" })
	end

	self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
		{allowed = pAllowed, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonRC.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonRC.start)
runner.Step("RAI1, PTU", commonRC.rai_ptu, { ptu_update_func })
runner.Step("RAI2", commonRC.rai_n, { 2 })

runner.Title("Test")
runner.Step("Enable RC from HMI with AUTO_DENY access mode", commonRC.defineRAMode, { true, "AUTO_DENY"})
runner.Step("Activate App1", commonRC.activate_app)
runner.Step("Activate App2", commonRC.activate_app, { 2 })
	-- App1: BACKGROUND, App2: FULL
runner.Step("Module CLIMATE App1 ButtonPress allowed", commonRC.rpcAllowed, { "CLIMATE", 1, "ButtonPress" })
runner.Step("Module CLIMATE App2 SetInteriorVehicleData denied", commonRC.rpcDenied, { "CLIMATE", 2, "SetInteriorVehicleData", "IN_USE" })
runner.Step("Disallow SDL functionality", setSDLFunctionality, { { 1, 2 }, false })
runner.Step("Allow SDL functionality", setSDLFunctionality, { {}, true })
runner.Step("Activate App2", commonRC.activate_app, { 2 })
-- App1: NONE, App2: FULL
runner.Step("Module CLIMATE App2 SetInteriorVehicleData allowed", commonRC.rpcAllowed, { "CLIMATE", 2, "SetInteriorVehicleData"})

runner.Title("Postconditions")
runner.Step("Stop SDL", commonRC.postconditions)
