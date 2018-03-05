---------------------------------------------------------------------------------------------------
-- OnRCStatus common module
---------------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.defaultProtocolVersion = 2
config.application1.registerAppInterfaceParams.appHMIType = { "REMOTE_CONTROL" }
config.application2.registerAppInterfaceParams.appHMIType = { "REMOTE_CONTROL" }
config.checkAllValidations = true

--[[ Required Shared libraries ]]
local commonRC = require('test_scripts/RC/commonRC')
local test = require("user_modules/dummy_connecttest")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local json = require("modules/json")

--[[ Local Variables ]]
local commonOnRCStatus = {}

function commonOnRCStatus.getModules()
  return commonFunctions:cloneTable({ "CLIMATE", "RADIO" })
end

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
  return commonRC.getRCAppConfig()
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

function commonOnRCStatus.ModulesArray(pModules)
  local out = {}
  for _, mod in pairs(pModules) do
    table.insert(out, { moduleType = mod })
  end
  return out
end

function commonOnRCStatus.getHMIAppIdsRC()
  local out = {}
  for appID, hmiAppId in pairs(commonRC.getHMIAppIds()) do
    for i = 1, 5 do
      local params = config["application" .. i].registerAppInterfaceParams
      if params.appID == appID and params.appHMIType[1] == "REMOTE_CONTROL" then
        table.insert(out, hmiAppId)
      end
    end
  end
  return out
end

local usedHmiAppIds = {}
function commonOnRCStatus.validateHMIAppIds(exp, data)
  if exp.occurences == 1 then
    usedHmiAppIds = {}
  end
  local avlHmiAppIds = {}
  for _, appId in pairs(commonOnRCStatus.getHMIAppIdsRC()) do
    avlHmiAppIds[appId] = true
  end
  local actAppId = data.params.appID
  if avlHmiAppIds[actAppId] and not usedHmiAppIds[actAppId] then
    usedHmiAppIds[actAppId] = true
    return true
  end
  local expAppIds = {}
  for appId in pairs(avlHmiAppIds) do
    if not usedHmiAppIds[appId] then
      table.insert(expAppIds, appId)
    end
  end
  return false, " Occurence: " .. exp.occurences .. ", "
    .. "expected appID: [" .. table.concat(expAppIds, ", ") .. "], " .. "actual: " .. tostring(actAppId)
end

function commonOnRCStatus.RegisterRCapplication(pAppId)
  if not pAppId then pAppId = 1 end
  local pModuleStatus = {
    freeModules = commonOnRCStatus.ModulesArray(commonOnRCStatus.getModules()),
    allocatedModules = { }
  }
  commonRC.rai_n(pAppId, test)
  for i = 1, pAppId do
    commonOnRCStatus.getMobileSession(i):ExpectNotification("OnRCStatus", pModuleStatus)
  end
  EXPECT_HMINOTIFICATION("RC.OnRCStatus", pModuleStatus)
  :Times(pAppId)
  :ValidIf(commonOnRCStatus.validateHMIAppIds)
end

function commonOnRCStatus.rai_ptu_n(ptu_update_func, pAppId)
  if not pAppId then pAppId = 1 end
  commonRC.rai_ptu_n(pAppId, ptu_update_func, test)
end

function commonOnRCStatus.rai_n(pAppId)
  commonRC.rai_n(pAppId, test)
end

function commonOnRCStatus.subscribeToModule(pModule, pAppId)
  if not pAppId then pAppId = 1 end
  commonRC.subscribeToModule(pModule, pAppId, test)
end

function commonOnRCStatus.ActivateApp(pAppId)
  commonRC.activate_app(pAppId, test)
end

function commonOnRCStatus.getHMIAppId(pAppId)
  return commonRC.getHMIAppId(pAppId)
end

function commonOnRCStatus.getSettableModuleControlData(pModuleType)
  return commonRC.getSettableModuleControlData(pModuleType)
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
  commonRC.deleteHMIAppId(pAppId)
  commonRC.unregisterApp(pAppId, test)
end

function commonOnRCStatus.closeSession(pAppId)
  if not pAppId then pAppId = 1 end
  commonRC.deleteHMIAppId(pAppId)
  commonOnRCStatus.getMobileSession(pAppId):Stop()
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

commonOnRCStatus.getAppEventName = commonRC.getAppEventName
commonOnRCStatus.getHMIEventName = commonRC.getHMIEventName
commonOnRCStatus.getAppRequestParams = commonRC.getAppRequestParams
commonOnRCStatus.getAppResponseParams = commonRC.getAppResponseParams
commonOnRCStatus.getHMIRequestParams = commonRC.getHMIRequestParams
commonOnRCStatus.getHMIResponseParams = commonRC.getHMIResponseParams

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
