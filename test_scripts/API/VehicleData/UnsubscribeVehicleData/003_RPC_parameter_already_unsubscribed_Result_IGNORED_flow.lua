---------------------------------------------------------------------------------------------------
-- Item: Use Case: request is allowed by Policies
--
-- Requirement summary:
-- [UnsubscribeVehicleData] As a mobile app wants to send a request to unsubscribe
--  for already subscribed specified parameter
--
-- Description:
-- In case:
-- 1) mobile application sends valid UnsubscribeVehicleData to SDL and this request is allowed by Policies
-- SDL must:
-- Transfer this request to HMI and after successful response from hmi
-- Respond SUCCESS, success:true to mobile application

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/VehicleData/commonVehicleData')

--[[ Local Variables ]]

local rpc_subscribe = {
  name = "SubscribeVehicleData",
  params = {
    engineOilLife = true
  }
}

local rpc_unsubscribe = {
  name = "UnsubscribeVehicleData",
  params = {
    engineOilLife = true
  }
}

local function processRPCSubscribeSuccess(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc_subscribe.name, rpc_subscribe.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc_subscribe.name, rpc_subscribe.params)
  :Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {engineOilLife = {dataType = "VEHICLEDATA_ENGINEOILLIFE", resultCode = "SUCCESS"}})
    end)
  mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS", engineOilLife = {dataType = "VEHICLEDATA_ENGINEOILLIFE", resultCode = "SUCCESS"} })
end

local function processRPCUnsubscribeSuccess(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc_unsubscribe.name, rpc_unsubscribe.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc_unsubscribe.name, rpc_unsubscribe.params)
  :Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {engineOilLife = {dataType = "VEHICLEDATA_ENGINEOILLIFE", resultCode = "SUCCESS"}})
    end)
  mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS", engineOilLife = {dataType = "VEHICLEDATA_ENGINEOILLIFE", resultCode = "SUCCESS"} })
end

local function processRPCUnsubscribeIgnored(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc_unsubscribe.name, rpc_unsubscribe.params)
  EXPECT_HMICALL("VehicleInfo." .. rpc_unsubscribe.name, rpc_unsubscribe.params):Times(0)
  mobileSession:ExpectResponse(cid, { success = false, resultCode = "IGNORED",
    engineOilLife = {dataType = "VEHICLEDATA_ENGINEOILLIFE",
    resultCode = "DATA_NOT_SUBSCRIBED"} })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")

runner.Step("RPC " .. rpc_subscribe.name, processRPCSubscribeSuccess)
runner.Step("RPC " .. rpc_unsubscribe.name, processRPCUnsubscribeSuccess)
runner.Title("Trying to unsubscribe from already unsubscribed parameter...")
runner.Step("RPC " .. rpc_unsubscribe.name, processRPCUnsubscribeIgnored)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
