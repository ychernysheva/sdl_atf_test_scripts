---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [Policies] "pre_DataConsent" policies and "preconsented_groups" validation
--
-- Description:
--     Validation of "preconsented_groups" sub-section in "pre_DataConsent" if "pre_DataConsent" policies assigned to the application.
--     Checking correct "preconsented_groups" value - one of the <functional grouping> under section "functional_groupings"
--     1. Used preconditions:
--      SDL and HMI are running
--      Connect device
--
--     2. Performed steps
--      Add session("pre_DataConsent" policies are assigned to the application)-> PTU is triggered
--
-- Expected result:
--     PoliciesManager must validate "preconsented_groups" sub-section in "pre_DataConsent" and treat it as valid->PTU is valid
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--[ToDo: should be removed when fixed: "ATF does not stop HB timers by closing session and connection"
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')
require('user_modules/AppTypes')

--[[ Local Functions ]]
local function Backup_preloaded()
  os.execute('cp ' .. config.pathToSDL .. 'sdl_preloaded_pt.json' .. ' ' .. config.pathToSDL .. 'backup_sdl_preloaded_pt.json')
  os.execute('rm ' .. config.pathToSDL .. 'policy.sqlite')
end

local function Restore_preloaded()
  os.execute('rm ' .. config.pathToSDL .. 'sdl_preloaded_pt.json')
  os.execute('cp ' .. config.pathToSDL .. 'backup_sdl_preloaded_pt.json' .. ' ' .. config.pathToSDL .. 'sdl_preloaded_pt.json')
end

local function Set_functional_grouping_as_preconsented_groups()
  local pathToFile = config.pathToSDL .. 'sdl_preloaded_pt.json'
  local file = io.open(pathToFile, "r")
  local json_data = file:read("*all") -- may be abbreviated to "*a";
  file:close()
  local json = require("modules/json")
  local data = json.decode(json_data)

  if data.policy_table.functional_groupings["DataConsent-2"] then
    data.policy_table.functional_groupings["DataConsent-2"] = nil
  end
  data.policy_table.app_policies["pre_DataConsent"] = {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE",
    groups = {"BaseBeforeDataConsent"},
    preconsented_groups = {"Location-1"}
  }
  data = json.encode(data)
  file = io.open(pathToFile, "w")
  file:write(data)
  file:close()
end

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test.Precondition_StopSDL()
  StopSDL()
end

function Test.Precondition_DeleteLogsAndPolicyTable()
  commonSteps:DeleteLogsFiles()
  commonSteps:DeletePolicyTable()
end

function Test.Precondition_Backup_preloadedPT()
  Backup_preloaded()
end

function Test.Precondition_Set_preconsented_groups()
  Set_functional_grouping_as_preconsented_groups()
end

function Test.Precondition_StartSDL()
  StartSDL(config.pathToSDL, config.ExitOnCrash)
end

function Test:Precondition_InitHMI()
  self:initHMI()
end

function Test:Precondition_InitHMI_onReady()
  self:initHMI_onReady()
end

function Test:Precondition_Connect_device()
  self:connectMobile()
end

function Test:Precondition_Start_session()
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Validate_preconsented_groups_upon_PTU()
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application1.appName } })
  :Do(function(_,data)
  local hmi_app_id = data.params.application.appID
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
  testCasesForPolicyTableSnapshot:create_PTS(true,
  {config.application1.registerAppInterfaceParams.appID},
  {config.deviceMAC},
  {hmi_app_id})
  local timeout_after_x_seconds = testCasesForPolicyTableSnapshot:get_data_from_PTS("module_config.timeout_after_x_seconds")
  local seconds_between_retries = {}
  for i = 1, #testCasesForPolicyTableSnapshot.pts_seconds_between_retries do
    seconds_between_retries[i] = testCasesForPolicyTableSnapshot.pts_seconds_between_retries[i].value
  end
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
  {
    file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate",
    timeout = timeout_after_x_seconds,
    retry = seconds_between_retries
  })
  :Do(function()
  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  end)
  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS"})
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_SDLStop()
  StopSDL()
end
function Test.Postcondition_Restore_preloaded()
  Restore_preloaded()
end
