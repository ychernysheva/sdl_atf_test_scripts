---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0105-remote-control-seat.md
-- User story:
-- Use case:
-- Item:
--
-- Description: TRS: GetInteriorVehicleData, #2
-- In case:
-- 1) RC app sends valid and allowed-by-policies GetInteriorVehicleData_request without "subscribe" parameter
-- 2) and SDL gets GetInteriorVehicleData_response with resultCode: <"any-result">
-- 3) and with "isSubscribed" parameter from HMI
-- SDL must:
-- 1) transfer GetInteriorVehicleData_response with resultCode: <"any-result">
-- and with "isSubscribed" param to the related app
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonRC = require('test_scripts/RC/commonRC')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
local function getDataForModule(pModuleType, isSubscriptionActive, pHMIrequestCount)
  local mobileSession = common.getMobileSession()
  local cid = mobileSession:SendRPC("GetInteriorVehicleData", {
      moduleType = pModuleType
      -- no subscribe parameter
    })

  EXPECT_HMICALL("RC.GetInteriorVehicleData", {
      moduleType = pModuleType
    })
  :Do(function(_, data)
      common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {
          moduleData = common.getModuleControlDataForResponse(pModuleType),
          isSubscribed = isSubscriptionActive -- return current value of subscription
        })
    end)
  :ValidIf(function(_, data) -- no subscribe parameter
      if (isSubscriptionActive and data.params.subscribe == false) or data.params.subscribe == nil then
        return true
      end
      return false, 'Parameter "subscribe" is transfered with to HMI value: ' .. tostring(data.params.subscribe)
    end)
  :Times(pHMIrequestCount)

  mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS",
      moduleData = common.getModuleControlDataForResponse(pModuleType),
      isSubscribed = isSubscriptionActive
    })
end


--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonRC.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonRC.start)
runner.Step("RAI", commonRC.registerAppWOPTU)
runner.Step("Activate App", commonRC.activateApp)

runner.Title("Test")
runner.Step("GetInteriorVehicleData SEAT NoSubscription", getDataForModule, { "SEAT", false, 1 })
runner.Step("Subscribe app to SEAT", commonRC.subscribeToModule, { "SEAT" })
runner.Step("GetInteriorVehicleData SEAT ActiveSubscription_subscribe", getDataForModule, { "SEAT", true, 1 })

runner.Title("Postconditions")
runner.Step("Stop SDL", commonRC.postconditions)
