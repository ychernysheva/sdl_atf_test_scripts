-- UNREADY
-- should be updated after Question APPLINK-30264 is resolved

---------------------------------------------------------------------------------------------
-- Requirement summary: 
--     [Policies]: OnAllowSDLFunctionality with 'allowed=true' and with 'device' param from HMI
--
-- Description: 
--     1. Preconditions: App is registered 
--     2. Steps: Activate App, send SDL.OnAllowSDLFunctionality with 'allowed=true' and with 'device' to HMI
--
-- Expected result:
--    app->SDL: RegisterAppInterface
--    SDL->HMI: OnAppRegistered (appID)
--    PoliciesManager: device needs consent; app is not present in Local PT.
--    PoliciesManager: "<appID>": "pre_DataConsent" //that is, adds appID to the Local PT and assigns default policies to it
--    SDL->HMI: SDL.OnSDLConsentNeeded
--    HMI->SDL: SDL.GetUserFriendlyMessages ("DataConsent")
--    SDL->HMI: SDL.GetUserFriendlyMessages_response
--    HMI displays the device consent pormpt. User makes choice.
--    HMI->SDL: OnAllowSDLFunctionality
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
require('user_modules/AppTypes')

--[[ General Precondition before ATF start ]]
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY", "EXTERNAL_PROPRIETARY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","EXTERNAL_PROPRIETARY")
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest') 
require('cardinalities')
require('mobile_session')

--[[ Local Functions ]]
local function get_id_value() 
  local sql_select = "sqlite3 " .. tostring(SDLStoragePath) .. "policy.sqlite \"SELECT id FROM functional_group WHERE name = \"BaseBeforeDataConsent\"\""
    local handle = assert( io.popen( sql_select , 'r'))
    sql_output = handle:read( '*l' )   
    local ret_value = tonumber(sql_output)    
    if (ret_value == nil) then
       self:FailTestCase("device id can't be read")
    else 
      return ret_value
    end
end

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:TestStep:ActivateApp_allowed_true_with_device()
  local request_id = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.HMIAppID})
  -- SDL -> HMI: SDL.ActivateApp {isSDLAllowed: false, device is omitted}
  EXPECT_HMIRESPONSE(request_id,{isSDLAllowed = false, method = "SDL.ActivateApp"})
    -- HMI -> SDL: SDL.GetUserFriendlymessage {messageCodes: DataConsent}
    local request_id = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
      {language = "EN-US", messageCodes = {"DataConsent"}})
    -- SDL -> HMI: SDL.GetUserFriendlymessage {messages}
    EXPECT_HMIRESPONSE(request_id,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
      -- HMI -> SDL: SDL.OnAllowSDLFunctionality {allowed: true, device, source}
      self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
      {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
      -- SDL -> MOB: OnPermissionChange
      self.mobileSession:ExpectNotification("OnPermissionsChange", {})
      -- SDL -> HMI: BC.ActivateApp {level:<"default_hmi" from "pre_DataConsent" section>, params}
      EXPECT_HMICALL("BasicCommunication.ActivateApp")
        :Do(function(_,data)
          --hmi side: sending BasicCommunication.ActivateApp response
          self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
        end)
  -- SDL -> MOB: OnHMIStatus {HMILevel:<"defaultHMI" from "pre_DataConsent" section>, params}
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "NONE", systemContext = "MAIN"}) 
end

function Test:TestStep_CheckValueOfDeviceID()
  device_id = get_id_value(self)
  print (device_id)  
  if (device_id == 0) then
    self:FailTestCase("device_id in database was not updated")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test:Postcondition_Force_Stop_SDL()
  commonFunctions:SDLForceStop(self)
end

return Test 