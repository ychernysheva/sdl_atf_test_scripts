---------------------------------------------------------------------------------------------
-- Script verifies issue https://github.com/SmartDeviceLink/sdl_core/issues/1772
-- 1. Make sure SDL is built with PROPRIETARY flag
-- 2. Start SDL and HMI, first ignition cycle
-- 3. Connect device
-- Steps:
-- 1. Register new application
-- 2. Perform PTU with updated default section(can use attached file ptu.json)
-- Expected result:
-- SDL performs update and sends OnPermissionsChange to mobile app with updated permissions.
-- DB has updated info.
-- Actual result:
-- SDL sends to HMI UP_TO_DATE status, but does not update permissions internally.
-- DB is not updated according to new permissions.
-- SDL does not send OnPermissionsChange to mobile app with new permissions.
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonDefects = require('test_scripts/Defects/4_5/commonDefects')

--[[ Local Functions ]]
local function ptuUpdateFunc(tbl)
  local VDgroup = {
    rpcs = {
      GetVehicleData = {
        hmi_levels = { "BACKGROUND", "FULL", "LIMITED" },
        parameters = { "gps" }
      }
    }
  }
  tbl.policy_table.functional_groupings["NewTestCaseGroup"] = VDgroup
  tbl.policy_table.app_policies.default.groups = { "Base-4", "NewTestCaseGroup" }
  tbl.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID] = nil
end

local function GetVD(self)
  local cid = self.mobileSession1:SendRPC("GetVehicleData", { gps = true })
  EXPECT_HMICALL("VehicleInfo.GetVehicleData")
  :Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonDefects.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonDefects.start)
runner.Step("RAI, PTU", commonDefects.rai_ptu, { ptuUpdateFunc })
runner.Step("Activate App", commonDefects.activate_app)

runner.Title("Test")
runner.Step("GetVD_requet_is_success", GetVD)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonDefects.postconditions)
