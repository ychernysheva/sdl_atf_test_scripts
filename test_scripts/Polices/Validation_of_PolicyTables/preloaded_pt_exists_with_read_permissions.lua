---------------------------------------------------------------------------------------------
-- Description: 
--     Behavior of SDL during start SDL with Preloaded PT file with read permissions
--     1. Used preconditions:
-- 	      Delete files and policy table from previous ignition cycle if any
--        Do not start default SDL
--     2. Performed steps:
--        Create correct PreloadedPolicyTable file with read permissions
--        Start SDL

-- Requirement summary: 
--     [Policy] Preloaded PT exists at the path defined in .ini file WITH "read" permissions 
--
-- Expected result:
--     SDL started successfully
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('connecttest')
local config = require('config')

--[[ General configuration parameters ]]
config.defaultProtocolVersion = 2

local preloaded_pt_file_name = "sdl_preloaded_pt.json"
local GRANT = "+"


--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local SDL = require('modules/SDL')

--[[ Preconditions ]]
function Test.change_read_permissions_from_preloaded_pt_file(sign)
	os.execute(table.concat({"chmod -f a", sign, "r ", config.pathToSDL, preloaded_pt_file_name}))
end

function Test:Precondition()
    StopSDL()
    commonSteps:DeletePolicyTable()
    self.change_read_permissions_from_preloaded_pt_file(GRANT)
end

--[[ Test ]]
function Test.checkSdl()
		local status = SDL:CheckStatusSDL()
	if status ~= SDL.RUNNING then
		commonFunctions:userPrint(31, "Test failed: SDL down with correct initialized Preloaded PT")
		return false 
	end
	return true
end

function Test:Test()
    StartSDL(config.pathToSDL, true)
    self.checkSdl()
end

--[[ Postconditions ]]
	commonFunctions:SDLForceStop()