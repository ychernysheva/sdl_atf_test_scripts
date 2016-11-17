---------------------------------------------------------------------------------------------
-- Description: 
--     UpdateDeviceList request from SDl to HMI upon new device connection
--     1. Used preconditions:
-- 	      Delete files and policy table from previous ignition cycle if any
--        Do not start default SDL
--     2. Performed steps:
--        Create  PreloadedPolicyTable file with one required parameter that has invalid type
--        Start SDL

-- Requirement summary: 
--     [PreloadedPT] At least one required param has invalid type 
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

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local json = require("modules/json")
local SDL = require('modules/SDL')

--[[ Preconditions ]]

function Test.backupPreloadedPT()
	os.execute("cp " .. config.pathToSDL .. preloaded_pt_file_name .. ' ' .. config.pathToSDL .. "backup_" .. preloaded_pt_file_name)
end

function Test.restorePreloadedPT()
	os.execute("mv " .. config.pathToSDL .. "backup_" .. preloaded_pt_file_name .. " " .. config.pathToSDL .. preloaded_pt_file_name)
end

function Test.corruptPreloadedPT()
	local wrong_parameter_name = "Devce"

	local pathToFile = config.pathToSDL .. preloaded_pt_file_name

    local file  = io.open(pathToFile, "r")
    local json_data = file:read("*a") 
    file:close()
		   
    local data = json.decode(json_data)
    if data.policy_table.app_policies.device then
	data.policy_table.app_policies[wrong_parameter_name] = data.policy_table.app_policies.device
	data.policy_table.app_policies.device = nil  
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
		commonFunctions:userPrint(3, "Test failed: SDL running with incorrect preloaded policy table")
		return false 
	end
	return true
end

function Test:Precondition()
    StopSDL(self)
end

--[[ Test ]]
function Test:Test()
    commonSteps:DeletePolicyTable()
	Test.backupPreloadedPT(self)
    Test.corruptPreloadedPT()
    StartSDL(config.pathToSDL, false)
    os.execute("usleep(10000)")
	Test.checkSdlShutdown()
    Test.restorePreloadedPT()
    commonFunctions:SDLForceStop()
end

--[[ Postconditions ]]
