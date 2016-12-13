---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [PolicyTableUpdate] PTU using consented device in case a user didn't consent the one which application required PTU
--
-- Description:
--      App that never received the updated policies registers from non-consented device and then the User does NOT consent this device
--     1. Used preconditions:
--        Delete files and policy table from previous ignition cycle if any
--        Connect device1
--        Register and activate app1
--        Connect device2 and register app2
--     2. Performed steps:
--        Register second app and don't consent second device
--
-- Expected result:
--      PoliciesManager must initiate the PT Update through the app from consented device,
--       second(non-consented) device should not be used e.i. no second query for user consent should be sent to HMI
---------------------------------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
local mobile_session = require('mobile_session')
local tcp = require('tcp_connection')
local file_connection = require('file_connection')
local mobile = require('mobile_connection')
local events = require('events')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
-- Create dummy connection
os.execute("ifconfig lo:1 1.0.0.1")

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')

--[[ Local variables ]]
local deviceMAC2 = "54286cb92365be544aa7008b92854b9648072cf8d8b17b372fd0786bef69d7a2"
local mobileHost = "1.0.0.1"
local Connections = {
  {connection = Test.mobileConnection2, session = Test.mobileSession2},
  {connection = Test.mobileConnection1, session = Test.mobileSession1},
}

--[[ Preconditions ]]
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Precondition_Connect_device1()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
  {
    deviceList = {
      {
        id = config.deviceMAC,
        name = "127.0.0.1",
        transportType = "WIFI"
      }
    }
  }
  ):Do(function(_,data)
  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  :Times(AtLeast(1))
end

function Test:Precondition_Register_app1()
  commonTestCases:DelayedExp(3000)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
  local RequestIDRai1 = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
  :Do(function(_,data)
  self.HMIAppID = data.params.application.appID
  end)
  self.mobileSession:ExpectResponse(RequestIDRai1, { success = true, resultCode = "SUCCESS" })
  self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
  end)
end

function Test:Precondition_Activate_app1()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID})
  EXPECT_HMIRESPONSE(RequestId, {result = { code = 0, device = { id = config.deviceMAC, name = "127.0.0.1" }, isSDLAllowed = false, method ="SDL.ActivateApp", priority ="NONE"}})
  :Do(function(_,data)
  if data.result.isSDLAllowed ~= true then
    local RequestIdGetMes = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
    EXPECT_HMIRESPONSE(RequestIdGetMes)
    :Do(function()
    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
    {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
    EXPECT_HMICALL("BasicCommunication.ActivateApp")
    :Do(function()
    self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
    end)
    :Times(AtLeast(1))
    end)
  end
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN", audioStreamingState = "AUDIBLE"})
end

function Test:Precondition_Connect_device2()
  local tcpConnection = tcp.Connection(mobileHost, config.mobilePort)
  local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
  Connections[1].connection = mobile.MobileConnection(fileConnection)
  Connections[1].session = mobile_session.MobileSession(self, Connections[1].connection)
  event_dispatcher:AddConnection(Connections[1].connection)
  Connections[1].session:ExpectEvent(events.connectedEvent, "Connection started")
  Connections[1].connection:Connect()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
  {
    deviceList = {
      {
        id = config.deviceMAC,
        name = "127.0.0.1",
        transportType = "WIFI"
      },
      {
        id = deviceMAC2,
        name = mobileHost,
        transportType = "WIFI"
      },
    }
  }
  ):Do(function(_,data)
  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  :Times(AtLeast(1))
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
function Test:PTU_for_consented_if_requested_by_app2_on_device2()
  Connections[1].session:StartService(7)
  :Do(function()
    local RaiIdSecond = Connections[1].session:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
    :Do(function(_,data)
      self.HMIAppID2 = data.params.application.appID
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
      EXPECT_HMINOTIFICATION("SDL.OnSDLConsentNeeded", {})
      local RequestIdGetMes2 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
      EXPECT_HMIRESPONSE(RequestIdGetMes2)
      :Do(function()
        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",{allowed = false, source = "GUI", device = {id = deviceMAC2, name = mobileHost}})
        EXPECT_HMICALL("BasicCommunication.PolicyUpdate",
        {
          file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
        })
        :Do(function()
          self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",{ requestType = "PROPRIETARY", fileName = "PolicyTableUpdate"})
          EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "PROPRIETARY", appID = self.HMIAppID })
          :Do(function()
            self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
          end)
        end)
      end)
    end)
  Connections[1].session:ExpectResponse(RaiIdSecond, { success = true, resultCode = "SUCCESS"})
  end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLForceStop()
  StopSDL()
end