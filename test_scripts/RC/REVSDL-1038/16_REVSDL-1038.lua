local commonPreconditions = require("user_modules/shared_testcases/commonPreconditions")
commonPreconditions:BackupFile("sdl_preloaded_pt.json")
commonPreconditions:ReplaceFile("sdl_preloaded_pt.json", "./test_scripts/RC/TestData/sdl_preloaded_pt.json")

	local commonSteps = require("user_modules/shared_testcases/commonSteps")
commonSteps:DeleteLogsFileAndPolicyTable()

revsdl = require("user_modules/revsdl")

revsdl.AddUnknownFunctionIDs()
revsdl.SubscribeToRcInterface()
config.ValidateSchema = false
config.application1.registerAppInterfaceParams.appHMIType = { "REMOTE_CONTROL" }

Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------
  --Begin Precondition.1. Need to be uncomment for checking Driver's device case
  --[[Description: Activation App by sending SDL.ActivateApp

    function Test:WaitActivation()

      --mobile side: Expect OnHMIStatus notification
      EXPECT_NOTIFICATION("OnHMIStatus")

      --hmi side: sending SDL.ActivateApp request
      local rid = self.hmiConnection:SendRequest("SDL.ActivateApp",
                            { appID = self.applications["Test Application"] })

      --hmi side: send request RC.OnSetDriversDevice
      self.hmiConnection:SendNotification("RC.OnSetDriversDevice",
      {device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

      --hmi side: Waiting for SDL.ActivateApp response
      EXPECT_HMIRESPONSE(rid)

    end]]
  --End Precondition.1

  -----------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------
-----------------------REVSDL-1038: HMI's RPCs validation rules------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

--NOTE: UPDATED "OnSetDriversDevice" to "OnDeviceRankChanged" base on REVSDL-1577
--=================================================BEGIN TEST CASES 16==========================================================--

  --Begin Test case ResponseFakeParamsNotification.16
  --Description:  --Fake params

    --Requirement/Diagrams id in jira:
        --REVSDL-1038

    --Verification criteria:
        --<17.>In case HMI sends a notification, expected by RSDL for internal processing, with one or more fake params (that is, non-existent per HMI_API) to RSDL, RSDL must cut these fake params off and process the notification
            --Information: applicable RPCs:
            --OnSetDriversDevice
            --OnReverseAppsAllowing

      --Begin Test case ResponseFakeParamsNotification.16.1
      --Description: send notification with fake params
              --NOTE: UPDATED "OnSetDriversDevice" to "OnDeviceRankChanged" base on REVSDL-1577
        function Test:OnSetDriversDevice_FakeParamsInsideDevice()

          -- --hmi side: sending RC.OnSetDriversDevice notification
          -- self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {
                  -- device = {
                    -- fake1 = true,
                    -- name = "127.0.0.1",
                    -- fake2 = {1},
                    -- id = 1,
                    -- isSDLAllowed = true,
                    -- fake3 = "   fake params   "
                  -- }
              -- })

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "DRIVER", fake1 = true, device = {name = "127.0.0.1", fake2 = {1}, id = 1, isSDLAllowed = true, fake3 = "   fake params   "}})

          --mobile side: SDL does not send fake params to mobile app
          EXPECT_NOTIFICATION("OnPermissionsChange")
          :Times(1)

        end
      --End Test case ResponseFakeParamsNotification.16.1

    -----------------------------------------------------------------------------------------

      --Begin Test case ResponseFakeParamsNotification.16.2
      --Description: send notification with fake params
              --NOTE: UPDATED "OnSetDriversDevice" to "OnDeviceRankChanged" base on REVSDL-1577
        function Test:OnSetDriversDevice_FakeParamsOutsideDevice()

          -- --hmi side: sending RC.OnSetDriversDevice notification
          -- self.hmiConnection:SendNotification("RC.OnSetDriversDevice", {
                  -- fake1 = {1},
                  -- device = {
                    -- name = "127.0.0.1",
                    -- id = 1,
                    -- isSDLAllowed = true
                  -- }
              -- })

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {fake0 = "ERROR", deviceRank = "PASSENGER", fake1 = true, device = {name = "127.0.0.1", fake2 = {1}, id = 1, isSDLAllowed = true, fake3 = "   fake params   "}})

          --mobile side: SDL does not send fake params to mobile app
          EXPECT_NOTIFICATION("OnPermissionsChange")
          :Times(1)

        end
      --End Test case ResponseFakeParamsNotification.16.2

    -----------------------------------------------------------------------------------------

      --Begin Test case ResponseFakeParamsNotification.16.3
      --Description: send notification with fake params
        function Test:OnReverseAppsAllowing_FakeParams()

          --hmi side: sending VehicleInfo.OnReverseAppsAllowing notification
          self.hmiConnection:SendNotification("VehicleInfo.OnReverseAppsAllowing", {allowed = true, isAllowed = false})

          --mobile side: Absence of notifications
          EXPECT_NOTIFICATION("OnPermissionsChange")
          :Times(1)

        end
      --End Test case ResponseFakeParamsNotification.16.3

  --End Test case ResponseFakeParamsNotification.16
--=================================================END TEST CASES 16==========================================================--

function Test:PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end