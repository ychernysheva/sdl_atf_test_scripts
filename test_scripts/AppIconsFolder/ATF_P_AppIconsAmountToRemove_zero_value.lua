---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [GENIVI] Conditions for SDL to create and use 'AppIconsFolder' storage 
--    [AppIconsFolder]: Value of "AppIconsAmountToRemove" param is zero
--
-- Description:
--    SDL behavior if "AppIconsAmountToRemove" is equal zero at .ini file
-- 1. Used preconditions:
--      Delete files and policy table from previous ignition cycle if any
--      Set AppIconsAmountToRemove=0 in .ini file
--      Start SDL and HMI
--      Connect mobile
--      Make AppIconsFolder full
-- 2. Performed steps:
--      Register app
--      Send SetAppIcon RPC with new icon
-- Expected result:
--    SDL must:
--      not delete any of already stored icons from "AppIconsFolder";
--      not save the new icon to "AppIconsFolder"
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ Required Shared Libraries ]]
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
require('user_modules/AppTypes')

--[[ Local variables ]]
local RAIParameters = config.application1.registerAppInterfaceParams

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()
assert(os.execute( "rm -rf " .. tostring(config.pathToSDL .. "Icons")))
commonFunctions:SetValuesInIniFile("AppIconsFolder%s-=%s-.-%s-\n", "AppIconsFolder", 'Icons')
commonFunctions:SetValuesInIniFile("AppIconsFolderMaxSize%s-=%s-.-%s-\n", "AppIconsFolderMaxSize", 1048576)
commonFunctions:SetValuesInIniFile("AppIconsAmountToRemove%s-=%s-.-%s-\n", "AppIconsAmountToRemove", 0)

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
  local sizeAppIconsFolderInBytes = folderSize(config.pathToSDL .. tostring(AppIconsFolder))
  local appIconsFolderMaxSize = 1048576
  local oneIconSize = 326360
  sizeToFull = appIconsFolderMaxSize - sizeAppIconsFolderInBytes
  local i =1
  while sizeToFull > oneIconSize do
    os.execute("sleep 10")
    local copyFileToAppIconsFolder = assert( os.execute( "cp files/icon.png " .. tostring(config.pathToSDL) .. tostring(AppIconsFolder) .. "/icon" .. tostring(i) ..".png"))
    i = i + 1
    if copyFileToAppIconsFolder ~= true then
      commonFunctions:userPrint(31, " Files are not copied to " .. tostring(AppIconsFolder))
    end
    sizeAppIconsFolderInBytes = folderSize(config.pathToSDL .. tostring(AppIconsFolder))
    sizeToFull = appIconsFolderMaxSize - sizeAppIconsFolderInBytes
    if i > 50 then
      commonFunctions:userPrint(31, " Loop is breaking due to a lot of iterations ")
      break
    end
  end
end

local function checkFunction()
  local status
  local aHandle = assert( io.popen( "ls " .. config.pathToSDL .. "Icons/" , 'r'))
  local listOfFilesInStorageFolder = aHandle:read( '*a' )
  commonFunctions:userPrint(32, "Content of storage folder: " ..tostring("\n" ..listOfFilesInStorageFolder))
  local iconFolder = config.pathToSDL .. tostring("Icons/")
  local applicationFileToCheck = iconFolder .. RAIParameters.appID
  local applicationFileExistsResult = commonSteps:file_exists(applicationFileToCheck)
  if applicationFileExistsResult ~= false then
    commonFunctions:userPrint(31, "New ".. tostring(RAIParameters.appID) .. " icon is stored in AppIconsFolder although free space is not enough")
    status = false
  end
  for i=1, 3 do
    local oldFileToCheck = iconFolder.. "icon" .. tostring(i) ..".png"
    local oldFileToCheckExistsResult = commonSteps:file_exists(oldFileToCheck)
    if oldFileToCheckExistsResult ~= true then
      commonFunctions:userPrint(31,"Oldest icon" .. tostring(i).. ".png is deleted from AppIconsFolder")
      status = false
    end
  end
    return status
end

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

 function Test:Precondition_connectMobile()
  self:connectMobile()
 end

function Test.Precondition_makeAppIconsFolderFull()
  makeAppIconsFolderFull( "Icons" )
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Check_old_icon_not_deleted_and_new_not_saved_if_AppIconsAmountToRemove_is_zero()
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
