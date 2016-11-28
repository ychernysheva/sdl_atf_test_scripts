- UNREADY (unimplemented stub used - commonFunctions:setSystemTime(days) and commonFunctions:reSetSystemTime()
  ---------------------------------------------------------------------------------------------
  -- Requirement summary:
  -- Request PTU - after "N" days
  --
  -- Description:
  -- The policies manager must request an update to its local policy table after "N" days only if the system provided time is available.
  -- 1. Used preconditions:
  -- a) device an app with app_ID is running is consented
  -- b) application is running on SDL
  -- c) The date previous PTU was received is 01.01.2016
  -- d) the value in PT "module_config"->"'exchange_after_x_days '":150
  -- 2. Performed steps:
  -- a) SDL gets the current date 06.06.2016, it's more than 150 days after the last PTU
  --
  -- Expected result:
  -- a) SDL initiates PTU:
  -- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
  -- PTS is created by SDL:
  -- SDL-> HMI: SDL.PolicyUpdate() //PTU sequence started
  ---------------------------------------------------------------------------------------------

  --[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
  --ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
  config.defaultProtocolVersion = 2

  --[[ Required Shared libraries ]]
  local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
  local commonSteps = require ('user_modules/shared_testcases/commonSteps')

  --[[ General Precondition before ATF start ]]
  commonSteps:DeleteLogsFiles()
  commonSteps:DeletePolicyTable()

  --[[ Local Functions ]]
  local function CreatePTUFromExisted()
    os.execute('cp files/ptu_general.json files/tmp_sdl_preloaded_pt.json')
  end

  local function DeleteTmpPTU()
    os.execute('rm files/tmp_sdl_preloaded_pt.json')
  end

  local function SetExchangeAfterXdaysToPTU(daysForUpdate)
    local pathToFile = 'files/tmp_sdl_preloaded_pt.json'
    local file = io.open(pathToFile, "r")
    local json_data = file:read("*all") -- may be abbreviated to "*a";
    file:close()
    local json = require("modules/json")
    local data = json.decode(json_data)

    if data.policy_table.functional_groupings["DataConsent-2"] then
      data.policy_table.functional_groupings["DataConsent-2"] = nil
    end
    -- set for group in pre_DataConsent section permissions with RPCs and HMI levels for them
    data.policy_table.module_config.exchange_after_x_days = daysForUpdate
    data = json.encode(data)
    file = io.open(pathToFile, "w")
    file:write(data)
    file:close()
  end

  --[[ General Settings for configuration ]]
  Test = require('connecttest')
  require('cardinalities')
  local mobile_session = require('mobile_session')

  --[[ Preconditions ]]
  function Test:Precondition_Activate_App_And_Consent_Device_To_Start_PTU()
    local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.applications["Test Application"]})
    EXPECT_HMIRESPONSE(RequestId, { result = {
          code = 0,
          isSDLAllowed = false},
        method = "SDL.ActivateApp"})
    :Do(function(_,_)
        local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
        EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
        :Do(function(_,_)
            self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
            EXPECT_HMICALL("BasicCommunication.ActivateApp")
            :Do(function(_,data)
                self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
              end)
            EXPECT_NOTIFICATION("OnPermissionsChange", {})
          end)
      end)
  end

  function Test:Preconditions_Set_Exchange_After_X_Days_For_PTU()
    CreatePTUFromExisted()
    SetExchangeAfterXdaysToPTU(150)
  end

  function Test:Precondition_Update_Policy_With_New_Exchange_After_X_Kilometers_Value()
    local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
    EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
    :Do(function()
        self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
          {
            requestType = "PROPRIETARY",
            fileName = "filename"
          }
        )
        EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
        :Do(function()
            local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
              {
                fileName = "PolicyTableUpdate",
                requestType = "PROPRIETARY"
              }, "files/tmp_sdl_preloaded_pt.json")
            local systemRequestId
            EXPECT_HMICALL("BasicCommunication.SystemRequest")
            :Do(function(_,data)
                systemRequestId = data.id
                self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
                  {
                    policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
                  })
                local function to_run()
                  self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
                end
                RUN_AFTER(to_run, 800)
                self.mobileSession:ExpectResponse(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
                EXPECT_NOTIFICATION("OnPermissionsChange", {})
                EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UP_TO_DATE"})
              end)
          end)
      end)
  end

  --[[ Test ]]
  function Test:TestStep_Set_System_Day_And_Check_That_PTU_Is_Triggered()

    -- Stub function to set system time
    -- days - int
    commonFunctions:setSystemTime(days)

    EXPECT_HMICALL("SDL.PolicyUpdate")
    EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"}):Timeout(500)
  end

  --[[ Postcondition ]]
  function Test:Postcondition_Reset_System_Time()
    -- Stub function to Reset system time
    commonFunctions:reSetSystemTime()
  end

  function Test:Postcondition_DeleteTmpPTU()
    DeleteTmpPTU()
  end

  --ToDo: shall be removed when issue: "SDL doesn't stop at execution ATF function StopSDL()" is fixed
  function Test:Postcondition_SDLForceStop()
    commonFunctions:SDLForceStop()
  end
