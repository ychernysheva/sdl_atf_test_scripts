---------------------------------------------------------------------------------------------------
-- User story: TO ADD !!!
-- Use case: TO ADD !!!
-- Item: Use Case: request is allowed but parameter of this request is NOT allowed by Policies
--
-- Requirement summary:
-- [GetVehicleData] As a mobile app wants to send a request to get the details of the vehicle data
--
-- Description:
-- In case:
-- 1) mobile application sends valid GetVehicleData to SDL and this request is allowed
--    by Policies but RPC parameter is not allowed
-- SDL must:
-- SDL responds DISALLOWED, success:false to mobile application
-- and doesn't transfer this request to HMI
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')

--[[ Local Variables ]]
local rpc = {
  name = "GetVehicleData",
  params = {
    engineOilLife = true,
    fuelRange = true,
    tirePressure = true,
    electronicParkBrakeStatus = true,
    turnSignal = true
  }
}

local vehicleDataValues = {
  engineOilLife = 52.3,
  fuelRange = {
    {
      type = "GASOLINE",
      range = 400.00
    }
  },
  tirePressure = {
    leftFront = {
      status = "NORMAL",
      tpms = "SYSTEM_ACTIVE",
      pressure = 35.00
    },
    rightFront = {
      status = "NORMAL",
      tpms = "SYSTEM_ACTIVE",
      pressure = 35.00
    }
  },
  electronicParkBrakeStatus = "CLOSED",
  turnSignal = "OFF"
}

--[[ Local Functions ]]
local function ptu_update_func(tbl)
  local params = tbl.policy_table.functional_groupings["Emergency-1"].rpcs["GetVehicleData"].parameters
  local newParams = {}
  for index, value in pairs(params) do
    if not (("engineOilLife" == value) or ("fuelRange" == value) or ("tirePressure" == value) or ("turnSignal" == value) or ("electronicParkBrakeStatus" == value)) then table.insert(newParams, value) end
  end
  tbl.policy_table.functional_groupings["Emergency-1"].rpcs["GetVehicleData"].parameters = newParams
end

local function processRPCSuccess(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc.name, rpc.params)
  :Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", vehicleDataValues)
    end)
  mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

local function processRPCFailure(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc.name, rpc.params):Times(0)
  commonTestCases:DelayedExp(common.timeout)
  mobileSession:ExpectResponse(cid, { success = false, resultCode = "DISALLOWED" })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
runner.Step("RPC " .. rpc.name .. " 1st time" , processRPCSuccess)
runner.Step("RAI 2nd app with PTU", common.registerAppWithPTU, {2, ptu_update_func})
runner.Step("RPC " .. rpc.name .. " 2nd time", processRPCFailure)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
