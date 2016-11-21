---------------------------------------------------------------------------------------------
-- Description:
-- Behavior of SDL during start SDL in case when PreloadedPT has omited parameters
-- 1. Used preconditions:
-- Delete files and policy table from previous ignition cycle if any
-- Do not start default SDL
-- 2. Performed steps:
-- Create PreloadedPolicyTable file with couple omited parameters
-- Start SDL

-- Requirement summary:
-- [Policies]: PreloadedPolicyTable: Validation rules for omited parameters - exists
--
-- Expected result:
-- PolicyManager shut SDL down
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('connecttest')
local config = require('config')

--[[ General configuration parameters ]]
config.defaultProtocolVersion = 2
local preloaded_pt_file_name = "sdl_preloaded_pt.json"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local json = require("modules/json")
local SDL = require('modules/SDL')

--[[ Preconditions ]]
function Test.backup_preloaded_pt()
  os.execute("cp " .. config.pathToSDL .. preloaded_pt_file_name .. ' ' .. config.pathToSDL .. "backup_" .. preloaded_pt_file_name)
end

function Test.restore_preloaded_pt()
  os.execute("mv " .. config.pathToSDL .. "backup_" .. preloaded_pt_file_name .. " " .. config.pathToSDL .. preloaded_pt_file_name)
end

function Test.corrupt_preloaded_pt()
  local omited_parameters = {vehicle_model = "Fiesta", vehicle_make = "Ford", vehicle_year = 2015}

  local pathToFile = config.pathToSDL .. preloaded_pt_file_name

  local file = io.open(pathToFile, "r")
  local json_data = file:read("*a")
  file:close()

  local data = json.decode(json_data)
  if data then
    for key, value in pairs(omited_parameters) do
      data.policy_table.module_config[key] = value
    end
  end

  local dataToWrite = json.encode(data)
  file = io.open(pathToFile, "w")
  file:write(dataToWrite)
  file:close()
end

function Test.check_sdl_shutdown()
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose",{}):Times(1)
  local status = SDL:CheckStatusSDL()
  if status == SDL.RUNNING then
    commonFunctions:userPrint(3, "Test failed: SDL running with omited parameters in preloaded policy table")
    return false
  end
  return true
end

function Test:Precondition_stop_sdl()
  StopSDL(self)
end

function Test:Precondition()
  commonSteps:DeletePolicyTable()
  self.backup_preloaded_pt()
  self.corrupt_preloaded_pt()
end

--[[ Test ]]

function Test:Test_start_sdl()
  StartSDL(config.pathToSDL, true, self)
end

function Test:Test()
  self.check_sdl_shutdown()
end

--[[ Postconditions ]]
function Test:Postconditions()
  self.restore_preloaded_pt()
end

commonFunctions:SDLForceStop()
