---------------------------------------------------------------------------------------------
-- Requirement summary:
--     [Policies] SDL must add a timestamp of the consent in a specific format
--
-- Description:
--     Format of user consent timestamp added to Local PolicyTable.
--     1. Used preconditions:
-- 			Start SDL and init HMI
-- 			Close default connection
--          Overwrite preloaded file to make device not consented
--          Connect device
--          Register app
--          Consent device on HMI
--     2. Performed steps
--			Check timestamp format is "<yyyy-mm-dd>T<hh:mm:ss>Z" in LPT
--
-- Expected result:
--    	PoliciesManager must add a timestamp of user consent for the current mobile device into “time_stamp” field in the format of "<yyyy-mm-dd>T<hh:mm:ss>Z".
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
local Preconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
require('user_modules/AppTypes')

--[[ Local functions ]]
local function ConsentDevice(self, allowedValue, idValue, nameValue)
  local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
  {language = "EN-US", messageCodes = {"DataConsent"}})
  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,data)
  self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
  {allowed = allowedValue, source = "GUI", device = {id = idValue, name = nameValue}})
  end)
end

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Precondition_CloseConnection()
  self.mobileConnection:Close()
  commonTestCases:DelayedExp(3000)

end

Preconditions:BackupFile("sdl_preloaded_pt.json")

testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/DeviceNotConsented_preloadedPT.json")

function Test:Precondition_ConnectDevice()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
  {
    deviceList = {
      {
        id = config.deviceMAC,
        isSDLAllowed = true,
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

function Test:Precondition_RegisterApplication()
  commonTestCases:DelayedExp(3000)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
  :Do(function(_,data)
  self.HMIAppID = data.params.application.appID
  end)
  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
  self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
  end)
end

function Test:Precondition_ConsentDevice()
  ConsentDevice(self, true, config.deviceMAC, config.mobileHost )
  -- get time of Device consent
  local CurrentUnixDateCommand = assert( io.popen( "date +%s" , 'r'))
  CurrentUnixDateForDeviceConsent = CurrentUnixDateCommand:read( '*l' )
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TimeStamp_in_userConsentRecords_table()
  local errorFlag = false
  local ErrorMessage = ""
  os.execute( " sleep 5 " )
  local TimeStamp_InUserConsentRecordsTable = "sqlite3 " .. tostring(config.pathToSDL) .. "storage/policy.sqlite \"SELECT time_stamp FROM user_consent_records WHERE rowid = 1\""

  local aHandle = assert( io.popen( TimeStamp_InUserConsentRecordsTable , 'r'))
  TimeStamp_InUserConsentRecordsTableValue = aHandle:read( '*l' )

  if TimeStamp_InUserConsentRecordsTableValue then

    commonFunctions:userPrint(33, "TimeStamp in user_consent_records " .. tostring(TimeStamp_InUserConsentRecordsTableValue))

    local Date, separatorFirst, Time, separatorSecond = TimeStamp_InUserConsentRecordsTableValue:match("([%d-]-)([T])([%d:]-)([Z])")

    -- Get current date
    local CurrentDateCommand = assert( io.popen( "date +%Y-%m-%d " , 'r'))
    CurrentDate = CurrentDateCommand:read( '*l' )

    if Date then
      if Date ~= CurrentDate then
        ErrorMessage = ErrorMessage .. "Date in user_consent_records is not equal to current date. Date from user_consent_records is " .. tostring(Date) .. ", current date is " .. tostring(CurrentDate) .. ". \n"
        errorFlag = true
      end
    else
      ErrorMessage = ErrorMessage .."Date in user_consent_records is wrong or absent. \n"
      errorFlag = true
    end

    if Time then

      local CurrentDateCommand = assert( io.popen( "date -d @" .. tostring(CurrentUnixDateForDeviceConsent) .. "  +%H:%M:%S " , 'r'))
      TimeForPermissionConsentValue = CurrentDateCommand:read( '*l' )

      local CurrentDateCommand2 = assert( io.popen( "date -d @" .. tostring(tonumber(CurrentUnixDateForDeviceConsent)+1) .. "  +%H:%M:%S " , 'r'))

      TimeForPermissionConsentValuePlusSecond = CurrentDateCommand2:read( '*l' )

      local CurrentDateCommand3 = assert( io.popen( "date -d @" .. tostring(tonumber(CurrentUnixDateForDeviceConsent)-1) .. "  +%H:%M:%S " , 'r'))
      TimeForPermissionConsentValueMinusSecond = CurrentDateCommand3:read( '*l' )

      if Time == TimeForPermissionConsentValue or
      Time == TimeForPermissionConsentValuePlusSecond or
      Time == TimeForPermissionConsentValueMinusSecond then
      else
        ErrorMessage = ErrorMessage .. "Time in user_consent_records is not equal to time of device consent. Time from user_consent_records is " .. tostring(Time) .. ", time to check is " .. tostring(TimeForPermissionConsentValue) .. " +- 1 second. \n"
        errorFlag = true
      end
    else
      print("Time in user_consent_records is wrong or absent")
    end
    if separatorFirst then
      if separatorFirst ~= "T" then
        ErrorMessage = ErrorMessage .. "Separator 'T' between date and time in user_consent_records is not equal to 'T'. Separator from user_consent_records is " .. tostring(separatorFirst) .. ". \n"
        errorFlag = true
      end
    else
      ErrorMessage = ErrorMessage .."Separator 'T' between date and time in user_consent_records is wrong or absent. \n"
      errorFlag = true
    end
    if separatorSecond then
      if separatorSecond ~= "Z" then
        ErrorMessage = ErrorMessage .. "Separator 'Z' after date and time in user_consent_records is not equal to 'Z'. Separator from user_consent_records is " .. tostring(separatorSecond) .. ". \n"
        errorFlag = true
      end
    else
      ErrorMessage = ErrorMessage .."Separator 'Z' after date and time in user_consent_records is wrong or absent. \n"
      errorFlag = true
    end
  else
    ErrorMessage = ErrorMessage .. "TimeStamp is absent or empty in user_consent_records. \n"
    errorFlag = true
  end
  if errorFlag == true then
    self:FailTestCase(ErrorMessage)
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end

function Test.Restore_PreloadedPT()
  testCasesForPolicyTable:Restore_preloaded_pt()
end