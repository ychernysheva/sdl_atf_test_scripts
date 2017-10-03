---------------------------------------------------------------------------------------------------
-- Item: Use Case: request is allowed by policies but app is already subscribed for specified parameter
--
-- Requirement summary:
-- [SubscribeVehicleData] As a mobile app wants to send a request to subscribe for specified parameter
--
-- Description:
-- In case:
-- Mobile application sends valid SubscribeVehicleData to SDL and this request
-- is allowed by Policies but app is already subscribed for specified parameter
-- SDL must:
-- SDL responds IGNORED, success:false and info: "Already subscribed on some provided VehicleData."
-- to mobile application and doesn't transfer this request to HMI
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')

--[[ Local Variables ]]
local rpc = {
    name = "SubscribeVehicleData",
    params = {
    engineOilLife = true
    }
}

--[[ Local Functions ]]
local function processRPCSuccess(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc.name, rpc.params)
  :Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS",
        {engineOilLife = {dataType = "VEHICLEDATA_ENGINEOILLIFE", resultCode = "SUCCESS"}})
    end)
  mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS",
    engineOilLife = {dataType = "VEHICLEDATA_ENGINEOILLIFE", resultCode = "SUCCESS"} })
end

local function processRPCIgnored(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc.name, rpc.params):Times(0)
  commonTestCases:DelayedExp(common.timeout)
  mobileSession:ExpectResponse(cid, { success = false, resultCode = "IGNORED",
    info = "Already subscribed on some provided VehicleData.",
    engineOilLife = {dataType = "VEHICLEDATA_ENGINEOILLIFE", resultCode = "DATA_ALREADY_SUBSCRIBED"} })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
runner.Step("RPC " .. rpc.name .. " 1st time" , processRPCSuccess)
runner.Step("RPC " .. rpc.name .. " 2nd time" , processRPCIgnored)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
