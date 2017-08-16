---------------------------------------------------------------------------------------------------
-- Requirement summary:
-- [SDL_RC] Set available control module settings SetInteriorVehicleData
--
-- Description:
-- In case:
-- 1) SDL receive several supported Radio parameters in GetCapabilites response
-- SDL must:
-- 1) Transfer to HMI remote control RPCs only with supported parameters and
-- 2) Reject any request for RADIO with unsupported parameters with UNSUPPORTED_RESOURCE result code, success: false
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonRC = require('test_scripts/RC/commonRC')
local common_functions = require('user_modules/shared_testcases/commonTestCases')

--[[ Local Variables ]]
local radio_capabilities = {{moduleName = "Radio", radioFrequencyAvailable = true, radioBandAvailable = true}}

local rc_capabilities = commonRC.buildHmiRcCapabilities(commonRC.DEFAULT, radio_capabilities, commonRC.DEFAULT)
local available_params =
{
    moduleType = "RADIO",
    radioControlData = {frequencyInteger = 1, frequencyFraction = 2, band = "AM"}
}
local absent_params = {moduleType = "RADIO", radioControlData = {signalStrength = 60}}

--[[ Local Functions ]]
local function rpcIsAllowed(params, self)
    local cid = self.mobileSession:SendRPC("SetInteriorVehicleData", {moduleData = params})

    EXPECT_HMICALL("RC.SetInteriorVehicleData",	{
        appID = commonRC.getHMIAppId(1),
        moduleData = params})
    :Do(function(_, data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
            moduleData = params})
    end)
    self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

--[[ Local Functions ]]
local function rpcIsDisallowed(params, self)
    local cid = self.mobileSession:SendRPC("SetInteriorVehicleData", {moduleData = params})

    EXPECT_HMICALL("RC.SetInteriorVehicleData"):Times(0)
    self.mobileSession:ExpectResponse(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE" })
    common_functions:DelayedExp(commonRC.timeout)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonRC.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonRC.start, {rc_capabilities})
runner.Step("RAI, PTU", commonRC.rai_ptu)
runner.Step("Activate_App", commonRC.activate_app)

runner.Title("Test")
for _, module_name in pairs({"CLIMATE", "RADIO"}) do
    runner.Step("GetInteriorVehicleData for " .. module_name, commonRC.subscribeToModule, {module_name, 1})
    runner.Step("ButtonPress for " .. module_name, commonRC.rpcAllowed, {module_name, 1, "ButtonPress"})
end
runner.Step("SetInteriorVehicleData processed for several supported params", rpcIsAllowed, { available_params })
runner.Step("SetInteriorVehicleData rejected with unsupported parameter", rpcIsDisallowed, { absent_params })

runner.Title("Postconditions")
runner.Step("Stop SDL", commonRC.postconditions)
