---------------------------------------------------------------------------------------------------
-- User story: TO ADD !!!
-- Use case: TO ADD !!!
--
-- Requirement summary:
-- [SubscribeVehicleData] As a mobile app wants to send a request to subscribe for specified parameter
--
-- Description:
-- In case:
-- 1) mobile application sends SubscribeVehicleData with wrong type of fuelRange parameter
-- SDL must:
-- not transfer this request to HMI
-- Respond INVALID_DATA, success:false to mobile application
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')
local commonTestCases = require("user_modules/shared_testcases/commonTestCases")

--[[ Local Functions ]]
local function SubscribeVDinvalidParamType(self)
  local cid = self.mobileSession1:SendRPC("SubscribeVehicleData", { fuelRange = 40 })
  EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData", { })
  :Times(0)
  self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "INVALID_DATA" })
  commonTestCases:DelayedExp(common.timeout)
end

local function OnVD(self)
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { fuelRange = {{ type = "DIESEL", range = 45.5 }}})
  self.mobileSession1:ExpectNotification("OnVehicleData", { })
  :Times(0)
  commonTestCases:DelayedExp(common.timeout)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
runner.Step("SubscribeVehicleData_fuelRange_invalidType", SubscribeVDinvalidParamType)
runner.Step("App_is_not_subcribed_still", OnVD)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
