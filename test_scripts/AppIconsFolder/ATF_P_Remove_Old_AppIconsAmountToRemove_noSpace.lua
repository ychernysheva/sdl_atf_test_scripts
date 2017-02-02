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

local function checkFilePresent(name, messages)
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
    sizeFolderInBytes = sizeFolder * 1048576
  end
  return sizeFolderInBytes
end

local function makeAppIconsFolderFull(AppIconsFolder)
  local sizeToFull
  local iconFolderSizeInBytes = 1048576
  local oneIconSizeInBytes = 326360
  local currentSizeIconsFolderInBytes = folderSize(config.pathToSDL .. tostring(AppIconsFolder))
  sizeToFull = iconFolderSizeInBytes - currentSizeIconsFolderInBytes
  local i =1
  while sizeToFull > oneIconSizeInBytes do
    os.execute("sleep " .. tonumber(10))
    local copyFileToAppIconsFolder = assert( os.execute( "cp files/icon.png " .. tostring(config.pathToSDL) .. tostring(AppIconsFolder) .. "/icon" .. tostring(i) ..".png"))
    i = i + 1
    if copyFileToAppIconsFolder ~= true then
      commonFunctions:userPrint(31, " Files are not copied to " .. tostring(AppIconsFolder))
    end
    currentSizeIconsFolderInBytes = folderSize(config.pathToSDL .. tostring(AppIconsFolder))
    sizeToFull = iconFolderSizeInBytes - currentSizeIconsFolderInBytes
    if i > 50 then
      commonFunctions:userPrint(31, " Loop is breaking due to a lot of iterations ")
      break
    end
  end
end

local function checkOldDeleted()
  local status = true
  local aHandle = assert( io.popen( "ls " .. config.pathToSDL .. "IconsFolder/" , 'r'))
  local ListOfFilesInStorageFolder = aHandle:read( '*a' )
  commonFunctions:userPrint(33, "Content of storage folder: " ..tostring("\n" ..ListOfFilesInStorageFolder))
  local iconFolderPath = config.pathToSDL .. tostring("IconsFolder/")
  local applicationFileToCheck = iconFolderPath .. RAIParameters.appID
  local applicationFileExistsResult = checkFilePresent(applicationFileToCheck)
  if applicationFileExistsResult ~= true then
    commonFunctions:userPrint(31, tostring(RAIParameters.appID) .. " icon is absent")
    status = false
  end
  for i=1, 1, 1 do 
    local oldFileToCheck = iconFolderPath.. "icon" .. tostring(i) ..".png"
    local oldFileExistResult = checkFilePresent(oldFileToCheck)
    if oldFileExistResult ~= false then
      commonFunctions:userPrint(31,"Oldest icon1.png is not deleted from AppIconsFolder")
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
 commonFunctions:SetValuesInIniFile("AppIconsFolder%s-=%s-.-%s-\n", "AppIconsFolder", 'IconsFolder')
end
 
function Test.Precondition_configureAppIconsFolderMaxSize()
  commonFunctions:SetValuesInIniFile("AppIconsFolderMaxSize%s-=%s-.-%s-\n", "AppIconsFolderMaxSize", 1048576)
end

function Test.Precondition_configureAppIconsAmountToRemove()
 commonFunctions:SetValuesInIniFile("AppIconsAmountToRemove%s-=%s-.-%s-\n", "AppIconsAmountToRemove", 1)
end
 
function Test.Precondition_removeAppIconsFolder()
  local addedFolderInScript = "IconsFolder"
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
  makeAppIconsFolderFull( "IconsFolder" )
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Check_Deleted_one_old_icon_if_space_not_enough()
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
      checkOldDeleted()
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
