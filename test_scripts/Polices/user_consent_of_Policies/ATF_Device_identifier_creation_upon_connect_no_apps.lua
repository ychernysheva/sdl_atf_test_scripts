--UNREADY
--Function for check device in LPT should be updated
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
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

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
  local test_fail = false
  local device_identifier = testCasesForPolicyTableSnapshot:get_data_from_PTS("device_data")
  print("device_identifier" ..tostring(device_identifier))
  if(device_identifier == nil) then
    commonFunctions:printError("Error: device_identifier wasn't added to LPT upon device connecting")
    test_fail = true
  end
  if(test_fail == true) then
    self:FailTestCase("Test failed")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end