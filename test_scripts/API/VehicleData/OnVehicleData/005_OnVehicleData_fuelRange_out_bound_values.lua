---------------------------------------------------------------------------------------------------
-- User story: TO ADD !!!
-- Use case: TO ADD !!!
-- Item: Use Case 1: TO ADD!!!
--
-- Requirement summary:
-- [OnVehicleData] As a mobile app is subscribed for VI parameter
-- and received notification about this parameter change from hmi
--
-- Description:
-- In case:
-- 1) If application is subscribed to get vehicle data with 'fuelRange' parameter
-- 2) Notification OnVehicleData with out of bound values
-- SDL must:
-- ignore invalid notification
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')
local commonTestCases = require("user_modules/shared_testcases/commonTestCases")

--[[ Local Variables ]]
local rangeValueTbl = { outUpper = 10000.1, outLower = -0.1 }
local typeDefault = "DIESEL"
local rangeDefault = 45.5
local arraySizeOutUpper = 101
local fuelRangeArray101 = { }

for i=1, arraySizeOutUpper do
  fuelRangeArray101[i] = { type = rangeDefault, range = typeDefault }
end

--[[ Local Functions ]]
local function SubscribeSuccess(self)
  local cid = self.mobileSession1:SendRPC("SubscribeVehicleData", { fuelRange = true })
  EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData", { fuelRange = true })
  :Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS",
        { fuelRange = { dataType = "VEHICLEDATA_FUELRANGE", resultCode = "SUCCESS" }})
    end)
  self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS", fuelRange =
    { dataType = "VEHICLEDATA_FUELRANGE", resultCode = "SUCCESS" }})
end

local function UnsubscribeSuccess(self)
  local cid = self.mobileSession1:SendRPC("UnsubscribeVehicleData", { fuelRange = true })
  EXPECT_HMICALL("VehicleInfo.UnsubscribeVehicleData", { fuelRange = true })
  :Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS",
        { fuelRange = { dataType = "VEHICLEDATA_FUELRANGE", resultCode = "SUCCESS" }})
    end)
  self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS", fuelRange =
    { dataType = "VEHICLEDATA_FUELRANGE", resultCode = "SUCCESS" }})
end

local function OnVehicleDataNotification(params, self)
  local mobileSession = common.getMobileSession(self, 1)
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { fuelRange = params })
  mobileSession:ExpectNotification("OnVehicleData", { })
  :Times(0)
  commonTestCases:DelayedExp(common.timeout)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)
runner.Step("SubscribeVehicleData", SubscribeSuccess)

runner.Title("Test")
runner.Step("OnVehicleData_fuelRange_type_out_bound", OnVehicleDataNotification,
  {{{ type = "ANY", range = rangeDefault }}})
runner.Step("OnVehicleData_fuelRange_range_out_upper", OnVehicleDataNotification,
  {{{ type = typeDefault, range = rangeValueTbl.outUpper }}})
runner.Step("OnVehicleData_fuelRange_range_out_lower", OnVehicleDataNotification,
  {{{ type = typeDefault, range = rangeValueTbl.outLower }}})
runner.Step("OnVehicleData_fuelRange_array_out_upper", OnVehicleDataNotification,
  { fuelRangeArray101 })

runner.Title("Postconditions")
runner.Step("UnsubscribeVehicleData", UnsubscribeSuccess)
runner.Step("Stop SDL", common.postconditions)
