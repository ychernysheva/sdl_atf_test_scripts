---------------------------------------------------------------------------------------------
-- Description:
-- Behavior of SDL during start SDL in case when LocalPT(database) has the value of "preloaded_pt" field (Boolean) is "true"
-- 1. Used preconditions:
-- Delete files and policy table from previous ignition cycle if any
-- Start default SDL with valid PreloadedPT json file for create LocalPT(database) with "preloaded_pt" = "true"
-- 2. Performed steps:
-- Delete PreloadedPT json file
-- Start SDL only with LocalPT database and with corrupted PreloadedPT json file

-- Requirement summary:
-- [Policies]: PreloadedPolicyTable: "preloaded_pt: true"
--
-- Expected result:
-- SDL must consider LocalPT as PreloadedPolicyTable and start correctly
---------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local testCasesForPolicySDLErrorsStops = require ('user_modules/shared_testcases/testCasesForPolicySDLErrorsStops')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')

--[[ General configuration parameters ]]
commonSteps:DeleteLogsFileAndPolicyTable()
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('connecttest')
require("user_modules/AppTypes")

--[[ Local variables ]]
local preloaded_pt = 1
local result_status

--[[ Preconditions ]]
function Test:Precondition_stop_sdl()
  StopSDL(self)
end

function Test:TestStep_CheckSDLStatus()
  --TODO(istoimenova): Should be checked when ATF problem is fixed with SDL crash
  --EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")
  result_status = testCasesForPolicySDLErrorsStops:CheckSDLShutdown(self)
end

function Test:TestStep_CheckPolicy()
  preloaded_pt = commonFunctions:get_data_policy_sql(config.pathToSDL.."/storage/policy.sqlite", "SELECT preloaded_pt FROM module_config")
  --print("preloaded_pt = "..tostring(preloaded_pt))
  if(preloaded_pt == 0) then
    --SDL is stopped!
    if (result_status == true) then
      self:FailTestCase("Error: SDL is not running.")
    end
  else
     if (result_status == false) then
      self:FailTestCase("Error: SDL doesn't stop.")
    end
  end
end
