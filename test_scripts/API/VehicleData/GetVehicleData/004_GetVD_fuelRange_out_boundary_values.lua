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
-- 2) HMI sends out of boundary values of parameters in response
-- SDL must:
-- validates values and respond INVALID_DATA, success: false
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')

--[[ Local Variables ]]
local rpc = {
  name = "GetVehicleData",
  params = {
    fuelRange = true
  }
}

local rangeValueTbl = { outUpper = 10000.1, outLower = -0.1 }
local typeDefault = "DIESEL"
local rangeDefault = 45.5
local arraySizeOutUpper = 101
local fuelRangeArray101 = { }

for i=1, arraySizeOutUpper do
  fuelRangeArray101[i] = { type = rangeDefault, range = typeDefault }
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
  mobileSession:ExpectResponse(cid, { success = false, resultCode = "INVALID_DATA" })
  :ValidIf(function(_,data)
    if data.payload.fuelRange then
      return false, "SDL sends to mobile app fuelRange in case of invalid parameters"
    else
      return true
    end
  end)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
runner.Step("GetVehicleData_fuelRange_fuelType_OutBound", processRPCSuccess,
  {{{ type = "ANY", range = rangeDefault }}})
runner.Step("GetVehicleData_fuelRange_rangeValue_out_upper", processRPCSuccess,
  {{{ type = typeDefault, range = rangeValueTbl.outUpper }}})
runner.Step("GetVehicleData_fuelRange_rangeValue_out_lower", processRPCSuccess,
  {{{ type = typeDefault, range = rangeValueTbl.outLower }}})
runner.Step("GetVehicleData_fuelRange_array_out_upper", processRPCSuccess,
  { fuelRangeArray101 })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
