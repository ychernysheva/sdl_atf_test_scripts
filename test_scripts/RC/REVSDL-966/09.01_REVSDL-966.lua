local commonSteps = require("user_modules/shared_testcases/commonSteps")
commonSteps:CheckSDLPath()
commonSteps:DeleteLogsFileAndPolicyTable()

local commonPreconditions = require("user_modules/shared_testcases/commonPreconditions")
commonPreconditions:BackupFile("sdl_preloaded_pt.json")
commonPreconditions:ReplaceFile("sdl_preloaded_pt.json", "./files/jsons/RC/rc_sdl_preloaded_pt.json")

local revsdl = require("user_modules/revsdl")

revsdl.AddUnknownFunctionIDs()
revsdl.SubscribeToRcInterface()
config.ValidateSchema = false
config.application1.registerAppInterfaceParams.appHMIType = { "REMOTE_CONTROL" }
config.application1.registerAppInterfaceParams.appID = "8675311"

Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')

--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice
--groups_nonPrimaryRC Group
local arrayGroups_nonPrimaryRC = revsdl.arrayGroups_nonPrimaryRC()


--======================================Requirement=========================================--
---------------------------------------------------------------------------------------------
-----------Requirement: "Allow", "Ask Driver" or "Disallow" permissions - depending-----------
------------------on zone value in RPC and this zone permissions in Policies-----------------
---------------------------------------------------------------------------------------------
--=========================================================================================--

