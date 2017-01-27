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

--=================================================BEGIN TEST CASES 14==========================================================--

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

  --Begin Test case ResponseWrongModuleTypeAnd<module>ControlDataNotification.14
  --Description:  --Invalid notification

    --Requirement/Diagrams id in jira:
        --REVSDL-1038

    --Verification criteria:
        --<15.>In case HMI sends a notification with non-corresponding-to-each-other moduleType and <module>ControlData (example: module: RADIO & climateControlData) to RSDL, RSDL must log an error and ignore this notification.

      --Begin Test case NotificationWrongModuleTypeAnd<module>ControlDataNotification.14.1
      --Description: OnInteriorVehicleData Notification with wrong moduleType and <module>ControlData
        function Test:OnInteriorVehicleData_NotificationWrongModuleTypeAndControlData_RADIO()
          --hmi side: sending RC.OnInteriorVehicleData notification
          self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
          {
                  moduleData =
                  {
                    radioControlData =
                    {
                      radioEnable = true,
                      frequencyInteger = 105,
                      frequencyFraction = 3,
                      band = "AM",
                      hdChannel = 1,
                      state = "ACQUIRED",
                      availableHDs = 1,
                      signalStrength = 50,
                      rdsData =
                      {
                        PS = "12345678",
                        RT = "Radio text minlength = 0, maxlength = 64",
                        CT = "2015-09-29T18:46:19-0700",
                        PI = "PIdent",
                        PTY = 0,
                        TP = true,
                        TA = false,
                        REG = "don't mention min,max length"
                      },
                      signalChangeThreshold = 10
                    },
                    moduleType = "CLIMATE",
                    moduleZone =
                    {
                      colspan = 2,
                      row = 0,
                      rowspan = 2,
                      col = 0,
                      levelspan = 1,
                      level = 0
                    }
                  }
          })

          --mobile side: Absence of notifications
          EXPECT_NOTIFICATION("OnPermissionsChange")
          :Times(0)

        end
      --End Test case NotificationWrongModuleTypeAnd<module>ControlDataNotification.14.1

    -----------------------------------------------------------------------------------------

      --Begin Test case NotificationWrongModuleTypeAnd<module>ControlDataNotification.14.2
      --Description: OnInteriorVehicleData Notification with wrong moduleType and <module>ControlData
        function Test:OnInteriorVehicleData_NotificationWrongModuleTypeAndControlData_CLIMATE()
          --hmi side: sending RC.OnInteriorVehicleData notification
          self.hmiConnection:SendNotification("RC.OnInteriorVehicleData",
          {
                moduleData =
                {
                  moduleType = "RADIO",
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

          --mobile side: Absence of notifications
          EXPECT_NOTIFICATION("OnPermissionsChange")
          :Times(0)

        end
      --End Test case NotificationWrongModuleTypeAnd<module>ControlDataNotification.14.2

  --End Test case ResponseWrongModuleTypeAnd<module>ControlDataNotification.14
--=================================================END TEST CASES 14==========================================================--
