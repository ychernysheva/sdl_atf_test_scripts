---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] Name defined in PathToSnapshot of .ini file is incorrect for the specific OS
--
-- Behavior of SDL during start SDL with correct path to PathToSnapshot in INI file for the specific OS (Linux)
-- 1. Used preconditions:
-- Do not start default SDL
-- 2. Performed steps:
-- Set incorrect PathToSnapshot path in INI file for the specific OS (Linux)
-- Start SDL
--
-- Expected result:
-- SDL must shutdown
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--TODO(istoimenova): shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local testCasesForPolicyTable = require ('user_modules/shared_testcases/testCasesForPolicyTable')
local SDL = require('modules/SDL')

--[[ Local Variables ]]
--local INCORRECT_LINUX_PATH_TO_POLICY_SNAPSHOT_FILE = "-\0sdl$snapshot.json"
local INCORRECT_LINUX_PATH_TO_POLICY_SNAPSHOT_FILE = "sdl$ \tsnapshot.json"
local oldPathToPtSnapshot

--[[ Local Functions ]]

local function setValueInSdlIni(parameterName, parameterValue)
  local sdlIniFileName = config.pathToSDL .. "smartDeviceLink.ini"
  local oldParameterValue
  local file = assert(io.open(sdlIniFileName, "r"))
  if file then
    local fileContent = file:read("*a")
    file:close()
    oldParameterValue = string.match(fileContent, parameterName .. "%s*=%s*(%S+)")
    if oldParameterValue then
      fileContent = string.gsub(fileContent, parameterName .. "%s*=%s*%S+", parameterName .. " = " .. parameterValue)
    else
      local lastCharOfFile = string.sub(fileContent, string.len(fileContent))
      if lastCharOfFile == "\n" then
        lastCharOfFile = ""
      else
        lastCharOfFile = "\n"
      end
      fileContent = table.concat({fileContent, lastCharOfFile, parameterName, " = ", parameterValue, "\n"})
      oldParameterValue = nil
    end
    file = assert(io.open(sdlIniFileName, "w"))
    if file then
      file:write(fileContent)
      file:close()
      return true, oldParameterValue
    else
      return false
    end
  else
    return false
  end
end

local function changePtsPathInSdlIni(newPath)
  local result, oldPath = setValueInSdlIni("PathToSnapshot", newPath)
  if not result then
    commonFunctions:userPrint(31, "Test can't change SDL .ini file")
  end
  return oldPath
end

--[[ General preconditinons before ATF starts]]
local function Precondition()
  oldPathToPtSnapshot = changePtsPathInSdlIni(INCORRECT_LINUX_PATH_TO_POLICY_SNAPSHOT_FILE)
end
Precondition()

--[[ General configuration parameters ]]
Test = require('connecttest')
require('user_modules/AppTypes')

function Test.checkSdl()
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose",{}):Times(1)
  local status = SDL:CheckStatusSDL()
  if status == SDL.RUNNING then
    commonFunctions:userPrint(31, "Test failed: SDL running with incorrect INI file")
    return false
  end
  return true
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_trigger_getting_device_consent()
  testCasesForPolicyTable:trigger_getting_device_consent(self, config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

function Test:Test()
  os.execute("sleep 3")
  self.checkSdl()
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_StopSDL()
  changePtsPathInSdlIni(oldPathToPtSnapshot)
  StopSDL()
end

return Test
