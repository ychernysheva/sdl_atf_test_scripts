---------------------------------------------------------------------------------------------------
-- OnRCStatus common module
---------------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.defaultProtocolVersion = 2
config.application1.registerAppInterfaceParams.appHMIType = { "REMOTE_CONTROL" }
config.application2.registerAppInterfaceParams.appHMIType = { "REMOTE_CONTROL" }

--[[ Required Shared libraries ]]
local commonRC = require('test_scripts/RC/commonRC')
local test = require("user_modules/dummy_connecttest")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local json = require("modules/json")

--[[ Local Variables ]]
local commonOnRCStatus = {}
commonOnRCStatus.modules = {
  "CLIMATE",
  "RADIO"
}

local function backupPreloadedPT()
  local preloadedFile = commonFunctions:read_parameter_from_smart_device_link_ini("PreloadedPT")
  commonPreconditions:BackupFile(preloadedFile)
end

local function updatePreloadedPT(pCountOfRCApps)
  if not pCountOfRCApps then pCountOfRCApps = 2 end
  local preloadedFile = commonPreconditions:GetPathToSDL()
    .. commonFunctions:read_parameter_from_smart_device_link_ini("PreloadedPT")
  local preloadedTable = commonRC.jsonFileToTable(preloadedFile)
  preloadedTable.policy_table.functional_groupings["DataConsent-2"].rpcs = json.null
  preloadedTable.policy_table.functional_groupings["RemoteControl"].rpcs.OnRCStatus = {
    hmi_levels = { "FULL", "BACKGROUND", "LIMITED", "NONE" }
  }
  for i = 1, pCountOfRCApps do
    local appId = config["application" .. i].registerAppInterfaceParams.appID
    preloadedTable.policy_table.app_policies[appId] = commonRC.getRCAppConfig()
    preloadedTable.policy_table.app_policies[appId].AppHMIType = nil
  end

  commonRC.tableToJsonFile(preloadedTable, preloadedFile)
end

local function restorePreloadedPT()
  local preloadedFile = commonFunctions:read_parameter_from_smart_device_link_ini("PreloadedPT")
  commonPreconditions:RestoreFile(preloadedFile)
end

function commonOnRCStatus.getRCAppConfig()
  local struct = commonRC.getRCAppConfig()
  struct.moduleType = { "RADIO", "CLIMATE" }
  return struct
end

function commonOnRCStatus.getMobileSession(pAppId)
  return commonRC.getMobileSession(test, pAppId)
end

function commonOnRCStatus.getHMIconnection()
  return test.hmiConnection
end

function commonOnRCStatus.preconditions(pCountOfRCApps)
  commonRC.preconditions()
  backupPreloadedPT()
  updatePreloadedPT(pCountOfRCApps)
end

function commonOnRCStatus.start()
  commonRC.start(nil, test)
end

function commonOnRCStatus.AddOnRCStatusToPT(tbl)
  tbl.policy_table.functional_groupings.RemoteControl.rpcs.OnRCStatus = {
    hmi_levels = { "NONE", "BACKGROUND", "FULL", "LIMITED" }
  }
end

local function PTUfunc(tbl)
  commonOnRCStatus.AddOnRCStatusToPT(tbl)
  local appId = config.application1.registerAppInterfaceParams.appID
  tbl.policy_table.app_policies[appId] = commonOnRCStatus.getRCAppConfig()
end

function commonOnRCStatus.ModulesArray(pModules)
  local out = {}
  for _, mod in pairs(pModules) do
    table.insert(out, { moduleType = mod })
  end
  return out
end

function commonOnRCStatus.RegisterRCapplication(pAppId)
  if not pAppId then pAppId = 1 end
  local pModuleStatus = {
    freeModules = commonOnRCStatus.ModulesArray(commonOnRCStatus.modules), allocatedModules = { }
  }
  commonRC.rai_n(pAppId, test)
  for i = 1, pAppId do
    commonOnRCStatus.getMobileSession(i):ExpectNotification("OnRCStatus", pModuleStatus)
  end
  -- TODO: implement check for HMI.appID
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", pModuleStatus)
  :Times(pAppId)
end

function commonOnRCStatus.rai_ptu_n(ptu_update_func, pAppId)
  if not pAppId then pAppId = 1 end
  if not ptu_update_func then
    ptu_update_func = PTUfunc
  end
  commonRC.rai_ptu_n(pAppId, ptu_update_func, test)
end

function commonOnRCStatus.rai_n(pAppId)
  commonRC.rai_n(pAppId, test)
end

function commonOnRCStatus.subscribeToModule(pModule, pAppId)
  if not pAppId then pAppId = 1 end
  commonRC.subscribeToModule(pModule, pAppId, test)
