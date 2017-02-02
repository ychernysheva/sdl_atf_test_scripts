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
-------------------------------------STARTING COMMON FUNCTIONS-------------------------------
---------------------------------------------------------------------------------------------


--Creating an interiorVehicleDataCapability with specificed zone and moduleType
local function interiorVehicleDataCapability(strModuleType, icol, icolspan, ilevel, ilevelspan, irow, irowspan)
  return{
      moduleZone = {
        col = icol,
        colspan = icolspan,
        level = ilevel,
        levelspan = ilevelspan,
        row = irow,
        rowspan=  irowspan
      },
      moduleType = strModuleType
  }
end

--Creating an interiorVehicleDataCapabilities array with maxsize = iMaxsize
local function interiorVehicleDataCapabilities(strModuleType, icol, icolspan, ilevel, ilevelspan, irow, irowspan, iMaxsize)
  local items = {}
  if iItemCount == 1 then
    table.insert(items, interiorVehicleDataCapability(strModuleType, icol, icolspan, ilevel, ilevelspan, irow, irowspan))
  else
    for i=1, iMaxsize do
      table.insert(items, interiorVehicleDataCapability(strModuleType, icol, icolspan, ilevel, ilevelspan, irow, irowspan))
    end
  end
  return items
end

---------------------------------------------------------------------------------------------
----------------------------------------END COMMON FUNCTIONS---------------------------------
---------------------------------------------------------------------------------------------


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
  --Begin Test suit CommonRequestCheck

  --Description: RSDL must validate each and every RPC (that is, responses and notifications) that HMI sends per "Remote-Control-API" ([attached|^SDL_RC_HMI_API_from_Ford_v2.xml]).
    -- Invalid response expected by mobile app
    -- Invalid response expected by RSDL
    -- Invalid notification
    -- Fake params

--=================================================BEGIN TEST CASES 13==========================================================--

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

      --Begin Test case Precondition.1
      --Description: mobile sends GetInteriorVehicleData request with subscribe = true for precondtion
        function Test:OnInteriorVehicleData_Precondition_RADIO()
          --mobile sends request for precondition
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
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleData request
          EXPECT_HMICALL("RC.GetInteriorVehicleData")
          :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleData response
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                  moduleData = {
                    moduleType = "RADIO",
                    moduleZone = {
                      col = 0,
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

            --mobile side: expect SUCCESS response
            EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

        end
      --End Test case Precondition.1

      --Begin Test case Precondition.2
      --Description: GetInteriorVehicleData response with subscribe = true for precondtion
        function Test:GetInteriorVehicleData_Precondition_CLIMATE()
          local cid = self.mobileSession:SendRPC("GetInteriorVehicleData",
          {
            moduleDescription =
            {
              moduleType = "CLIMATE",
              moduleZone =
              {
                colspan = 2,
                row = 0,
                rowspan = 2,
                col = 0,
                levelspan = 1,
                level = 0,
              }
            },
            subscribe = true
          })

          --hmi side: expect RC.GetInteriorVehicleData request
          EXPECT_HMICALL("RC.GetInteriorVehicleData")
            :Do(function(_,data)
              --hmi side: sending RC.GetInteriorVehicleData response
              self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { isSubscribed = true,
                moduleData =
                {
                  moduleType = "CLIMATE",
                  moduleZone =
                  {
                    colspan = 2,
                    row = 0,
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

          --mobile side: expect GENERIC_ERROR response with info
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})

        end
      --End Test case Precondition.2

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

  --Begin Test case ResponseInvalidJsonNotification.13
  --Description:  --Invalid notification

    --Requirement/Diagrams id in jira:
        --REVSDL-1038

    --Verification criteria:
        --<14.>In case HMI sends a notification of invalid JSON to RSDL, RSDL must log an error and ignore this notification.

      --Begin Test case ResponseInvalidJsonNotification.13.1
      --Description: OnInteriorVehicleData with wrong json
        function Test:OnInteriorVehicleData_WrongJson()

              --hmi side: sending RC.OnInteriorVehicleData notification
              self.hmiConnection:Send('{"jsonrpc":"2.0","method":"RC.OnInteriorVehicleData","params":{"moduleData":{"moduleType":"CLIMATE","moduleZone":{"col":0,"row":0,"level":0,"colspan":2,"rowspan":2,"levelspan":1},"climateControlData":{"fanSpeed":50,"currentTemp":86,"desiredTemp":75,"temperatureUnit":"FAHRENHEIT","acEnable":true,"circulateAirEnable":true,"autoModeEnable":true,"defrostZone":"FRONT","dualModeEnable" true}}}}')

              --mobile side: Absence of notifications
              EXPECT_NOTIFICATION("OnInteriorVehicleData")
              :Times(0)


        end
      --End Test case ResponseInvalidJsonNotification.13.1

    -----------------------------------------------------------------------------------------

      --Begin Test case ResponseInvalidJsonNotification.13.2
      --Description: OnSetDriversDevice with wrong json
        function Test:OnSetDriversDevice_WrongJson()
          --hmi side: sending RC.OnSetDriversDevice notification
          self.hmiConnection:Send('{"jsonrpc":"2.0","method":"RC.OnSetDriversDevice","params":{"device":{"name":"10.42.0.73","id":1,"isSDLAllowed" false}}}')

          --mobile side: Absence of notifications
          EXPECT_NOTIFICATION("OnPermissionsChange")
          :Times(0)
        end
      --End Test case ResponseInvalidJsonNotification.13.2

    -----------------------------------------------------------------------------------------

      --Begin Test case ResponseInvalidJsonNotification.13.3
      --Description: OnReverseAppsAllowing with wrong json
        function Test:OnReverseAppsAllowing_WrongJson()
          --hmi side: sending RC.OnReverseAppsAllowing notification
          self.hmiConnection:Send('{"jsonrpc":"2.0","method":"RC.OnReverseAppsAllowing","params":{"allowed" false}}')

          --mobile side: Absence of notifications
          EXPECT_NOTIFICATION("OnPermissionsChange")
          :Times(0)
        end
      --End Test case ResponseInvalidJsonNotification.13.3

  --End Test case ResponseInvalidJsonNotification.13
--=================================================END TEST CASES 13==========================================================--

function Test:PostconditionsRestoreFile()
  commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
end