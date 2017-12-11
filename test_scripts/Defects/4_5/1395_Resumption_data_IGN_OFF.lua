---------------------------------------------------------------------------------------------------
-- Script verifies SUSPEND -> OnSDLAwake -> SUSPEND -> IGN_OFF sequence for resumption data saving
-- Precondition:
-- 1. SDL and HMI are started.
-- 2. App is registered.
-- Steps:
-- 1. Send AddCommand and check that OnHashChanged() notification is sent to mobile.
-- 2. Send BC.OnExitAllApplications(SUSPEND) and check that OnHashChanged() notification
-- is not sent to mobile when new data are added.
-- 3. Send BasicCommunication.OnAwakeSDL and check that OnHashChanged() notification is sent to mobile.
-- 4. Perform IGN_OFF - IGN_ON cycle and check resumption of persistent data and HMI Level

---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local mobile_session = require("mobile_session")
local common = require('test_scripts/Defects/4_5/commonDefects')
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local SDL = require('SDL')

--[[ Local Variables ]]

--[[ Local Functions ]]
local function AddCommand(self)
  self.mobileSession1:SendRPC("AddCommand", { cmdID = 1, vrCommands = {"VRCommand1"}})
  EXPECT_HMICALL("VR.AddCommand"):Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  self.mobileSession1:ExpectResponse("AddCommand", { success = true, resultCode = "SUCCESS" })
  self.mobileSession1:ExpectNotification("OnHashChange")
end

local function AddCommandAfterSUSPEND(self)
  self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "SUSPEND" })
  self.mobileSession1:SendRPC("AddCommand", { cmdID = 2, vrCommands = {"VRCommand2"}})
  EXPECT_HMICALL("VR.AddCommand"):Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
    end)
  self.mobileSession1:ExpectResponse("AddCommand", { success = true, resultCode = "SUCCESS" })
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
  self.mobileSession1:ExpectNotification("OnHashChange"):Times(0)
  common.delayedExp(3000)
end

local function OnAwakeSDL(self)
  self.hmiConnection:SendNotification("BasicCommunication.OnAwakeSDL",{})
  self.mobileSession1:ExpectNotification("OnHashChange"):Do(function(_, data)
      self.currentHashID = data.payload.hashID
    end)
end

local function IGNITION_OFF(self)
  self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
    { reason = "SUSPEND" })
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete"):Do(function()
      self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
        { reason = "IGNITION_OFF" })
      self.mobileSession1:ExpectNotification("OnAppInterfaceUnregistered",
        { reason = "IGNITION_OFF" })
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", { unexpectedDisconnect = false })
      EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")
      SDL:DeleteFile()
    end)
end

local function expectResumeData(self)
  local on_vr_commands_added = EXPECT_HMICALL("VR.AddCommand"):Do(function(_,data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS")
      end):Times(2)
    on_vr_commands_added:ValidIf(function(_, data)
        if (data.params.type == "Command" and (data.params.cmdID == 1 or data.params.cmdID == 2)) then
          if (data.params.appID == config.application1.registerAppInterfaceParams.hmi_app_id) then
            return true
          else
            commonFunctions:userPrint(31, "Received the same notification or App is registered with wrong appID")
            return false
          end
        end
      end)
    self.mobileSession1:ExpectNotification("OnHashChange")
  end

  local function registerAppAndResumeData(self)
    self.mobileSession1 = mobile_session.MobileSession(self, self.mobileConnection)
    self.mobileSession1:StartService(7):Do(function()
        config.application1.registerAppInterfaceParams.hashID = self.currentHashID
        expectResumeData(self)
        local corId = self.mobileSession1:SendRPC("RegisterAppInterface",
          config.application1.registerAppInterfaceParams)
        EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered",
          { application = { appName = config.application1.registerAppInterfaceParams.appName }}):Do(function(_, data)
            config.application1.registerAppInterfaceParams.hmi_app_id = data.params.application.appID
          end)
        self.mobileSession1:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
        EXPECT_HMICALL("BasicCommunication.ActivateApp",
          {appID = config.application1.registerAppInterfaceParams.hmi_app_id}):Do(function(_,data)
            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
          end)
        self.mobileSession1:ExpectNotification("OnHMIStatus",
          {hmiLevel = "NONE", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE"},
          {hmiLevel = "FULL", systemContext = "MAIN", audioStreamingState = "AUDIBLE"}):Times(2)
      end)
  end

  --[[ Scenario ]]
  runner.Title("Preconditions")
  runner.Step("Clean environment", common.preconditions)
  runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
  runner.Step("RAI, PTU", common.rai_ptu)
  runner.Step("Activate App", common.activate_app)

  runner.Title("Test")
  runner.Step("Add Command", AddCommand)
  runner.Step("Add Command After SUSPEND", AddCommandAfterSUSPEND)
  runner.Step("Send OnAwakeSDL", OnAwakeSDL)
  runner.Step("IGNITION_OFF", IGNITION_OFF)
  runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
  runner.Step("Register App And Resume Data", registerAppAndResumeData)

  runner.Title("Postconditions")
  runner.Step("Stop SDL", common.postconditions)
