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
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

---------------------------------------------------------------------------------------------
--Declaration connected devices.
--1. Device 2:
local device2 = "172.30.192.146"
local device2Port = 12345
---------------------------------------------------------------------------------------------



--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice
--groups_PrimaryRC Group
local arrayGroups_PrimaryRC = revsdl.arrayGroups_PrimaryRC()
--groups_nonPrimaryRC Group
local arrayGroups_nonPrimaryRC = revsdl.arrayGroups_nonPrimaryRC()


---------------------------------------------------------------------------------------------
-------------------------------------STARTING COMMON FUNCTIONS-------------------------------
---------------------------------------------------------------------------------------------

--New connection device2
function newConnectionDevice2(self, DeviceIP, Port)

  local tcpConnection = tcp.Connection(DeviceIP, Port)
  local fileConnection = file_connection.FileConnection("mobile2.out", tcpConnection)
  self.mobileConnection2 = mobile.MobileConnection(fileConnection)
  self.mobileSession21 = mobile_session.MobileSession(
    self,
    self.mobileConnection2,
    config.application51.registerAppInterfaceParams
  )
  event_dispatcher:AddConnection(self.mobileConnection2)
  self.mobileSession21:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection2:Connect()
end

---------------------------------------------------------------------------------------------
----------------------------------------END COMMON FUNCTIONS---------------------------------
---------------------------------------------------------------------------------------------






--======================================REVSDL-1577========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1577: A device previously set as "driver's" must be---------------------
------------------------------ switchable to "passenger's"-----------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--

--=================================================BEGIN TEST CASES 2==========================================================--
  --Begin Test suit CommonRequestCheck.2 for Req.#2 (TCs: REVSDL-1618 - [REVSDL-1577][TC-06]: Switch from driver's to passenger's device and vice versa when receiving OnDeviceRankChanged().)

  --Description: In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("DRIVER", deviceID) for another device comes from HMI, RSDL must set the named device as driver's and set the previous one to passenger's.


  --Begin Test case CommonRequestCheck.2.1
  --Description:  In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("DRIVER", deviceID) for another device comes from HMI, RSDL must set the named device as driver's and set the previous one to passenger's.


    --Requirement/Diagrams id in jira:
        --REVSDL-1577
        --TC: REVSDL-1618

    --Verification criteria:
        --In case RSDL knows a device to be driver's and RC.OnDeviceRankChanged ("DRIVER", deviceID) for another device comes from HMI, RSDL must set the named device as driver's and set the previous one to passenger's.

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.1
      --Description: Connect device2 for precondition
        function Test:ConnectDevice2()

          newConnectionDevice2(self, device2, device2Port)

        end
      --End Test case Precondition.1

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.2
      --Description: Register App from Device2
        function Test:App1Device2Register()

            --mobile side: RegisterAppInterface request
            self.mobileSession21:StartService(7)
            :Do(function()
             local CorIdRAI = self.mobileSession21:SendRPC("RegisterAppInterface",
                 {

                syncMsgVersion =
                {
                 majorVersion = 2,
                 minorVersion = 2,
                },
                appName ="SyncProxyTester",
                ttsName =
                {

                 {
                  text ="4005",
                  type ="PRE_RECORDED",
                 },
                },
                isMediaApplication = true,
                languageDesired ="EN-US",
                hmiDisplayLanguageDesired ="EN-US",
                appHMIType = { "NAVIGATION", "REMOTE_CONTROL" },
                appID ="123456",

                 })

             --mobile side: RegisterAppInterface response
             self.mobileSession21:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
            end)

        end
      --End Test case Precondition.2

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.2.1.1
      --Description: Set device1 to Driver's device from HMI
        function Test:OnDeviceRankChanged_Driver()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Driver's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

        end
      --End Test case CommonRequestCheck.2.1.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.2.1.2
      --Description: Set device2 to Driver's device from HMI, after that Device1 become Passenger's device.
        function Test:OnDeviceRankChanged_SetAnotherToDriver()

          --hmi side: send request RC.OnDeviceRankChanged to Device2
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "DRIVER", device = {name = device2, id = 2, isSDLAllowed = true}})

          --APP FROM DEVICE1:
          --mobile side: Expect OnPermissionsChange notification for Device1 is Passenger
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )
          --mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

          --APP FROM DEVICE2:
          self.mobileSession21:ExpectNotification("OnPermissionsChange", arrayGroups_PrimaryRC )
          --mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
          self.mobileSession21:ExpectNotification("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

        end
      --End Test case CommonRequestCheck.2.1.2

    -----------------------------------------------------------------------------------------
  --End Test case CommonRequestCheck.2.1


--=================================================END TEST CASES 2==========================================================--

function Test:PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end