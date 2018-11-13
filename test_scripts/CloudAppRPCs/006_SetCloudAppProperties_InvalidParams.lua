---------------------------------------------------------------------------------------------------
--  Precondition: 
--  1) Application with <appID> is registered on SDL.
--  2) Specific permissions are assigned for <appID> with SetCloudAppProperties
--
--  Steps:
--  1) Application sends a SetCloudAppProperties RPC request
--
--  Expected:
--  1) SDL responds to mobile app with "ResultCode: SUCCESS,
--        success: true
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
    hybridAppPreference = "CORE"
  }
}


--[[ Local Functions ]]
local function processRPCSuccess(self)
  local mobileSession = common.getMobileSession(self, 1)
  local cid = mobileSession:SendRPC(rpc.name, rpc.params)

  local responseParams = {}
  responseParams.success = false
  responseParams.resultCode = "INVALID_DATA"
  mobileSession:ExpectResponse(cid, responseParams)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI with PTU", common.registerAppWithPTU)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
runner.Step("RPC " .. rpc.name .. "_resultCode_INVALID_DATA", processRPCSuccess)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
