---------------------------------------------------------------------------------------------
-- Description:
-- Check that SDL ask user for consent new permissions and apply them
-- Preconditions:
-- 1. Delete policy.sqlite file, app_info.dat files
-- 2. <Device> is connected to SDL and consented by the User, <App> is running on that device.
-- 3. <App> is registered with SDL and is present in HMI list of registered aps.
-- 4. Local PT has permissions for <App> that require User`s consent.
--
-- Requirement summary:
-- On getting user consent information from HMI and storage into LocalPolicyTable , 
-- SDL must notify an application about the current permissions active on HMI via onPermissionsChange() notification.
--
-- Actions:
-- 1. User choose <App> in the list of registered aps on HMI.
-- 2. The User allows definite permissions.
--
-- Expected:
-- 1. HMI->SDL: SDL.ActivateApp {appID}
--    SDL->HMI: SDL.ActivateApp_response{isPermissionsConsentNeeded: true, params}
--    HMI->SDL: GetUserFriendlyMessage{params},
--    SDL->HMI: GetUserFriendlyMessage_response{params}
--    HMI->SDL: GetListOfPermissions{appID}
--    SDL->HMI: GetListOfPermissions_response{}  
-- 2. HMI->SDL: OnAppPermissionConsent {params}
--    PoliciesManager: update "<appID>" subsection of "user_consent_records" subsection of "<device_identifier>" section of "device_data" section in Local PT.
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')


--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ Local Functions ]]
local function BackupPreloaded()
  os.execute('cp ' .. config.pathToSDL .. 'sdl_preloaded_pt.json' .. ' ' .. config.pathToSDL .. 'backup_sdl_preloaded_pt.json')
  os.execute('rm ' .. config.pathToSDL .. 'policy.sqlite')
end

local function RestorePreloadedPT()
  os.execute('rm ' .. config.pathToSDL .. 'sdl_preloaded_pt.json')
  os.execute('cp ' .. config.pathToSDL .. 'backup_sdl_preloaded_pt.json' .. ' ' .. config.pathToSDL .. 'sdl_preloaded_pt.json')
end

local function SetPermissionsForPre_DataConsent()
  local pathToFile = config.pathToSDL .. 'sdl_preloaded_pt.json'
  local file = io.open(pathToFile, "r")
  local json_data = file:read("*all") -- may be abbreviated to "*a";
  file:close()
  local json = require("modules/json")
  local data = json.decode(json_data)

  if data.policy_table.functional_groupings["DataConsent-2"] then
    data.policy_table.functional_groupings["DataConsent-2"] = {rpcs = null}
  end
  -- set for group in pre_DataConsent section permissions with RPCs and HMI levels for them
  data.policy_table.functional_groupings[data.policy_table.app_policies.default.groups[1]] = {rpcs = {
      OnHMIStatus =
      {hmi_levels = {"BACKGROUND", "FULL", "LIMITED", "NONE"}},
      OnPermissionsChange =
      {hmi_levels = {"BACKGROUND", "FULL", "LIMITED", "NONE"}},
      OnSystemRequest = 
      {hmi_levels = {"BACKGROUND", "FULL", "LIMITED", "NONE"}},
      SystemRequest = 
      {hmi_levels = {"BACKGROUND", "FULL", "LIMITED", "NONE"}},
  }}
  data = json.encode(data)
  file = io.open(pathToFile, "w")
  file:write(data)
  file:close()
end


--[[ Precondition ]]
local function Precondition()

  commonFunctions:userPrint(34, "-- Precondition --")

  function Test:StopSDL()
    StopSDL()
  end

  --ToDo: shall be removed when issue: "SDL doesn't stop at execution ATF function StopSDL()" is fixed
  function Test:SDLForceStop()
    commonFunctions:SDLForceStop()
  end

  function Test:DeleteLogsAndPolicyTable()
    commonSteps:DeleteLogsFiles()
    commonSteps:DeletePolicyTable()
  end

  function Test:Backup_sdl_preloaded_pt()
    BackupPreloaded()
  end

  function Test:SetPermissionsForPre_DataConsent()
    SetPermissionsForPre_DataConsent()
  end

  function Test:StartSDL_FirstLifeCycle()
    StartSDL(config.pathToSDL, config.ExitOnCrash)
  end

  function Test:InitHMI_FirstLifeCycle()
    self:initHMI()
  end

  function Test:InitHMI_onReady_FirstLifeCycle()
    self:initHMI_onReady()
  end

  function Test:ConnectMobile_FirstLifeCycle()
    self:connectMobile()
  end

  function Test:StartSession()
    self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
    self.mobileSession:StartService(7)
  end

  function Test:RestorePreloadedPT()
    RestorePreloadedPT()
  end

  function Test:Activate_App_And_Consent_Device()

  local CorIdRAI = self.mobileSession:SendRPC("RegisterAppInterface",
    {
      syncMsgVersion =
      {
        majorVersion = 3,
        minorVersion = 0
      },
      appName = "SPT",
      isMediaApplication = true,
      languageDesired = "EN-US",
      hmiDisplayLanguageDesired = "EN-US",
      appID = "1234567",
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
        appName = "SPT",
        policyAppID = "1234567",
        isMediaApplication = true,
        hmiDisplayLanguageDesired = "EN-US",
        deviceInfo =
        {
          name = "127.0.0.1",
          id = config.deviceMAC,
          transportType = "WIFI",
          isSDLAllowed = false
        }
      }
    })
  :Do(function(_,data)
      self.applications["SPT"] = data.params.application.appID
    EXPECT_RESPONSE(CorIdRAI, { success = true, resultCode = "SUCCESS"})

  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.applications["SPT"]})
    
  EXPECT_HMIRESPONSE(RequestId, { result = { 
  code = 0, 
  isSDLAllowed = false}, 
  method = "SDL.ActivateApp"})
  :Do(function(_,data)
    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
    EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
    :Do(function(_,data)
      self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",  {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
        EXPECT_HMICALL("BasicCommunication.ActivateApp")
        :Do(function(_,data)
          self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
            EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
        end)
      end)
    end)
  end)
end

function Test:DeactivateApp()
    self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["SPT"], reason = "GENERAL"})
    EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "LIMITED"})
end

function Test:UpdatePolicyWithPTU()
local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
  :Do(function()
    self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
      {
        requestType = "PROPRIETARY",
        fileName = "filename"
      }
    )
    EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
    :Do(function()
      local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = "PROPRIETARY"
        }, "files/PTU_with_permissions_for_app_1234567.json")
      local systemRequestId
      EXPECT_HMICALL("BasicCommunication.SystemRequest")
      :Do(function(_,data)
        systemRequestId = data.id
        self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
        {
          policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
      })
    local function to_run()
      self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end     
    RUN_AFTER(to_run, 800)
      self.mobileSession:ExpectResponse(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
      end)
  end)
end)
end

end
Precondition()

--[[ Test ]]
function Test:Step1_User_Consents_New_Permissions_After_App_Activation()

 commonFunctions:userPrint(34, "-- Test --")
local RequestIdActivateApp = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.applications["SPT"]})

EXPECT_HMIRESPONSE(RequestIdActivateApp, 
  { result = { 
  code = 0, 
  isPermissionsConsentNeeded = true, 
  isAppPermissionsRevoked = false, 
  isAppRevoked = false}, 
  method = "SDL.ActivateApp"})

local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage, 
  { result = { code = 0, 
  messages = {{ messageCode = "DataConsent"}}, 
  method = "SDL.GetUserFriendlyMessage"}})

local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", { appID = self.applications["SPT"] })
       EXPECT_HMIRESPONSE(RequestIdListOfPermissions, 
         { result = { 
      code = 0, 
      allowedFunctions = {{name = "New_permissions"}} }, 
      method = "SDL.GetListOfPermissions"})

      :Do(function(_,data)
          local functionalGroupID = data.result.allowedFunctions[1].id
   self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent", 
     { appID = self.applications["SPT"], source = "GUI", consentedFunctions = {{name = "New_permissions", allowed = true, id = functionalGroupID} }})
end)
 end 

function Test:Step2_Check_Allowed_RPC()

  local CorIdRAI = self.mobileSession:SendRPC("Show",
    {
      mediaClock = "00:00:01",
      mainField1 = "Show1"
    })
  EXPECT_HMICALL("UI.Show", {}):Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, "UI.Show", "SUCCESS", { })
    end)
  EXPECT_RESPONSE(CorIdRAI, { success = true, resultCode = "SUCCESS"})
end

function Test:Step3_Check_Disallowed_RPC()
  local cid = self.mobileSession:SendRPC("AddSubMenu",
    {
      menuID = 1000,
      position = 500,
      menuName ="SubMenupositive"
    })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED" })
end

--[[ Postcondition ]]
--ToDo: shall be removed when issue: "SDL doesn't stop at execution ATF function StopSDL()" is fixed
function Test:SDLForceStop()
  commonFunctions:userPrint(34, "-- Postcondition --")
  commonFunctions:SDLForceStop()
end
