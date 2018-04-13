---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0037-Expand-Mobile-putfile-RPC.md
-- User story:TBD
-- Use case:TBD
--
-- Requirement summary:
-- TBD
--
-- Description:
-- In case: SDL reveives SystemRequest and on SystemRequest with requestType = HTTP and requestSubType
-- SDL does: ignore requestSubType and process messages as usual
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/Expanded_proprietary_data_exchange/commonDataExchange')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local usedFile = "./files/action.png"
local params = {
  requestType = "HTTP",
  requestSubType = "SomeSubType",
  fileName = "action.png"
}

local function systemRequest(pParams, pFile)
  local mobSession = common.getMobileSession()
  local cid = mobSession:SendRPC("SystemRequest", pParams, pFile)
  if pParams.fileName then pParams.fileName = "/tmp/fs/mp/images/ivsu_cache/" .. pParams.fileName end
  EXPECT_HMICALL("BasicCommunication.SystemRequest",pParams)
  :Times(0)
  mobSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerApp)

runner.Title("Test")
runner.Step("SystemRequest with request type OEM_SPECIFIC", systemRequest, {params, usedFile})
runner.Step("OnSystemRequest with request type OEM_SPECIFIC", common.onSystemRequest, {params})

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
