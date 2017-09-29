---------------------------------------------------------------------------------------------------
-- Item: Use Case: request is allowed but parameter of this request is NOT allowed by Policies
--
-- Requirement summary:
-- [UnsubscribeVehicleData] As a mobile app wants to send a request to get the details of the vehicle data
--
-- Description:
-- In case:
-- 1) mobile application sends valid UnsubscribeVehicleData to SDL and this request is allowed by Policies but RPC parameter is not allowed
-- SDL must:
-- 1) SDL responds DISALLOWED, success:false to mobile application and doesn't transfer this request to HMI

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

-- Function which removes engineOilLife parameter from specified func group and rpc
local function ptu_update_func(tbl)
  local params = tbl.policy_table.functional_groupings["Emergency-1"].rpcs["UnsubscribeVehicleData"].parameters
  for index, value in pairs(params) do
    if ("engineOilLife" == value) then params[index] = nil end
  end
end

local function processRPCFailure(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc.name, rpc.params):Times(0)
  mobileSession:ExpectResponse(cid, { success = false, resultCode = "DISALLOWED",
    info = "'engineOilLife' disallowed by policies.",
    engineOilLife = {dataType = "VEHICLEDATA_ENGINEOILLIFE", resultCode = "DISALLOWED"} })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU, {1, ptu_update_func})
runner.Step("Activate App", common.activateApp)

runner.Title("Test")

runner.Step("RPC " .. rpc.name , processRPCFailure)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)