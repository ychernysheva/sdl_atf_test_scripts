---------------------------------------------------------------------------------------------------
-- User story: TO ADD !!!
-- Use case: TO ADD !!!
--
-- Requirement summary:
-- [UnsubscribeVehicleData] As a mobile app wants to send a request to unsubscribe for specified parameter
--
-- Description:
-- In case:
-- 1) mobile application sends UnsubscribeVehicleData with wrong type of fuelRange parameter
-- SDL must:
-- not transfer this request to HMI
-- Respond INVALID_DATA, success:false to mobile application
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')
local commonTestCases = require("user_modules/shared_testcases/commonTestCases")

--[[ Local Functions ]]
local function SubscribeVD(self)
  local cid = self.mobileSession1:SendRPC("SubscribeVehicleData", { fuelRange = true })
  EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData", { fuelRange = true })
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS",
    { fuelRange = { dataType = "VEHICLEDATA_STEERINGWHEEL", resultCode = "SUCCESS" }})
  end)
  self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

local function UnsubscribeVDinvalidParamType(self)
  local cid = self.mobileSession1:SendRPC("UnsubscribeVehicleData", { fuelRange = 40 })
  EXPECT_HMICALL("VehicleInfo.UnsubscribeVehicleData", { })
  :Times(0)
  self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "INVALID_DATA" })
  commonTestCases:DelayedExp(common.timeout)
end

local function OnVD(self)
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { fuelRange = {{ type = "DIESEL", range = 45.5 }}})
  self.mobileSession1:ExpectNotification("OnVehicleData", { fuelRange = {{ type = "DIESEL", range = 45.5 }}})
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)
runner.Step("SubscribeVehicleData", SubscribeVD)

runner.Title("Test")
runner.Step("UnsubscribeVehicleData_fuelRange_invalidType", UnsubscribeVDinvalidParamType)
runner.Step("App_is_subcribed_still", OnVD)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
