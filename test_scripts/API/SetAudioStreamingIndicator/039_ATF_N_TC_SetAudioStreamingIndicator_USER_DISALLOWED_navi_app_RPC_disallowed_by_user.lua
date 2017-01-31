---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [USER_DISALLOWED]: Conditions for USER_DISALLOWED result code
-- [MOBILE_API] SetAudioStreamingIndicator
-- [HMI_API] [MOBILE_API] AudioStreamingIndicator enum
-- [PolicyTable] SetAudioStreamingIndicator RPC
--
-- Description:
-- For Genivi applicable ONLY for 'EXTERNAL_PROPRIETARY' Polciies
-- SDL must return 'USER_DISALLOWED, success:false' to mobile app
-- in case the requested RPC is included to the group disallowed by the user.
--
-- 1. Used preconditions
-- SDL is built with External Proprietary flag.
-- Include in Testing_group(user_consent group) RPC SetAudioStreamingIndicator
-- Register and activate navi application
-- Perform successfull PTU for External Proprietary flow
-- Disallow by user SetAudioStreamingIndicator
--
-- 2. Performed steps
-- Send SetAudioStreamingIndicator(audioStreamingIndicator = "PAUSE")
--
-- Expected result:
-- SDL->mobile: SetAudioStreamingIndicator_response("USER_DISALLOWED", success:false)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.application1.registerAppInterfaceParams.appHMIType = {"NAVIGATION"}

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local json = require('json')

--[[ Local Functions ]]

--[[@create_ptu_SetAudioStreamingIndicator_group: update preloaded_pt and creates 2 PTU files
! preloaded_pt.json: add Testing_group with RPC SetAudioStreamingIndicator and user consent
! SetAudioStreamingIndicator_group1.json: Assign groups "Base-4", "Testing_group" to application
! SetAudioStreamingIndicator_group1.json: Assign only group "Base-4" to application
! @parameters: NO
]]
local function create_ptu_SetAudioStreamingIndicator_group()
  commonPreconditions:BackupFile("sdl_preloaded_pt.json")
  os.execute(" cp " .. config.pathToSDL .. "sdl_preloaded_pt.json" .. " " .. "SetAudioStreamingIndicator_group1.json" )
  os.execute(" cp " .. config.pathToSDL .. "sdl_preloaded_pt.json" .. " " .. "SetAudioStreamingIndicator_group2.json" )
  local pathToFile = config.pathToSDL .. 'sdl_preloaded_pt.json'
  local file = io.open(pathToFile, "r")
  local json_data = file:read("*all")
  file:close()

  local data = json.decode(json_data)
  if(data.policy_table.functional_groupings["DataConsent-2"]) then
    data.policy_table.functional_groupings["DataConsent-2"].rpcs = { json.null }
  end
  
  data.policy_table.functional_groupings["Base-4"].rpcs.SetAudioStreamingIndicator = json.null
  data.policy_table.functional_groupings["Testing_group"] = {
    user_consent_prompt = "Purpose_of_Test",
    rpcs = {
      SetAudioStreamingIndicator = {
        hmi_levels = { "BACKGROUND", "FULL", "LIMITED" }
      }
    }
  }
  local data_preloaded = data

  data_preloaded = json.encode(data_preloaded)
  file = io.open(config.pathToSDL .. 'sdl_preloaded_pt.json', "w")
  file:write(data_preloaded)
  file:close()

  data.policy_table.module_config.preloaded_pt = nil
  data.policy_table.module_config.preloaded_date = nil
  local data1 = data
  data.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID] =
  {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE",
    groups = {"Base-4", "Testing_group"}
  }

  data = json.encode(data)
  file = io.open("SetAudioStreamingIndicator_group1.json", "w")
  file:write(data)
  file:close()

  data1.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID] =
  {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE",
    groups = {"Base-4"}
  }

  data1 = json.encode(data1)
  file = io.open("SetAudioStreamingIndicator_group2.json", "w")
  file:write(data1)
  file:close()
end

