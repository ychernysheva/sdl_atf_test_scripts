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

--=================================================BEGIN TEST CASES 4==========================================================--
  --Begin Test suit CommonRequestCheck.4 for Req.#4

  --Description: RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device


  --Begin Test case CommonRequestCheck.4
  --Description:  --RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device
              --in case RSDL has treated <deviceID> as driver's
              --AND RSDL gets OnDeviceRankChanged ("DRIVER", <deviceID_2>) notification from HMI (meaning, in case the device the rc-apps are running from is set as passenger's because of another device is chosen as driver's)


    --Requirement/Diagrams id in jira:
        --REVSDL-1587
        --https://adc.luxoft.com/jira/secure/attachment/121955/121955_Req_4_of_REVSDL-1587.png

    --Verification criteria:
        --RSDL must send OnHMIStatus("deviceRank: PASSENGER", params) notification to application(s) registered with REMOTE_CONTROL appHMIType from <deviceID> device
              --in case RSDL has treated <deviceID> as driver's
              --AND RSDL gets OnDeviceRankChanged ("DRIVER", <deviceID_2>) notification from HMI (meaning, in case the device the rc-apps are running from is set as passenger's because of another device is chosen as driver's)

    -----------------------------------------------------------------------------------------

      --Begin Test case Precondition.4
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
      --End Test case Precondition.4

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.4.1
      --Description: Set device2 to Driver's device. After that Device1 become passenger's device
        function Test:OnHMIStatus_SetAnotherDeviceToDriver()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
          {deviceRank = "DRIVER", device = {name = "127.0.0.2", id = 2, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for passenger's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })
          :Timeout(5000)

        end
      --End Test case CommonRequestCheck.4.1

    -----------------------------------------------------------------------------------------

  --End Test case CommonRequestCheck.4

--=================================================END TEST CASES 4==========================================================--

function Test:PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end