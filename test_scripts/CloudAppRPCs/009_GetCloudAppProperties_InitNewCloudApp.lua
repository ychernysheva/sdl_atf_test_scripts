---------------------------------------------------------------------------------------------------
--  Precondition: 
--  1) Application with <appID> is registered on SDL.
--  2) Specific permissions are assigned for <appID> with SetCloudAppProperties
--
--  Steps:
--  1) Application sends a SetCloudAppProperties RPC request(with app_id which does not currently exist in policy table)
--  2) Application triggers a PTU
--  3) Checks policy table to make sure cloud app properties are set correctly
--  4) Application sends a GetCloudAppProperties RPC request to verify changes
--
--  Expected:
--  1) SDL responds to mobile app with "ResultCode: SUCCESS,
--        success: true
--  2) VerifyCloudAppProperties succeeds
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/CloudAppRPCs/commonCloudAppRPCs')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local rpc = {
  name = "SetCloudAppProperties",
  params = {
    properties = {
        nicknames = { "TestApp" },
        appID = "232",
        enabled = true,
        authToken = "ABCD12345",
        cloudTransportType = "WSS",
        hybridAppPreference = "CLOUD",
        endpoint = "ws://127.0.0.1:8080/"
    }
  }
}
local expected = {
  auth_token = "ABCD12345",
  cloud_transport_type = "WSS",
  enabled = "true",
  hybrid_app_preference = "CLOUD"
}

local get_rpc = {
    name = "GetCloudAppProperties",
    params = {
      appID = "231"
    }
}

local get_expected = {
    authToken = "ABCD12345",
    cloudTransportType = "WSS",
    enabled = true,
    hybridAppPreference = "CLOUD"
}

--[[ Local Functions ]]
local function processRPCSuccess()
  local mobileSession = common.getMobileSession(1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)

  local responseParams = {}
  responseParams.success = true
  responseParams.resultCode = "SUCCESS"
  mobileSession:ExpectResponse(cid, responseParams)
end

local function processGetRPCFailure()
    local mobileSession = common.getMobileSession(1)
    local cid = mobileSession:SendRPC(get_rpc.name, get_rpc.params)
  
    local responseParams = {}
    responseParams.success = false
    responseParams.resultCode = "DATA_NOT_AVAILABLE"
    mobileSession:ExpectResponse(cid, responseParams)
end

local function verifyCloudAppProperties()
  local snp_tbl = common.GetPolicySnapshot()
  local app_id = rpc.params.properties.appID
  local result = {}

  result.auth_token = snp_tbl.policy_table.app_policies[app_id].auth_token
  common.test_assert(result.auth_token == expected.auth_token, "Incorrect auth token value")

  result.cloud_transport_type = snp_tbl.policy_table.app_policies[app_id].cloud_transport_type
  common.test_assert(result.cloud_transport_type == expected.cloud_transport_type, "Incorrect cloud_transport_type value")

  result.enabled = tostring(snp_tbl.policy_table.app_policies[app_id].enabled) 
  common.test_assert(result.enabled == expected.enabled, "Incorrect enabled value")

  result.hybrid_app_preference = snp_tbl.policy_table.app_policies[app_id].hybrid_app_preference
  common.test_assert(result.hybrid_app_preference == expected.hybrid_app_preference, "Incorrect hybrid_app_preference value")

end

local function PTUfunc(tbl)
  tbl.policy_table.app_policies[common.getConfigAppParams(1).fullAppID] = common.getCloudAppStoreConfig(1);
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI", common.registerApp)
runner.Step("PTU", common.policyTableUpdate, { PTUfunc })
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
runner.Step("RPC " .. rpc.name .. "_resultCode_SUCCESS(new_app_id)", processRPCSuccess)
runner.Step("Request PTU", common.Request_PTU)
runner.Step("Verify CloudApp Properties", verifyCloudAppProperties)
runner.Step("RPC " .. get_rpc.name .. "_resultCode_DATA_NOT_AVAILABLE", processGetRPCFailure)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)

