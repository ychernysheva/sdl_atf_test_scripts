--UNREADY
-- should be updated after testCasesForPolicyTable.lua implementation

---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PTU] Trigger: kilometers
--
-- Description:
-- Describe correctly the CASE of requirement that is covered, conditions that will be used.
-- 1. Used preconditions: The odometer value was "1234" when previous PTU was successfully applied. 
--    Policies DataBase contains "exchange_after_x_kilometers" = 1000
-- 2. Performed steps: 
-- SDL->HMI: Vehicleinfo.SubscribeVehicleData ("odometer")
-- HMI->SDL: Vehicleinfo.SubscribeVehicleData (SUCCESS)
-- user sets odometer to 2200
-- HMI->SDL: Vehicleinfo.OnVehicleData ("odometer:2200")
-- SDL: checks wether amount of kilometers sinse previous update is equal or greater "exchange_after_x_kilometers"
-- user sets odometer to 2250
-- HMI->SDL: Vehicleinfo.OnVehicleData ("odometer:2500")
-- SDL: checks wether amount of kilometers sinse previous update is equal or greater "exchange_after_x_kilometers"
-- SDL->HMI: OnStatusUpdate (UPDATE_NEEDED)
--
-- Expected result:
-- PTU flow started
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
Test = require('connecttest')

--[[Local Functions]]
local function genpattern2str(name, value_type)
  return "(%s*\"" .. name .. "\"%s*:%s*)".. value_type
end
 
local function modify_preloaded(pattern, value)
  local preloaded_file = io.open(config.pathToSDL .. 'sdl_preloaded_pt.json', "r")
  local content = preloaded_file:read("*a")
  preloaded_file:close()
  local res = string.gsub(content, pattern, "%1"..value, 1)
  preloaded_file = io.open(config.pathToSDL .. 'sdl_preloaded_pt.json', "w+")
  preloaded_file:write(res)
  preloaded_file:close()
  local check = string.find(res, value)
  if ( check ~= nil) then
    return true
  end
  return false
end

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()

commonPreconditions:BackupFile("sdl_preloaded_pt.json")

function Test.Preconditions_set_exchange_after_x_kilometers_to_1000()
  modify_preloaded(genpattern2str("exchange_after_x_kilometers", "%d+"), "1000")
end

--[[ General Settings for configuration ]]
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_Set_odometer_to_1234()
  self.hmiConnection:SendNotification("Vehicleinfo.OnVehicleData", { odometer = 1234 })

  EXPECT_NOTIFICATION("OnVehicleData", { odometer = 1234 })
end

function Test.Precondition_Successfull_PTU()
  testCasesForPolicyTable.flow_PTU_SUCCESS_EXTERNAL_PROPRTIETARY()
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_SubscribeVehicleData_odometer()
  local CorIdSubscribeVD= self.mobileSession:SendRPC("SubscribeVehicleData", {odometer = true})
  EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData", {odometer = true})
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, "VehicleInfo.SubscribeVehicleData", "SUCCESS", 
      {odometer = {dataType = "VEHICLEDATA_ODOMETER", resultCode = "SUCCESS"}})
    end)
  self.mobileSession:ExpectResponse(CorIdSubscribeVD, { success = true, resultCode = "SUCCESS", 
    odometer = {dataType = "VEHICLEDATA_ODOMETER", resultCode = "SUCCESS"},
    })
end

function Test:TestStep_Set_odometer_to_2200()
  self.hmiConnection:SendNotification("Vehicleinfo.OnVehicleData", { odometer = 2200 })

  EXPECT_NOTIFICATION("OnVehicleData", { odometer = 2200 })
end

-- ToDo(VVVakulenko): clarify is it needed to implement "SDL checks wether amount of kilometers sinse previous update is equal or greater "exchange_after_x_kilometers" 

function Test:TestStep_Set_odometer_to_2500()
  self.hmiConnection:SendNotification("Vehicleinfo.OnVehicleData", { odometer = 2500 })

  EXPECT_NOTIFICATION("OnVehicleData", { odometer = 2500 })
end

--ToDo(VVVakulenko): clarify is it needed to implement "SDL checks wether amount of kilometers sinse previous update is equal or greater "exchange_after_x_kilometers" 

-- ToDo(VVVakulenko): check wether any update needed after testCasesForPolicyTable.lua will be merged
function Test.TestSTep_PTU_after_N_kilometers()
  testCasesForPolicyTable.trigger_PTU_N_kilometers()
end

--[[ Postconditions ]]

commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_ForceStopSDL()
  commonFunctions:SDLForceStop()
end

function Test.Postcondition_RestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end

return Test