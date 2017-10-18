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
-- 2) HMI sends response with missed fuelRange params
-- SDL must:
-- transfer parameter values to mobile app
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')

--[[ Local Variables ]]
local rangeDefault = 45.5
local typeDefault = "DIESEL"
local rpc = {
  name = "GetVehicleData",
  params = {
    fuelRange = true
  }
}
local resParams = {
  typeMissed = {range = rangeDefault},
  rangeMissed = {type = typeDefault},
  emptyElement = { }
}

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
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
for k,value in pairs(resParams) do
  runner.Step("GetVehicleData_fuelRange_" .. k, processRPCSuccess,{{ value }})
end

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
