---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PTU] Trigger: days
--
-- Description:
-- If the difference between current system time value_2 and system time value_1 when the previous
-- UpdatedPollicyTable was applied is equal or greater than to the value of "exchange_after_x_days"
-- field ("module_config" section) of policies database SDL must trigger a PolicyTableUpdate sequence
-- 1. Used preconditions:
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- Application is registered.
-- The date previous PTU was received is 01.01.2016
-- the value in PT "module_config"->"'exchange_after_x_days '"is set to 150
-- 2. Performed steps:
-- SDL gets the current date 06.06.2016, it's more than 150 days after the last PTU
--
-- Expected result:
-- SDL initiates PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- PTS is created by SDL: SDL-> HMI: SDL.PolicyUpdate() //PTU sequence started
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--ToDo: Should be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTableSnapshot = require ('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ Local Variables ]]
local exchangeDays = testCasesForPolicyTableSnapshot:get_data_from_Preloaded_PT("module_config.exchange_after_x_days")
local currentSystemDaysAfterEpoch

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()

--[[ Local Functions ]]
local function CreatePTUFromExisted()
  os.execute('cp files/ptu_general.json files/tmp_PTU.json')
end

local function DeleteTmpPTU()
  os.execute('rm files/tmp_PTU.json')
end

local function getSystemDaysAfterEpoch()
  return math.floor(os.time()/86400)
end

local function setPtExchangedXDaysAfterEpochInDB(daysAfterEpochFromPTS)
  local pathToDB = config.pathToSDL .. "storage/policy.sqlite"
  local DBQuery = 'sqlite3 ' .. pathToDB .. ' \"UPDATE module_meta SET pt_exchanged_x_days_after_epoch = ' .. daysAfterEpochFromPTS .. ' WHERE rowid = 1;\"'
  os.execute(DBQuery)
  os.execute(" sleep 1 ")
end

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require("user_modules/AppTypes")
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test.Preconditions_Set_Exchange_After_X_Days_For_PTU()
  CreatePTUFromExisted()
end

function Test:Precondition_Activate_App()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.applications["Test Application"]})
  EXPECT_HMIRESPONSE(RequestId, {result = {code = 0, isSDLAllowed = false}, method = "SDL.ActivateApp"})
  :Do(function(_,_)
      local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
      EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
      :Do(function(_,_)
          EXPECT_HMICALL("BasicCommunication.ActivateApp")
          :Do(function(_,data1)
              self.hmiConnection:SendResponse(data1.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
              EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
          end)
      end)
  end)
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
end

function Test:Precondition_Update_Policy_With_Exchange_After_X_Days_Value()
  currentSystemDaysAfterEpoch = getSystemDaysAfterEpoch()
  local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
  :Do(function()
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",{requestType = "HTTP", fileName = "filename"})
      EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "HTTP" })
      :Do(function()
          local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {fileName = "PolicyTableUpdate", requestType = "HTTP"}, "files/tmp_PTU.json")

          EXPECT_HMICALL("BasicCommunication.SystemRequest")
          :Do(function(_,data1)

              self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate", { policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"})
              self.hmiConnection:SendResponse(data1.id, "BasicCommunication.SystemRequest", "SUCCESS", {})
              EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
            end)
        end)
    end)
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate",
    {status = "UPDATING"}, {status = "UP_TO_DATE"}):Times(2)
end

function Test.Precondition_StopSDL()
  StopSDL()
end

function Test.SetExchangedXDaysInDB()
  setPtExchangedXDaysAfterEpochInDB(currentSystemDaysAfterEpoch - exchangeDays)
end

function Test.Precondition_StartSDL_FirstLifeCycle()
  StartSDL(config.pathToSDL, config.ExitOnCrash)
end

function Test:Precondition_InitHMI_FirstLifeCycle()
  self:initHMI()
end

function Test:Precondition_InitHMI_onReady_FirstLifeCycle()
  self:initHMI_onReady()
end

function Test:Precondition_ConnectMobile_FirstLifeCycle()
  self:connectMobile()
end

function Test:Precondition_StartSession()
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_Register_App_And_Check_That_PTU_Triggered()
  local CorIdRAI = self.mobileSession:SendRPC("RegisterAppInterface",
    {
      syncMsgVersion =
      {
        majorVersion = 3,
        minorVersion = 0
      },
      appName = "Test Application",
      isMediaApplication = true,
      languageDesired = "EN-US",
      hmiDisplayLanguageDesired = "EN-US",
      appID = "0000001",
      deviceInfo =
      {
        os = "Android",
        carrier = "Megafon",
        firmwareRev = "Name: Linux, Version: 3.4.0-perf",
        osVersion = "4.4.2",
        maxNumberRFCOMMPorts = 1
      }
    })
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered",
    {
      application =
      {
        appName = "Test Application",
        policyAppID = "0000001",
        isMediaApplication = true,
        hmiDisplayLanguageDesired = "EN-US",
        deviceInfo =
        {
          name = "127.0.0.1",
          id = config.deviceMAC,
          transportType = "WIFI",
          isSDLAllowed = true
        }
      }
    })
  EXPECT_RESPONSE(CorIdRAI, { success = true, resultCode = "SUCCESS"})
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate",{status = "UPDATE_NEEDED"})
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
end

--[[ Postcondition ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_DeleteTmpPTU()
  DeleteTmpPTU()
end

function Test.Postcondition_Stop_SDL()
  StopSDL()
end

return Test
