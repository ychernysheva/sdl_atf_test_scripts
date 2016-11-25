---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [SubscribeVehicleData] DISALLOWED response when all parameters are not allowed in the request
--
-- Description:
-- SDL must:
-- - not send anything to HMI,
-- - AND return the individual results of DISALLOWED to response to mobile app + "ResultCode:DISALLOWED, success: false"
-- In case:
-- - SubscribeVehicleData RPC is allowed by policies with less than supported by protocol parameters
-- - AND the app assigned with such policies requests SubscribeVehicleData with one and-or more NOT-allowed params only
--
-- Preconditions:
-- 1. Application with <appID> is registered on SDL.
-- 2. Specific permissions are assigned for <appID> with SubscribeVehicleData
-- Steps:
-- 1. Send SubscribeVehicleData RPC App -> SDL with not specified parameters
-- 2. Verify status of response
--
-- Expected result:
-- SDL -> App:
-- General: success: false, resultCode: DISALLOWED
-- Individual: dataType: <parameter>, resultCode: DISALLOWED
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local testCasesForPolicyAppIdManagament = require("user_modules/shared_testcases/testCasesForPolicyAppIdManagament")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTERNAL_PROPRIETARY")
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require("connecttest")
require("user_modules/AppTypes")

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:UpdatePolicy()
  testCasesForPolicyAppIdManagament:updatePolicyTable(self, "files/jsons/Policies/App_Permissions/ptu_016.json")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:Test()
  local corId = self.mobileSession:SendRPC("SubscribeVehicleData",
    {
      fuelLevel_State = true,
      instantFuelConsumption = true,
    })
  EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData")
  :Times(0)
  self.mobileSession:ExpectResponse(corId,
    {
      success = false,
      resultCode = "DISALLOWED",
      fuelLevel_State =
      {
        dataType = "VEHICLEDATA_FUELLEVEL_STATE",
        resultCode = "DISALLOWED"
      },
      instantFuelConsumption =
      {
        dataType = "VEHICLEDATA_FUELCONSUMPTION",
        resultCode = "DISALLOWED"
      },
    })
end

return Test
