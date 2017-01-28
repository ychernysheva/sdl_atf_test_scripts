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

--=================================================BEGIN TEST CASES 8==========================================================--

  --Begin Test case ResponseWrongTypeCheck.8
  --Description:  --Invalid response expected by RSDL

    --Requirement/Diagrams id in jira:
        --REVSDL-1038
        --GetInteriorVehicleDataConsent

    --Verification criteria:
        --<9.>In case RSDL sends a request following the internal processes to HMI (example: permission request), and HMI responds with one or more params of wrong type per rc-HMI_API to RSDL, RSDL must log an error and ignore the received message (meaning: not process the values from response)


      --Begin Test case ResponseWrongTypeCheck.8.1
      --Description: GetInteriorVehicleDataConsent responses with allowed wrong type
        function Test:GetInteriorVehicleDataConsent_ResponseWrongTypeAllowed()
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


        --hmi side: expect RC.GetInteriorVehicleDataConsent request
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
            --hmi side: sending RC.GetInteriorVehicleDataConsent response
            self.hmiConnection:SendResponse(data.id, "RC.GetInteriorVehicleDataConsent", "SUCCESS", {allowed = "true"})

          end)

          EXPECT_RESPONSE(cid, { success = false, resultCode = "USER_DISALLOWED" })
          :Timeout(3000)
        end
      --End Test case ResponseWrongTypeCheck.8.1

--=================================================END TEST CASES 8==========================================================--
