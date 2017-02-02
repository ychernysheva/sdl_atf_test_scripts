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
config.application1.registerAppInterfaceParams.appID = "8675311"

Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')

--List permission of "OnPermissionsChange" for PrimaryDevice and NonPrimaryDevice
--groups_PrimaryRC Group
local arrayGroups_PrimaryRC = revsdl.arrayGroups_PrimaryRC()
--groups_nonPrimaryRC Group
local arrayGroups_nonPrimaryRC = revsdl.arrayGroups_nonPrimaryRC()


--======================================REVSDL-1577========================================--
---------------------------------------------------------------------------------------------
--------------REVSDL-1577: A device previously set as "driver's" must be---------------------
------------------------------ switchable to "passenger's"-----------------------------------
---------------------------------------------------------------------------------------------
--=========================================================================================--




--=================================================BEGIN TEST CASES 1==========================================================--
  --Begin Test suit CommonRequestCheck.1 for Req.#1 (TCs: REVSDL-1616 - [REVSDL-1577][TC-04]: RSDL sets device as driver in case receiving RC.OnDeviceRankChanged ("DRIVER", deviceID).)

  --Description: In case RSDL receives RC.OnDeviceRankChanged ("DRIVER", deviceID) from HMI, Rev-SDL must set the named device as driver's one.


  --Begin Test case CommonRequestCheck.1
  --Description:  In case RSDL receives RC.OnDeviceRankChanged ("DRIVER", deviceID) from HMI, Rev-SDL must set the named device as driver's one.


    --Requirement/Diagrams id in jira:
        --REVSDL-1577
        --TC: REVSDL-1616, REVSDL-1617

    --Verification criteria:
        --In case RSDL receives RC.OnDeviceRankChanged ("DRIVER", deviceID) from HMI, Rev-SDL must set the named device as driver's one.

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.1.1
      --Description: Set device1 to Driver's device from HMI (TC: REVSDL-1617)
        function Test:OnDeviceRankChanged_Driver()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "DRIVER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Driver's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_PrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "DRIVER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "DRIVER" })

        end
      --End Test case CommonRequestCheck.1.1

    -----------------------------------------------------------------------------------------

      --Begin Test case CommonRequestCheck.1.2
      --Description: Set device1 to Passenger's device from HMI (TC: REVSDL-1616)
        function Test:OnDeviceRankChanged_Passenger()

          --hmi side: send request RC.OnDeviceRankChanged
          self.hmiConnection:SendNotification("RC.OnDeviceRankChanged",
                              {deviceRank = "PASSENGER", device = {name = "127.0.0.1", id = 1, isSDLAllowed = true}})

          --mobile side: Expect OnPermissionsChange notification for Passenger's device
          EXPECT_NOTIFICATION("OnPermissionsChange", arrayGroups_nonPrimaryRC )

          --mobile side: OnHMIStatus notifications with deviceRank = "PASSENGER"
          EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", deviceRank = "PASSENGER" })

        end
      --End Test case CommonRequestCheck.1.2

    -----------------------------------------------------------------------------------------

  --End Test case CommonRequestCheck.1

--=================================================END TEST CASES 1==========================================================--

function Test:PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end