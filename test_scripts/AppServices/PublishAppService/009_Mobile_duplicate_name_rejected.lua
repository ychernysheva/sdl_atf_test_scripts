---------------------------------------------------------------------------------------------------
--  Precondition: 
--  1) Application with <appID> is registered on SDL.
--  2) Specific permissions are assigned for <appID> with PublishAppService
--
--  Steps:
--  1) Application sends a PublishAppService RPC request
--
--  Expected:
--  1) SDL sends a OnSystemCapabilityUpdated(APP_SERVICES, PUBLISHED) notification to mobile app
--  2) SDL sends a OnSystemCapabilityUpdated(APP_SERVICES, ACTIVATED) notification to mobile app
--  3) SDL responds to mobile app with "resultCode: SUCCESS, success: true"
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/AppServices/commonAppServices')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local manifest = {
  serviceName = config.application1.registerAppInterfaceParams.appName,
  serviceType = "MEDIA",
  allowAppConsumers = true,
  rpcSpecVersion = config.application1.registerAppInterfaceParams.syncMsgVersion,
  mediaServiceManifest = {}
}

local manifest2 = {
  serviceName = config.application1.registerAppInterfaceParams.appName,
  serviceType = "NAVIGATION",
  allowAppConsumers = false,
  rpcSpecVersion = config.application1.registerAppInterfaceParams.syncMsgVersion,
  mediaServiceManifest = {}
}

local rpc = {
  name = "PublishAppService",
  params = {
    appServiceManifest = manifest2
  }
}

local expectedResponse = {
  success = false,
  resultCode = "REJECTED"
}

local function PTUfunc(tbl)
  local config = common.getAppServiceProducerConfig(1);
  local config2 = common.getAppServiceProducerConfig(1, manifest2.serviceType);
  config.app_services[manifest2.serviceType] = config2.app_services[manifest2.serviceType];

  tbl.policy_table.app_policies[common.getConfigAppParams(1).fullAppID] = config;
end

--[[ Local Functions ]]

local function processRPCRejected(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)

  mobileSession:ExpectNotification("OnSystemCapabilityUpdated"):Times(0)
  mobileSession:ExpectResponse(cid, rejectedResponse)

  EXPECT_HMINOTIFICATION("BasicCommunication.OnSystemCapabilityUpdated"):Times(0)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI", common.registerApp)
runner.Step("PTU", common.policyTableUpdate, { PTUfunc })
runner.Step("Activate App", common.activateApp)
runner.Step("Publish App Service", common.publishMobileAppService, { manifest })

runner.Title("Test")
runner.Step("RPC " .. rpc.name .. "_resultCode_SUCCESS", processRPCRejected)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)

