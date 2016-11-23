 -----  Name of requirement that is covered-----
 ----- [Security]: SDL behavior in case 'certificates' field is empty
 -----Description: 
 ----- Certificate have empty value in sdl_preloaded_pt JSON of module_config section
  ----- Expected result------
 -----  SDL must continue working as assigned.

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')

--[[ General Precondition before ATF start ]]
--Copy attached json file in SDL_bin folder.
--Json contains certificate filed with empty value
commonSteps:DeleteLogsFileAndPolicyTable()

--[[Test]]
commonFunctions:userPrint(33, "================= Test_Case ==================")
Test = require('connecttest')

--[[ Postconditions ]]
Test["StopSDL"] = function()
commonFunctions:userPrint(33, "================= Postcondition ==================")
    StopSDL()
  end