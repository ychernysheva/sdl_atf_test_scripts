---------------------------------------------------------------------------------------------------
--  Precondition: 
--  1) Application with <appID> is registered on SDL.
--
--  Steps:
--  1) Application triggers a PTU which includes a new enabled cloud application
--
--  Expected:
--  1) SDL sends an UpdateAppList message with the new cloud application
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/CloudAppRPCs/commonCloudAppRPCs')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Variables ]]
local appID = "0000002"

local function updatePTU(tbl)
  tbl.policy_table.app_policies[appID] = common.getCloudAppConfig(2)
end

local function checkUpdateAppList(self)
  EXPECT_HMINOTIFICATION("BasicCommunication.UpdateAppList"):Times(AnyNumber())
  :ValidIf(function(_,data)
    if #data.params.applications ~= 0 then
      for i=1,#data.params.applications do
        local app = data.params.applications[i]
        print("APP: " .. app.policyAppID)
        if app.policyAppID == appID then
          return app.isCloudApplication and app.cloudConnectionStatus == "NOT_CONNECTED"
        end
      end
      print(" \27[36m Application was not found in application array \27[0m")
    else
      print(" \27[36m Application array in BasicCommunication.UpdateAppList was empty \27[0m")
    end
    return false
  end)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI", common.registerAppWOPTU, { 1 })

runner.Title("Test")
runner.Step("Check UpdateAppList", common.policyTableUpdate, { updatePTU, checkUpdateAppList })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)

