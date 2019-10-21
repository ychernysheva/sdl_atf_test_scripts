-----------------------------------------------------------------------------------------------------------------------
-- Proposal:
-- https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0211-ServiceStatusUpdateToHMI.md
-----------------------------------------------------------------------------------------------------------------------
-- Description: Opening of the non-protected Audio/Video/RPC service with successful OnServiceUpdate notification
--
-- Preconditions:
-- 1) SDL certificate is missing/expired
-- 2) App is registered with NAVIGATION appHMIType and activated
-- Steps:
-- 1) App sends StartService request (<service_type>, encryption = false)
-- SDL does:
--   - send OnServiceUpdate (<service_type>, REQUEST_RECEIVED) to HMI
--   - not send GetSystemTime() request to HMI
--   - not start PTU sequence
--   - send OnServiceUpdate (<service_type>, REQUEST_ACCEPTED) to HMI
--   - send StartServiceACK(<service_type>, encryption = false) to App
-- 2) App sends start stream
-- SDL does:
--  - send Navigation.StartStream request to HMI
-- 3) HMI sends Navigation.StartStream (REJECTED, Ignored by USER!")
-- SDL does:
--   - not send Navigation.StartStream request to HMI
-----------------------------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/API/ServiceStatusUpdateToHMI/common')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
common.serviceData = {
  [11] = {
    forceCode = "0x0B",
    serviceType = "VIDEO",
    startStreamFunc = function()
      common.getHMIConnection():ExpectRequest("Navigation.StartStream")
      :Do(function(_, data)
        common.getHMIConnection():SendError(data.id, data.method, "REJECTED", "Ignored by USER!")
      end)
    end
  }
}

function common.startServiceFunc(pServiceId)
  local msg = {
    frameType = common.const.FRAME_TYPE.CONTROL_FRAME,
    serviceType = pServiceId,
    frameInfo = common.const.FRAME_INFO.START_SERVICE,
    encryption = false
  }
  common.getMobileSession():Send(msg)
end

function common.policyTableUpdateFunc()
  common.getHMIConnection():ExpectNotification("SDL.OnStatusUpdate")
  :Times(0)
end

function common.onServiceUpdateFunc(pServiceTypeValue)
  common.getHMIConnection():ExpectNotification("BasicCommunication.OnServiceUpdate",
    { serviceEvent = "REQUEST_RECEIVED", serviceType = pServiceTypeValue, appID = common.getHMIAppId() },
    { serviceEvent = "REQUEST_ACCEPTED", serviceType = pServiceTypeValue, appID = common.getHMIAppId() })
  :Times(2)
end

function common.serviceResponseFunc(pServiceId)
  common.getMobileSession():ExpectControlMessage(pServiceId, {
    frameInfo = common.const.FRAME_INFO.START_SERVICE_ACK,
    encryption = false
  })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerApp)
runner.Step("PolicyTableUpdate", common.policyTableUpdate)
runner.Step("App activation", common.activateApp)

runner.Title("Test")
runner.Step("User canceling start video stream", common.startServiceWithOnServiceUpdate, { 11, 0, 0 })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
