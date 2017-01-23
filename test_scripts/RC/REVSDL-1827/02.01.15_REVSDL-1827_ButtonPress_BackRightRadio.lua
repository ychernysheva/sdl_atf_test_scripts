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


--======================================REVSDL-1827========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1827: Policies: "equipment" permissions must be checked-----------------
-------------------------- against location provided from HMI--------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


    -------------------------FOR BACK LEFT PASSENGER ZONE----------------------------------------

      --Begin Precondition.1. HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL (zone:BACK LEFT Passenger)
      --Description: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL

        function Test:ChangedLocation_Left()
          --hmi side: HMI sends notification RC.OnDeviceLocationChanged(<deviceID>) to RSDL
          self.hmiConnection:SendNotification("RC.OnDeviceLocationChanged",
            {device = {name = "127.0.0.1", id = 1, isSDLAllowed = true},
              deviceLocation =
                {
                  colspan = 2,
                  row = 1,
                  rowspan = 2,
                  col = 0,
                  levelspan = 1,
                  level = 0
                }
            })
        end
      --End Precondition.1

      --Begin Test case CommonRequestCheck.2.1.15
      --Description: application sends ButtonPress as Back Right Passenger and ModuleType = RADIO
        function Test:ButtonPress_RightRADIO()
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 1,
              rowspan = 2,
              col = 1,
              levelspan = 1,
              level = 0
            },
            moduleType = "RADIO",
            buttonPressMode = "SHORT",
            buttonName = "SHUFFLE"
          })

        --hmi side: expect Buttons.ButtonPress request
        EXPECT_HMICALL("Buttons.ButtonPress",
                {
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 1,
                    levelspan = 1,
                    level = 0
                  },
                  moduleType = "RADIO",
                  buttonPressMode = "SHORT",
                  buttonName = "SHUFFLE"
                })
          :Do(function(_,data)
            --hmi side: sending Buttons.ButtonPress response
            self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
          end)

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.2.1.15