--=================================================BEGIN TEST CASES 9==========================================================--
  --Begin Test suit CommonRequestCheck.9 for Req.#9

  --Description: 9. In case:
            --the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
            --and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section
            --and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent
            --and RSDL has processed this (app's initial) RPC
            --and another application sends a valid RPC with the same or different <interiorZone> and same <moduleType> and params that exist in "driver_allow" sub-section
            --==> RSDL must send a new RC.GetInteriorVehicleDataConsent for such application to the vehicle (HMI)
            --Source: MOM, p.9
  --Begin Test case CommonRequestCheck.9.1
  --Description:  For ButtonPress (RADIO)

    --Requirement/Diagrams id in jira:
        --Requirement
        --TC: Requirement

    --Verification criteria:
        --In case: the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.9.1.1
      --Description: Register new session for check OnHMIStatus with deviceRank = "PASSENGER"
        function Test:PreconditionNewSession()
          --New session1
          self.mobileSession1 = mobile_session.MobileSession(
            self,
            self.mobileConnection)

          --New session2
          self.mobileSession2 = mobile_session.MobileSession(
            self,
            self.mobileConnection)

          --New session3
          self.mobileSession3 = mobile_session.MobileSession(
            self,
            self.mobileConnection)

          --New session1
          self.mobileSession4 = mobile_session.MobileSession(
            self,
            self.mobileConnection)

          --New session2
          self.mobileSession5 = mobile_session.MobileSession(
            self,
            self.mobileConnection)

          --New session3
          self.mobileSession6 = mobile_session.MobileSession(
            self,
            self.mobileConnection)
        end
      --End Test case Precondition.9.1.1

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.9.1.2
      --Description: Register App1 for precondition
          function Test:TC1_PassengerDevice_App1()
            self.mobileSession1:StartService(7)
            :Do(function()
                local CorIdRegister = self.mobileSession1:SendRPC("RegisterAppInterface",
                {
                  syncMsgVersion =
                  {
                  majorVersion = 3,
                  minorVersion = 0
                  },
                  appName = "Test Application1",
                  isMediaApplication = true,
                  languageDesired = 'EN-US',
                  hmiDisplayLanguageDesired = 'EN-US',
                  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
                  appID = "1"
                })

                EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
                {
                  application =
                  {
                  appName = "Test Application1"
                  }
                })
                :Do(function(_,data)
                  self.applications["Test Application1"] = data.params.application.appID
                end)

                --SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
                self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

                --mobile side: Expect OnPermissionsChange notification for Passenger's device
                self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

                --check OnHMIStatus with deviceRank = "PASSENGER"
                self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"},{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
                :Times(2):Timeout(3000)

              end)
            end
      --End Test case Precondition.9.1.2

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.9.1.3
      --Description: Register App2 for precondition
          function Test:TC1_PassengerDevice_App2()
            self.mobileSession2:StartService(7)
            :Do(function()
                local CorIdRegister = self.mobileSession2:SendRPC("RegisterAppInterface",
                {
                  syncMsgVersion =
                  {
                  majorVersion = 3,
                  minorVersion = 0
                  },
                  appName = "Test Application2",
                  isMediaApplication = true,
                  languageDesired = 'EN-US',
                  hmiDisplayLanguageDesired = 'EN-US',
                  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
                  appID = "2"
                })

                EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
                {
                  application =
                  {
                  appName = "Test Application2"
                  }
                })
                :Do(function(_,data)
                  self.applications["Test Application2"] = data.params.application.appID
                end)

                --SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
                self.mobileSession2:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

                --mobile side: Expect OnPermissionsChange notification for Passenger's device
                self.mobileSession2:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

                --check OnHMIStatus with deviceRank = "PASSENGER"
                self.mobileSession2:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"}, { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
                :Times(2):Timeout(3000)

              end)
            end
      --End Test case Precondition.9.1.3

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.9.1.4
      --Description: Register App3 for precondition
          function Test:TC1_PassengerDevice_App3()
            self.mobileSession3:StartService(7)
            :Do(function()
                local CorIdRegister = self.mobileSession3:SendRPC("RegisterAppInterface",
                {
                  syncMsgVersion =
                  {
                  majorVersion = 3,
                  minorVersion = 0
                  },
                  appName = "Test Application3",
                  isMediaApplication = true,
                  languageDesired = 'EN-US',
                  hmiDisplayLanguageDesired = 'EN-US',
                  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
                  appID = "3"
                })

                EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
                {
                  application =
                  {
                  appName = "Test Application3"
                  }
                })
                :Do(function(_,data)
                  self.applications["Test Application3"] = data.params.application.appID
                end)

                --SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
                self.mobileSession3:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

                --mobile side: Expect OnPermissionsChange notification for Passenger's device
                self.mobileSession3:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

                --check OnHMIStatus with deviceRank = "PASSENGER"
                self.mobileSession3:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"}, { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
                :Times(2):Timeout(3000)

              end)
            end
      --End Test case Precondition.9.1.4

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.9.1.5
      --Description: Register App4 for precondition
          function Test:TC1_PassengerDevice_App4()
            self.mobileSession4:StartService(7)
            :Do(function()
                local CorIdRegister = self.mobileSession4:SendRPC("RegisterAppInterface",
                {
                  syncMsgVersion =
                  {
                  majorVersion = 3,
                  minorVersion = 0
                  },
                  appName = "Test Application4",
                  isMediaApplication = true,
                  languageDesired = 'EN-US',
                  hmiDisplayLanguageDesired = 'EN-US',
                  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
                  appID = "4"
                })

                EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
                {
                  application =
                  {
                  appName = "Test Application4"
                  }
                })
                :Do(function(_,data)
                  self.applications["Test Application4"] = data.params.application.appID
                end)

                --SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
                self.mobileSession4:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

                --mobile side: Expect OnPermissionsChange notification for Passenger's device
                self.mobileSession4:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

                --check OnHMIStatus with deviceRank = "PASSENGER"
                self.mobileSession4:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"}, { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
                :Times(2):Timeout(3000)
              end)
            end
      --End Test case Precondition.9.1.5

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.9.1.6
      --Description: Register App5 for precondition
          function Test:TC1_PassengerDevice_App5()
            self.mobileSession5:StartService(7)
            :Do(function()
                local CorIdRegister = self.mobileSession5:SendRPC("RegisterAppInterface",
                {
                  syncMsgVersion =
                  {
                  majorVersion = 3,
                  minorVersion = 0
                  },
                  appName = "Test Application5",
                  isMediaApplication = true,
                  languageDesired = 'EN-US',
                  hmiDisplayLanguageDesired = 'EN-US',
                  appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
                  appID = "5"
                })

                EXPECT_HMICALL("BasicCommunication.OnAppRegistered",
                {
                  application =
                  {
                  appName = "Test Application5"
                  }
                })
                :Do(function(_,data)
                  self.applications["Test Application5"] = data.params.application.appID
                end)

                --SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
                self.mobileSession5:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

                --mobile side: Expect OnPermissionsChange notification for Passenger's device
                self.mobileSession5:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

                --check OnHMIStatus with deviceRank = "PASSENGER"
                self.mobileSession5:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"}, { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
                :Times(2):Timeout(3000)

              end)
            end
      --End Test case Precondition.9.1.6

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.9.1.7
      --Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO
        function Test:ButtonPress_App1FrontRADIO()
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
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL
              self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", {"SUCCESS"}, {allowed = true})

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
      --End Test case CommonRequestCheck.9.1.7

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.9.1.8
      --Description: application sends ButtonPress as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (same zone and same moduleType)
        function Test:ButtonPress_App2FrontRADIO_SameZone()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession1:SendRPC("ButtonPress",
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
                  appID = self.applications["Test Application1"],
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
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
              self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false
          self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
        end
      --End Test case CommonRequestCheck.9.1.8

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.9.1.9
      --Description: application sends GetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (same zone and same moduleType)
        function Test:GetInterior_App3FrontRADIO_SameZone()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
          local cid = self.mobileSession2:SendRPC("GetInteriorVehicleData",
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
                  appID = self.applications["Test Application2"],
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
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
              self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false
          self.mobileSession2:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
        end
      --End Test case CommonRequestCheck.9.1.9

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.9.1.10
      --Description: application sends SetInteriorVehicleData as Front Passenger (col=1, row=0, level=0) and ModuleType = RADIO (same zone and same moduleType)
        function Test:SetInterior_App4FrontRADIO_SameZone()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies and "equipment" section of policies database contains this RPC name with <params> in <moduleType> in "driver_allow" sub-section of <interiorZone> section and the vehicle (HMI) responds with "allowed: true" for RSDL's RC.GetInteriorVehicleDataConsent - RSDL must send this (app's initial) RPC with these <params> to the vehicle (HMI).
          local cid = self.mobileSession3:SendRPC("SetInteriorVehicleData",
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
                  appID = self.applications["Test Application3"],
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
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
              self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false
          self.mobileSession3:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
        end
      --End Test case CommonRequestCheck.9.1.10

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.9.1.11
      --Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (Different zone and same moduleType)
        function Test:GetInterior_App5LeftRADIO_DifferentZone()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession4:SendRPC("GetInteriorVehicleData",
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
                  appID = self.applications["Test Application4"],
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
            --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
            self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')
          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false
          self.mobileSession4:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
        end
      --End Test case CommonRequestCheck.9.1.11

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.9.1.12
      --Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = RADIO (Different zone and same moduleType)
        function Test:SetInterior_App6LeftRADIO_DifferentZone()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession5:SendRPC("SetInteriorVehicleData",
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
                  appID = self.applications["Test Application5"],
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
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
              self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false
          self.mobileSession5:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
        end
      --End Test case CommonRequestCheck.9.1.12

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.9.1.13
      --Description: application sends ButtonPress as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (first time, asking permission)
        function Test:ButtonPress_App1LeftCLIMATE()
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
      --End Test case CommonRequestCheck.9.1.13

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.9.1.14
      --Description: application sends GetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (same zone and same moduleType)
        function Test:GetInterior_App2LeftCLIMATE_SameZone()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession1:SendRPC("GetInteriorVehicleData",
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
                  appID = self.applications["Test Application1"],
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
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
              self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false
          self.mobileSession1:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
        end
      --End Test case CommonRequestCheck.9.1.14

    -----------------------------------------------------------------------------------------


      --Begin Test case CommonRequestCheck.9.1.15
      --Description: application sends SetInteriorVehicleData as Left Rare Passenger (col=0, row=1, level=0) and ModuleType = CLIMATE (same zone and same moduleType)
        function Test:SetInterior_App3LeftCLIMATE_SameZone()
          --mobile side: In case the application sends a valid rc-RPC with <interiorZone>, <moduleType> and <params> allowed by app's assigned policies
          local cid = self.mobileSession2:SendRPC("SetInteriorVehicleData",
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
                  appID = self.applications["Test Application2"],
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
              --hmi side: sending RC.GetInteriorVehicleDataConsent response to RSDL and HMI auto reject this request.
              self.hmiConnection:Send('{"jsonrpc":"2.0","id":'..tostring(data.id)..',"error":{"code":4,"message":"Already consented!","data":{"method":"RC.GetInteriorVehicleDataConsent"}}}')

          end)

          --RSDL must respond with "resultCode: USER_DISALLOWED, success: false
          self.mobileSession2:ExpectResponse(cid, { success = false, resultCode = "USER_DISALLOWED" })
        end
      --End Test case CommonRequestCheck.9.1.15

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.9.1

--=================================================END TEST CASES 9==========================================================--

function Test.PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end