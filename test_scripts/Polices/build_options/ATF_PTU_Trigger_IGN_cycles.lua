--UNREADY
-- should be updated after testCasesForPolicyTable.lua implementation

---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PTU] Trigger: ignition cycles
--
-- Description:
-- 1. Used preconditions: the 1-st IGN cycle, PTU was succesfully applied. Policies DataBase contains "exchange_after_x_ignition_cycles" = 10
-- 2. Performed steps: Perform ignition_on/off 11 times
--
-- Expected result:
-- When amount of ignition cycles notified by HMI via BasicCommunication.OnIgnitionCycleOver gets equal to the value of "exchange_after_x_ignition_cycles" 
-- field ("module_config" section) of policies database, SDL must trigger a PolicyTableUpdate sequence
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
Test = require('connecttest')

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps   = require('user_modules/shared_testcases/commonSteps')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
--local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ Local Functions ]]
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

function Test:IGNITION_OFF()
-- ToDo(VVVakulenko): substitute SDLForceStop with StopSDL after resolve APPLINK-19717
  commonFunctions:SDLForceStop()
  :Do(function()
    self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",{reason = "IGNITION_OFF"})
  end)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
  :Times(1)
end

local function StartSDLAfterStop(prefix)
  Test["Precondition_StartSDL_" .. tostring(prefix) ] = function()
	StartSDL(config.pathToSDL, config.ExitOnCrash)
  end
  Test["Precondition_InitHMI_" .. tostring(prefix) ] = function(self)
	self:initHMI()
  end
  Test["Precondition_InitHMI_onReady_" .. tostring(prefix) ] = function(self)
	self:initHMI_onReady()
  end
  Test["Precondition_ConnectMobile_" .. tostring(prefix) ] = function(self)
  	self:connectMobile()
  end
  Test["Precondition_StartSessionRegisterApp_" .. tostring(prefix) ] = function(self)
  	self:startSession()
  end
end

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()

commonSteps:DeleteLogsFileAndPolicyTable()
--TODO(VVVakulenko): Should be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

commonPreconditions:BackupFile("sdl_preloaded_pt.json")

function Test.Preconditions_set_exchange_after_x_ignition_cycles_to_10()
  modify_preloaded(genpattern2str("exchange_after_x_ignition_cycles", "%d+"), "10")
end

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

-- --[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test.Preconditions_perform_10_IGN_OFF_ON()
  -- local count_of_ign_cycles = {}
  --   for i = 1, 10 do
  --     IGNITION_OFF()
      StartSDLAfterStop()
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test.TestStep_PTU_start_on_11_th_IGN_OFF()
-- ToDo(VVVakulenko): update after implementation of testCasesForPolicyTable
-- testCasesForPolicyTable.trigger_PTU_N_ign_cycles()
  return true
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