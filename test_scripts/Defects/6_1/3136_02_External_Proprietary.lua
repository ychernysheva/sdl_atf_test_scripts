---------------------------------------------------------------------------------------------------
-- Issue: https://github.com/smartdevicelink/sdl_core/issues/3136
--
-- Description: Successful 2nd PTU if it's triggered within failed retry for the 1st PTU
-- Note: script is applicable for EXTERNAL_PROPRIETARY policy flow
--
-- Preconditions:
-- 1) SDL and HMI are started
-- 2) App_1 is registered
-- SDL does:
--  - start PTU sequence
--
-- Steps:
-- 1) App_1 doesn't provide PTU update
-- 2) App_2 is registered within PTU retry sequence
-- SDL does:
--  - postpone new PTU sequence until the previous one is finished
-- 3) App_1 still doesn't provide PTU update
-- SDL does:
--  - finish 1st PTU retry sequence with `UPDATE_NEEDED` status
--  - start new PTU sequence with `UPDATE_NEEDED` status and send `BC.PolicyUpdate` request to HMI
-- 4) Mobile provides valid PTU update
-- SDL does:
--  - finish 2nd PTU sequence successfully with `UP_TO_DATE` status
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require("user_modules/sequences/actions")
local utils = require("user_modules/utils")
local color = require("user_modules/consts").color

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false
runner.testSettings.restrictions.sdlBuildOptions = { { extendedPolicy = { "EXTERNAL_PROPRIETARY" } } }

--[[ Local Variables ]]
local secondsBetweenRetries = { 1, 2 }
local timeout_after_x_seconds = 4

--[[ Local Functions ]]
local function log(...)
  local str = "[" .. atf_logger.formated_time(true) .. "]"
  for i, p in pairs({...}) do
    local delimiter = "\t"
    if i == 1 then delimiter = " " end
    str = str .. delimiter .. p
  end
  utils.cprint(color.magenta, str)
end

local function updatePreloadedTimeout(pTbl)
  pTbl.policy_table.module_config.timeout_after_x_seconds = timeout_after_x_seconds
  pTbl.policy_table.module_config.seconds_between_retries = secondsBetweenRetries
end

local function updatePreloaded(pUpdFunc)
  local preloadedTable = common.sdl.getPreloadedPT()
  preloadedTable.policy_table.functional_groupings["DataConsent-2"].rpcs = common.json.null
  pUpdFunc(preloadedTable)
  common.sdl.setPreloadedPT(preloadedTable)
end

local function checkPTUStatus(pExpStatus)
  local cid = common.hmi.getConnection():SendRequest("SDL.GetStatusUpdate")
  common.hmi.getConnection():ExpectResponse(cid, { result = { status = pExpStatus }})
end

local function sendOnSystemRequest()
  common.hmi.getConnection():SendNotification("BasicCommunication.OnSystemRequest",
    { requestType = "PROPRIETARY", fileName = "files/ptu.json" })
  log("HMI->SDL:", "BC.OnSystemRequest")
end

local function unsuccessfulPTUviaMobile()
  sendOnSystemRequest()
  local timeout = 60000
  common.mobile.getSession():ExpectNotification("OnSystemRequest", { requestType = "PROPRIETARY" })
  :Do(function(_, data)
      log("SDL->MOB1:", "OnSystemRequest", data.payload.requestType)
    end)
  :Times(4)
  :Timeout(timeout)

  local isBCPUReceived = false
  common.hmi.getConnection():ExpectRequest("BasicCommunication.PolicyUpdate")
  :Do(function(_, data)
      log("SDL->HMI:", "BC.PolicyUpdate")
      isBCPUReceived = true
      common.hmi.getConnection():SendResponse(data.id, data.method, "SUCCESS", { })
      log("HMI->SDL:", "SUCCESS BC.PolicyUpdate")
    end)
  :Timeout(timeout)

  local exp = {
    { status = "UPDATING" },
    { status = "UPDATE_NEEDED" },
    { status = "UPDATING" },
    { status = "UPDATE_NEEDED" },
    { status = "UPDATING" },
    { status = "UPDATE_NEEDED" },
    { status = "UPDATING" },
    { status = "UPDATE_NEEDED" },
    { status = "UPDATE_NEEDED" } -- new PTU sequence
  }
  common.hmi.getConnection():ExpectNotification("SDL.OnStatusUpdate", table.unpack(exp))
  :Times(#exp)
  :Timeout(timeout)
  :Do(function(e, data)
      log("SDL->HMI:", "SDL.OnStatusUpdate(" .. data.params.status .. ")")
      if data.params.status == "UPDATE_NEEDED" and e.occurences < #exp - 2 then
        common.run.runAfter(sendOnSystemRequest, 1000)
      end
      if e.occurences == 1 then
        checkPTUStatus("UPDATING")
        common.sdl.deletePTS()
      end
      if e.occurences == 2 then
        common.app.registerNoPTU(2)
        log("SDL->MOB2:", "RAI2")
      end
    end)
    :ValidIf(function(e)
      if e.occurences == #exp and isBCPUReceived == true then
        return false, "BC.PolicyUpdate is sent before new PTU sequence"
      end
      if e.occurences == #exp - 2 and common.sdl.getPTS() ~= nil then
        return false, "PTS was created before new PTU sequence"
      end
      return true
    end)
end

local function policyTableUpdate()
  if common.sdl.getPTS == nil then
    common.run.fail("PTS was not created within new PTU sequence")
  end
  local function expNotifFunc()
    common.hmi.getConnection():ExpectRequest("VehicleInfo.GetVehicleData", { odometer = true })
    common.hmi.getConnection():ExpectNotification("SDL.OnStatusUpdate",
      { status = "UPDATING" }, { status = "UP_TO_DATE" })
    :Times(2)
  end
  common.ptu.policyTableUpdate(nil, expNotifFunc)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Preloaded update with retry parameters", updatePreloaded, { updatePreloadedTimeout })
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)

runner.Title("Test")
runner.Step("Register App", common.app.register)
runner.Step("Activate App", common.app.activate)
runner.Step("Unsuccessful PTU via a mobile device", unsuccessfulPTUviaMobile)

runner.Step("Successful PTU via Mobile", policyTableUpdate)
runner.Step("Check PTU status UP_TO_DATE", checkPTUStatus, { "UP_TO_DATE" })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
