---------------------------------------------------------------------------------------------
-- Requirement summary:
--   [Policies] "ignition_cycles_since_last_exchange" reset in LocalPT
--
-- Description:
--     Incrementing value in 'ignition_cycles_since_last_exchange' section of LocalPT
--     1. Used preconditions:
--      Delete log file and policy table if any
--      Start SDL and HMI
--      Perform ignition OFF
--      Perform ignition ON
--      Register app
--      Activate app-> PTU is triggered
--
--     2. Performed steps
--      Check "ignition_cycles_since_last_exchange" value of LocalPT
--
-- Expected result:
--     On successful PolicyTable exchange, Policies Manager must reset to "0" the value in 'ignition_cycles_since_last_exchange"
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--[ToDo: should be removed when fixed: "ATF does not stop HB timers by closing session and connection"
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_SDL_Ign_Off()
  StopSDL()
  self.hmiConnection:SendNotification("BasicCommunication.OnIgnitionCycleOver")
  self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
  {
    reason = "IGNITION_OFF"
  })
end

function Test.Precondition_SDL_Ign_On()
  StartSDL(config.pathToSDL, config.ExitOnCrash)
end

function Test:Precondition_InitHMI()
  self:initHMI()
end

function Test:Precondition_InitOnready()
  self:initHMI_onReady()
end

function Test:Precondition_StartNewSession()
  self:connectMobile()
  self.mobileSession = mobile_session.MobileSession( self, self.mobileConnection)
  self.mobileSession:StartService(7)
end

function Test:Precondition_PTU_upon_Registering_app()
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application1.appName } })
  :Do(function(_,data)
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
  {
    file = "/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json",
  })
  :Do(function()
  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  end)
  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS"})
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Ignition_cycles_since_last_exchange_should_be_reset()
  local query
  if commonSteps:file_exists(config.pathToSDL .. "storage/policy.sqlite") then
    query = "sqlite3 " .. config.pathToSDL .. "storage/policy.sqlite".. " \"select ignition_cycles_since_last_exchange from module_meta\""
  elseif commonSteps:file_exists(config.pathToSDL .. "policy.sqlite") then
    query = "sqlite3 " .. config.pathToSDL .. "policy.sqlite".. " \"select ignition_cycles_since_last_exchange from module_meta\""
  else commonFunctions:userPrint(31, "policy.sqlite is not found")
  end
  if query ~= nil then
    os.execute("sleep 3")
    local handler = io.popen(query, 'r')
    os.execute("sleep 1")
    local result = handler:read( '*l' )
    handler:close()
    print(result)
    if result == 0 then
      return true
    else
      self:FailTestCase("ignition_cycles_since_last_exchange in DB has wrong value: " .. tostring(result))
      return false
    end
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_SDLStop()
  StopSDL()
end