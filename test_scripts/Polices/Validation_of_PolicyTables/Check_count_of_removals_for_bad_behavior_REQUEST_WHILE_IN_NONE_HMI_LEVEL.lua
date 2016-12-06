---------------------------------------------------------------------------------------------

-- See APPLINK-23481, APPLINK-16147
-- Requirement summary:
-- [Policies] "usage_and_error_counts" and "count_of_rpcs_sent_in_hmi_none" update.
--
-- Description:
-- In case an application has been unregistered with any of:
-- -> TOO_MANY_PENDING_REQUESTS,
-- -> TOO_MANY_REQUESTS,
-- -> REQUEST_WHILE_IN_NONE_HMI_LEVEL resultCodes,
-- Policy Manager must increment "count_of_removals_for_bad_behavior" section value
-- of Local Policy Table for the corresponding application.

-- Pre-conditions:
-- a. SDL and HMI are started
-- b. app successfully registers and running in NONE

-- Steps:
-- 1. Application is sending more requests than AppHMILevelNoneTimeScaleMaxRequests in
-- AppHMILevelNoneRequestsTimeScale milliseconds:
-- appID->AnyRPC()
-- 2. Application is unregistered:
-- SDL->appID: OnAppUnregistered(REQUEST_WHILE_IN_NONE_HMI_LEVEL)

-- Expected:
-- 3. PoliciesManager increments value of <count_of_removals_for_bad_behavior>

-- Thic

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local Preconditions = require('user_modules/shared_testcases/commonPreconditions')
-- local variables
local count_of_requests = 10

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

-- Precondition: application is activate
--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test.Precondition_StopSDL()
  StopSDL()
end

function Test.ChangeIniFile( )
  Preconditions:BackupFile("smartDeviceLink.ini")
  commonFunctions:write_parameter_to_smart_device_link_ini("AppHMILevelNoneTimeScaleMaxRequests", count_of_requests)
  commonFunctions:write_parameter_to_smart_device_link_ini("AppHMILevelNoneRequestsTimeScale", 1000)
end
--[[ end of Preconditions ]]

-- Precondition: application is NONE
function Test:Send_TOO_MANY_REQUESTS_WHILE_IN_NONE_HMI_LEVEL()
  local count_of_sending_requests = count_of_requests+10
  for i=1, count_of_sending_requests do
    self.mobileSession:SendRPC("AddCommand",
      {
        cmdID = i,
        menuParams =
        {
          position = 0,
          menuName ="Command"..tostring(i)
        }
      })
  end
  EXPECT_RESPONSE("AddCommand" , { success = false, resultCode = "DISALLOWED" })
  :Times(count_of_sending_requests)
  :Timeout(150000)

  -- --mobile side: expect notification
  EXPECT_NOTIFICATION("OnAppInterfaceUnregistered", {reason = "REQUEST_WHILE_IN_NONE_HMI_LEVEL"})
end

function Test:Check_TOO_MANY_REQUESTS_in_DB()
  local db_path = config.pathToSDL.."storage/policy.sqlite"
  local sql_query = "SELECT count_of_removals_for_bad_behavior FROM app_level WHERE application_id = "..config.application1.registerAppInterfaceParams.appID
  local exp_result = 1
  if commonFunctions:is_db_contains(db_path, sql_query, exp_result) == false then
    self:FailTestCase("DB doesn't include expected value")
  end
end

function Test.Postcondition_Stop_SDL()
  StopSDL()
end
function Test.RestoreIniFile()
  Preconditions:RestoreFile("smartDeviceLink.ini")
end

return Test
