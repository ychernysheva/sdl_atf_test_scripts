---------------------------------------------------------------------------------------------
-- Description:
-- Behavior of SDL during start SDL in case when LocalPT(database) has the value of "preloaded_pt" field (Boolean) is "true"
-- 1. Used preconditions:
-- Delete files and policy table from previous ignition cycle if any
-- Start default SDL with valid PreloadedPT json file for create LocalPT(database) with "preloaded_pt" = "true"
-- 2. Performed steps:
-- Delete PreloadedPT json file
-- Start SDL only with LocalPT database and without PreloadedPT json file

-- Requirement summary:
-- [Policies]: PreloadedPolicyTable: "preloaded_pt: true"
--
-- Expected result:
-- SDL must consider LocalPT as PreloadedPolicyTable and start correctly
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('connecttest')
local config = require('config')

--[[ General configuration parameters ]]
config.defaultProtocolVersion = 2
local PRELOADED_PT_FILE_NAME = "sdl_preloaded_pt.json"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local SDL = require('modules/SDL')

--[[ Preconditions ]]
function Test.backup_preloaded_pt()
  os.execute(table.concat({"cp ", config.pathToSDL, PRELOADED_PT_FILE_NAME, ' ', config.pathToSDL, "backup_", PRELOADED_PT_FILE_NAME}))
end

function Test.remove_preloaded_pt()
  os.execute(table.concat({"rm ", config.pathToSDL, PRELOADED_PT_FILE_NAME}))
end

function Test.check_sdl()
  local status = SDL:CheckStatusSDL()
  if status ~= SDL.RUNNING then
    commonFunctions:userPrint(31, "Test failed: SDL aren't running only with LocalPT database and without PreloadedPT json file")
    return false
  end
  return true
end

function Test:Precondition_stop_sdl()
  StopSDL(self)
end

function Test:Precondition()
  self.backup_preloaded_pt()
  self.remove_preloaded_pt()
end

--[[ Test ]]

function Test:Test_start_sdl()
  StartSDL(config.pathToSDL, true, self)
end

function Test:Test()
  self.check_sdl()
end

--[[ Postconditions ]]
function Test.restore_preloaded_pt()
  os.execute(table.concat({"mv ", config.pathToSDL, "backup_", PRELOADED_PT_FILE_NAME, " ", config.pathToSDL, PRELOADED_PT_FILE_NAME}))
end

function Test:Postconditions()
  self.restore_preloaded_pt()
end

commonFunctions:SDLForceStop()
