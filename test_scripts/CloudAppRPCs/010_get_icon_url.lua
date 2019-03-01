---------------------------------------------------------------------------------------------------
--  Precondition: 
--  1) Application with <appID> is registered on SDL.
--  2) Specific permissions are assigned for a cloud app with an icon_url
--
--  Steps:
--  1) Core sends a systemRequest type = ICONURL
--  2) Mobile responds with image data in a SystemRequest ICON_URL
--
--  Expected:
--  1) SDL responds to mobile app with "ResultCode: SUCCESS,
--        success: true
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/CloudAppRPCs/commonCloudAppRPCs')

--[[ Local Variables ]]
local cloud_app_id = "cloudAppID123"
config.application1.registerAppInterfaceParams.syncMsgVersion.majorVersion = 5
config.application1.registerAppInterfaceParams.syncMsgVersion.minorVersion = 1

--[[ Local Functions ]]
local function PTUfunc(tbl)
    params = {
        keep_context = false,
        steal_focus = false,
        priority = "NONE",
        default_hmi = "NONE",
        groups = {"Base-4"},
        RequestType = {},
        RequestSubType = {},
        hybrid_app_preference = "CLOUD",
        endpoint = "ws://192.168.1.1:3000/",
        enabled = true,
        cloud_transport_type = "WS",
        icon_url = "https://fakeurl1234512345.com",
        nicknames = {"CloudApp"}
    }
    
    tbl.policy_table.app_policies[cloud_app_id] = params
end

local rpc = {
    name = "SystemRequest",
    params = {
        requestType = "ICON_URL", fileName = "https://fakeurl1234512345.com"
    }
}

local icon_image_path = "files/icon.png"

local function processRPCSuccess(self)
    local mobileSession = common.getMobileSession(self, 1)
    local cid = mobileSession:SendRPC(rpc.name, rpc.params, icon_image_path)
    EXPECT_HMICALL("BasicCommunication." .. "UpdateAppList")
    :Do(function(_, data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS")
      end)
    local responseParams = {}
    responseParams.success = true
    responseParams.resultCode = "SUCCESS"
    mobileSession:ExpectResponse(cid, responseParams)
  end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)

runner.Title("Test")
runner.Step("OnSystemRequest ICON_URL Post PTU", common.registerAppWithPTUExpectIconURL, {nil, PTUfunc})
runner.Step("Send App Icon SystemRequest", processRPCSuccess)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
