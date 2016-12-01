--UNREADY
-- commonFunctions:setSystemTime(days) should be developed
-- testCasesForPolicyTable.flow_PTU_SUCCESS_EXTERNAL_PROPRTIETARY should be developed
-- currently stub functions are used

---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PTU] Trigger: days
--
-- Description:
-- Describe correctly the CASE of requirement that is covered, conditions that will be used.
-- 1. Used preconditions: The date was "1-May-2016" when prev PTU was successfully applied
--    Policies DB contains: "exchange_after_x_days: 30"
-- 2. Performed steps: 
-- Ignition_ON
-- User set system date to "31-May-2016"
--
-- Expected result:
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- start PTU flow
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
--local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ General Precondition before ATF start ]]
--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY", "PROPRIETARY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","PROPRIETARY")

commonSteps:DeleteLogsFileAndPolicyTable()

function Test.Precondition_Set_System_Day_to_1_May_2016()
-- Stub function to set system time
-- commonFunctions:setSystemTime(date)
return true
end

function Test.Precondition_Successfull_PTU()
	return true
  --testCasesForPolicyTable.flow_PTU_SUCCESS_EXTERNAL_PROPRTIETARY()
end

function Test:Precondition_SUSPEND()
	self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", {reason = "SUSPEND"})
	EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
end
  
function Test:Precontiotion_IGN_OFF() 
-- ToDo(VVVakulenko): substitute commonFunctions:SDLForceStop() with StopSDL() after resolve issue "SDL doesn't stop at execution ATF function StopSDL()"
  --StopSDL()
  commonFunctions:SDLForceStop()	
  self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",{reason = "IGNITION_OFF"})
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
  :Times(1)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test.TestStep_IGN_ON()
  Test["StartSDL"] = function ()
	StartSDL(config.pathToSDL, config.ExitOnCrash)
  end

  Test["TestInitHMI"] = function (self)
	self:initHMI()
  end

  Test["TestInitHMIOnReady"] = function (self)
	self:initHMI_onReady()
  end

  Test["ConnectMobile"] = function (self)
	self:connectMobile()
  end

  Test["StartSession"] = function (self)
	self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  end
end

function Test.TestStep_Set_System_Day_And_Check_That_PTU_Is_Triggered()
-- Stub function to set system time
--commonFunctions:setSystemTime(date)
  EXPECT_HMICALL("SDL.PolicyUpdate")
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"}):Timeout(500)
end

function Test.TestStep_Successfull_PTU()
	return true
  --testCasesForPolicyTable.flow_PTU_SUCCESS_EXTERNAL_PROPRTIETARY()
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_ForceStopSDL()
  commonFunctions:SDLForceStop()
end

return Test