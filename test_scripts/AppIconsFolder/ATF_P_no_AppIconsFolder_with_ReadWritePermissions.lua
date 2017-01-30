---------------------------------------------------------------------------------------------
-- Requirement summary:
--		[GENIVI] Conditions for SDL to create and use 'AppIconsFolder' storage 
--	  [AppIconsFolder]: Folder defined at "AppIconsFolder" param does NOT exist but has read-write permissions
-- Description:
--    SDL behavior when on startup AppIconsFolder doesn't exist
-- 1. Used preconditions:
--    Delete log files and polisy table from previous cycle if any
--    AppIconsFolder doesn't exist
-- 2. Performed steps:
--    Start SDL and HMI
-- Expected result:
-- 	  SDL:
--      checks if AppIconsFolder exists;
--      creates AppIconsFolder
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.defaultProtocolVersion = 4
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ General Settings for configuration ]]
local preconditions = require('user_modules/shared_testcases/commonPreconditions')
preconditions:Connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp("connecttestIcons.lua")
Test = require('user_modules/connecttestIcons')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ Required Shared Libraries ]]
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
require('user_modules/AppTypes')

--[[ Local variables ]]
local pathToAppFolder
local file
local fileContent
local status = true
local fileContentUpdated
local SDLini = config.pathToSDL .. tostring("smartDeviceLink.ini")
local RAIParameters = config.application1.registerAppInterfaceParams

--[[ Local functions ]]
local function registerApplication(self)
  local corIdRAI = self.mobileSession:SendRPC("RegisterAppInterface", RAIParameters)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered",
  {
    application =
    {
     appName = RAIParameters.appName
    }
  })
  :Do(function(_,data)
    self.applications[RAIParameters.appName] = data.params.application.appID
  end)
  self.mobileSession:ExpectResponse(corIdRAI, { success = true, resultCode = "SUCCESS" })
end

-- Check file existence 
local function checkFileExistence(name, messages)
  file=io.open(name,"r")
  if file ~= nil then
    io.close(file)
    if messages == true then
      commonFunctions:userPrint(32, "File " .. tostring(name) .. " exists")
    end
    return true
  else
    if messages == true then
      commonFunctions:userPrint(31, "File " .. tostring(name) .. " does not exist")
    end
    return false
  end
end

--Check path to SDL in case last symbol is not'/' add '/'
local function checkSDLPathValue()
  local findResult = string.find (config.pathToSDL, '.$')
  if string.sub(config.pathToSDL,findResult) ~= "/" then
    config.pathToSDL = config.pathToSDL..tostring("/")
  end
end

-- Generate path to application folder
local function pathToAppFolderFunction(appID)
  checkSDLPathValue()
  local path = config.pathToSDL .. tostring("storage/") .. tostring(appID) .. "_" .. tostring(config.deviceMAC) .. "/"
  return path
end

-- Check directory existence
local function checkDirectoryExistence(DirectoryPath)
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

local function checkIconStored()
  local applicationFileToCheck = config.pathToSDL .. tostring("Icons/" .. RAIParameters.appID)
  local applicationFileExistsResult = checkFileExistence(applicationFileToCheck)
  local aHandle = assert( io.popen( "ls " .. config.pathToSDL .. "Icons/" , 'r'))
  local listOfFilesInStorageFolder = aHandle:read( '*a' )
  commonFunctions:userPrint(32, "Content of Icons folder: " ..tostring("\n" ..listOfFilesInStorageFolder) )

  if applicationFileExistsResult ~= true then
    commonFunctions:userPrint(31, tostring(RAIParameters.appID) .. " icon is absent")
    status = false
  end
  return status
end

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()
commonFunctions:newTestCasesGroup("Preconditions")

function Test.Precondition_stopSDL()
  StopSDL()
end  

function Test.Precondition_configureAppIconsFolder()
  checkSDLPathValue()
  local appIconsFolderValueToReplace = "Icons"
  local stringToReplace = "AppIconsFolder = " .. tostring(appIconsFolderValueToReplace) .. "\n"
  file = assert(io.open(SDLini, "r"))
  if file then
    fileContent = file:read("*all")
    local matchResult = string.match(fileContent, "AppIconsFolder%s-=%s-.-%s-\n")
    if matchResult ~= nil then
      fileContentUpdated  =  string.gsub(fileContent, matchResult, stringToReplace)
      file = assert(io.open(SDLini, "w"))
      file:write(fileContentUpdated)
    else
      commonFunctions:userPrint(31, "'AppIconsFolder = value' is not found. Expected string finding and replacing value with " .. tostring(appIconsFolderValueToReplace))
    end
    file:close()
  end
end 

function Test.Precondition_removeAppIconsFolder()
  checkSDLPathValue()
  local addedFolderInScript = "Icons"
  local existsResult = checkDirectoryExistence( tostring(config.pathToSDL .. addedFolderInScript))
  if existsResult == true then
    local rmAppIconsFolder  = assert( os.execute( "rm -rf " .. tostring(config.pathToSDL .. addedFolderInScript)))
    if rmAppIconsFolder ~= true then
      commonFunctions:userPrint(31, tostring(addedFolderInScript) .. " folder is not deleted")
    end
  end
end

 function Test.Precondition_StartSDL()
  StartSDL(config.pathToSDL, config.ExitOnCrash)
 end

 function Test:Precondition_InitHMI()
  self:initHMI()
 end

 function Test:Precondition_InitHMIonReady()
  self:initHMI_onReady()
 end

 function Test:Precondition_ConnectMobile()
  self:connectMobile()
 end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test.Step1_Check_AppIconsFolder_was_created_on_startup()
  local dirExistResult = checkDirectoryExistence(config.pathToSDL .. "Icons")
  if dirExistResult == true then
    commonFunctions:userPrint(32, "AppIconsFolder exists")
  else
    commonFunctions:userPrint(31, "Icons folder doesn't exist in SDL bin folder")
  end
end

function Test:Step2_Check_SDL_uses_AppIconsFolder_for_storing_icons()
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession.version = 4
  self.mobileSession:StartService(7)
  :Do(function()
    registerApplication(self)
    EXPECT_NOTIFICATION("OnHMIStatus", { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"})
    :Do(function()
     local cidPutFile = self.mobileSession:SendRPC("PutFile",
      {
        syncFileName = "iconFirstApp.png",
        fileType = "GRAPHIC_PNG",
        persistentFile = false,
        systemFile = false
      }, "files/icon.png")
     EXPECT_RESPONSE(cidPutFile, { success = true, resultCode = "SUCCESS" })
     :Do(function()
     local cidSetAppIcon = self.mobileSession:SendRPC("SetAppIcon",{ syncFileName = "iconFirstApp.png" })
     pathToAppFolder = pathToAppFolderFunction(RAIParameters.appID)
     EXPECT_HMICALL("UI.SetAppIcon",
      {
        syncFileName =
          {
            imageType = "DYNAMIC",
            value = pathToAppFolder .. "iconFirstApp.png"
          }
       })
    :Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
    end)
    EXPECT_RESPONSE(cidSetAppIcon, { resultCode = "SUCCESS", success = true })
    :ValidIf(function()
      checkIconStored()
    end)
    end)
    end)
  end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test.Postcondition_removeSpecConnecttest()
  os.execute(" rm -f  ./user_modules/connecttestIcons.lua")
end 

function Test.Postcondition_stopSDL()
  StopSDL()
end