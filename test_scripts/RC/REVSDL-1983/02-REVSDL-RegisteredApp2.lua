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
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local config = require('config')
local module = require('testbase')


--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice
--groups_nonPrimaryRC Group
local arrayGroups_nonPrimaryRC = {
                permissionItem = {
                    {
                     hmiPermissions = {
                      allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
                      userDisallowed = {}
                     },
                     parameterPermissions = {
                      allowed = {},
                      userDisallowed = {}
                     },
                     rpcName = "ButtonPress"
                    },
                    {
                     hmiPermissions = {
                      allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
                      userDisallowed = {}
                     },
                     parameterPermissions = {
                      allowed = {},
                      userDisallowed = {}
                     },
                     rpcName = "GetInteriorVehicleData"
                    },
                    {
                     hmiPermissions = {
                      allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
                      userDisallowed = {}
                     },
                     parameterPermissions = {
                      allowed = {},
                      userDisallowed = {}
                     },
                     rpcName = "GetInteriorVehicleDataCapabilities"
                    },
                    {
                     hmiPermissions = {
                      allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
                      userDisallowed = {}
                     },
                     parameterPermissions = {
                      allowed = {},
                      userDisallowed = {}
                     },
                     rpcName = "OnHMIStatus"
                    },
                    {
                     hmiPermissions = {
                      allowed = { "BACKGROUND", "FULL", "LIMITED" },
                      userDisallowed = {}
                     },
                     parameterPermissions = {
                      allowed = {},
                      userDisallowed = {}
                     },
                     rpcName = "OnInteriorVehicleData"
                    },
                    {
                     hmiPermissions = {
                      allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
                      userDisallowed = {}
                     },
                     parameterPermissions = {
                      allowed = {},
                      userDisallowed = {}
                     },
                     rpcName = "OnPermissionsChange"
                    },
                    {
                     hmiPermissions = {
                      allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
                      userDisallowed = {}
                     },
                     parameterPermissions = {
                      allowed = {},
                      userDisallowed = {}
                     },
                     rpcName = "OnSystemRequest"
                    },
                    {
                     hmiPermissions = {
                      allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
                      userDisallowed = {}
                     },
                     parameterPermissions = {
                      allowed = {},
                      userDisallowed = {}
                     },
                     rpcName = "SetInteriorVehicleData"
                    },
                    {
                     hmiPermissions = {
                      allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" },
                      userDisallowed = {}
                     },
                     parameterPermissions = {
                      allowed = {},
                      userDisallowed = {}
                     },
                     rpcName = "SystemRequest"
                    },
                   }
            }

--======================================REVSDL-1983========================================--
---------------------------------------------------------------------------------------------
-----------REVSDL-1983: Subscriptions: reset upon device location changed--------------------
---------------------------------via RC.OnDeviceLocationChanged------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--


  --Begin Test case CommonRequestCheck.2.1.0
  --Description: Set Device1 to Driver's device
     function Test:TC2_Pre_SetDevice1ToDriver()

      --hmi side: send request RC.OnDeviceRankChanged
      self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                          {deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})


    end
  -- --End Test case CommonRequestCheck.2.1.0


  --Begin Test suit CommonRequestCheck.3 for REVSDL-2177 and REVSDL-1691

  --Description: 3. REVSDL-2177
      --Begin Test case Precondition.3.1.1
      --Description: Register new session for register new app
        function Test:TC3_Precondition1()
          self.mobileSession1 = mobile_session.MobileSession(
          self,
          self.mobileConnection)
        end
      --End Test case Precondition.3.1.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.1.2
      --Description: Register App2, App2=NONE for precondition
        function Test:TC3_RegisteredApp2()
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

               --RSDL sends BC.ActivateApp (level: NONE) to HMI.
                EXPECT_HMICALL("BasicCommunication.ActivateApp",
                {
                  appID = self.applications["Test Application1"],
                  level = "NONE",
                  priority = "NONE"
                })


              --SDL sends RegisterAppInterface_response (success:true) with the following resultCodes: SUCCESS
              self.mobileSession1:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })

              --mobile side: Expect OnPermissionsChange notification for DRIVER's device
              self.mobileSession1:ExpectNotification("OnPermissionsChange", arrayGroups_nonPrimaryRC )

              --mobile side:RSDL sends OnHMIStatus (NONE,params) to mobile application.
              self.mobileSession1:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

            end)
          end
      --End Test case CommonRequestCheck.3.1.2
return Test