end

function commonOnRCStatus.unsubscribeToModule(pModule, pModuleStatus, pAppId)
  if not pAppId then pAppId = 1 end
  commonRC.unSubscribeToModule(pModule, pAppId, test)
  local mobSession = commonOnRCStatus.getMobileSession(pAppId)
  mobSession:ExpectNotification("OnRCStatus",pModuleStatus)
  pModuleStatus.appID = commonRC.getHMIAppId()
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", pModuleStatus)
end

function commonOnRCStatus.ActivateApp(pAppId)
  commonRC.activate_app(pAppId, test)
end

function commonOnRCStatus.getHMIAppId(pAppId)
  local appId  = commonRC.getHMIAppId(pAppId)
  return appId
end

function commonOnRCStatus.getSettableModuleControlData(pModuleType)
  local struct = commonRC.getSettableModuleControlData(pModuleType)
  return struct
end

function commonOnRCStatus.postconditions()
  commonRC.postconditions()
  restorePreloadedPT()
end

function commonOnRCStatus.SetModuleStatus(pFreeMod, pAllocatedMod, pModule)
  local ModulesStatus = { }
  table.insert(pAllocatedMod, pModule)
  for key, value in pairs(pFreeMod) do
    if pModule == value then
      table.remove(pFreeMod, key)
    end
  end
  ModulesStatus.freeModules = commonOnRCStatus.ModulesArray(pFreeMod)
  ModulesStatus.allocatedModules = commonOnRCStatus.ModulesArray(pAllocatedMod)
  return ModulesStatus
end

function commonOnRCStatus.SetModuleStatusByDeallocation(pFreeMod, pAllocatedMod, pModule)
  local ModulesStatus = { }
  table.insert(pFreeMod, pModule)
  for key, value in pairs(pAllocatedMod) do
    if pModule == value then
      table.remove(pAllocatedMod, key)
    end
  end
  ModulesStatus.freeModules = commonOnRCStatus.ModulesArray(pFreeMod)
  ModulesStatus.allocatedModules = commonOnRCStatus.ModulesArray(pAllocatedMod)
  return ModulesStatus
end

function commonOnRCStatus.unregisterApp(pAppId)
  if not pAppId then pAppId = 1 end
  commonRC.unregisterApp(pAppId, test)
end

function commonOnRCStatus.defineRAMode(pAllowed, pAccessMode)
  commonRC.defineRAMode(pAllowed, pAccessMode, test)
end

function commonOnRCStatus.rpcRejectWithConsent(pModuleType, pAppId, pRPC)
  commonRC.rpcRejectWithConsent(pModuleType, pAppId, pRPC, test)
end

function commonOnRCStatus.rpcAllowedWithConsent(pModuleType, pAppId, pRPC)
  commonRC.rpcAllowedWithConsent(pModuleType, pAppId, pRPC, test)
end

function commonOnRCStatus.setVehicleData(pModuleType, pAppId)
  if not pAppId then pAppId = 1 end
  local mobSession = commonOnRCStatus.getMobileSession(pAppId)
  local cid = mobSession:SendRPC("SetInteriorVehicleData", {
    moduleData = commonOnRCStatus.getSettableModuleControlData(pModuleType)
  })
  EXPECT_HMICALL("RC.SetInteriorVehicleData", {
    appID = commonOnRCStatus.getHMIAppId(),
    moduleData = commonOnRCStatus.getSettableModuleControlData(pModuleType)
  })
  :Do(function(_, data)
    commonOnRCStatus.getHMIconnection():SendResponse(data.id, data.method, "SUCCESS", {
      moduleData = commonOnRCStatus.getSettableModuleControlData(pModuleType)
    })
  end)
  mobSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

