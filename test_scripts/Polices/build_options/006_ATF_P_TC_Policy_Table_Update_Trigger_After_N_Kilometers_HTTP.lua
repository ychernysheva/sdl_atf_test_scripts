---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PTU] Trigger: kilometers
--
-- Description:
-- If SDL gets OnVehicleData ("odometer") notification from HMI and the difference between
-- between current "odometer" value_2 and "odometer" value_1 when the previous UpdatedPollicyTable
-- was applied is equal or greater than to the value of "exchange_after_x_kilometers" field ("module_config" section)
-- of policies database, SDL must trigger a PolicyTableUpdate sequence
-- 1. Used preconditions:
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- Application is registered.
-- The value of odometer received on previous PTU is "500" -> VehicleInfo.SubscribeVehicleData (odometer:500)
-- The value in PT "module_config"->"'exchange_after_x_kilometers'":500
-- 2. Performed steps:
-- HMI->SDL:OnVehicleData ("odometer":1005)
--
-- Expected result:
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- PTS is created by SDL:
-- SDL-> HMI: SDL.PolicyUpdate() //PTU sequence started
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--ToDo: Should be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTable = require ('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()

--[[ Local parameters ]]
local PermissionLinesForBase4 =
[[
"SubscribeVehicleData": {
  "hmi_levels": [
  "BACKGROUND",
  "FULL",
  "LIMITED"
  ],
  "parameters" : ["odometer"]
},
"OnVehicleData": {
  "hmi_levels": [
  "BACKGROUND",
  "FULL",
  "LIMITED"
  ],
  "parameters" : ["odometer"]
},
]]

local PTName = testCasesForPolicyTable:createPolicyTableFile_temp(PermissionLinesForBase4, nil, nil, {"SubscribeVehicleData","OnVehicleData"})
testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt(PTName)

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require("user_modules/AppTypes")

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_Activate_App_Start_PTU()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"], level = "FULL"})
  --hmi side: expect SDL.ActivateApp response
  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,data)
      --In case when app is not allowed, it is needed to allow app
      if data.result.isSDLAllowed ~= true then
        --hmi side: sending SDL.GetUserFriendlyMessage request
        RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
          {language = "EN-US", messageCodes = {"DataConsent"}})

        EXPECT_HMIRESPONSE(RequestId)
        :Do(function(_,_)
            --hmi side: send request SDL.OnAllowSDLFunctionality
            self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
              {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
            --hmi side: expect BasicCommunication.ActivateApp request
            EXPECT_HMICALL("BasicCommunication.ActivateApp")
            :Do(function(_,data2)
                --hmi side: sending BasicCommunication.ActivateApp response
                self.hmiConnection:SendResponse(data2.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
              end)
            :Times(2)
          end)
        EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN" })
      end
    end)

end

function Test:Preconditions_Set_Odometer_Value1()
  local cidVehicle = self.mobileSession:SendRPC("SubscribeVehicleData", {odometer = true})
  EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData")
  :Do(function(_,data) self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {}) end)

  EXPECT_RESPONSE(cidVehicle, { success = true, resultCode = "SUCCESS" })
  :Do(function()
      self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", {odometer = 500})
      EXPECT_NOTIFICATION("OnVehicleData", {odometer = 500})
    end)
end

function Test.Precondition_Update_Policy_With_New_Exchange_After_X_Kilometers_Value()
  commonFunctions:check_ptu_sequence_fully(Test, "files/jsons/Policies/Policy_Table_Update/odometer_ptu.json", "PolicyTableUpdate")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_Set_Odometer_Value_NO_PTU_Is_Triggered()
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", {odometer = 999})
  EXPECT_NOTIFICATION("OnVehicleData", {odometer = 999})
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate"):Times(0)
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"}):Times(0)
end

function Test.TestStep_Set_Odometer_Value_And_Check_That_PTU_Is_Triggered()
  commonFunctions:trigger_ptu_by_odometer(Test)
end

function Test.TestStep_Update_Policy_With_New_Exchange_After_X_Kilometers_Value()
  commonFunctions:check_ptu_sequence_fully(Test, "files/jsons/Policies/Policy_Table_Update/odometer_ptu.json", "PolicyTableUpdate")
end

--[[ Postcondition ]]
commonFunctions:newTestCasesGroup("Postconditions")

testCasesForPolicyTable:Restore_preloaded_pt()

function Test.Postcondition_Stop()
  StopSDL()
end

return Test
