---------------------------------------------------------------------------------------------------
--  Precondition: 
--  1) Application with <appID> is registered on SDL.
--  2) Specific permissions are assigned for <appID> with SetCloudAppProperties
--
--  Steps:
--  1) Application sends a SetCloudAppProperties RPC request(with app_id which does not currently exist in policy table)
--  2) Application triggers a PTU
--  3) Checks policy table to make sure cloud app properties are set correctly
--
--  Expected:
--  1) SDL responds to mobile app with "ResultCode: SUCCESS,
--        success: true
--  2) VerifyCloudAppProperties succeeds
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/CloudAppRPCs/commonCloudAppRPCs')

--[[ Local Variables ]]
local rpc = {
  name = "SetCloudAppProperties",
  params = {
    appName = "TestApp",
    appID = "232",
    enabled = true,
    cloudAppAuthToken = "ABCD12345",
    cloudTransportType = "WSS",
    hybridAppPreference = "CLOUD"
  }
}
local expected = {
  auth_token = "ABCD12345",
  cloud_transport_type = "WSS",
  enabled = "true",
  hybrid_app_preference = "CLOUD"
}

--[[ Local Functions ]]
local function processRPCSuccess(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)

  local responseParams = {}
  responseParams.success = true
  responseParams.resultCode = "SUCCESS"
  mobileSession:ExpectResponse(cid, responseParams)
end

local function verifyCloudAppProperties(self)
  local snp_tbl = common.GetPolicySnapshot()
  local app_id = rpc.params.appID
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

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
runner.Step("RPC " .. rpc.name .. "_resultCode_SUCCESS(new_app_id)", processRPCSuccess)
runner.Step("Request PTU", common.Request_PTU)
runner.Step("Verify CloudApp Properties", verifyCloudAppProperties)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)