-- RC RPCs structure
local rcRPCs = {
  GetInteriorVehicleData = {
    appEventName = "GetInteriorVehicleData",
    hmiEventName = "RC.GetInteriorVehicleData",
    requestParams = function(pModuleType, pSubscribe)
      return {
        moduleType = pModuleType,
        subscribe = pSubscribe
      }
    end,
    hmiRequestParams = function(pModuleType, pAppId, pSubscribe)
      return {
        appID = commonRC.getHMIAppId(pAppId),
        moduleType = pModuleType,
        subscribe = pSubscribe
      }
    end,
    hmiResponseParams = function(pModuleType, pSubscribe)
      return {
        moduleData = commonRC.getModuleControlData(pModuleType),
        isSubscribed = pSubscribe
      }
    end,
    responseParams = function(success, resultCode, pModuleType, pSubscribe)
      return {
        success = success,
        resultCode = resultCode,
        moduleData = commonRC.getModuleControlData(pModuleType),
        isSubscribed = pSubscribe
      }
    end
  },
  SetInteriorVehicleData = {
    appEventName = "SetInteriorVehicleData",
    hmiEventName = "RC.SetInteriorVehicleData",
    requestParams = function(pModuleType)
      return {
        moduleData = commonRC.getSettableModuleControlData(pModuleType)
      }
    end,
    hmiRequestParams = function(pModuleType, pAppId)
      return {
        appID = commonRC.getHMIAppId(pAppId),
        moduleData = commonRC.getSettableModuleControlData(pModuleType)
      }
    end,
    hmiResponseParams = function(pModuleType)
      return {
        moduleData = commonRC.getSettableModuleControlData(pModuleType)
      }
    end,
    responseParams = function(success, resultCode, pModuleType)
      return {
        success = success,
        resultCode = resultCode,
        moduleData = commonRC.getSettableModuleControlData(pModuleType)
      }
    end
  },
  ButtonPress = {
    appEventName = "ButtonPress",
    hmiEventName = "Buttons.ButtonPress",
    requestParams = function(pModuleType)
      return {
        moduleType = pModuleType,
        buttonName = commonRC.getButtonNameByModule(pModuleType),
        buttonPressMode = "SHORT"
      }
    end,
    hmiRequestParams = function(pModuleType, pAppId)
      return {
        appID = commonRC.getHMIAppId(pAppId),
        moduleType = pModuleType,
        buttonName = commonRC.getButtonNameByModule(pModuleType),
        buttonPressMode = "SHORT"
      }
    end,
    hmiResponseParams = function()
      return {}
    end,
    responseParams = function(success, resultCode)
      return {
        success = success,
        resultCode = resultCode
      }
    end
  },
  GetInteriorVehicleDataConsent = {
    hmiEventName = "RC.GetInteriorVehicleDataConsent",
    hmiRequestParams = function(pModuleType, pAppId)
      return {
        appID = commonRC.getHMIAppId(pAppId),
        moduleType = pModuleType
      }
    end,
    hmiResponseParams = function(pAllowed)
      return {
        allowed = pAllowed
      }
    end,
  },
  OnInteriorVehicleData = {
    appEventName = "OnInteriorVehicleData",
    hmiEventName = "RC.OnInteriorVehicleData",
    hmiResponseParams = function(pModuleType)
      return {
        moduleData = commonRC.getAnotherModuleControlData(pModuleType)
      }
    end,
    responseParams = function(pModuleType)
      return {
        moduleData = commonRC.getAnotherModuleControlData(pModuleType)
      }
    end
  },
  OnRemoteControlSettings = {
    hmiEventName = "RC.OnRemoteControlSettings",
    hmiResponseParams = function(pAllowed, pAccessMode)
      return {
        allowed = pAllowed,
        accessMode = pAccessMode
      }
    end
  }
}

function commonOnRCStatus.getAppEventName(pRPC)
  return rcRPCs[pRPC].appEventName
end

function commonOnRCStatus.getHMIEventName(pRPC)
  return rcRPCs[pRPC].hmiEventName
end

function commonOnRCStatus.getAppRequestParams(pRPC, ...)
  return rcRPCs[pRPC].requestParams(...)
end

function commonOnRCStatus.getAppResponseParams(pRPC, ...)
  return rcRPCs[pRPC].responseParams(...)
end

function commonOnRCStatus.getHMIRequestParams(pRPC, ...)
  return rcRPCs[pRPC].hmiRequestParams(...)
end

function commonOnRCStatus.getHMIResponseParams(pRPC, ...)
  return rcRPCs[pRPC].hmiResponseParams(...)
end

function commonOnRCStatus.rpcAllowed(pModuleType, pAppId, pRPC)
  local mobSession = commonOnRCStatus.getMobileSession(pAppId)
  local cid = mobSession:SendRPC(commonOnRCStatus.getAppEventName(pRPC),
    commonOnRCStatus.getAppRequestParams(pRPC, pModuleType))
  EXPECT_HMICALL(commonOnRCStatus.getHMIEventName(pRPC),
    commonOnRCStatus.getHMIRequestParams(pRPC, pModuleType, pAppId))
  :Do(function(_, data)
      commonOnRCStatus.getHMIconnection():SendResponse(data.id, data.method, "SUCCESS",
        commonOnRCStatus.getHMIResponseParams(pRPC, pModuleType))
    end)
  mobSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

function commonOnRCStatus.cloneTable(...)
  commonFunctions:cloneTable(...)
end

return commonOnRCStatus
