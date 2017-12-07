---------------------------------------------------------------------------------------------------
-- Preconditions:
-- SDL is built with Extended policy flag.
-- SDL and HMI are started. First ignition cycle.
-- Connect device.
-- App registered, consented on device.
-- App has consented groups.
-- Steps to reproduce:
-- Send OnExitAllApplications ("reason":"FACTORY_DEFAULTS") fron HMI.
-- Or run script ATF_Factory_reset.lua
-- Actual result:
-- SDL not clear all user consent records in "user_consent_records" section of the LocalPT after FACTORY_DEFAULTS.
-- Scenario is failed.
-- Expected result:
-- On FACTORY_DEFAULTS, Policy Manager must clear all user consent records in "user_consent_records" section
-- of the LocalPT, other content of the LocalPT must be unchanged.
-- Scenario is passed.
---------------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.ExitOnCrash = false

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonDefects = require('test_scripts/Defects/4_5/commonDefects')
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local mobile_session = require('mobile_session')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTableSnapshot = require ('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ Local Variables ]]
local HMIid
local groups = {}

--[[ Local Functions ]]
local function ReplacePreloadedFile()
  os.execute('cp ' .. config.pathToSDL .. 'sdl_preloaded_pt.json' .. ' ' .. config.pathToSDL ..
  'backup_sdl_preloaded_pt.json')
  os.execute('cp files/jsons/Policies/Related_HMI_API/OnAppPermissionConsent.json ' .. config.pathToSDL ..
  'sdl_preloaded_pt.json')
  os.execute('rm ' .. config.pathToSDL .. 'policy.sqlite')
end

local function RestorePreloadedPT()
  os.execute('rm ' .. config.pathToSDL .. 'sdl_preloaded_pt.json')
  os.execute('cp ' .. config.pathToSDL .. 'backup_sdl_preloaded_pt.json' .. ' ' .. config.pathToSDL ..
  'sdl_preloaded_pt.json')
end

local function Register_App(self)
  self.mobileSession1 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession1:StartService(7)
  :Do(function()
      local CorIdRAI = self.mobileSession1:SendRPC
      ("RegisterAppInterface", config.application1.registerAppInterfaceParams)
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application =
          { appName = config.application1.registerAppInterfaceParams.appName }})
      :Do(function(_,data) HMIid = data.params.application.appID end)
      self.mobileSession1:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
    end)
end

