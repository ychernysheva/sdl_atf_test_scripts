---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [UpdateDeviceList] sending to HMI
--
-- Description:
-- UpdateDeviceList request from SDl to HMI upon new device connection
-- 1. Used preconditions:
-- Delete files and policy table from previous ignition cycle if any
-- Close current connection
-- 2. Performed steps:
-- Connect device
--
-- Expected result:
-- SDL sends UpdateDeviceList to HMI right after new device connects over WiFi
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local commonTestCases = require ('user_modules/shared_testcases/commonTestCases')
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonPreconditions = require ('user_modules/shared_testcases/commonPreconditions')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()
commonPreconditions:Connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp("connecttest_ConnectMobile.lua")

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_ConnectMobile')
require('cardinalities')
require('user_modules/AppTypes')
require('mobile_session')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:UpdateDeviceList_on_device_connect()
  local ServerAddress = commonFunctions:read_parameter_from_smart_device_link_ini("ServerAddress")
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
    {
      deviceList = {
        {
          id = config.deviceMAC,
          isSDLAllowed = false,
          name = ServerAddress,
          transportType = "WIFI"
        }
      }
    }
    ):Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  --:Times(AtLeast(1))
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end

return Test