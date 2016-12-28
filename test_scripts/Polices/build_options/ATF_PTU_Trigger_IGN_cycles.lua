-- Requirement summary:
-- [PTU] Trigger: ignition cycles
--
-- Description:
-- When the amount of ignition cycles notified by HMI via BasicCommunication.OnIgnitionCycleOver gets equal to the value of
-- "exchange_after_x_ignition_cycles" field ("module_config" section) of policies database, SDL must trigger a PTU sequence
-- 1. Used preconditions:
-- SDL is built with "DEXTENDED_POLICY: ON" flag
-- the 1-st IGN cycle, PTU was succesfully applied. Policies DataBase contains "exchange_after_x_ignition_cycles" = 10
-- 2. Performed steps: Perform ignition_on/off 11 times
--
-- Expected result:
-- When amount of ignition cycles notified by HMI via BasicCommunication.OnIgnitionCycleOver gets equal to the value of "exchange_after_x_ignition_cycles"
-- field ("module_config" section) of policies database, SDL must trigger a PolicyTableUpdate sequence
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local mobileSession = require("mobile_session")
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

--[[ Local Variables ]]
local exchnage_after = 5
local sdl_preloaded_pt = "sdl_preloaded_pt.json"
local ptu_file = "files/ptu.json"

--[[ Local Functions ]]
local function genpattern2str(name, value_type)
  return "(%s*\"" .. name .. "\"%s*:%s*)".. value_type
end

local function modify_file(file_name, pattern, value)
  local f = io.open(file_name, "r")
  local content = f:read("*a")
  f:close()
  local res = string.gsub(content, pattern, "%1"..value, 1)
  f = io.open(file_name, "w+")
  f:write(res)
  f:close()
  local check = string.find(res, value)
  if check ~= nil then
    return true
  end
  return false
end

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()
commonSteps:DeleteLogsFileAndPolicyTable()

config.defaultProtocolVersion = 2

-- Backup files
commonPreconditions:BackupFile(sdl_preloaded_pt)
os.execute("cp ".. ptu_file .. " " .. ptu_file .. ".BAK")

-- Update files
for _, v in pairs({config.pathToSDL .. sdl_preloaded_pt, ptu_file}) do
  modify_file(v, genpattern2str("exchange_after_x_ignition_cycles", "%d+"), tostring(exchnage_after))
end

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:ActivateApp()
  local requestId1 = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName] })
  EXPECT_HMIRESPONSE(requestId1)
  :Do(function(_, data1)
      if data1.result.isSDLAllowed ~= true then
        local requestId2 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
          { language = "EN-US", messageCodes = { "DataConsent" } })
        EXPECT_HMIRESPONSE(requestId2)
        :Do(function()
            self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
              { allowed = true, source = "GUI", device = { id = config.deviceMAC, name = "127.0.0.1" } })
            EXPECT_HMICALL("BasicCommunication.ActivateApp")
            :Do(function(_, data2)
                self.hmiConnection:SendResponse(data2.id,"BasicCommunication.ActivateApp", "SUCCESS", { })
              end)
            :Times(1)
          end)
      end
    end)
end

function Test:TestStep_SUCCEESS_Flow_EXTERNAL_PROPRIETARY()
  testCasesForPolicyTable:flow_SUCCEESS_EXTERNAL_PROPRIETARY(self)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

for i = 1, exchnage_after do
  Test["Preconditions_perform_" .. tostring(i) .. "_IGN_OFF_ON"] = function() end

  function Test:IGNITION_OFF()
    self.hmiConnection:SendNotification("BasicCommunication.OnIgnitionCycleOver")
  end

  function Test.StopSDL()
    StopSDL()
  end
  function Test.StartSDL()
    StartSDL(config.pathToSDL, config.ExitOnCrash)
  end
  function Test:InitHMI()
    self:initHMI()
  end
  function Test:InitHMI_onReady()
    self:initHMI_onReady()
  end
  function Test:Register_app()
    self:connectMobile()
    self.mobileSession = mobileSession.MobileSession(self, self.mobileConnection)
    self.mobileSession:StartService(7)
    :Do(function()
        local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
        EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
        self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
        self.mobileSession:ExpectNotification("OnHMIStatus", { hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN" })
      end)
    if i == exchnage_after then
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", { status = "UPDATE_NEEDED" })
      :Times(AtLeast(1))
      EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
    end
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_Stop_SDL()
  StopSDL()
end

function Test.Postcondition_RestoreFiles()
  commonPreconditions:RestoreFile(sdl_preloaded_pt)
  local ptu_file_bak = ptu_file..".BAK"
  os.execute("cp -f " .. ptu_file_bak .. " " .. ptu_file)
  os.execute("rm -f " .. ptu_file_bak)
end

return Test
