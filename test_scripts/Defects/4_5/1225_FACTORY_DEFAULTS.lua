---------------------------------------------------------------------------------------------------
-- Script verifies issue https://github.com/SmartDeviceLink/sdl_core/issues/1225
-- Flow: EXTERNAL_PROPRIETARY
-- Preconditions:
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
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local sdl = require("SDL")
local events = require('events')
local json = require("modules/json")

--[[ Local Variables ]]
local pathToPTS = commonFunctions:read_parameter_from_smart_device_link_ini("SystemFilesPath") .. "/"
  .. commonFunctions:read_parameter_from_smart_device_link_ini("PathToSnapshot")
local pathToLPT = config.pathToSDL .. "/storage/policy.sqlite"

--[[ Local Functions ]]
local function start(self)
  self:runSDL()
  commonFunctions:waitForSDLStart(self)
  :Do(function()
      self:initHMI(self)
      :Do(function()
          commonFunctions:userPrint(35, "HMI initialized")
          self:initHMI_onReady()
          :Do(function()
              commonFunctions:userPrint(35, "HMI is ready")
              self:connectMobile()
              :Do(function()
                  commonFunctions:userPrint(35, "Mobile connected")
                end)
            end)
        end)
    end)
end

local function allowSDL(self)
  self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {
    allowed = true, source = "GUI", device = { id = config.deviceMAC, name = "127.0.0.1" }
  })
end

local function delayedExp(pTime, self)
  local event = events.Event()
  event.matches = function(e1, e2) return e1 == e2 end
  EXPECT_HMIEVENT(event, "Delayed event")
  :Timeout(pTime + 5000)
  local function toRun()
    event_dispatcher:RaiseEvent(self.hmiConnection, event)
  end
  RUN_AFTER(toRun, pTime)
end

local function ptsToTable(pts_f)
  local f = io.open(pts_f, "r")
  local content = f:read("*all")
  f:close()
  return json.decode(content)
end

local function ptUpdateFunc(pTbl)
  local appId = config.application1.registerAppInterfaceParams.appID
  table.insert(pTbl.policy_table.app_policies[appId].groups, "Location-1")
end

local function removeSnapshotAndTriggerPTUFromHMI(self)
  os.execute("rm -f " .. pathToPTS)
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate", { file = pathToPTS })
  self.hmiConnection:SendNotification("SDL.OnPolicyUpdate", { })
end

local function makeConsent(self)
  local request_id = self.hmiConnection:SendRequest("SDL.GetListOfPermissions")
  EXPECT_HMIRESPONSE(request_id,{
      result = {
        code = 0,
        method = "SDL.GetListOfPermissions",
        allowedFunctions = {{name = "Location", allowed = nil}},
        externalConsentStatus = {}
      }
    })
  :Do(function(_,data)
      local groupId
      for i = 1, #data.result.allowedFunctions do
        if(data.result.allowedFunctions[i].name == "Location") then
          groupId = data.result.allowedFunctions[i].id
        end
      end
      if groupId then
        self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent", {
          appID = commonDefects.getHMIAppId(),
          source = "GUI",
          consentedFunctions = {{name = "Location", id = groupId, allowed = true}}
        })
      else
        self:FailTestCase("GroupId for Location was not found")
      end
    end)
  delayedExp(1000, self)
end

local function Check_user_consent_records_in_LPT(self)
  local is_test_fail = false
  if (commonSteps:file_exists(pathToLPT) == false) then
    self:FailTestCase(config.pathToSDL .. pathToLPT .. " is not created")
  else
    local queryCG = "select device_id from consent_group"
    local r_actual_CG = commonFunctions:get_data_policy_sql(pathToLPT, queryCG)
    if #r_actual_CG ~= 1 then
      commonFunctions:printError("Error: consent_group does not contain 1 required records in LPT")
      is_test_fail = true
    end
    local queryDCG = "select device_id from device_consent_group"
    local r_actualDCG = commonFunctions:get_data_policy_sql(pathToLPT, queryDCG)
    if #r_actualDCG ~= 1 then
      commonFunctions:printError("Error: device_consent_group does not contain 1 required record in LPT")
      is_test_fail = true
    end
  end
  if(is_test_fail == true) then
    self:FailTestCase("Test is FAILED.")
  end
