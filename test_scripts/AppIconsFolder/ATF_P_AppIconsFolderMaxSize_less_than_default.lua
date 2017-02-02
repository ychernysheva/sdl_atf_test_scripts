---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [GENIVI] Conditions for SDL to create and use 'AppIconsFolder' storage 
--    [AppIconsFolder]: SDL must compare the value from "AppIconsFolderMaxSize" param with the referenced value
--    [AppIconsFolder]: Value of "AppIconsFolderMaxSize" param less than default
-- Description:
--    Case when value defined at "AppIconsFolderMaxSize" param in .ini file is less than 1048576 bytes  
-- 1. Used preconditions:
--      Stop SDL
--      Configure "AppIconsFolderMaxSize" param in .ini file to be less than 1048576 bytes  
--      Start SDL and HMI
--      Connect mobile
--      Make AppIconsFolder full 
-- 2. Performed steps:
--      Register app 
--      Send SetAppicon
-- Expected result:
--    SDL should use default value of 1048576 bytes as the "AppIconsFolder" folder size:
--        a.SDL should delete oldest icon from AppIconsFolder
--        b.SDL should save the new icon having AppIconsFolder size not more than 1048576 bytes
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

local function checkFilePersists(name, messages)
  local file
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

-- Generate path to application folder
local function pathToAppFolderFunction(appID)
  commonSteps:CheckSDLPath()
  local path = config.pathToSDL .. tostring("storage/") .. tostring(appID) .. "_" .. tostring(config.deviceMAC) .. "/"
  return path
end

local function folderSize(PathToFolder)
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
    sizeFolderInBytes = sizeFolder * 524288
  end
  return sizeFolderInBytes
end  

local function makeAppIconsFolderFull(AppIconsFolder)
  local sizeToFull
  local folderSizeInBytes = 524288
  local oneIconSizeInBytes = -326360 
  local currentsSizeIconsFolderInBytes = folderSize(config.pathToSDL .. tostring(AppIconsFolder))
  sizeToFull = folderSizeInBytes - currentsSizeIconsFolderInBytes
  local i =1
  while sizeToFull > oneIconSizeInBytes do
    os.execute("sleep " .. tonumber(10))
    local copyFileToAppIconsFolder = assert( os.execute( "cp files/icon.png " .. tostring(config.pathToSDL) .. tostring(AppIconsFolder) .. "/icon" .. tostring(i) ..".png"))
    i = i + 1
    if copyFileToAppIconsFolder ~= true then
      commonFunctions:userPrint(31, " Files are not copied to " .. tostring(AppIconsFolder))
    end
    currentsSizeIconsFolderInBytes = folderSize(config.pathToSDL .. tostring(AppIconsFolder))
    sizeToFull = folderSizeInBytes - currentsSizeIconsFolderInBytes
    if i > 50 then
      commonFunctions:userPrint(31, " Loop is breaking due to a lot of iterations ")
      break
    end
  end
end

local function checkFunction()
  local status = true
  local aHandle = assert( io.popen( "ls " .. config.pathToSDL .. "Icons/" , 'r'))
  local listOfFilesInStorageFolder = aHandle:read( '*a' )
  commonFunctions:userPrint(33, "Content of storage folder: " ..tostring("\n" ..listOfFilesInStorageFolder) )
  local iconsFolder = config.pathToSDL .. tostring("Icons/")
  local applicationFileToCheck = iconsFolder .. RAIParameters.appID
  local applicationFileExistsResult = checkFilePersists(applicationFileToCheck)
  if applicationFileExistsResult ~= true then
    commonFunctions:userPrint(31, tostring(RAIParameters.appID) .. " icon is absent")
    status = false
  end
    for i=1, 1, 1 do
      local oldFileToCheck = iconsFolder.. "icon" .. tostring(i) ..".png"
      local oldFileExistResult = checkFilePersists(oldFileToCheck)
      if oldFileExistResult ~= false then
        commonFunctions:userPrint(31,"Oldest icon1.png is not deleted from AppIconsFolder.More space is occupied than default(1Mb) folder size")
        status = false
      end
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
  commonFunctions:SetValuesInIniFile("AppIconsFolder%s-=%s-.-%s-\n", "AppIconsFolder", 'Icons')
end

function Test.Precondition_configureAppIconsFolderMaxSize()
  commonFunctions:SetValuesInIniFile("AppIconsFolderMaxSize%s-=%s-.-%s-\n", "AppIconsFolderMaxSize", 524288)
end

function Test.Precondition_configureAppIconsAmountToRemove()
  commonFunctions:SetValuesInIniFile("AppIconsAmountToRemove%s-=%s-.-%s-\n", "AppIconsAmountToRemove", 1)
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

function Test.Precondition_makeAppIconsFolderFull()
  makeAppIconsFolderFull( "Icons" )
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Check_SDL_uses_default_folder_size_and_deletes_oldest_ison()
  local pathToAppFolder
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
