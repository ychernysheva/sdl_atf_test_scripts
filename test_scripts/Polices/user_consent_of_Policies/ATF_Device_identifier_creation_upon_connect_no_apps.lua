---------------------------------------------------------------------------------------------
-- Requirement summary:
--     [Policies] <device identifier> section creation. Connection of the new device without SDL-enabled applications
--
-- Description:
--    New device is connected over WiFi WITHOUT SDL-enabled applications
-- 1. Used preconditions:
--    SDL and HMI are running
--
-- 2. Performed steps:
--    Connect device
--
-- Expected result:
--    SDL must add new <device identifier> section in "device_data" section
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
require('user_modules/AppTypes')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_Connect_device()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
  {
    deviceList = {
      {
        id = config.deviceMAC,
        name = "127.0.0.1",
        transportType = "WIFI",
        isSDLAllowed = false
      }
    }
  }
  ):Do(function(_,data)
  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  :Times(AtLeast(1))
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Check_LocalPT_for_device_identifier()
  local query
  if commonSteps:file_exists(config.pathToSDL .. "storage/policy.sqlite") then
    query = "sqlite3 " .. config.pathToSDL .. "storage/policy.sqlite".. " \"select device_identifier from device_data\""
  elseif commonSteps:file_exists(config.pathToSDL .. "policy.sqlite") then
    query = "sqlite3 " .. config.pathToSDL .. "policy.sqlite".. " \"select device_identifier from device_data\""
  else commonFunctions:userPrint(31, "policy.sqlite is not found")
  end

  if query ~= nil then
    os.execute("sleep 3")
    local handler = io.popen(query, 'r')
    os.execute("sleep 1")
    local result = handler:read( '*l' )
    handler:close()

    print(result)
    if result == "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0" then
      return true
    else
      self:FailTestCase("device_identifier in DB has unexpected value: " .. tostring(result))
      return false
    end
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  StopSDL()
end
