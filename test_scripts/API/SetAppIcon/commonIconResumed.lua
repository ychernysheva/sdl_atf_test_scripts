---------------------------------------------------------------------------------------------------
-- Common module
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local actions = require("user_modules/sequences/actions")
local utils = require("user_modules/utils")
local test = require("user_modules/dummy_connecttest")
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')

--[[ Module ]]
local m = actions

--[[ Variables ]]
local hmiAppIds = {}

--[[ @getPathToFileInStorage: Return app file from storage
--! @parameters:
--! pFile - Path to file will be used to send to SDL
--! pAppId - application number (1, 2, etc.)
--]]
function m.getPathToFileInStorage(pFileName, pAppId)
  if not pAppId then pAppId = 1 end
  return commonPreconditions:GetPathToSDL() .. "storage/"
  .. m.getConfigAppParams( pAppId ).appID .. "_"
  .. utils.getDeviceMAC() .. "/" .. fileName
end

--[[ @registerAppWOPTU: register mobile application
--! @parameters:
--! pAppId - application number (1, 2, etc.)
--! pIconResumed - apps icon was resumed at system or is not resumed
--! pReconnection - re-register mobile application
--! pIconValue - 
--! @return: none
--]]
function m.registerAppWOPTU(pAppId, pIconResumed, pReconnection, pIconValue)
  if not pAppId then pAppId = 1 end
  if pIconResumed == true then
    if not pIconValue then
      pIconValue = m.getPathToFileInStorage("icon.png")
    else
      pIconValue = m.getPathToFileInStorage(pIconValue)
    end
  end
  local mobSession = m.getMobileSession(pAppId)
  local function RegisterApp()
    local corId = mobSession:SendRPC("RegisterAppInterface",
        config["application" .. pAppId].registerAppInterfaceParams)
      test.hmiConnection:ExpectNotification("BasicCommunication.OnAppRegistered",
        { application = {
            appName = config["application" .. pAppId].registerAppInterfaceParams.appName,
            icon = pIconValue
        }})
      :Do(function(_, d1)
          hmiAppIds[m.getConfigAppParams(pAppId).appID] = d1.params.application.appID
        end)
      :ValidIf(function(_,data)
        if false == pIconResumed and
          data.params.application.icon then
          return false, "BC.OnAppRegistered notification contains unexpected icon value "
        end
        return true
      end)
      mobSession:ExpectResponse(corId, { success = true, resultCode = "SUCCESS", iconResumed = pIconResumed })
      :Do(function()
          mobSession:ExpectNotification("OnHMIStatus",
            { hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN" })
          mobSession:ExpectNotification("OnPermissionsChange")
      end)
    end
  if pReconnection == true then
    RegisterApp()
  else
    mobSession:StartService(7)
    :Do(function()
      RegisterApp()
    end)
  end
end

--[[ @unregisterAppInterface: Mobile application successfully unregistered
--! @parameters:
--! pAppId - Application number (1, 2, etc.)
--]]
function m.unregisterAppInterface(pAppId)
  if not pAppId then pAppId = 1 end
  local mobSession = m.getMobileSession(pAppId)
  local corId = mobSession:SendRPC("UnregisterAppInterface", { })
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
    { appID = m.getHMIAppId(pAppId), unexpectedDisconnect = false })
  mobSession:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
end

--[[ @putFileAllParams: Set all parameter for PutFile
--! @parameters: none 
--! @return: none
--]]
local function getPutFileAllParams()
  local temp = {
    syncFileName = "icon.png",
    fileType = "GRAPHIC_PNG",
    persistentFile = false,
    systemFile = false,
    offset = 0,
    length = 11600
  }
  return temp
end

--[[ @PutFile: File downloaded successfully
--! @parameters:
--! pFile - Path to file will be used to send to SDL
--! pAppId - Application number (1, 2, etc.)
--! @return: none
--]]
function m.putFile(paramsSend, pFile, pAppId)
  if paramsSend then
    paramsSend = paramsSend
  else paramsSend =  putFileAllParams()
  end
  if not pAppId then pAppId = 1 end
  local mobSession = m.getMobileSession(pAppId)
  local cid
  if file ~= nil then
    cid = mobSession:SendRPC("PutFile", paramsSend, file)
  else
    cid = mobSession:SendRPC("PutFile", paramsSend, "files/icon.png")
  end

  mobSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

 

--[[ @setAppIcon: Icon set successfully
--! @parameters:
--! params - Parameters will be sent to SDL
--! pAppId - Application number (1, 2, etc.)
--! @return: m
--]]
function m.setAppIcon(params, pAppId)
  if not pAppId then pAppId = 1 end
  local mobSession = m.getMobileSession(pAppId)
  local cid = mobSession:SendRPC("SetAppIcon", params.requestParams)
  params.requestUiParams.appID = m.getHMIAppId()
  EXPECT_HMICALL("UI.SetAppIcon", params.requestUiParams)
  :Do(function(_, data)
      m.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  mobSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

return m

--[[ @CloseConnection: Close mobile connection successfully
--! @parameters: none
--! @return: none
--]]
function m.CloseConnection()
  test.mobileConnection:Close()
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", { unexpectedDisconnect = true })
end


--[[ @OpenConnection: return Mobile connection object
--! @parameters: none
--! return: none
--]]
function m.OpenConnection()
  test.mobileSession[1] = mobile_session.MobileSession(
    test,
    test.mobileConnection,
    config.application1.registerAppInterfaceParams)
  test.mobileConnection:Connect()
  test.mobileSession[1]:StartRPC()
end
