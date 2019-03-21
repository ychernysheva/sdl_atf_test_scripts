
local actions = require("user_modules/sequences/actions")

local commonAppServices = actions

local serviceIDs = {}

local function appServiceCapability(update_reason, manifest) 
  local appService = {
    updateReason = update_reason,
    updatedAppServiceRecord = {
      serviceManifest = manifest
    }
  }
  if update_reason == "PUBLISHED" then
    appService.updatedAppServiceRecord.servicePublished = true
    appService.updatedAppServiceRecord.serviceActive = false
  elseif update_reason == "REMOVED" then
    appService.updatedAppServiceRecord.servicePublished = false
    appService.updatedAppServiceRecord.serviceActive = false
  elseif update_reason == "ACTIVATED" then
    appService.updatedAppServiceRecord.servicePublished = true
    appService.updatedAppServiceRecord.serviceActive = true
  elseif update_reason == "DEACTIVATED" then
    appService.updatedAppServiceRecord.servicePublished = true
    appService.updatedAppServiceRecord.serviceActive = false
  end
  return appService
end

function commonAppServices.appServiceCapabilityUpdateParams(update_reason, manifest)
  return {
    systemCapability = {
      systemCapabilityType = "APP_SERVICES",
      appServicesCapabilities = {
        appServices = {
          appServiceCapability(update_reason, manifest)
        }
      }
    }
  }
end

function commonAppServices.getAppServiceConsumerConfig(app_id)
  return {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE",
    groups = { "Base-4" , "AppServiceConsumer" },
    nicknames = { config["application" .. app_id].registerAppInterfaceParams.appName }
  }
end

function commonAppServices.getAppServiceProducerConfig(app_id)
  return {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE",
    groups = { "Base-4" , "AppServiceProducer" },
    nicknames = { config["application" .. app_id].registerAppInterfaceParams.appName },
    app_services = {
      MEDIA = {
        handled_rpcs = {{function_id = 2000}},
        service_names = {
          config["application" .. app_id].registerAppInterfaceParams.appName
        }
      }
    }
  }
end

function commonAppServices.publishEmbeddedAppService(manifest)
  local cid = commonAppServices.getHMIConnection():SendRequest("AppService.PublishAppService", {
    appServiceManifest = manifest
  })

  EXPECT_HMINOTIFICATION("BasicCommunication.OnSystemCapabilityUpdated", 
    commonAppServices.appServiceCapabilityUpdateParams("PUBLISHED", manifest),
    commonAppServices.appServiceCapabilityUpdateParams("ACTIVATED", manifest)):Times(AtLeast(1))
  EXPECT_HMIRESPONSE(cid, {
    result = {
      appServiceRecord = {
        serviceManifest = manifest,
        servicePublished = true
      },
      code = 0, 
      method = "AppService.PublishAppService"
    }
  }):Do(function(_, data)
      if data.result.appServiceRecord then
        serviceIDs[0] = data.result.appServiceRecord.serviceID
      end
    end)
end

function commonAppServices.publishMobileAppService(manifest, app_id)
  if not app_id then app_id = 1 end
  local mobileSession = commonAppServices.getMobileSession(app_id)
  local cid = mobileSession:SendRPC("PublishAppService", {
    appServiceManifest = manifest
  })

  mobileSession:ExpectNotification("OnSystemCapabilityUpdated",
    commonAppServices.appServiceCapabilityUpdateParams("PUBLISHED", manifest),
    commonAppServices.appServiceCapabilityUpdateParams("ACTIVATED", manifest)):Times(AtLeast(1))
  mobileSession:ExpectResponse(cid, {
    appServiceRecord = {
      serviceManifest = manifest,
      servicePublished = true
    },
    success = true,
    resultCode = "SUCCESS"
  }):Do(function(_, data)
      if data.payload.success then
        serviceIDs[app_id] = data.payload.appServiceRecord.serviceID
      end
    end)
end

function commonAppServices.getAppServiceID(app_id)
  if not app_id then app_id = 1 end
  return serviceIDs[app_id]
end

function commonAppServices.setValidateSchema(value)
  config.ValidateSchema = value
end

return commonAppServices