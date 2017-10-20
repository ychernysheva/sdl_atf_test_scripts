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
-- 2) Notification about changes in subscribed parameter is received from hmi
-- SDL must:
-- Forward this notification to mobile application
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')

--[[ Local Variables ]]
local rangeDefault = 45.5
local typeDefault = "DIESEL"
local notParams = {
  typeMissed = { range = rangeDefault },
  rangeMissed = { type = typeDefault },
  emptyElement = { }
}

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
  mobileSession:ExpectNotification("OnVehicleData", { fuelRange = params })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)
runner.Step("SubscribeVehicleData", SubscribeSuccess)

runner.Title("Test")
for k,value in pairs(notParams) do
  runner.Step("OnVehicleData_fuelRange_" .. k, OnVehicleDataNotification,{{ value }})
end

runner.Title("Postconditions")
runner.Step("UnsubscribeVehicleData", UnsubscribeSuccess)
runner.Step("Stop SDL", common.postconditions)
