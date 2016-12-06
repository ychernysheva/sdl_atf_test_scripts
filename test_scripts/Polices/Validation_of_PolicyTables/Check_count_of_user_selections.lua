---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] "usage_and_error_counts" and "count_of_rejections_duplicate_name" update
--
-- Description:
-- In case application registers with the name already registered on SDL now,
-- Policy Manager must increment "count_of_rejections_duplicate_name" section value
-- of Local Policy Table for the corresponding application.

-- a. SDL and HMI are started
-- b. app_1 with <abc> name successfully registers and running on SDL

-- Steps:
-- 1. app_2 -> SDL; RegisterAppInterface (appName: <abc>)
-- 2. SDL -> app_2: RegisterAppInterface (DUPLICATE_NAME)

-- Expected:
-- 3. PoliciesMananger increments "count_of_rejections_duplicate_name" filed at PolicyTable

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local json = require('json')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
local mobile_session = require('mobile_session')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Common variables ]]

local HMIAppID
-- Basic PTU file
local basic_ptu_file = "files/ptu.json"
-- PTU for first app
local ptu_first_app_registered = "files/ptu1app.json"

-- Basic applications. Using in Register tests
local application2 =
{
  registerAppInterfaceParams =
  {
    syncMsgVersion =
    {
      majorVersion = 3,
      minorVersion = 0
    },
    appName = "Test Application", -- the same name in config.application1
    isMediaApplication = true,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appHMIType = { "NAVIGATION" },
    appID = "0000003", --ID different
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  }
}

-- Prepare parameters for app to save it in json file
local function PrepareJsonPTU1(name, new_ptufile)
  local json_app = [[ {
    "keep_context": false,
    "steal_focus": false,
    "priority": "NONE",
    "default_hmi": "NONE",
    "groups": [
    "Base-4", "Location-1"
    ],
    "RequestType":[
    "TRAFFIC_MESSAGE_CHANNEL",
    "PROPRIETARY",
    "HTTP",
    "QUERY_APPS"
    ]
  }]]
  local app = json.decode(json_app)
  testCasesForPolicyTable:AddApplicationToPTJsonFile(basic_ptu_file, new_ptufile, name, app)
end

--[[Preconditions]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test.Precondition_StopSDL()
  StopSDL()
end
function Test.Precondition_StartSDL()
  StartSDL(config.pathToSDL, config.ExitOnCrash)
end

function Test:Precondition_initHMI()
  self:initHMI()
end

function Test:Precondition_initHMI_onReady()
  self:initHMI_onReady()
end

function Test:Precondition_ConnectMobile()
  self:connectMobile()
end

function Test:Precondition_StartSession()
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
end

function Test.Precondition_PreparePTData()
  PrepareJsonPTU1(config.application1.registerAppInterfaceParams.appID, ptu_first_app_registered)
end

function Test:RegisterFirstApp()
  self.mobileSession:StartService(7)
  :Do(function (_,_)
      local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
      :Do(function(_,data)
          HMIAppID = data.params.application.appID
        end)
      EXPECT_RESPONSE(correlationId, { success = true })
      EXPECT_NOTIFICATION("OnPermissionsChange")
    end)
end

function Test.Precondition_PreparePTData()
  PrepareJsonPTU1(config.application1.registerAppInterfaceParams.appID, ptu_first_app_registered)
end
--[[ end of Preconditions ]]

--[[ Test ]]
function Test:RegisterSecondApp_DuplicateData()
  self.mobileSession1 = mobile_session.MobileSession(self, self.mobileConnection)

  self.mobileSession1:StartService(7)
  :Do(function (_,_)
      local correlationId = self.mobileSession1:SendRPC("RegisterAppInterface", application2.registerAppInterfaceParams)
      self.mobileSession1:ExpectResponse(correlationId, { success = false, resultCode = "DUPLICATE_NAME" })
    end)
end

function Test:ActivateAppInSpecificLevel()
  commonSteps:ActivateAppInSpecificLevel(self,HMIAppID,"FULL")
end

function Test:InitiatePTUForGetSnapshot()
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
  testCasesForPolicyTable:updatePolicyInDifferentSessions(Test, ptu_first_app_registered,
    config.application1.registerAppInterfaceParams.appName, self.mobileSession)
end

function Test:CheckDB_updated_count_of_rejections_duplicate_name()
  local db_path = config.pathToSDL.."storage/policy.sqlite"
  local sql_query = "SELECT count_of_rejections_duplicate_name FROM app_level WHERE application_id = 0000003"
  local exp_result = 1
  if commonFunctions:is_db_contains(db_path, sql_query, exp_result) ==false then
    self:FailTestCase("DB doesn't include expected value")
  end
end
--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_RemovePTUfiles()
  os.remove(ptu_first_app_registered)
end
function Test.Postcondition_Stop_SDL()
  StopSDL()
end

return Test
