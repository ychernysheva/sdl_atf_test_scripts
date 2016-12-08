---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [GetVehicleData] "vin" storage into PolicyTable
--
-- Description:
--     Getting "vin" via VehicleInfo.GetVehicleData on SDL start and storing it in policy table
--     1. Used preconditions:
--      SDL and HMI are running
--
--     2. Performed steps
--      Check policy table for 'vin'
--
-- Expected result:
--     Policies Manager must request <vin> via VehicleInfo.GetVehicleData("vin") before LocalPT creation;
--     PoliciesManager writes <vin> to "module_meta" section of created LocalPT
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--[ToDo: should be removed when fixed: "ATF does not stop HB timers by closing session and connection"
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_vin')
require('cardinalities')
require('user_modules/AppTypes')

--[[ General precondition brfore ATF start]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ Precondition ]]
function Test.Precondition_StopSDL()
  StopSDL()
end

function Test.Precondition_DeletePolicyTable()
  if commonSteps:file_exists(config.pathToSDL .. "storage/policy.sqlite") then
    os.remove(config.pathToSDL .. "storage/policy.sqlite")
  else
    commonFunctions:userPrint(33, "policy.sqlite is not found")
  end
end

function Test.Precondition_StartSDL()
  StartSDL(config.pathToSDL, config.ExitOnCrash)
end

function Test:Precondition_InitHMI()
  self:initHMI()
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Step1_SDL_requests_vin_on_InitHMI_OnReady()
  if commonSteps:file_exists(config.pathToSDL .. "storage/policy.sqlite") then
    self:FailTestCase("policy.sqlite is found, VehicleInfo.GetVehicleData is sent after LPT created")
    return false
  else
    commonFunctions:userPrint(33, "policy.sqlite is not found, VehicleInfo.GetVehicleData is requested before LPT created")
    return true
  end
  self:initHMI_onReady()
end

function Test:Step2_Check_vin_stored_in_PT()
  local query
  if commonSteps:file_exists(config.pathToSDL .. "storage/policy.sqlite") then
    query = "sqlite3 " .. config.pathToSDL .. "storage/policy.sqlite".. " \"select vin from module_meta\""
  elseif commonSteps:file_exists(config.pathToSDL .. "policy.sqlite") then
    query = "sqlite3 " .. config.pathToSDL .. "policy.sqlite".. " \"select vin from module_meta\""
  else commonFunctions:userPrint(31, "policy.sqlite is not found")
  end

  if query ~= nil then
    os.execute("sleep 3")
    local handler = io.popen(query, 'r')
    os.execute("sleep 1")
    local result = handler:read( '*l' )
    handler:close()

    print(result)
    if result == "55-555-66-777" then
      return true
    else
      self:FailTestCase("vin in DB has unexpected value: " .. tostring(result)..", expected: 55-555-66-777")
      return false
    end
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLStop()
  StopSDL()
end
