---------------------------------------------------------------------------------------------------
-- Item: Use Case: request is allowed but parameter of this request is NOT allowed by Policies
--
-- Requirement summary:
-- [UnsubscribeVehicleData] As a mobile app wants to send a request to get the details of the vehicle data
--
-- Description:
-- In case:
-- 1) mobile application sends valid UnsubscribeVehicleData to SDL and this request
--    is allowed by Policies for parameter not yet subscribed
-- SDL must:
-- 1) SDL responds IGNORED, success:false to mobile application and doesn't transfer this request to HMI

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')
--[[ Local Variables ]]

local rpc = {
    name = "UnsubscribeVehicleData",
    params = {
    engineOilLife = true
    }
}

local function processRPCFailure(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc.name, rpc.params):Times(0)
  mobileSession:ExpectResponse(cid, { success = false, resultCode = "IGNORED",
    info = "Some provided VehicleData was not subscribed.",
    engineOilLife = {dataType = "VEHICLEDATA_ENGINEOILLIFE", resultCode = "DATA_NOT_SUBSCRIBED"} })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")

runner.Step("RPC " .. rpc.name , processRPCFailure)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)