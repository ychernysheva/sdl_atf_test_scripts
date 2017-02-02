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


--======================================REVSDL-966=========================================--
---------------------------------------------------------------------------------------------
-----------REVSDL-966: "Allow", "Ask Driver" or "Disallow" permissions - depending-----------
------------------on zone value in RPC and this zone permissions in Policies-----------------
---------------------------------------------------------------------------------------------
--=========================================================================================--

---------------------NOTE: THIS SCRIPT ONLY TEST FOR PASSENGER'S DEVICE----------------------

--=================================================BEGIN TEST CASES 10==========================================================--
  --Begin Test suit CommonRequestCheck.10 for Req.#10

  --Description: 10. In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
            --and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
            --and the permission for this app&<interiorZone>&<moduleType> was denied either by the driver or by timeout or erroneous HMI's response
            --RSDL must send the RC.GetInteriorVehicleDataConsent for getting driver's allowance to the vehicle (HMI).


  --Begin Test case CommonRequestCheck.10.1
  --Description:  For ButtonPress

    --Requirement/Diagrams id in jira:
        --REVSDL-966
        --TC: REVSDL-1393

    --Verification criteria:
        --In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.1.1
      --Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time)
        function Test:ButtonPress_DriverAllowFrontRADIO_DriverDenied()
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
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

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
                :Times(0)
                :Do(function(_,data)
                  --hmi side: sending Buttons.ButtonPress response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.1.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.1.2
      --Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time)
        function Test:ButtonPress_DriverAllowFrontRADIO_Error()
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
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "ERROR", {allowed = true})

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
                :Times(0)
                :Do(function(_,data)
                  --hmi side: sending Buttons.ButtonPress response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.1.2

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.1.3
      --Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
        function Test:ButtonPress_DriverAllowFrontRADIO_TimeOut()
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

          --hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
              local function HMIResponse()
                --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
                self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})

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
                :Times(0)
                :Do(function(_,data)
                  --hmi side: sending Buttons.ButtonPress response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                end)
              end

              RUN_AFTER(HMIResponse, 10000)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
          :Timeout(11000)
        end
      --End Test case CommonRequestCheck.10.1.3

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.1.4
      --Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (first time)
        function Test:ButtonPress_DriverAllowFrontRADIO_SUCCESS()
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

          --RSDL must respond with "resultCode: SUCCESS, success: true
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.10.1.4

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.1.5
      --Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:ButtonPress_DriverAllowLeftCLIMATE_DriverDenied()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 1,
              rowspan = 2,
              col = 0,
              levelspan = 1,
              level = 0
            },
            moduleType = "CLIMATE",
            buttonPressMode = "SHORT",
            buttonName = "LOWER_VENT"
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

              --hmi side: expect Buttons.ButtonPress request
              EXPECT_HMICALL("Buttons.ButtonPress",
                      {
                        zone =
                        {
                          colspan = 2,
                          row = 1,
                          rowspan = 2,
                          col = 0,
                          levelspan = 1,
                          level = 0
                        },
                        moduleType = "CLIMATE",
                        buttonPressMode = "SHORT",
                        buttonName = "LOWER_VENT"
                })
                :Times(0)
                :Do(function(_,data)
                  --hmi side: sending Buttons.ButtonPress response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.1.5

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.1.6
      --Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:ButtonPress_DriverAllowLeftCLIMATE_Error()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 1,
              rowspan = 2,
              col = 0,
              levelspan = 1,
              level = 0
            },
            moduleType = "CLIMATE",
            buttonPressMode = "SHORT",
            buttonName = "LOWER_VENT"
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "Error", {allowed = true})

              --hmi side: expect Buttons.ButtonPress request
              EXPECT_HMICALL("Buttons.ButtonPress",
                      {
                        zone =
                        {
                          colspan = 2,
                          row = 1,
                          rowspan = 2,
                          col = 0,
                          levelspan = 1,
                          level = 0
                        },
                        moduleType = "CLIMATE",
                        buttonPressMode = "SHORT",
                        buttonName = "LOWER_VENT"
                })
                :Times(0)
                :Do(function(_,data)
                  --hmi side: sending Buttons.ButtonPress response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.1.6

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.1.7
      --Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:ButtonPress_DriverAllowLeftCLIMATE_TimeOut()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 1,
              rowspan = 2,
              col = 0,
              levelspan = 1,
              level = 0
            },
            moduleType = "CLIMATE",
            buttonPressMode = "SHORT",
            buttonName = "LOWER_VENT"
          })

          --hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              local function HMIResponse()
                  --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
                  self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})

                  --hmi side: expect Buttons.ButtonPress request
                  EXPECT_HMICALL("Buttons.ButtonPress",
                          {
                            zone =
                            {
                              colspan = 2,
                              row = 1,
                              rowspan = 2,
                              col = 0,
                              levelspan = 1,
                              level = 0
                            },
                            moduleType = "CLIMATE",
                            buttonPressMode = "SHORT",
                            buttonName = "LOWER_VENT"
                  })
                  :Times(0)
              end

              RUN_AFTER(HMIResponse, 10000)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
          :Timeout(11000)
        end
      --End Test case CommonRequestCheck.10.1.7

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.1.8
      --Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:ButtonPress_DriverAllowLeftCLIMATE_Success()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("ButtonPress",
          {
            zone =
            {
              colspan = 2,
              row = 1,
              rowspan = 2,
              col = 0,
              levelspan = 1,
              level = 0
            },
            moduleType = "CLIMATE",
            buttonPressMode = "SHORT",
            buttonName = "LOWER_VENT"
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
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
                          row = 1,
                          rowspan = 2,
                          col = 0,
                          levelspan = 1,
                          level = 0
                        },
                        moduleType = "CLIMATE",
                        buttonPressMode = "SHORT",
                        buttonName = "LOWER_VENT"
                      })
                :Do(function(_,data)
                  --hmi side: sending Buttons.ButtonPress response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                end)
          end)

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.10.1.8

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.10.1


  --Begin Test case CommonRequestCheck.10.2
  --Description:  For GetInteriorVehicleData

    --Requirement/Diagrams id in jira:
        --REVSDL-966
        --TC: REVSDL-1393

    --Verification criteria:
        --In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.1
      --Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
        function Test:GetInterior_DriverAllowFrontRADIO_DriverDenied()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 1,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
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
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 1,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 0,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM",
                          rdsData = {
                            PS = "name",
                            RT = "radio",
                            CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                            PI = "Sign",
                            PTY = 1,
                            TP = true,
                            TA = true,
                            REG = "Murica"
                          },
                          availableHDs = 3,
                          hdChannel = 1,
                          signalStrength = 50,
                          signalChangeThreshold = 60,
                          radioEnable = true,
                          state = "ACQUIRING"
                        }
                      }
                  })

              end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.2.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.2
      --Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
        function Test:GetInterior_DriverAllowFrontRADIO_Error()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 1,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
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
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", {}, {allowed = true})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 1,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 0,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM",
                          rdsData = {
                            PS = "name",
                            RT = "radio",
                            CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                            PI = "Sign",
                            PTY = 1,
                            TP = true,
                            TA = true,
                            REG = "Murica"
                          },
                          availableHDs = 3,
                          hdChannel = 1,
                          signalStrength = 50,
                          signalChangeThreshold = 60,
                          radioEnable = true,
                          state = "ACQUIRING"
                        }
                      }
                  })

              end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.2.2

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.3
      --Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
        function Test:GetInterior_DriverAllowFrontRADIO_TimeOut()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 1,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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

              local function HMIResponse()
                  --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
                  self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})

                  --hmi side: expect RC.GetInteriorVehicleData request
                  EXPECT_HMICALL("RC.GetInteriorVehicleData")
                  :Times(0)
                  :Do(function(_,data)
                      --hmi side: sending RC.GetInteriorVehicleData response
                      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                          moduleData = {
                            moduleType = "RADIO",
                            moduleZone = {
                              col = 1,
                              colspan = 2,
                              level = 0,
                              levelspan = 1,
                              row = 0,
                              rowspan = 2
                            },
                            radioControlData = {
                              frequencyInteger = 99,
                              frequencyFraction = 3,
                              band = "FM",
                              rdsData = {
                                PS = "name",
                                RT = "radio",
                                CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                                PI = "Sign",
                                PTY = 1,
                                TP = true,
                                TA = true,
                                REG = "Murica"
                              },
                              availableHDs = 3,
                              hdChannel = 1,
                              signalStrength = 50,
                              signalChangeThreshold = 60,
                              radioEnable = true,
                              state = "ACQUIRING"
                            }
                          }
                  })

                  end)
              end

              RUN_AFTER(HMIResponse, 10000)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
          :Timeout(11000)
        end
      --End Test case CommonRequestCheck.10.2.3

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.4
      --Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
        function Test:GetInterior_DriverAllowFrontRADIO_Sucess()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 1,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
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

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 1,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 0,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM",
                          rdsData = {
                            PS = "name",
                            RT = "radio",
                            CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                            PI = "Sign",
                            PTY = 1,
                            TP = true,
                            TA = true,
                            REG = "Murica"
                          },
                          availableHDs = 3,
                          hdChannel = 1,
                          signalStrength = 50,
                          signalChangeThreshold = 60,
                          radioEnable = true,
                          state = "ACQUIRING"
                        }
                      }
                  })

              end)
          end)

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.10.2.4

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.5
      --Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
        function Test:GetInterior_DriverAllowLeftRADIO_DriverDenied()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 0,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 1,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM",
                          rdsData = {
                            PS = "name",
                            RT = "radio",
                            CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                            PI = "Sign",
                            PTY = 1,
                            TP = true,
                            TA = true,
                            REG = "Murica"
                          },
                          availableHDs = 3,
                          hdChannel = 1,
                          signalStrength = 50,
                          signalChangeThreshold = 60,
                          radioEnable = true,
                          state = "ACQUIRING"
                        }
                      }
                  })

              end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.2.5

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.6
      --Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
        function Test:GetInterior_DriverAllowLeftRADIO_Error()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", 123, {allowed = true})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 0,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 1,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM",
                          rdsData = {
                            PS = "name",
                            RT = "radio",
                            CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                            PI = "Sign",
                            PTY = 1,
                            TP = true,
                            TA = true,
                            REG = "Murica"
                          },
                          availableHDs = 3,
                          hdChannel = 1,
                          signalStrength = 50,
                          signalChangeThreshold = 60,
                          radioEnable = true,
                          state = "ACQUIRING"
                        }
                      }
                  })

              end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.2.6

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.7
      --Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
        function Test:GetInterior_DriverAllowLeftRADIO_TimeOut()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              local function HMIResponse()
                  --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
                  self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})

                  --hmi side: expect RC.GetInteriorVehicleData request
                  EXPECT_HMICALL("RC.GetInteriorVehicleData")
                  :Times(0)
                  :Do(function(_,data)
                      --hmi side: sending RC.GetInteriorVehicleData response
                      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                          moduleData = {
                            moduleType = "RADIO",
                            moduleZone = {
                              col = 0,
                              colspan = 2,
                              level = 0,
                              levelspan = 1,
                              row = 1,
                              rowspan = 2
                            },
                            radioControlData = {
                              frequencyInteger = 99,
                              frequencyFraction = 3,
                              band = "FM",
                              rdsData = {
                                PS = "name",
                                RT = "radio",
                                CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                                PI = "Sign",
                                PTY = 1,
                                TP = true,
                                TA = true,
                                REG = "Murica"
                              },
                              availableHDs = 3,
                              hdChannel = 1,
                              signalStrength = 50,
                              signalChangeThreshold = 60,
                              radioEnable = true,
                              state = "ACQUIRING"
                            }
                          }
                      })

                  end)
              end

              RUN_AFTER(HMIResponse, 10000)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
          :Timeout(11000)
        end
      --End Test case CommonRequestCheck.10.2.7

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.8
      --Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
        function Test:GetInterior_DriverAllowLeftRADIO_Success()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "RADIO",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 0,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 1,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM",
                          rdsData = {
                            PS = "name",
                            RT = "radio",
                            CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                            PI = "Sign",
                            PTY = 1,
                            TP = true,
                            TA = true,
                            REG = "Murica"
                          },
                          availableHDs = 3,
                          hdChannel = 1,
                          signalStrength = 50,
                          signalChangeThreshold = 60,
                          radioEnable = true,
                          state = "ACQUIRING"
                        }
                      }
                  })

              end)
          end)

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.10.2.8

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.9
      --Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:GetInterior_DriverAllowLeftCLIMATE_DriverDenied()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                    moduleData =
                    {
                      moduleType = "CLIMATE",
                      moduleZone =
                      {
                        colspan = 2,
                        row = 1,
                        rowspan = 2,
                        col = 0,
                        levelspan = 1,
                        level = 0
                      },
                      climateControlData =
                      {
                        fanSpeed = 50,
                        circulateAirEnable = true,
                        dualModeEnable = true,
                        currentTemp = 30,
                        defrostZone = "FRONT",
                        acEnable = true,
                        desiredTemp = 24,
                        autoModeEnable = true,
                        temperatureUnit = "CELSIUS"
                      }
                    }
                  })

              end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.2.9

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.10
      --Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:GetInterior_DriverAllowLeftCLIMATE_Error()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", true, {allowed = true})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                    moduleData =
                    {
                      moduleType = "CLIMATE",
                      moduleZone =
                      {
                        colspan = 2,
                        row = 1,
                        rowspan = 2,
                        col = 0,
                        levelspan = 1,
                        level = 0
                      },
                      climateControlData =
                      {
                        fanSpeed = 50,
                        circulateAirEnable = true,
                        dualModeEnable = true,
                        currentTemp = 30,
                        defrostZone = "FRONT",
                        acEnable = true,
                        desiredTemp = 24,
                        autoModeEnable = true,
                        temperatureUnit = "CELSIUS"
                      }
                    }
                  })

              end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.2.10

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.11
      --Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:GetInterior_DriverAllowLeftCLIMATE_TimeOut()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              local function HMIResponse()
                  --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
                  self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})

                  --hmi side: expect RC.GetInteriorVehicleData request
                  EXPECT_HMICALL("RC.GetInteriorVehicleData")
                  :Times(0)
                  :Do(function(_,data)
                      --hmi side: sending RC.GetInteriorVehicleData response
                      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                        moduleData =
                        {
                          moduleType = "CLIMATE",
                          moduleZone =
                          {
                            colspan = 2,
                            row = 1,
                            rowspan = 2,
                            col = 0,
                            levelspan = 1,
                            level = 0
                          },
                          climateControlData =
                          {
                            fanSpeed = 50,
                            circulateAirEnable = true,
                            dualModeEnable = true,
                            currentTemp = 30,
                            defrostZone = "FRONT",
                            acEnable = true,
                            desiredTemp = 24,
                            autoModeEnable = true,
                            temperatureUnit = "CELSIUS"
                          }
                        }
                      })

                  end)
              end

              RUN_AFTER(HMIResponse, 10000)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
          :Timeout(11000)
        end
      --End Test case CommonRequestCheck.10.2.11

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.2.12
      --Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:GetInterior_DriverAllowLeftCLIMATE_Success()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect RC.GetInteriorVehicleData request
              EXPECT_HMICALL("RC.GetInteriorVehicleData")
              :Do(function(_,data)
                  --hmi side: sending RC.GetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                    moduleData =
                    {
                      moduleType = "CLIMATE",
                      moduleZone =
                      {
                        colspan = 2,
                        row = 1,
                        rowspan = 2,
                        col = 0,
                        levelspan = 1,
                        level = 0
                      },
                      climateControlData =
                      {
                        fanSpeed = 50,
                        circulateAirEnable = true,
                        dualModeEnable = true,
                        currentTemp = 30,
                        defrostZone = "FRONT",
                        acEnable = true,
                        desiredTemp = 24,
                        autoModeEnable = true,
                        temperatureUnit = "CELSIUS"
                      }
                    }
                  })

              end)
          end)

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.10.2.12

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.10.2


  --Begin Test case CommonRequestCheck.10.3
  --Description:  For GetInteriorVehicleData

    --Requirement/Diagrams id in jira:
        --REVSDL-966
        --TC: REVSDL-1393

    --Verification criteria:
        --In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.1
      --Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
        function Test:SetInterior_DriverAllowFrontRADIO_DriverDenied()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData = {
              moduleType = "RADIO",
              moduleZone = {
                col = 1,
                colspan = 2,
                level = 0,
                levelspan = 1,
                row = 0,
                rowspan = 2
              },
              radioControlData = {
                frequencyInteger = 99,
                frequencyFraction = 3,
                band = "FM",
                rdsData = {
                  PS = "name",
                  RT = "radio",
                  CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                  PI = "Sign",
                  PTY = 1,
                  TP = true,
                  TA = true,
                  REG = "Murica"
                },
                availableHDs = 3,
                hdChannel = 1,
                signalStrength = 50,
                signalChangeThreshold = 60,
                radioEnable = true,
                state = "ACQUIRING"
              }
            }
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
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

              --hmi side: expect RC.SetInteriorVehicleData request
              EXPECT_HMICALL("RC.SetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.SetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 1,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 0,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM",
                          rdsData = {
                            PS = "name",
                            RT = "radio",
                            CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                            PI = "Sign",
                            PTY = 1,
                            TP = true,
                            TA = true,
                            REG = "Murica"
                          },
                          availableHDs = 3,
                          hdChannel = 1,
                          signalStrength = 50,
                          signalChangeThreshold = 60,
                          radioEnable = true,
                          state = "ACQUIRING"
                        }
                      }
                  })

                end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.3.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.2
      --Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
        function Test:SetInterior_DriverAllowFrontRADIO_Error()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData = {
              moduleType = "RADIO",
              moduleZone = {
                col = 1,
                colspan = 2,
                level = 0,
                levelspan = 1,
                row = 0,
                rowspan = 2
              },
              radioControlData = {
                frequencyInteger = 99,
                frequencyFraction = 3,
                band = "FM",
                rdsData = {
                  PS = "name",
                  RT = "radio",
                  CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                  PI = "Sign",
                  PTY = 1,
                  TP = true,
                  TA = true,
                  REG = "Murica"
                },
                availableHDs = 3,
                hdChannel = 1,
                signalStrength = 50,
                signalChangeThreshold = 60,
                radioEnable = true,
                state = "ACQUIRING"
              }
            }
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
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", false, {allowed = true})

              --hmi side: expect RC.SetInteriorVehicleData request
              EXPECT_HMICALL("RC.SetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.SetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 1,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 0,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM",
                          rdsData = {
                            PS = "name",
                            RT = "radio",
                            CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                            PI = "Sign",
                            PTY = 1,
                            TP = true,
                            TA = true,
                            REG = "Murica"
                          },
                          availableHDs = 3,
                          hdChannel = 1,
                          signalStrength = 50,
                          signalChangeThreshold = 60,
                          radioEnable = true,
                          state = "ACQUIRING"
                        }
                      }
                  })

                end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.3.2

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.3
      --Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
        function Test:SetInterior_DriverAllowFrontRADIO_TimeOut()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData = {
              moduleType = "RADIO",
              moduleZone = {
                col = 1,
                colspan = 2,
                level = 0,
                levelspan = 1,
                row = 0,
                rowspan = 2
              },
              radioControlData = {
                frequencyInteger = 99,
                frequencyFraction = 3,
                band = "FM",
                rdsData = {
                  PS = "name",
                  RT = "radio",
                  CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                  PI = "Sign",
                  PTY = 1,
                  TP = true,
                  TA = true,
                  REG = "Murica"
                },
                availableHDs = 3,
                hdChannel = 1,
                signalStrength = 50,
                signalChangeThreshold = 60,
                radioEnable = true,
                state = "ACQUIRING"
              }
            }
          })

          --hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
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
              local function HMIResponse()
                  --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
                  self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})

                  --hmi side: expect RC.SetInteriorVehicleData request
                  EXPECT_HMICALL("RC.SetInteriorVehicleData")
                  :Times(0)
                  :Do(function(_,data)
                      --hmi side: sending RC.SetInteriorVehicleData response
                      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                          moduleData = {
                            moduleType = "RADIO",
                            moduleZone = {
                              col = 1,
                              colspan = 2,
                              level = 0,
                              levelspan = 1,
                              row = 0,
                              rowspan = 2
                            },
                            radioControlData = {
                              frequencyInteger = 99,
                              frequencyFraction = 3,
                              band = "FM",
                              rdsData = {
                                PS = "name",
                                RT = "radio",
                                CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                                PI = "Sign",
                                PTY = 1,
                                TP = true,
                                TA = true,
                                REG = "Murica"
                              },
                              availableHDs = 3,
                              hdChannel = 1,
                              signalStrength = 50,
                              signalChangeThreshold = 60,
                              radioEnable = true,
                              state = "ACQUIRING"
                            }
                          }
                      })

                    end)
              end

              RUN_AFTER(HMIResponse, 10000)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
          :Timeout(11000)
        end
      --End Test case CommonRequestCheck.10.3.3

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.4
      --Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
        function Test:SetInterior_DriverAllowFrontRADIO_Success()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData = {
              moduleType = "RADIO",
              moduleZone = {
                col = 1,
                colspan = 2,
                level = 0,
                levelspan = 1,
                row = 0,
                rowspan = 2
              },
              radioControlData = {
                frequencyInteger = 99,
                frequencyFraction = 3,
                band = "FM",
                rdsData = {
                  PS = "name",
                  RT = "radio",
                  CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                  PI = "Sign",
                  PTY = 1,
                  TP = true,
                  TA = true,
                  REG = "Murica"
                },
                availableHDs = 3,
                hdChannel = 1,
                signalStrength = 50,
                signalChangeThreshold = 60,
                radioEnable = true,
                state = "ACQUIRING"
              }
            }
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

              --hmi side: expect RC.SetInteriorVehicleData request
              EXPECT_HMICALL("RC.SetInteriorVehicleData")
              :Do(function(_,data)
                  --hmi side: sending RC.SetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 1,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 0,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM",
                          rdsData = {
                            PS = "name",
                            RT = "radio",
                            CT = "YYYY-MM-DDThh:mm:ss.sTZD",
                            PI = "Sign",
                            PTY = 1,
                            TP = true,
                            TA = true,
                            REG = "Murica"
                          },
                          availableHDs = 3,
                          hdChannel = 1,
                          signalStrength = 50,
                          signalChangeThreshold = 60,
                          radioEnable = true,
                          state = "ACQUIRING"
                        }
                      }
                  })

                end)
          end)

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.10.3.4

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.5
      --Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
        function Test:SetInterior_DriverAllowLeftRADIO_DriverDenied()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData = {
              moduleType = "RADIO",
              moduleZone = {
                col = 0,
                colspan = 2,
                level = 0,
                levelspan = 1,
                row = 1,
                rowspan = 2
              },
              radioControlData = {
                frequencyInteger = 99,
                frequencyFraction = 3,
                band = "FM"
              }
            }
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

              --hmi side: expect RC.SetInteriorVehicleData request
              EXPECT_HMICALL("RC.SetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.SetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 0,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 1,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM"
                        }
                      }
                  })

                end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.3.5

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.6
      --Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
        function Test:SetInterior_DriverAllowLeftRADIO_Error()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData = {
              moduleType = "RADIO",
              moduleZone = {
                col = 0,
                colspan = 2,
                level = 0,
                levelspan = 1,
                row = 1,
                rowspan = 2
              },
              radioControlData = {
                frequencyInteger = 99,
                frequencyFraction = 3,
                band = "FM"
              }
            }
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "", {allowed = true})

              --hmi side: expect RC.SetInteriorVehicleData request
              EXPECT_HMICALL("RC.SetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.SetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 0,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 1,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM"
                        }
                      }
                  })

                end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.3.6

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.7
      --Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
        function Test:SetInterior_DriverAllowLeftRADIO_TimeOut()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData = {
              moduleType = "RADIO",
              moduleZone = {
                col = 0,
                colspan = 2,
                level = 0,
                levelspan = 1,
                row = 1,
                rowspan = 2
              },
              radioControlData = {
                frequencyInteger = 99,
                frequencyFraction = 3,
                band = "FM"
              }
            }
          })

          --hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              local function HMIResponse()
                  --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
                  self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})

                  --hmi side: expect RC.SetInteriorVehicleData request
                  EXPECT_HMICALL("RC.SetInteriorVehicleData")
                  :Times(0)
                  :Do(function(_,data)
                      --hmi side: sending RC.SetInteriorVehicleData response
                      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                          moduleData = {
                            moduleType = "RADIO",
                            moduleZone = {
                              col = 0,
                              colspan = 2,
                              level = 0,
                              levelspan = 1,
                              row = 1,
                              rowspan = 2
                            },
                            radioControlData = {
                              frequencyInteger = 99,
                              frequencyFraction = 3,
                              band = "FM"
                            }
                          }
                      })

                    end)
              end

              RUN_AFTER(HMIResponse, 10000)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
          :Timeout(11000)
        end
      --End Test case CommonRequestCheck.10.3.7

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.8
      --Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO
        function Test:SetInterior_DriverAllowLeftRADIO_Success()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData = {
              moduleType = "RADIO",
              moduleZone = {
                col = 0,
                colspan = 2,
                level = 0,
                levelspan = 1,
                row = 1,
                rowspan = 2
              },
              radioControlData = {
                frequencyInteger = 99,
                frequencyFraction = 3,
                band = "FM"
              }
            }
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "RADIO",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect RC.SetInteriorVehicleData request
              EXPECT_HMICALL("RC.SetInteriorVehicleData")
              :Do(function(_,data)
                  --hmi side: sending RC.SetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                      moduleData = {
                        moduleType = "RADIO",
                        moduleZone = {
                          col = 0,
                          colspan = 2,
                          level = 0,
                          levelspan = 1,
                          row = 1,
                          rowspan = 2
                        },
                        radioControlData = {
                          frequencyInteger = 99,
                          frequencyFraction = 3,
                          band = "FM"
                        }
                      }
                  })

                end)
          end)

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.10.3.8

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.9
      --Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:SetInterior_DriverAllowLeftCLIMATE_DriverDenied()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0
              },
              climateControlData =
              {
                fanSpeed = 50,
                desiredTemp = 24,
                temperatureUnit = "CELSIUS"
              }
            }
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = false})

              --hmi side: expect RC.SetInteriorVehicleData request
              EXPECT_HMICALL("RC.SetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.SetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                    moduleData =
                    {
                      moduleType = "CLIMATE",
                      moduleZone =
                      {
                        colspan = 2,
                        row = 1,
                        rowspan = 2,
                        col = 0,
                        levelspan = 1,
                        level = 0
                      },
                      climateControlData =
                      {
                        fanSpeed = 50,
                        desiredTemp = 24,
                        temperatureUnit = "CELSIUS"
                      }
                    }
                  })

                end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.3.9

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.10
      --Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:SetInterior_DriverAllowLeftCLIMATE_Error()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0
              },
              climateControlData =
              {
                fanSpeed = 50,
                desiredTemp = 24,
                temperatureUnit = "CELSIUS"
              }
            }
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "UNSUCCESS", {allowed = true})

              --hmi side: expect RC.SetInteriorVehicleData request
              EXPECT_HMICALL("RC.SetInteriorVehicleData")
              :Times(0)
              :Do(function(_,data)
                  --hmi side: sending RC.SetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                    moduleData =
                    {
                      moduleType = "CLIMATE",
                      moduleZone =
                      {
                        colspan = 2,
                        row = 1,
                        rowspan = 2,
                        col = 0,
                        levelspan = 1,
                        level = 0
                      },
                      climateControlData =
                      {
                        fanSpeed = 50,
                        desiredTemp = 24,
                        temperatureUnit = "CELSIUS"
                      }
                    }
                  })

                end)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
        end
      --End Test case CommonRequestCheck.10.3.10

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.11
      --Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:SetInterior_DriverAllowLeftCLIMATE_TimeOut()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0
              },
              climateControlData =
              {
                fanSpeed = 50,
                desiredTemp = 24,
                temperatureUnit = "CELSIUS"
              }
            }
          })

          --hmi side: expect RSDL sends RC.GetInteriorVehicleDataConsent request to HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              local function HMIResponse()
                  --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
                  self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "TIMED_OUT", {})

                  --hmi side: expect RC.SetInteriorVehicleData request
                  EXPECT_HMICALL("RC.SetInteriorVehicleData")
                  :Times(0)
                  :Do(function(_,data)
                      --hmi side: sending RC.SetInteriorVehicleData response
                      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                        moduleData =
                        {
                          moduleType = "CLIMATE",
                          moduleZone =
                          {
                            colspan = 2,
                            row = 1,
                            rowspan = 2,
                            col = 0,
                            levelspan = 1,
                            level = 0
                          },
                          climateControlData =
                          {
                            fanSpeed = 50,
                            desiredTemp = 24,
                            temperatureUnit = "CELSIUS"
                          }
                        }
                      })

                    end)
              end

              RUN_AFTER(HMIResponse, 10000)
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false, info: "The driver disallows this remote-control RPC" to this application.
          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED", info = "The driver disallows this remote-control RPC" })
          :Timeout(11000)
        end
      --End Test case CommonRequestCheck.10.3.12

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.10.3.13
      --Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE
        function Test:SetInterior_DriverAllowLeftCLIMATE_Success()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession:SendRPC("SetInteriorVehicleData",
          {
            moduleData =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 1,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0
              },
              climateControlData =
              {
                fanSpeed = 50,
                desiredTemp = 24,
                temperatureUnit = "CELSIUS"
              }
            }
          })

          --hmi side: expect RC.GetInteriorVehicleDataConsent request from HMI
          EXPECT_HMICALL("RC.GetInteriorVehicleDataConsent",
                {
                  appID = self.applications["Test Application"],
                  moduleType = "CLIMATE",
                  zone =
                  {
                    colspan = 2,
                    row = 1,
                    rowspan = 2,
                    col = 0,
                    levelspan = 1,
                    level = 0
                  }
                })
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = true})

              --hmi side: expect RC.SetInteriorVehicleData request
              EXPECT_HMICALL("RC.SetInteriorVehicleData")
              :Do(function(_,data)
                  --hmi side: sending RC.SetInteriorVehicleData response
                  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {
                    moduleData =
                    {
                      moduleType = "CLIMATE",
                      moduleZone =
                      {
                        colspan = 2,
                        row = 1,
                        rowspan = 2,
                        col = 0,
                        levelspan = 1,
                        level = 0
                      },
                      climateControlData =
                      {
                        fanSpeed = 50,
                        desiredTemp = 24,
                        temperatureUnit = "CELSIUS"
                      }
                    }
                  })

                end)
          end)

          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
        end
      --End Test case CommonRequestCheck.10.3.13

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.10.3

--=================================================END TEST CASES 10==========================================================--

function Test:PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end