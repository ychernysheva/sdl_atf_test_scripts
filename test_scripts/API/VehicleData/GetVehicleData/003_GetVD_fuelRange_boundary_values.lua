---------------------------------------------------------------------------------------------------
-- User story: TO ADD !!!
-- Use case: TO ADD !!!
--
-- Requirement summary:
-- [GetVehicleData] As a mobile app wants to send a request to get the details of the vehicle data
--
-- Description:
-- In case:
-- 1) mobile application sends valid GetVehicleData to SDL and this request is allowed by Policies
-- 2) HMI sends boundary values of parameters in response
-- SDL must:
-- transfer parameter values to mobile app
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')
local commonTestCases = require("user_modules/shared_testcases/commonTestCases")

--[[ Local Variables ]]
local rpc = {
  name = "GetVehicleData",
  params = {
    fuelRange = true
  }
}

local rangeDefault = 45.5
local typeDefault = "DIESEL"
local ArraySize = 100
local fuelRangeType = { "GASOLINE", "DIESEL", "CNG", "LPG", "HYDROGEN", "BATTERY" }
local rangeValueTbl = { upper = 10000, lower = 0, float = 10.1111111 }

local fuelRangeUpperArray = { }
for i=1,ArraySize do
  fuelRangeUpperArray[i] = { type =  typeDefault, range = rangeDefault }
end

local fuelRangeUpperArrayValue = { }
for i=1,ArraySize do
  fuelRangeUpperArrayValue[i] = { type =  typeDefault, range = rangeValueTbl.upper }
end

--[[ Local Functions ]]
local function processRPCSuccess(fuelRangeValue, self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc.name, rpc.params)
  :Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS",
       { fuelRange = fuelRangeValue })
    end)
  mobileSession:ExpectResponse(cid,
    { success = true, resultCode = "SUCCESS", fuelRange = fuelRangeValue })
  commonTestCases:DelayedExp(500)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
for _,value in pairs(fuelRangeType) do
  runner.Step("GetVehicleData_fuelRange_fuelType_" .. value, processRPCSuccess,
    {{{ type = value, range = rangeDefault }}})
end
runner.Step("GetVehicleData_fuelRange_rangeValue_upper", processRPCSuccess,
  {{{ type = typeDefault, range = rangeValueTbl.upper }}})
runner.Step("GetVehicleData_fuelRange_rangeValue_lower", processRPCSuccess,
  {{{ type = typeDefault, range = rangeValueTbl.lower }}})
runner.Step("GetVehicleData_fuelRange_range_float_value", processRPCSuccess,
  {{{ type = typeDefault, range = rangeValueTbl.float }}})
runner.Step("GetVehicleData_fuelRange_array_upper", processRPCSuccess,
  { fuelRangeUpperArray })
runner.Step("GetVehicleData_fuelRange_array_value_upper", processRPCSuccess,
  { fuelRangeUpperArrayValue })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
