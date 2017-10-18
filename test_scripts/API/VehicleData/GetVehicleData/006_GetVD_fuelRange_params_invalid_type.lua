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
-- 2) HMI sends invalid types of parameters in response
-- SDL must:
-- validates values and respond INVALID_DATA, success: false
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

local typeDefault = "DIESEL"
local rangeDefault = 45.5
local resParams = {
  typeInvalidType = {{ range = rangeDefault, type = 111 }},
  rangeinvalidType = {{ type = typeDefault, range = "string" }},
  elementInvaliType = { "elemnt" },
  fuelRangeInvalidType = "string"
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
    { success = false, resultCode = "INVALID_DATA", info = 'Received invalid data on HMI response' })
  :ValidIf(function(_,data)
    if data.payload.fuelRange then
      return false, "SDL sends to mobile app fuelRange in case of invalid parameters"
    else
      return true
    end
  end)
end

local function RPCrequest(requestParams, self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, requestParams)
  EXPECT_HMICALL("VehicleInfo." .. rpc.name, rpc.params)
  :Times(0)
  mobileSession:ExpectResponse(cid,
    { success = false, resultCode = "INVALID_DATA" })
  commonTestCases:DelayedExp(1000)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
for k,value in pairs(resParams) do
  runner.Step("GetVehicleData_fuelRange_" .. k, processRPCSuccess,{ value })
end
runner.Step("GetVehicleData_fuelRange_invalid_type_in_request", RPCrequest,{{ fuelRange = "string" }})

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
