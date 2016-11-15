---------------------------------------------------------------------------------------------
-- Description: 
--     UpdateDeviceList request from SDl to HMI upon new device connection
--     1. Used preconditions:
-- 	      Delete files and policy table from previous ignition cycle if any
--        Close current connection 
--     2. Performed steps:
--        Connect device 

-- Requirement summary: 
--    [UpdateDeviceList] sending to HMI 
--
-- Expected result:
--    SDL sends UpdateDeviceList to HMI right after new device connects over WiFi
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:CloseConnection()
	self.mobileConnection:Close()
	commonTestCases:DelayedExp(3000)
		
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

commonFunctions:userPrint(34, "Test is intended to check that UpdateDeviceList to HMI is sent upon new device connect")

function Test:UpdateDeviceList_on_device_connect()
	commonTestCases:DelayedExp(2000)
	self:connectMobile()
	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
					{
						deviceList = {
							{
								id = config.deviceMAC,
								isSDLAllowed = false,
								name = "127.0.0.1",
								transportType = "WIFI"
							}
						}
					}
	):Do(function(_,data)
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)
	:Times(AtLeast(1))
end

--[[ Postconditions ]]
commonFunctions:SDLForceStop()

  
