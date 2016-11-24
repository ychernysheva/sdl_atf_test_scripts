---------------------------------------------------------------------------------------------
-- Requirement summary: 
--    [UpdateDeviceList] isSDLAllowed:false
--
-- Description: 
--     SDL behavior if DataConsent status was never asked for the corresponding device.
--     1. Used preconditions:
-- 	      Delete files and policy table from previous ignition cycle if any
--        Close current connection 
--     2. Performed steps:
--        Connect device 
--
-- Expected result:
--    PoliciesManager must provide "isSDLAllowed:false" param of "DeviceInfo" struct ONLY when sending "UpdateDeviceList" RPC to HMI
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
require('mobile_session')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Precondition_CloseConnection()
	self.mobileConnection:Close()
	commonTestCases:DelayedExp(3000)		
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:UpdateDeviceList_isSDLAllowed_false()
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
			        })
	:Do(function(_,data)
		if  isSDLAllowed ~= false then
			commonFunctions:userPrint(31, "Error: SDL should not be allowed for a new unconsented device")
		else
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	    end
	end)
	:Times(AtLeast(1)) 
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
	
function Test:Postcondition_SDLForceStop()
	commonFunctions:SDLForceStop()
end
