---------------------------------------------------------------------------------------------
-- Description: 
--     1. Preconditions: App is registered
--     2. Steps: Activate App, send SDL.OnAllowSDLFunctionality with 'allowed=false' and with 'device' to HMI
-- Requirement summary: 
--     [Policy] "EXTERNAL_PROPRIETARY" flow: Related HMI API
--     [Policies]: OnAllowSDLFunctionality with 'allowed=false' and with 'device' param from HMI
--
-- Expected result:
--     In case PoliciesManager receives SDL.OnAllowSDLFunctionality with 'allowed=false' and with 'device' param, PoliciesManager must record the named 
--     device ('device' param) as NOT consented in Local PT ("user_consent_records"-> "device" sub-section) and send BasicCommunication.ActivateApp with 
--     'level' param of the value from 'default_hmi' key of 'pre-DataConsent'section of Local PT to HMI. App should stay in NONE HMI level
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('connecttest') 
require('cardinalities')
require('mobile_session')
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--[[ Local Functions ]]
local function get_id_value() 
  local sql_select = "sqlite3 " .. tostring(SDLStoragePath) .. "policy.sqlite \"SELECT id FROM functional_group WHERE name = "BaseBeforeDataConsent"\""
    local aHandle = assert( io.popen( sql_select , 'r'))
    sql_output = aHandle:read( '*l' )   
    local retvalue = tonumber(sql_output)    
    if (retvalue == nil) then
       self:FailTestCase("device id can't be read")
    else 
      return retvalue
    end
end
--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
require('user_modules/AppTypes')
--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:RegisterApp_allowed_false_without_device()
   -- HMI -> SDL: SDL.ActivateApp
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.HMIAppID})
  -- SDL -> HMI: SDL.ActivateApp {isSDLAllowed: false, device is omitted}
  EXPECT_HMIRESPONSE(RequestId,{isSDLAllowed = false, method = "SDL.ActivateApp"})
    -- HMI -> SDL: SDL.GetUserFriendlymessage {messageCodes: DataConsent}
    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
      {language = "EN-US", messageCodes = {"DataConsent"}})
    -- SDL -> HMI: SDL.GetUserFriendlymessage {messages}
    EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
      -- HMI -> SDL: SDL.OnAllowSDLFunctionality {allowed: false, device, source}
      self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
      {allowed = false, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
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
--check if device_id was updated in local PT
function Test:CheckValueOfDeviseID()
device_id = get_id_value(self)
  print (device_id)  
  if (device_id == 0) then
    self:FailTestCase("device_id in database was not updated")
  end
end

--[[ Postconditions ]]
commonFunctions:SDLForceStop()

return Test 