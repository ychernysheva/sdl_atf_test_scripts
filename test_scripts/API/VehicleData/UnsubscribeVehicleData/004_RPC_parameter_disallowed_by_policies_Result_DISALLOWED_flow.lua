---------------------------------------------------------------------------------------------------
-- User story: TO ADD !!!
-- Use case: TO ADD !!!
-- Item: Use Case: request is allowed but parameter of this request is NOT allowed by Policies
--
-- Requirement summary:
-- [UnsubscribeVehicleData] Mobile app wants to send a request to unsubscribe
-- from specified parameter but parameter is disallowed by Policies
-- Description:
-- In case:
-- 1) mobile application sends valid UnsubscribeVehicleData to SDL and this request is
-- allowed by Policies but RPC parameter is not allowed
-- SDL must:
-- 1) SDL responds DISALLOWED, success:false to mobile application and doesn't transfer this request to HMI
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
    electronicParkBrakeStatus = true,
    turnSignal = true
  }
}

local vehicleDataResults = {
  engineOilLife = {
    dataType = "VEHICLEDATA_ENGINEOILLIFE", 
    resultCode = "DISALLOWED"
  },
  fuelRange = {
    dataType = "VEHICLEDATA_FUELRANGE", 
    resultCode = "DISALLOWED"
  },
  tirePressure = {
    dataType = "VEHICLEDATA_TIREPRESSURE", 
    resultCode = "DISALLOWED"
  },
  electronicParkBrakeStatus = {
    dataType = "VEHICLEDATA_ELECTRONICPARKBRAKESTATUS", 
    resultCode = "DISALLOWED"
  },
  turnSignal = {
    dataType = "VEHICLEDATA_TURNSIGNAL", 
    resultCode = "DISALLOWED"
  }
}

--[[ Local Functions ]]
local function ptu_update_func(tbl)
  local params = tbl.policy_table.functional_groupings["Emergency-1"].rpcs["UnsubscribeVehicleData"].parameters
  local newParams = {}
  for index, value in pairs(params) do
    if not (("engineOilLife" == value) or ("fuelRange" == value) or ("tirePressure" == value) or ("turnSignal" == value) or ("electronicParkBrakeStatus" == value)) then table.insert(newParams, value) end
  end
  tbl.policy_table.functional_groupings["Emergency-1"].rpcs["UnsubscribeVehicleData"].parameters = newParams

  params = tbl.policy_table.functional_groupings["VehicleInfo-3"].rpcs["UnsubscribeVehicleData"].parameters
  newParams = {}
  for index, value in pairs(params) do
    if not (("engineOilLife" == value) or ("fuelRange" == value) or ("tirePressure" == value) or ("turnSignal" == value) or ("electronicParkBrakeStatus" == value)) then table.insert(newParams, value) end
  end
  tbl.policy_table.functional_groupings["VehicleInfo-3"].rpcs["UnsubscribeVehicleData"].parameters = newParams
end

local function processRPCFailure(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc.name, rpc.params):Times(0)
  commonTestCases:DelayedExp(common.timeout)
  local responseParams = vehicleDataResults
  responseParams.success = false
  responseParams.resultCode = "DISALLOWED"
  mobileSession:ExpectResponse(cid, responseParams)
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