--[[ General Precondition before ATF start ]]
create_ptu_SetAudioStreamingIndicator_group()
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_trigger_getting_device_consent()
  testCasesForPolicyTable:trigger_getting_device_consent(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

function Test:Precondition_PTU_appPermissionsConsentNeeded_true()
  local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
  :Do(function(_,_)
    self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest", { requestType = "PROPRIETARY", fileName = "filename"})

    EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
    :Do(function(_,_)
      self.mobileSession:SendRPC("SystemRequest", { fileName = "PolicyTableUpdate", requestType = "PROPRIETARY"}, "SetAudioStreamingIndicator_group1.json")

      EXPECT_HMICALL("BasicCommunication.SystemRequest")
      :Do(function(_,data)
        self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate", { policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"})

        local function to_run()
          self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
        end
        RUN_AFTER(to_run, 500)
      end)

      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATING"}, {status = "UP_TO_DATE"}):Times(2)
      :Do(function(_,data)
        if(data.params.status == "UP_TO_DATE") then
          EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], appPermissionsConsentNeeded = true })
          :Do(function()
            local RequestIdListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", { appID = self.applications[config.application1.registerAppInterfaceParams.appName] })

            EXPECT_HMIRESPONSE(RequestIdListOfPermissions)
            :Do(function(_,data1)
              local groups = {}
              if #data1.result.allowedFunctions > 0 then
                for i = 1, #data1.result.allowedFunctions do
                  groups[i] = {
                    name = data1.result.allowedFunctions[i].name,
                    id = data1.result.allowedFunctions[i].id,
                    allowed = true}
                end
              end
              self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent", { appID = self.applications[config.application1.registerAppInterfaceParams.appName], consentedFunctions = groups, source = "GUI"})
              EXPECT_NOTIFICATION("OnPermissionsChange")
            end)
          end)
        end
      end)
    end)
  end)
end

function Test:Precondition_trigger_user_request_update_from_HMI()
  testCasesForPolicyTable:trigger_user_request_update_from_HMI(self)
end

function Test:Precondition_SetAppTo_NONE()
  self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", { appID = self.applications[config.application1.registerAppInterfaceParams.appName], reason = "USER_EXIT" })
  EXPECT_NOTIFICATION("OnHMIStatus", { hmiLevel = "NONE" })
end

function Test:Precondition_PTU_revoke_app_group()
  local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
  :Do(function()
    self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest", { requestType = "PROPRIETARY", fileName = "filename"})

    EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
    :Do(function()
      local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", { fileName = "PolicyTableUpdate", requestType = "PROPRIETARY"}, "SetAudioStreamingIndicator_group2.json")

      EXPECT_HMICALL("BasicCommunication.SystemRequest")
      :Do(function(_,data)
        self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate", { policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"})

        local function to_run()
          self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
        end
        RUN_AFTER(to_run, 500)
        self.mobileSession:ExpectResponse(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
      end)

      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATING"}, {status = "UP_TO_DATE"}):Times(2)
      :Do(function(_,data)
        if(data.params.status == "UP_TO_DATE") then EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged") :Times(0) end
      end)
    end)
  end)
end

function Test:Precondition_Activate_app_isAppPermissionRevoked_true()
  local RequestIdActivateAppAgain = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName] })
  EXPECT_HMIRESPONSE(RequestIdActivateAppAgain, { result = {
    code = 0,
    method = "SDL.ActivateApp", isAppRevoked = false, isAppPermissionsRevoked = true,
    appRevokedPermissions = { {name = "Purpose_of_Test"} }}})

  EXPECT_NOTIFICATION("OnHMIStatus", { hmiLevel = "FULL" })
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_SetAudioStreamingIndicator_GENERIC_ERROR_audioStreamingIndicator_PAUSE_HMI_replies_empty_value()
  local corr_id = self.mobileSession:SendRPC("SetAudioStreamingIndicator", { audioStreamingIndicator = "PAUSE" })

  EXPECT_HMICALL("UI.SetAudioStreamingIndicator", {}):Times(0)
  EXPECT_RESPONSE(corr_id, { success = false, resultCode = "USER_DISALLOWED"})
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_Restore_preloaded_file()
  os.execute( " rm -f SetAudioStreamingIndicator_group1.json" )
  os.execute( " rm -f SetAudioStreamingIndicator_group2.json" )
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end

function Test.Postcondition_Stop()
  StopSDL()
end

return Test