---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [GENIVI] Conditions for SDL to create and use 'AppIconsFolder' storage 
--    [AppIconsFolder]: Folder defined at "AppIconsFolder" param does NOT exist but has read-write permissions
-- Description:
--    SDL behavior when on startup AppIconsFolder doesn't exist
-- 1. Used preconditions:
--    Delete log files and polisy table from previous cycle if any
--    AppIconsFolder doesn't exist
-- 2. Performed steps:
--    Start SDL and HMI
-- Expected result:
--    SDL:
--      checks if AppIconsFolder exists;
--      creates AppIconsFolder
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ General Settings for configuration ]]
local preconditions = require('user_modules/shared_testcases/commonPreconditions')
preconditions:Connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp("connecttestIcons.lua")
Test = require('user_modules/connecttestIcons')
require('cardinalities')

--[[ Required Shared Libraries ]]
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
require('user_modules/AppTypes')


--[[ Local functions ]]
local function checkDirectoryPresent(DirectoryPath)
  local returnValue
  local command = assert( io.popen(  "[ -d " .. tostring(DirectoryPath) .. " ] && echo \"Exist\" || echo \"NotExist\"" , 'r'))
  os.execute("sleep 0.5")
  local commandResult = tostring(command:read( '*l' ))
    if commandResult == "NotExist" then
      returnValue = false
    elseif
      commandResult == "Exist" then
      returnValue =  true
    else
      commonFunctions:userPrint(31," Unexpected result in checkDirectoryExistence function, commandResult = " .. tostring(commandResult))
      returnValue = false
    end
    return returnValue
end

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()
commonFunctions:newTestCasesGroup("Preconditions")

function Test.Precondition_stopSDL()
  StopSDL()
end  

function Test.Precondition_configureAppIconsFolder()
  commonFunctions:SetValuesInIniFile("AppIconsFolder%s-=%s-.-%s-\n", "AppIconsFolder", 'Icons')
end 

function Test.Precondition_removeAppIconsFolder()
  local addedFolderInScript = "Icons"
  local existsResult = commonSteps:Directory_exist( tostring(config.pathToSDL .. addedFolderInScript))
  if existsResult == true then
    local rmAppIconsFolder  = assert( os.execute( "rm -rf " .. tostring(config.pathToSDL .. addedFolderInScript)))
    if rmAppIconsFolder ~= true then
      commonFunctions:userPrint(31, tostring(addedFolderInScript) .. " folder is not deleted")
    end
  end
end

function Test.Precondition_startSDL()
  StartSDL(config.pathToSDL, config.ExitOnCrash)
end

function Test:Precondition_initHMI()
  self:initHMI()
end

function Test:Precondition_initHMIonReady()
  self:initHMI_onReady()
end

function Test:Precondition_connectMobile()
  self:connectMobile()
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test.Check_AppIconsFolder_is_created_on_startup()
  local dirExistResult = checkDirectoryPresent(config.pathToSDL .. "Icons")
  if dirExistResult == true then
    commonFunctions:userPrint(32, "AppIconsFolder exists")
  else
    commonFunctions:userPrint(31, "Icons folder doesn't exist in SDL bin folder")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_removeSpecConnecttest()
  os.execute(" rm -f  ./user_modules/connecttestIcons.lua")
end 

function Test.Postcondition_stopSDL()
  StopSDL()
end