end

local function Check_user_consent_records_in_Snapshot(self)
  local is_test_fail = false
  if (commonSteps:file_exists(pathToPTS) == false) then
    self:FailTestCase(pathToPTS .. " is not created")
  else
    local pts = ptsToTable(pathToPTS)
    local ucr = pts.policy_table.device_data[config.deviceMAC].user_consent_records
    if not (ucr[config.application1.registerAppInterfaceParams.appID]) then
      commonFunctions:printError("Error: user_consent_records.consent_groups.Location is not present in Snapshot")
      is_test_fail = true
    end
  end
  if (is_test_fail == true) then
    self:FailTestCase("Test is FAILED.")
  end
end

local function performFACTORY_DEFAULTS(self)
  self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "FACTORY_DEFAULTS" })
  self.mobileSession1:ExpectNotification("OnAppInterfaceUnregistered", { reason = "FACTORY_DEFAULTS" })
  :Do(function() sdl:DeleteFile() end)
end

local function Wait_SDL_stop(self)
  delayedExp(5000, self)
end

local function Check_no_user_consent_records_in_LPT(self)
  local is_test_fail = false
  if (commonSteps:file_exists(pathToLPT) == false) then
    self:FailTestCase(config.pathToSDL .. pathToLPT .. " is not created")
  else
    local queryCG = "select count(*) from consent_group"
    local r_actual_CG = commonFunctions:get_data_policy_sql(pathToLPT, queryCG)
    if r_actual_CG[1] ~= "0" then
      commonFunctions:printError("Error: consent_group contains redundant records in LPT")
      is_test_fail = true
    end
    local queryDCG = "select count(*) from device_consent_group"
    local r_actualDCG = commonFunctions:get_data_policy_sql(pathToLPT, queryDCG)
    if r_actualDCG[1] ~= "0" then
      commonFunctions:printError("Error: device_consent_group contains redundant record in LPT")
      is_test_fail = true
    end
  end
  if(is_test_fail == true) then
    self:FailTestCase("Test is FAILED.")
  end
end

local function Check_no_user_consent_records_in_Snapshot(self)
  local is_test_fail = false
  if (commonSteps:file_exists(pathToPTS) == false) then
    self:FailTestCase(pathToPTS .. " is not created")
  else
     local pts = ptsToTable(pathToPTS)
    local ucr = pts.policy_table.device_data[config.deviceMAC].user_consent_records
    if (ucr[config.application1.registerAppInterfaceParams.appID]) then
      commonFunctions:printError("Error: user_consent_records.consent_groups.Location was not reset in Snapshot")
      is_test_fail = true
    end
  end
  if (is_test_fail == true) then
    self:FailTestCase("Test is FAILED.")
  end
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonDefects.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", start)
runner.Step("Allow SDL for device", allowSDL)
runner.Step("RAI, PTU", commonDefects.rai_ptu, { ptUpdateFunc})
runner.Step("Make consent for Location group", makeConsent)

runner.Title("Test")
runner.Step("Remove Snapshot and Trigger PTU", removeSnapshotAndTriggerPTUFromHMI)
runner.Step("Check_presence_of_user_consent_records_in_LPT", Check_user_consent_records_in_LPT)
runner.Step("Check_presence_of_user_consent_records_in_Snapshot", Check_user_consent_records_in_Snapshot)
runner.Step("FACTORY_DEFAULTS", performFACTORY_DEFAULTS)
runner.Step("Wait_SDL_stop", Wait_SDL_stop)
runner.Step("Start SDL, HMI, connect Mobile, start Session", start)
runner.Step("Check_absence_of_user_consent_records_in_LPT", Check_no_user_consent_records_in_LPT)
runner.Step("Allow SDL for device", allowSDL)
runner.Step("RAI", commonDefects.rai_n)
runner.Step("Remove Snapshot and Trigger PTU", removeSnapshotAndTriggerPTUFromHMI)
runner.Step("Check_absence_of_user_consent_records_in_Snapshot", Check_no_user_consent_records_in_Snapshot)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonDefects.postconditions)
