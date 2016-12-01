---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies]: PreloadedPolicyTable: Validation rules for omited parameters - exists
--
-- Description:
-- Behavior of SDL during start SDL in case when PreloadedPT has omited parameters
-- 1. Used preconditions:
-- Delete files and policy table from previous ignition cycle if any
-- Do not start default SDL
-- 2. Performed steps:
-- Create PreloadedPolicyTable file with couple omited parameters
-- Start SDL
--
-- Expected result:
-- PolicyManager shut SDL down
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
Test = require('connecttest')
local config = require('config')
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local json = require("modules/json")
local SDL = require('modules/SDL')

--[[ Local Variables ]]
local PRELOADED_PT_FILE_NAME = "sdl_preloaded_pt.json"
local testParameters = {vehicle_model = "Fiesta", vehicle_make = "Ford", vehicle_year = 2015}

--[[ Local Functions ]]
function Test.backupPreloadedPT()
  os.execute("cp " .. config.pathToSDL .. PRELOADED_PT_FILE_NAME .. ' ' .. config.pathToSDL .. "backup_" .. PRELOADED_PT_FILE_NAME)
end

function Test.restorePreloadedPT()
  os.execute("mv " .. config.pathToSDL .. "backup_" .. PRELOADED_PT_FILE_NAME .. " " .. config.pathToSDL .. PRELOADED_PT_FILE_NAME)
end

function Test.corruptPreloadedPT(omitedParameters)

  local pathToFile = config.pathToSDL .. PRELOADED_PT_FILE_NAME

  local file = io.open(pathToFile, "r")
  local json_data = file:read("*a")
  file:close()

  local data = json.decode(json_data)
  if data then
    for key, value in pairs(omitedParameters) do
      data.policy_table.module_config[key] = value
    end
  end

  local dataToWrite = json.encode(data)
  file = io.open(pathToFile, "w")
  file:write(dataToWrite)
  file:close()
end

function Test.checkSdlShutdown()
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose",{}):Times(1)
  local status = SDL:CheckStatusSDL()
  if status == SDL.RUNNING then
    commonFunctions:userPrint(3, "Test failed: SDL running with omited parameters in preloaded policy table")
    return false
  end
  return true
end

--[[ Preconditions ]]
function Test:Precondition_stop_sdl()
  StopSDL(self)
end

function Test:Precondition()
  commonSteps:DeletePolicyTable()
  self.backupPreloadedPT()
  self.corruptPreloadedPT(testParameters)
end

--[[ Test ]]
function Test:Test_start_sdl()
  StartSDL(config.pathToSDL, true, self)
end

function Test:Test()
  self.checkSdlShutdown()
end

--[[ Postconditions ]]
function Test:Postconditions()
  self.restorePreloadedPT()
end

function Test:Postcondition_StopSDL()
  StopSDL(self)
end

return Test
