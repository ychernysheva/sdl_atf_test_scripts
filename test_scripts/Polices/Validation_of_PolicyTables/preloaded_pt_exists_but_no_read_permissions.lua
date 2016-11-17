---------------------------------------------------------------------------------------------
-- Description: 
--     Behavior of SDL during start SDL with Preloaded PT file without read permissions
--     1. Used preconditions:
-- 	      Delete files and policy table from previous ignition cycle if any
--        Do not start default SDL
--     2. Performed steps:
--        Create correct PreloadedPolicyTable file without read permissions
--        Start SDL

-- Requirement summary: 
--     [Policy] Preloaded PT exists at the path defined in .ini file but NO "read" permissions 
--
-- Expected result:
--     PolicyManager shut SDL down
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('connecttest')
local config = require('config')

--[[ General configuration parameters ]]
-- config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.defaultProtocolVersion = 2

local preloaded_pt_file_name = "sdl_preloaded_pt.json"
local GRANT = "+"
local REVOKE = "-"


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
    self.change_read_permissions_from_preloaded_pt_file(REVOKE)
end

--[[ Test ]]
function Test.checkSdlShutdown()
	EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose",{}):Times(1)
	local status = SDL:CheckStatusSDL()
	if status == SDL.RUNNING then
		commonFunctions:userPrint(31, "Test failed: SDL running without initialized Preloaded PT")
		return false 
	end
	return true
end

function Test:Test()
    StartSDL(config.pathToSDL, false)
    os.execute("sleep 3 ")
    self.checkSdlShutdown()
end

--[[ Postconditions ]]
function Test:Postcondition()
	self.change_read_permissions_from_preloaded_pt_file(GRANT)
	commonFunctions:SDLForceStop()
end