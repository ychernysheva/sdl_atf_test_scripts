----------------------------------------------------------------------------------------------------
-- Script verifies issue https://github.com/SmartDeviceLink/sdl_core/issues/1211
-- Flow: EXTERNAL_PROPRIETARY
----------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require("user_modules/script_runner")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local mobile_session = require("mobile_session")
local common = require("test_scripts/Defects/4_5/commonDefects")
local commonTestCases = require("user_modules/shared_testcases/commonTestCases")

--[[ General configuration parameters ]]
config.ExitOnCrash = false

-- [[Local variables]]
local count_of_requests = 10

local function updateINIFile()
  common.backupINIFile()
  commonFunctions:write_parameter_to_smart_device_link_ini("AppHMILevelNoneTimeScaleMaxRequests", count_of_requests)
  commonFunctions:write_parameter_to_smart_device_link_ini("AppHMILevelNoneRequestsTimeScale", 30000)
end

local function registerApp(self)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function ()
      local cid = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
      EXPECT_RESPONSE(cid, { success = true })
      EXPECT_NOTIFICATION("OnPermissionsChange")
    end)
end

local function Send_TOO_MANY_REQUESTS_WHILE_IN_NONE_HMI_LEVEL(self)
  local count_of_sending_requests = count_of_requests + 10
  for i = 1, count_of_sending_requests do
    self.mobileSession:SendRPC("AddCommand", {
      cmdID = i,
      menuParams =
      {
        position = 0,
        menuName ="Command" .. tostring(i)
      }
    })
  end
  EXPECT_NOTIFICATION("OnAppInterfaceUnregistered", {reason = "REQUEST_WHILE_IN_NONE_HMI_LEVEL"})
end

local function Wait()
  commonTestCases:DelayedExp(3000)
end

local function Check_TOO_MANY_REQUESTS_in_DB(self)
  local db_path = config.pathToSDL.."storage/policy.sqlite"
  local sql_query = "SELECT count_of_removals_for_bad_behavior FROM app_level WHERE application_id = '"
    .. config.application1.registerAppInterfaceParams.appID .. "'"
  local exp_result = {"1"}
  if commonFunctions:is_db_contains(db_path, sql_query, exp_result) == false then
    self:FailTestCase("DB doesn't include expected value")
  end
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Update INI file", updateINIFile)
runner.Step("Start SDL, HMI, connect Mobile", common.start)
runner.Step("SDL Configuration", common.printSDLConfig)

runner.Title("Test")
runner.Step("Register App", registerApp)
runner.Step("Send_TOO_MANY_REQUESTS_WHILE_IN_NONE_HMI_LEVEL", Send_TOO_MANY_REQUESTS_WHILE_IN_NONE_HMI_LEVEL)
runner.Step("Wait 3sec", Wait)
runner.Step("Check_TOO_MANY_REQUESTS_in_DB", Check_TOO_MANY_REQUESTS_in_DB)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
runner.Step("Restore INI file", common.restoreINIFile)
