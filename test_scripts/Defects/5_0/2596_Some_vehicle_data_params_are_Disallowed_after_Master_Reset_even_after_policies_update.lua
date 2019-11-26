---------------------------------------------------------------------------------------------------
-- User story: https://github.com/SmartDeviceLink/sdl_core/issues/2596
-- Description:
-- Some vehicle data params are Disallowed after Master Reset even after policies update (1586634)
-- Preconditions:
-- 1) Clear environment
-- 2) SDL started, HMI and Mobile connected
-- 3) Application is registered and activated
-- Steps:
-- 1) App requests "GetVehicleData" RPC
-- SDl does:
--  a) send response with resultCode = "DISALLOWED" to the app
-- 2) Perform PTU
-- 3) App requests "GetVehicleData" RPC
-- SDl does:
--  a) send response with resultCode = "SUCCESS" to the app
-- 4) Perform Master Reset
-- SDL does:
--  a) send BC.OnExitAllApplications with reason = "MASTER_RESET"
-- 5) Clean mobile session
-- 6) Start SDL, HMI, mobile session
-- 7) Application is registered and activated
-- 8) App requests "GetVehicleData" RPC
-- SDl does:
--  a) send response with resultCode = "DISALLOWED" to the app
-- 9) Perform PTU
-- 10) App requests "GetVehicleData" RPC
-- SDl does:
--  a) send response with resultCode = "SUCCESS" to the app
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('user_modules/sequences/actions')
local utils = require('user_modules/utils')
local test = require("user_modules/dummy_connecttest")

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
local function ptuFunc(tbl)
	tbl.policy_table.app_policies[common.getConfigAppParams().fullAppID].groups = {
		"Base-4", "Location-1", "DrivingCharacteristics-3", "VehicleInfo-3", "Emergency-1"
	}
end

local function masterReset()
	common.getHMIConnection():SendNotification("BasicCommunication.OnExitAllApplications", {reason = "MASTER_RESET"})
	common.getMobileSession():ExpectNotification("OnAppInterfaceUnregistered", { reason = "MASTER_RESET" })
	common.getHMIConnection():ExpectNotification("BasicCommunication.OnAppUnregistered", { unexpectedDisconnect = false })
	utils.wait(2000)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")
  :Do(function()
		StopSDL()
  end)
end

local function cleanMobileSession(pAppId)
	if not pAppId then pAppId = 1 end
	test.mobileSession[pAppId] = nil
end

local function getVehicleDataDisallowed()
	local cid = common.getMobileSession():SendRPC("GetVehicleData", { prndl = true })
	common.getHMIConnection():ExpectRequest("VehicleInfo.GetVehicleData")
	:Times(0)

	common.getMobileSession():ExpectResponse(cid, { success = false, resultCode = "DISALLOWED" })
end

local function getVehicleDataAllowed()
	local cid = common.getMobileSession():SendRPC("GetVehicleData", { prndl = true })
	common.getHMIConnection():ExpectRequest("VehicleInfo.GetVehicleData", { prndl = true })
		:Do(function(_, data)
			common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", { prndl = "PARK" } )
	  end)
	common.getMobileSession():ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI", common.registerApp)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")
runner.Step("Get Vehicle Data disallowed", getVehicleDataDisallowed)
runner.Step("PTU", common.policyTableUpdate, { ptuFunc })
runner.Step("Get Vehicle Data allowed", getVehicleDataAllowed)
runner.Step("Master Reset", masterReset)
runner.Step("Clean Mobile session", cleanMobileSession)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI", common.registerApp)
runner.Step("Activate App", common.activateApp)
runner.Step("Get Vehicle Data disallowed", getVehicleDataDisallowed)
runner.Step("PTU", common.policyTableUpdate, { ptuFunc })
runner.Step("Get Vehicle Data allowed", getVehicleDataAllowed)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
