---------------------------------------------------------------------------------------------------
-- Proposal:
-- User story: TBD
-- Use case: TBD
--
-- Requirement summary: TBD
--
-- Description:
-- In case:
-- 1. App is subscribed to all modules
-- 2. Transport disconnect and reconnect are performed
-- 3. App starts registration with actual hashId after unexpected disconnect
-- SDL does:
-- 1. send RC.GetInteriorVD(subscribe=true) to HMI during resumption data for all modules
-- 2. respond RAI(SUCCESS) to mobile app
-- 3. update hashId after successful resumption
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/Resumption/InteriorVehicleData/commonResumptionsInteriorVD')
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
local function checkResumptionData()
  local actualModuled = { }
  EXPECT_HMICALL("RC.GetInteriorVehicleData")
  :Do(function(_, data)
      common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS",
        { moduleData = common.getModuleControlData(data.params.moduleType), isSubscribed = true })
    end)
  :ValidIf(function(exp, data)
    table.insert(actualModuled, data.params.moduleType)
    if exp.occurences == #common.modules then
      if commonFunctions:is_table_equal(actualModuled, common.modules) == false then
        local errorMessage = "Not all modules are resumed.\n" ..
          "Actual result:" .. common.tableToString(actualModuled) .. "\n" ..
          "Expected result:" .. common.tableToString(common.modules) .."\n"
        return false, errorMessage
      end
    end
    return true
  end)
  :Times(#common.modules)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("App registration", common.registerAppWOPTU)
runner.Step("App activation", common.activateApp)
for _, mod in pairs(common.modules) do
  runner.Step("Add interiorVD subscription for " .. mod, common.GetInteriorVehicleData, { mod, true, 1, 1 })
end

runner.Title("Test")
runner.Step("Unexpected disconnect", common.unexpectedDisconnect)
runner.Step("Connect mobile", common.connectMobile)
runner.Step("Reregister App resumption data", common.reRegisterApp,
  { 1, checkResumptionData, common.resumptionFullHMILevel})
for _, mod in pairs(common.modules) do
  runner.Step("Check subscription with OnInteriorVD " .. mod, common.onInteriorVD, { 1, mod, 1})
  runner.Step("Check subscription with GetInteriorVD(false) for " .. mod, common.GetInteriorVehicleData, { mod, false, 1, 1 })
end

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
