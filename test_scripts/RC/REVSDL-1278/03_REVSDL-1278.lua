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

--List of resultscode
local RESULTS_CODE = {"SUCCESS", "WARNINGS", "RESUME_FAILED", "WRONG_LANGUAGE"}

--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice
--groups_nonPrimaryRC Group
local arrayGroups_nonPrimaryRC = revsdl.arrayGroups_nonPrimaryRC()


--======================================REVSDL-1278=========================================--
---------------------------------------------------------------------------------------------
------------REVSDL-1278: HMILevel change for rc-apps from passenger's device ----------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--

--=================================================BEGIN TEST CASES 3==========================================================--
  --Begin Test suit CommonRequestCheck.3 for Req.#3

  --Description: 3. --An application with AppHMILevel "NONE" or "BACKGROUND"


  --Begin Test case CommonRequestCheck.3.1
  --Description:  --An application with AppHMIType "REMOTE_CONTROL"
            --An application with AppHMIType "REMOTE_CONTROL"
            --From passenger's device
            --Of NONE or BACKGROUND HMILevel sends an RPC
            --And this RPC is allowed by app's assigned policies
            --And this RPC is from "driver_allow" section (see REVSDL-966 for details)
            --And the driver accepted the permission prompt
            --RSDL must notify this app via OnHMIStatus (LIMITED, params) about assigned LIMITED HMILevel.

    --Requirement/Diagrams id in jira:
        --REVSDL-1278
        --TC: REVSDL-1328, REVSDL-1359

    --Verification criteria:
        --1. Assign LIMITED for passenger's rc-app - from NONE
        --2. Assign LIMITED for passenger's rc-app - from BACKGROUND

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.1.1
      --Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (NONE to LIMITED)
        function Test:TC2_NONEToLIMITED()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 0,
              rowspan = 2,
              col = 1,
              levelspan = 1,
              level = 0
            },
            moduleType = "RADIO",
            buttonPressMode = "LONG",
            buttonName = "VOLUME_UP"
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 0,
                    rowspan = 2,
                    col = 1,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect Buttons.ButtonPress request
              EXPECT_HMICALL("Buttons.ButtonPress",
                      {
                        zone =
                        {
                          colspan = 2,
                          row = 0,
                          rowspan = 2,
                          col = 1,
                          levelspan = 1,
                          level = 0
                        },
                        moduleType = "RADIO",
                        buttonPressMode = "LONG",
                        buttonName = "VOLUME_UP"
                      })
                :Do(function(_,data)
                  --hmi side: sending Buttons.ButtonPress response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                end)
          end)

          --Mobile side: RSDL sends OnHMIStatus (LIMITED,params)
          self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE"})

          self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.3.1.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.1.2
      --Description:
              --1. HMI sends to RSDL: BasicCommunication.OnExitApplication(USER_EXIT, appID)
              --2. RSDL returns to App_1: OnHMIStatus(NONE) notification.
        function Test:TC2_PreconditionNONE()

          --hmi side: HMI send BC.OnExitApplication to Rsdl.
          self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})

          --mobile side: Check that OnHMIStatus(NONE, deviceRank:Driver) sent by RSDL and received by App1
          self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
          :Timeout(5000)

        end
      --End Test case CommonRequestCheck.3.1.2

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.1.3
      --Description: application sends ButtonPress as Driver and ModuleType = RADIO, buttonPressMode = LONG (BACKGROUND)
        function Test:TC2_App1BACKGROUND()
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 0,
              rowspan = 2,
              col = 0,
              levelspan = 1,
              level = 0
            },
            moduleType = "RADIO",
            buttonPressMode = "LONG",
            buttonName = "VOLUME_UP"
          })

        --hmi side: expect Buttons.ButtonPress request
        EXPECT_HMICALL("Buttons.ButtonPress",
                {
                  zone =
                  {
                    colspan = 2,
                    row = 0,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  },
                  moduleType = "RADIO",
                  buttonPressMode = "LONG",
                  buttonName = "VOLUME_UP"
                })
          :Do(function(_,data)
            --hmi side: sending Buttons.ButtonPress response
            self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
          end)

          --Mobile side: RSDL sends OnHMIStatus (BACKGROUND,params)
          self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.3.1.3

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.1.4
      --Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (set BACKGROUND to LIMITED)
        function Test:TC2_BACKGROUNDToLIMITED()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 0,
              rowspan = 2,
              col = 1,
              levelspan = 1,
              level = 0
            },
            moduleType = "RADIO",
            buttonPressMode = "LONG",
            buttonName = "VOLUME_UP"
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 0,
                    rowspan = 2,
                    col = 1,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect Buttons.ButtonPress request
              EXPECT_HMICALL("Buttons.ButtonPress",
                      {
                        zone =
                        {
                          colspan = 2,
                          row = 0,
                          rowspan = 2,
                          col = 1,
                          levelspan = 1,
                          level = 0
                        },
                        moduleType = "RADIO",
                        buttonPressMode = "LONG",
                        buttonName = "VOLUME_UP"
                      })
                :Do(function(_,data)
                  --hmi side: sending Buttons.ButtonPress response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                end)
          end)

          --Mobile side: RSDL sends OnHMIStatus (LIMITED,params)
          self.mobileSession:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE"})

          self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.3.1.4

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.3.1
--=================================================END TEST CASES 3==========================================================--

function Test:PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end