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
--groups_PrimaryRC Group
local arrayGroups_PrimaryRC = revsdl.arrayGroups_PrimaryRC()
--groups_nonPrimaryRC Group
local arrayGroups_nonPrimaryRC = revsdl.arrayGroups_nonPrimaryRC()

--======================================REVSDL-1587========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1587: Send OnHMIStatus("deviceRank") when the device status-------------
---------------------------changes between "driver's" and "passenger's"----------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--

--=================================================BEGIN TEST CASES 3==========================================================--
  --Begin Test suit CommonRequestCheck.3 for Req.#3

  --Description: RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device


  --Begin Test case CommonRequestCheck.3
  --Description:  --RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device
              --in case RSDL has treated <deviceID> as driver's
              --AND RSDL gets OnDeviceRankChanged ("PASSENGER", <deviceID>) notification from HMI (meaning, in case the device the rc-apps are running from is set as passenger's)


    --Requirement/Diagrams id in jira:
        --REVSDL-1587
        --https://adc.luxoft.com/jira/secure/attachment/121954/121954_Req_3_of_REVSDL-1587.png

    --Verification criteria:
        --RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device
              --in case RSDL has treated <deviceID> as driver's
              --AND RSDL gets OnDeviceRankChanged ("PASSENGER", <deviceID>) notification from HMI (meaning, in case the device the rc-apps are running from is set as passenger's)

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.3
      --Description: Set device1 to Driver's device
        function Test:OnHMIStatus_SetDriverDevice()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
          {deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Driver's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

        end
      --End Test case Precondition.3

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.3.1
      --Description: Set device1 from Driver's to passenger's device
        function Test:OnHMIStatus_SetDriverToPassenger()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
          {deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for passenger's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

        end
      --End Test case CommonRequestCheck.3.1

    -----------------------------------------------------------------------------------------

  --End Test case CommonRequestCheck.3

--=================================================END TEST CASES 3==========================================================--
