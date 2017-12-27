---------------------------------------------------------------------------------------------------
-- Issue: https://github.com/SmartDeviceLink/sdl_core/issues/1921
-- Precondition:
-- 1. SDL and HMI are started.
-- 2. App is registered.
-- Steps:
-- 1. SDL received UpdatedPT with at least one <unknown_parameter> or <unknown_RPC>
-- and after cutting off <unknown_parameter> or <unknown_RPC> UpdatedPT is invalid
-- Expected result: SDL must log the error internally and discard Policy Table Update
-- Actual result:N/A
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonDefects = require('test_scripts/Defects/4_5/commonDefects')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local json = require("modules/json")

--[[ Local Functions ]]
local isError
local ErrorMessage
-- Path to policy table snapshot
local pathToPTS = commonFunctions:read_parameter_from_smart_device_link_ini("SystemFilesPath") .. "/"
.. commonFunctions:read_parameter_from_smart_device_link_ini("PathToSnapshot")

--[[ Local Functions ]]
--[[ @ptsToTable: decode snapshot from json to table
--! @parameters:
--! pts_f - file for decode
--! @return: created table from file
--]]
local function ptsToTable(pts_f)
  local f = io.open(pts_f, "r")
  local content = f:read("*all")
  f:close()
  return json.decode(content)
end

--[[ @ptuUpdateFunc: update table for PTU
--! @parameters:
--! tbl - table for update
--! @return: none
--]]
local function ptuUpdateFunc(tbl)
  local VDgroup = {
    rpcs = {
      GetVehicleData = {
        hmi_levels = {"BACKGROUND", "FULL", "LIMITED"},
        parameters = {"gps", "newParameter"}
      },
      SubscribeVehicleData = {
        hmi_levels = {"BACKGROUND", "FULL", "LIMITED"},
      },
      UnknownAPI = {
        hmi_levels = {"BACKGROUND", "FULL", "LIMITED"},
        parameters = {"gps"}
      },
      SendLocation = {
        hmi_levels = {"BACKGROUND", "FULL", "LIMITED"}
      }
    }
  }
  tbl.policy_table.functional_groupings["NewTestCaseGroup"] = VDgroup
  tbl.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID].groups =
  {"Base-4", "NewTestCaseGroup"}
end

--[[ @NotValidPtuUpdateFunc: update table for PTU with invalid content
--! @parameters:
--! tbl - table for update
--! @return: none
--]]
local function NotValidPtuUpdateFunc(tbl)
  local VDgroup = {
    rpcs = {
      GetVehicleData = {
        hmi_levels = {"BACKGROUND", "FULL", "LIMITED"},
        parameters = {"gps", "newParameter"}
      },
      SubscribeVehicleData = {
        hmi_levels = {"BACKGROUND", "FULL", "LIMITED"},
      },
      UnknownAPI = {
        hmi_levels = {"BACKGROUND", "FULL", "LIMITED"},
        parameters = {"gps"}
      },
      SendLocation = {
        -- missed mandatory hmi_levels parameter
      }
    }
  }
  tbl.policy_table.functional_groupings["NewTestCaseGroup"] = VDgroup
  tbl.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID].groups =
  {"Base-4", "NewTestCaseGroup"}
end

--[[ @ErrorOccurred: set error status and write Error message
--! @parameters:
--! Message - Error message
--! @return: none
--]]
local function ErrorOccurred(Message)
  isError = true
  ErrorMessage = ErrorMessage .. Message
end

--[[ @CheckCuttingUnknowValues: Perform app registration, PTU and check absence of unknown values in
--! OnPermissionsChange notification
--! @parameters:
--! self - test object
--! @return: none
--]]
local function CheckCuttingUnknowValues(self)
  commonDefects.rai_ptu_n_without_OnPermissionsChange(1, ptuUpdateFunc,self)
  self.mobileSession1:ExpectNotification("OnPermissionsChange")
  :Times(2)
  :ValidIf(function(_,data)
      isError = false
      ErrorMessage = ""
      if #data.payload.permissionItem ~= 0 then
        for i=1, #data.payload.permissionItem do
          if data.payload.permissionItem[i].rpcName == "UnknownAPI" then
            ErrorOccurred(" OnPermissionsChange contains unknown_RPC value.\n")
          end
          if data.payload.permissionItem[i].parameterPermissions.allowed["newParameter"] or
          data.payload.permissionItem[i].parameterPermissions.userDisallowed["newParameter"] then
            ErrorOccurred(" OnPermissionsChange contains unknown_parameter value.\n")
          end
        end
      else
        ErrorOccurred("OnPermissionsChange is not contain permissionItem elements")
      end
      if isError == true then
        return false, ErrorMessage
      else
        return true
      end
    end)
end

--[[ @removeSnapshotAndTriggerPTUFromHMI: Remove snapshot and trigger PTU from HMI for creation new snapshot,
--! check absence of unknown parameters in snapshot
--! @parameters:
--! self - test object
--! @return: none
--]]
local function removeSnapshotAndTriggerPTUFromHMI(self)
  -- remove Snapshot
  os.execute("rm -f " .. pathToPTS)
  -- expect PolicyUpdate request on HMI side
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate", { file = pathToPTS })
  :Do(function()
      if (commonSteps:file_exists(pathToPTS) == false) then
        self:FailTestCase(pathToPTS .. " is not created")
      else
        local isErrorInvalidPT = false
        local ErrorMessageInvalidPT = ""
        local pts = ptsToTable(pathToPTS)
        local isUnknownAPI = pts.policy_table.functional_groupings.NewTestCaseGroup.rpcs["UnknownAPI"]
        local isnewParameter = pts.policy_table.functional_groupings.NewTestCaseGroup.rpcs.GetVehicleData.parameters["newParameter"]
        if isUnknownAPI then
          isErrorInvalidPT = true
          ErrorMessageInvalidPT = ErrorMessageInvalidPT .. "Snapshot contains UnknownAPI\n"
        end
        if isnewParameter then
          isErrorInvalidPT = true
          ErrorMessageInvalidPT = ErrorMessageInvalidPT .. "Snapshot contains newParameter for GetVehicleData RPC\n"
        end
        if isErrorInvalidPT == true then
          self:FailTestCase(ErrorMessageInvalidPT)
        end
      end
    end)
  -- Sending OnPolicyUpdate notification form HMI
  self.hmiConnection:SendNotification("SDL.OnPolicyUpdate", { })
  -- Expect OnStatusUpdate notifications on HMI side
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate",
    { status = "UPDATE_NEEDED" }, { status = "UPDATING" })
  :Times(2)
end

--[[ @InvalidPTAfterCutingUnknownValues: Unsuccessful policy table update
--! @parameters:
--! self - test object
--! @return: none
--]]
local function InvalidPTAfterCutingUnknownValues(self)
  commonDefects.UnsuccessPTU(NotValidPtuUpdateFunc,self)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonDefects.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonDefects.start)

runner.Title("Test")
runner.Step("Check_cutting_unknown_values_from_PT", CheckCuttingUnknowValues)
runner.Step("Remove Snapshot and trigger PTU, check new created PTS", removeSnapshotAndTriggerPTUFromHMI)
runner.Step("Invalid_PTU_after_cuting_unknown_values", InvalidPTAfterCutingUnknownValues)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonDefects.postconditions)
