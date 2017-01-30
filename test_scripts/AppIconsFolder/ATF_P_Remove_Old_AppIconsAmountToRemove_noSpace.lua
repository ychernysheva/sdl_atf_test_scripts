---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [GENIVI] Conditions for SDL to create and use 'AppIconsFolder' storage 
--    [AppIconsFolder]: Conditions for SDL to remove old icons on value defined at "AppIconsAmountToRemove" param
-- Description:
--    SDL should remove oldest icon due AppIconsAmountToRemove param in .ini file if not enough space 
-- 1. Used preconditions:
--      Stop SDL
--      Set AppIconsFolder in .ini file
--      Set AppIconsFolder maxSize
--      Set Icons Amount to remove if not enough space 
--      Start SDL and HMI
--      Connect mobile
--      Make AppIconsFolder is full
-- 2. Performed steps:
--      Register app
--      Send SetAppIcon
-- Expected result:
--    SDL should delete oldest icon and save a new one in AppIconsFolder	
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
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

-- Get folder size
local function dSize(PathToFolder)
  local sizeFolderInBytes
  local aHandle = assert( io.popen( "du -sh " ..  tostring(PathToFolder), 'r'))
  local buff = aHandle:read( '*l' )
  local sizeFolder, measurementUnits = buff:match("([^%a]+)(%a)")
  if measurementUnits == "K" then
    sizeFolder  =  string.gsub(sizeFolder, ",", ".")
    sizeFolder = tonumber(sizeFolder)
    sizeFolderInBytes = sizeFolder * 1024
  elseif
    measurementUnits == "M" then
    sizeFolder  =  string.gsub(sizeFolder, ",", ".")
    sizeFolder = tonumber(sizeFolder)
    sizeFolderInBytes = sizeFolder * 1048576
  end
  return sizeFolderInBytes
end

-- Make AppIconsFolder full
local function makeAppIconsFolderFull(AppIconsFolder)
  local sizeToFull
  local sizeAppIconsFolderInBytes = dSize(config.pathToSDL .. tostring(AppIconsFolder))
  sizeToFull = 1048576 - sizeAppIconsFolderInBytes
  local i =1
  while sizeToFull > 326360 do
    os.execute("sleep " .. tonumber(10))
    local copyFileToAppIconsFolder = assert( os.execute( "cp files/icon.png " .. tostring(config.pathToSDL) .. tostring(AppIconsFolder) .. "/icon" .. tostring(i) ..".png"))
    i = i + 1
    if copyFileToAppIconsFolder ~= true then
      commonFunctions:userPrint(31, " Files are not copied to " .. tostring(AppIconsFolder))
    end
    sizeAppIconsFolderInBytes = dSize(config.pathToSDL .. tostring(AppIconsFolder))
    sizeToFull = 1048576 - sizeAppIconsFolderInBytes
    if i > 50 then
      commonFunctions:userPrint(31, " Loop is breaking due to a lot of iterations ")
      break
    end
  end
end

local function checkFunction()
  local status = true
  local applicationFileToCheck = config.pathToSDL .. tostring("IconsFolder/" .. RAIParameters.appID)
  local oldFileToCheck = config.pathToSDL .. tostring("IconsFolder/icon1.png")
  local applicationFileExistsResult = checkFileExistence(applicationFileToCheck)
  local oldFileExistResult = checkFileExistence(oldFileToCheck)
  local aHandle = assert( io.popen( "ls " .. config.pathToSDL .. "IconsFolder/" , 'r'))
  local ListOfFilesInStorageFolder = aHandle:read( '*a' )
  commonFunctions:userPrint(33, "Content of storage folder: " ..tostring("\n" ..ListOfFilesInStorageFolder) )

  if applicationFileExistsResult ~= true then
    commonFunctions:userPrint(31, tostring(RAIParameters.appID) .. " icon is absent")
    status = false
  end

  if oldFileExistResult ~= false then
    commonFunctions:userPrint(31,"Oldest icon1.png is not deleted from AppIconsFolder")
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
  local appIconsFolderValueToReplace = "IconsFolder"
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
 
function Test.Precondition_configureAppIconsFolderMaxSize()
  checkSDLPathValue()
  local appIconsFolderMaxSizeValueToReplace = "1048576"
  local stringToReplace = "AppIconsFolderMaxSize = " .. tostring(appIconsFolderMaxSizeValueToReplace) .. "\n"
  file = assert(io.open(SDLini, "r"))
  if file then
    fileContent = file:read("*all")
    local matchResult = string.match(fileContent, "AppIconsFolderMaxSize%s-=%s-.-%s-\n")
    if matchResult ~= nil then
      fileContentUpdated  =  string.gsub(fileContent, matchResult, stringToReplace)
      file = assert(io.open(SDLini, "w"))
      file:write(fileContentUpdated)
    else
      commonFunctions:userPrint(31, "'AppIconsFolderMaxSize = value' is not found. Expected string finding and replacing value with " .. tostring(appIconsFolderMaxSizeValueToReplace))
    end
    file:close()
  end
end

function Test.Precondition_configureAppIconsAmountToRemove()
  checkSDLPathValue()
  local appIconsAmountToRemoveValueToReplace = "1"
  local stringToReplace = "AppIconsAmountToRemove = " .. tostring(appIconsAmountToRemoveValueToReplace) .. "\n"
  file = assert(io.open(SDLini, "r"))
  if file then
    fileContent = file:read("*all")
    local matchResult = string.match(fileContent, "AppIconsAmountToRemove%s-=%s-.-%s-\n")
    if matchResult ~= nil then
      fileContentUpdated  =  string.gsub(fileContent, matchResult, stringToReplace)
      file = assert(io.open(SDLini, "w"))
      file:write(fileContentUpdated)
      commonFunctions:userPrint(32, "'AppIconsAmountToRemove' is set to " .. tostring(appIconsAmountToRemoveValueToReplace) .. " in .ini")
    else
      commonFunctions:userPrint(31, "'AppIconsAmountToRemove = value' is not found. Expected string finding and replacing value with " .. tostring(appIconsAmountToRemoveValueToReplace))
    end
    file:close()
  end
end
 
function Test.Precondition_removeAppIconsFolder()
  checkSDLPathValue()
  local addedFolderInScript = "IconsFolder"
  local existsResult = checkDirectoryExistence( tostring(config.pathToSDL .. addedFolderInScript))
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

function Test.Precondition_makeAppIconsFolderFull()
  makeAppIconsFolderFull( "IconsFolder" )
end


--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Check_Deleted_one_old_icon_if_space_not_enough()
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
      checkFunction()
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