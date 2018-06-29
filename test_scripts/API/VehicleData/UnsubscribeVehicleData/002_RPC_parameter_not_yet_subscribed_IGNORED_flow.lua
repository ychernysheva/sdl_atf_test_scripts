---------------------------------------------------------------------------------------------------
-- User story: TO ADD !!!
-- Use case: TO ADD !!!
-- Item: Use Case: request is allowed by Policies
--
-- Requirement summary:
-- [UnsubscribeVehicleData] Mobile app wants to send a request to unsubscribe
-- for not yet subscribed specified parameter
--
-- Description:
-- In case:
-- Mobile application sends valid UnsubscribeVehicleData to SDL and this request
-- is allowed by Policies but app is not yet subscribed for this parameter
-- SDL must:
-- Respond IGNORED, success:false to mobile application and not transfer this request to HMI
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')

--[[ Local Variables ]]
local rpc = {
  name = "UnsubscribeVehicleData",
  params = {
    engineOilLife = true,
    fuelRange = true,
    tirePressure = true,
    turnSignal = true
  }
}

local vehicleDataResults = {
  engineOilLife = {
    dataType = "VEHICLEDATA_ENGINEOILLIFE", 
    resultCode = "DATA_NOT_SUBSCRIBED"
  },
  fuelRange = {
    dataType = "VEHICLEDATA_FUELRANGE", 
    resultCode = "DATA_NOT_SUBSCRIBED"
  },
  tirePressure = {
    dataType = "VEHICLEDATA_TIREPRESSURE", 
    resultCode = "DATA_NOT_SUBSCRIBED"
  },
  turnSignal = {
    dataType = "VEHICLEDATA_TURNSIGNAL", 
    resultCode = "DATA_NOT_SUBSCRIBED"
  }
}

--[[ Local Functions ]]
local function processRPCFailure(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc.name, rpc.params):Times(0)
  commonTestCases:DelayedExp(common.timeout)
  local responseParams = vehicleDataResults
  responseParams.success = false
  responseParams.resultCode = "IGNORED"
  mobileSession:ExpectResponse(cid, responseParams)
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