local function Precondition_Activate_app_To_Trigger_PTU(self)
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIid })
  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,_)
      local RequestId1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
        {language = "EN-US", messageCodes = {"DataConsent"}})
      EXPECT_HMIRESPONSE( RequestId1, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
      :Do(function(_,_)
          self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
            {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1", isSDLAllowed = true}})
          local request_id_list_of_permissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions",
            { appID = HMIid })
          EXPECT_HMIRESPONSE(request_id_list_of_permissions)
          :Do(function(_,data)
              if #data.result.allowedFunctions > 0 then
                for i = 1, #data.result.allowedFunctions do
                  groups[i] = data.result.allowedFunctions[i]
                  groups[i].allowed = true
                end
              end
              commonFunctions:printTable(groups)
              self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent",
                { appID = HMIid, consentedFunctions = groups, source = "GUI"})
              self.mobileSession1:ExpectNotification("OnPermissionsChange")
            end)
        end)
    end)
  self.mobileSession1:ExpectNotification("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
end

local function TrigerPTUForCreationSnapshotWithConsent(self)
  local RequestId1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
    {language = "EN-US", messageCodes = {"DataConsent"}})
  EXPECT_HMIRESPONSE( RequestId1, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
  :Do(function(_,_)
      self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
        {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1", isSDLAllowed = true}})
      local request_id_list_of_permissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions",
        { appID = HMIid })
      EXPECT_HMIRESPONSE(request_id_list_of_permissions)
      commonDefects.delayedExp(1000) -- without delayed snapshot is not created in time
    end)
end

local function Check_user_consent_records_in_PT(self)
  local is_test_fail = false
  if( commonSteps:file_exists("/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json") == false) then
    self:FailTestCase("/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json is not created")
  else
    testCasesForPolicyTableSnapshot:extract_pts({HMIid})
    local app_consent_location = testCasesForPolicyTableSnapshot:get_data_from_PTS("device_data." ..
      config.deviceMAC .. ".user_consent_records."..config.application1.registerAppInterfaceParams.appID ..
    ".consent_groups.Location-1")
    local app_consent_notifications = testCasesForPolicyTableSnapshot:get_data_from_PTS("device_data." ..
      config.deviceMAC .. ".user_consent_records." .. config.application1.registerAppInterfaceParams.appID ..
    ".consent_groups.Notifications")
    if(app_consent_location ~= true) then
      commonFunctions:printError("Error: user_consent_records.consent_groups.Location is not present in LPT")
      is_test_fail = true
    end
    if(app_consent_notifications ~= true) then
      commonFunctions:printError("Error: user_consent_records.consent_groups.Notifications is not present in LPT")
      is_test_fail = true
    end
    if( commonSteps:file_exists(config.pathToSDL.."/storage/policy.sqlite") == false) then
      self:FailTestCase(config.pathToSDL .."/storage/policy.sqlite is not created")
    else
      local queryCG = "select device_id from consent_group"
      local r_actual_CG = commonFunctions:get_data_policy_sql(config.pathToSDL.."/storage/policy.sqlite", queryCG)
      if #r_actual_CG ~= 2 then
        commonFunctions:printError("Error: consent_group does not contain 2 required records in LPT")
        is_test_fail = true
      end
      local queryDCG = "select device_id from device_consent_group"
      local r_actualDCG = commonFunctions:get_data_policy_sql(config.pathToSDL.."/storage/policy.sqlite", queryDCG)
      if #r_actualDCG ~= 1 then
        commonFunctions:printError("Error: device_consent_group does not contain 1 required record in LPT")
        is_test_fail = true
      end
    end
  end
  if(is_test_fail == true) then
    self:FailTestCase("Test is FAILED.")
  end
end

local function CheckLPT(self)
  local is_test_fail = false
  if( commonSteps:file_exists(config.pathToSDL.."/storage/policy.sqlite") == false) then
    self:FailTestCase(config.pathToSDL .."/storage/policy.sqlite is not created")
  else
    local queryCG = "select device_id from consent_group"
    local r_actual_CG = commonFunctions:get_data_policy_sql(config.pathToSDL.."/storage/policy.sqlite", queryCG)
    if #r_actual_CG ~= 0 then
      commonFunctions:printError("Error: consent_group contains redundant records in LPT")
      is_test_fail = true
    end
    local queryDCG = "select device_id from device_consent_group"
    local r_actualDCG = commonFunctions:get_data_policy_sql(config.pathToSDL.."/storage/policy.sqlite", queryDCG)
    if #r_actualDCG ~= 0 then
      commonFunctions:printError("Error: device_consent_group contains redundant record in LPT")
      is_test_fail = true
    end
  end
  if(is_test_fail == true) then
    self:FailTestCase("Test is FAILED.")
  end
end

local function Check_no_user_consent_records_in_PT(self)
  local is_test_fail = false
  if( commonSteps:file_exists("/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json") == false) then
    self:FailTestCase(config.pathToSDL .. "sdl_preloaded_pt.json " .. "is not created")
  else
    testCasesForPolicyTableSnapshot:extract_pts(
      {self.applications[config.application1.registerAppInterfaceParams.appName]})
    local app_consent_location = testCasesForPolicyTableSnapshot:get_data_from_PTS
    ("device_data." .. config.deviceMAC .. ".user_consent_records." ..
      config.application1.registerAppInterfaceParams.appID .. ".consent_groups.Location-1")
    local app_consent_notifications = testCasesForPolicyTableSnapshot:get_data_from_PTS
    ("device_data." .. config.deviceMAC .. ".user_consent_records." ..
      config.application1.registerAppInterfaceParams.appID .. ".consent_groups.Notifications")
    if(app_consent_location == true) then
      commonFunctions:printError("Error: user_consent_records.consent_groups.Location was not reset in LPT")
      is_test_fail = true
    end
    if(app_consent_notifications == true) then
      commonFunctions:printError("Error: user_consent_records.consent_groups.Notifications was not reset in LPT")
      is_test_fail = true
    end
  end
  if(is_test_fail == true) then
    self:FailTestCase("Test is FAILED.")
  end
end

local function FACTORY_DEFAULTS(self)
  self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "FACTORY_DEFAULTS" })
end

local function Wait_SDL_stop()
  os.execute("sleep 15")
end

local function RemoveSnapshot()
  os.execute('rm "/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json"')
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonDefects.preconditions)
runner.Step("ReplacePreloadedFile", ReplacePreloadedFile)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonDefects.start)
runner.Step("RAI, PTU", Register_App)
runner.Step("Activate App", Precondition_Activate_app_To_Trigger_PTU)

runner.Title("Test")
runner.Step("TrigerPTUForCreationSnapshotWithConsent", TrigerPTUForCreationSnapshotWithConsent)
runner.Step("Check_user_consent_records_in_PT", Check_user_consent_records_in_PT)
runner.Step("FACTORY_DEFAULTS", FACTORY_DEFAULTS)
runner.Step("Wait_SDL_stop", Wait_SDL_stop)
runner.Step("CheckLPT", CheckLPT)
runner.Step("RemoveSnapshot", RemoveSnapshot)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonDefects.start)
runner.Step("RAI, PTU", Register_App)
runner.Step("Activate App", Precondition_Activate_app_To_Trigger_PTU)
runner.Step("Check_no_user_consent_records_in_PT", Check_no_user_consent_records_in_PT)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonDefects.postconditions)
runner.Step("RestorePreloadedPT", RestorePreloadedPT)
