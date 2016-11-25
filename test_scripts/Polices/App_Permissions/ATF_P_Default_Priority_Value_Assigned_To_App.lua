---------------------------------------------------------------------------------------------
-- Requirement summary:
-- "default" policies assigned to the application and "priority" value
--
-- Description:
-- In case the "default" policies are assigned to the application,
-- PoliciesManager must provide to HMI the app`s priority value taken from "priority" field in "default" section of PolicyTable.
-- 1. Used preconditions:
-- a) Set SDL to first life cycle state.
-- b) Register application, activate and consent device
-- c) preloaded_pt.json has "priority": "NONE" in default section, set "priority": "NORMAL" to "pre_DataConsent" section to get OnAppPermissionChanged after consenting device
-- d) Aplication registered
-- 2. Performed steps:
-- a) Activate App and consent device
--
-- Expected result:
-- SDL->HMI: SDL.ActivateApp_response {priority: NONE, params}
-- SDL->HMI: SDL.OnAppPermissionsChanged {priority: NONE, params}
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')

--[[ Local Functions ]]
local function BackupPreloaded()
  os.execute('cp ' .. config.pathToSDL .. 'sdl_preloaded_pt.json' .. ' ' .. config.pathToSDL .. 'backup_sdl_preloaded_pt.json')
  os.execute('rm ' .. config.pathToSDL .. 'policy.sqlite')
end

local function RestorePreloadedPT()
  os.execute('rm ' .. config.pathToSDL .. 'sdl_preloaded_pt.json')
  os.execute('cp ' .. config.pathToSDL .. 'backup_sdl_preloaded_pt.json' .. ' ' .. config.pathToSDL .. 'sdl_preloaded_pt.json')
end

local function SetPriorityToPre_DataConsentNORMAL()
  local pathToFile = config.pathToSDL .. 'sdl_preloaded_pt.json'
  local file = io.open(pathToFile, "r")
  local json_data = file:read("*all") -- may be abbreviated to "*a";
  file:close()
  local json = require("modules/json")
  local data = json.decode(json_data)

  -- json library restriction to decode-encode element which defined as "null"
  if data.policy_table.functional_groupings["DataConsent-2"] then
    data.policy_table.functional_groupings["DataConsent-2"] = {rpcs = null}
  end
  -- set "NORMAL" priority to pre_DataConsent section to get OnAppPermissionChanged after consenting device (for default priority = NONE)
  data.policy_table.app_policies.pre_DataConsent["priority"] = "NORMAL"

  data = json.encode(data)
  file = io.open(pathToFile, "w")
  file:write(data)
  file:close()
end

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()
BackupPreloaded()
SetPriorityToPre_DataConsentNORMAL()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')

--[[ Preconditions ]]
function Test:TestStep_Activate_App_Consent_Device_And_Check_Priority_In_ActivateApp_And_OnAppPermissionChanged()

  local RequestIdActivateApp = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.applications["Test Application"], priority = "NONE"})
  EXPECT_HMIRESPONSE(RequestIdActivateApp, { result = {code = 0, isSDLAllowed = false}, method = "SDL.ActivateApp"})
  :Do(function(_,_)
      local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
      EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
      :Do(function(_,_)
          self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
          EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged", {appID = self.applications["Test Application"], priority = "NONE"})
          EXPECT_HMICALL("BasicCommunication.ActivateApp")
          :Do(function(_,data)
              self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
              EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
            end)
          EXPECT_NOTIFICATION("OnPermissionsChange", {})
        end)
    end)
end

--[[ Postcondition ]]
--ToDo: shall be removed when issue: "SDL doesn't stop at execution ATF function StopSDL()" is fixed
function Test:Postcondition_SDLForceStop()
  RestorePreloadedPT()
  commonFunctions:SDLForceStop()
end

