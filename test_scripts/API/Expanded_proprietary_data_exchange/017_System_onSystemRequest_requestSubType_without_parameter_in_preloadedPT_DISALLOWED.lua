---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0083-Expandable-design-for-proprietary-data-exchange.md
-- User story:TBD
-- Use case:TBD
--
-- Requirement summary:
-- TBD
--
-- Description:
-- In case:
-- 1. requestSubType is absent in PreloadedPT
-- 2. SDL receives the following messages with 'requestSubType' value:
--   'SystemRequest' request from mobile app
--   'OnSystemRequest' notification from HMI
-- SDL does:
-- 1. Respond with DISALLOWED to app
-- 2. Not transfer 'OnSystemRequest' notification to app
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/Expanded_proprietary_data_exchange/commonDataExchange')
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local utils = require('user_modules/utils')
local json = require("modules/json")

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local file = "./files/action.png"
local params = {
  requestType = "OEM_SPECIFIC",
  requestSubType = "someValue",
  fileName = "action.png"
}
local preloadedPT = commonFunctions:read_parameter_from_smart_device_link_ini("PreloadedPT")

--[[ Local Functions ]]
local function backupPreloadedPT()
  commonPreconditions:BackupFile(preloadedPT)
end

local function updatePreloadedPT()
  local preloadedFile = commonPreconditions:GetPathToSDL() .. preloadedPT
  local pt = utils.jsonFileToTable(preloadedFile)
  pt.policy_table.functional_groupings["DataConsent-2"].rpcs = json.null
  pt.policy_table.app_policies["default"].RequestSubType = nil
  utils.tableToJsonFile(pt, preloadedFile)
end

local function restorePreloadedPT()
  commonPreconditions:RestoreFile(preloadedPT)
end

local function systemRequest()
  local cid = common.getMobileSession():SendRPC("SystemRequest", params, file)
  EXPECT_HMICALL("BasicCommunication.SystemRequest")
  :Times(0)
  common.getMobileSession():ExpectResponse(cid, { success = false, resultCode = "DISALLOWED" })
end

local function onSystemRequest()
  common.getHMIConnection():SendNotification("BasicCommunication.OnSystemRequest", params)
  common.getMobileSession():ExpectNotification("OnSystemRequest")
  :Times(0)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Back-up PreloadedPT", backupPreloadedPT)
runner.Step("Update PreloadedPT", updatePreloadedPT)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerApp)

runner.Title("Test")
runner.Step("SystemRequest with requestSubType_DISALLOWED", systemRequest)
runner.Step("OnSystemRequest with requestSubType_no_transfer_to_app", onSystemRequest)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
runner.Step("Restore PreloadedPT", restorePreloadedPT)
