---------------------------------------------------------------------------------------------
-- Requirement summary:
-- SDL must re-assign "default" policies to app in case "default" policies was updated via PolicyTable update
--
-- Description:
-- PoliciesManager must: re-assign updated "default" policies to this app
-- In case Policies Manager assigns the "default" policies to app AND the value of "default" policies was updated in case of PolicyTable update
-- 1. Used preconditions:
-- a) Set SDL to first life cycle state.
-- b) Set permissions for default section.
-- c) Register and activate app, consent device.
-- 2. Performed steps:
-- a) Verify applied permision by send RPC (allowed and disallowed)
-- b) Update policy with new permissions in defult section
-- c) Verify applied permision by send RPC (allowed and disallowed)
--
-- Expected result:
-- a) SDL respons SUCCESS for allowed RPC and DISALLOW for disallow
-- b) PTU successfully passed
-- c) SDL respons SUCCESS for allowed RPC and DISALLOW for disallow
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

local function SetPermissionsForDefault()
  local pathToFile = config.pathToSDL .. 'sdl_preloaded_pt.json'
  local file = io.open(pathToFile, "r")
  local json_data = file:read("*all") -- may be abbreviated to "*a";
  file:close()
  local json = require("modules/json")
  local data = json.decode(json_data)

  if data.policy_table.functional_groupings["DataConsent-2"] then
    data.policy_table.functional_groupings["DataConsent-2"] = nil
  end
  -- set for group in default section permissions with RPCs and HMI levels for them
  data.policy_table.functional_groupings[data.policy_table.app_policies.default.groups[1]] = {rpcs = {
      OnHMIStatus =
      {hmi_levels = {"BACKGROUND", "FULL", "LIMITED", "NONE"}},
      OnPermissionsChange =
      {hmi_levels = {"BACKGROUND", "FULL", "LIMITED", "NONE"}},
      OnSystemRequest =
      {hmi_levels = {"BACKGROUND", "FULL", "LIMITED", "NONE"}},
      SystemRequest =
      {hmi_levels = {"BACKGROUND", "FULL", "LIMITED", "NONE"}},
      Show =
      {hmi_levels = {"BACKGROUND", "FULL", "LIMITED", "NONE"}},
  }}

  data = json.encode(data)
  file = io.open(pathToFile, "w")
  file:write(data)
  file:close()
end

--[[ Preconditions ]]
function Test:Precondition_StopSDL()
  StopSDL()
end

--ToDo: shall be removed when issue: "SDL doesn't stop at execution ATF function StopSDL()" is fixed
function Test:Precondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end

function Test:Precondition_DeleteLogsAndPolicyTable()
  commonSteps:DeleteLogsFiles()
  commonSteps:DeletePolicyTable()
end

function Test:Precondition_Backup_sdl_preloaded_pt()
  BackupPreloaded()
end

function Test:Precondition_SetPermissionsFor_Default()
  SetPermissionsForDefault()
end

function Test:Precondition_StartSDL_FirstLifeCycle()
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

function Test:Precondition_RestorePreloadedPT()
  RestorePreloadedPT()
end

function Test:Precondition_Register_Activate_App_And_Consent_Device()

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

      local RequestIdActivateApp = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.applications["SPT"]})
      EXPECT_HMIRESPONSE(RequestIdActivateApp, { result = {
            code = 0,
            isSDLAllowed = false},
          method = "SDL.ActivateApp"})
      :Do(function(_,_)
          local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
          EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
          :Do(function(_,_)
              self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
              EXPECT_HMICALL("BasicCommunication.ActivateApp")
              :Do(function(_,data)
                  self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
                end)
            end)
        end)
    end)
end

--[[ Test ]]
function Test:TestStep_Check_Allowed_RPC()

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

function Test:TestStep_Check_Disallowed_RPC()
  local cid = self.mobileSession:SendRPC("AddSubMenu",
    {
      menuID = 1000,
      position = 500,
      menuName ="SubMenupositive"
    })
  EXPECT_RESPONSE(cid, { success = false, resultCode = "DISALLOWED" })
end

function Test:TestStep_Update_Policy_With_New_Permission_In_Default_Section()
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
            }, "files/ptu_general_default_app-1234567.json")
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

function Test:TestStep_Check_Allowed_RPC()
  local CorIdRAI = self.mobileSession:SendRPC("Show",
    {
      mediaClock = "00:00:01",
      mainField1 = "Show1"
    })
  EXPECT_RESPONSE(CorIdRAI, { success = false, resultCode = "DISALLOWED"})
end

function Test:TestStep_Check_Disallowed_RPC()
  local cid = self.mobileSession:SendRPC("AddSubMenu",
    {
      menuID = 1000,
      position = 500,
      menuName ="SubMenupositive"
    })
  EXPECT_HMICALL("UI.AddSubMenu")
  :Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
end

--[[ Postcondition ]]
--ToDo: shall be removed when issue: "SDL doesn't stop at execution ATF function StopSDL()" is fixed
function Test:Postcondition_SDLForceStop()
  commonFunctions:SDLForceStop()
end
