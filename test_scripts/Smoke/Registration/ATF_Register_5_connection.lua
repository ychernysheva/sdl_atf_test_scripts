--  Requirement summary:
--  [RegisterAppInterface] SUCCESS
--  [RegisterAppInterface] RegisterAppInterface and HMILevel
--
--  Description:
--  Check that it is able to register up to 5 Apps on different connections via one transport.
--
--  1. Used precondition
--  SDL, HMI are running on system.
--
--  2. Performed steps
--  1st mobile device connect to system
--  appID_1->RegisterAppInterface(params)
--  2nd mobile device connect to system
--  appID_2->RegisterAppInterface(params)
--  3rd mobile device connect to system
--  appID_3->RegisterAppInterface(params)
--  4th mobile device connect to system
--  appID_4->RegisterAppInterface(params)
--  5th mobile device connect to system
--  appID_5->RegisterAppInterface(params)
--
--  Expected behavior:
--  1. SDL successfully registers all five applications and notifies HMI and mobile
--     SDL->HMI: OnAppRegistered(params)
--     SDL->appID: SUCCESS, success:"true":RegisterAppInterface()
--  3. SDL assignes HMILevel after application registering:
--     SDL->appID: OnHMIStatus(HMlLevel, audioStreamingState, systemContext)

-- [[ Required Shared Libraries ]]
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection') 

--[[ General Settings for configuration ]]
Test = require('user_modules/dummy_connecttest')
require('cardinalities')
require('user_modules/AppTypes')

-- [[Local variables]]
local default_app_params1 = config.application1.registerAppInterfaceParams
local default_app_params2 = config.application2.registerAppInterfaceParams
local default_app_params3 = config.application3.registerAppInterfaceParams
local default_app_params4 = config.application4.registerAppInterfaceParams
local default_app_params5 = config.application5.registerAppInterfaceParams
local devicePort = 12345

--1. Device 1:
local device1 = "127.0.0.1"
--2. Device 2:
local device2 = "192.168.100.199"
--3. Device 3:
local device3 = "10.42.0.1"
--4. Device 4:
local device4 = "1.0.0.1"
--5. Device 5:
local device5 = "8.8.8.8"

-- Cretion dummy connections fo script
os.execute("ifconfig lo:1 " .. device2)
os.execute("ifconfig lo:2 " .. device3)
os.execute("ifconfig lo:3 " .. device4)
os.execute("ifconfig lo:4 " .. device5)

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
commonSteps:DeletePolicyTable()
commonSteps:DeleteLogsFiles()

function Test:Start_SDL()
  self:runSDL()
  commonFunctions:waitForSDLStart(self):Do(function()
    self:initHMI():Do(function()
      commonFunctions:userPrint(35, "HMI initialized")
      self:initHMI_onReady():Do(function ()
        commonFunctions:userPrint(35, "HMI is ready")
      end)
    end)
  end)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Check that it is able to register up to 5 Apps on different connections")

function Test:FirstConnection()
  local tcpConnection = tcp.Connection(device1, devicePort)
  local fileConnection = file_connection.FileConnection("mobile1.out", tcpConnection)
  self.mobileConnection = mobile.MobileConnection(fileConnection)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection, default_app_params1)
  event_dispatcher:AddConnection(self.mobileConnection)
  self.mobileSession:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection:Connect()
  self.mobileSession:StartService(7):Do(function()
    local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", default_app_params1)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {application = { appName = default_app_params1.appName}})
    self.mobileSession:ExpectResponse(correlationId , { success = true, resultCode = "SUCCESS"})
    self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "NONE", 
         audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"}):Do(function(_, data)
      commonFunctions:userPrint(35, "1st App is successfully registered")
    end)
  end)
end

function Test:SecondConnection()
  local tcpConnection = tcp.Connection(device2, devicePort)
  local fileConnection = file_connection.FileConnection("mobile2.out", tcpConnection)
  self.mobileConnection2 = mobile.MobileConnection(fileConnection)
  self.mobileSession2 = mobile_session.MobileSession(self, self.mobileConnection2, default_app_params2)
  event_dispatcher:AddConnection(self.mobileConnection2)
  self.mobileSession2:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection2:Connect()
  self.mobileSession2:StartService(7):Do(function()
    local correlationId = self.mobileSession2:SendRPC("RegisterAppInterface", default_app_params2)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {application = { appName = default_app_params2.appName}})
    self.mobileSession2:ExpectResponse(correlationId , { success = true, resultCode = "SUCCESS"})
    self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "NONE", 
         audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"}):Do(function(_, data)
      commonFunctions:userPrint(35, "2nd App is successfully registered")
    end)
  end)
end

function Test:ThirdConnection()
  local tcpConnection = tcp.Connection(device3, devicePort)
  local fileConnection = file_connection.FileConnection("mobile3.out", tcpConnection)
  self.mobileConnection3 = mobile.MobileConnection(fileConnection)
  self.mobileSession3 = mobile_session.MobileSession(
    self, self.mobileConnection3, default_app_params3)
  event_dispatcher:AddConnection(self.mobileConnection3)
  self.mobileSession3:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection3:Connect()
  self.mobileSession3:StartService(7):Do(function()
    local correlationId = self.mobileSession3:SendRPC("RegisterAppInterface", default_app_params3)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {application = { appName = default_app_params3.appName}})
    self.mobileSession3:ExpectResponse(correlationId , { success = true, resultCode = "SUCCESS"})
    self.mobileSession3:ExpectNotification("OnHMIStatus",{hmiLevel = "NONE", 
         audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"}):Do(function(_, data)
      commonFunctions:userPrint(35, "3rd App is successfully registered")
    end)
  end)
end

function Test:FourthConnection()
  local tcpConnection = tcp.Connection(device4, devicePort)
  local fileConnection = file_connection.FileConnection("mobile4.out", tcpConnection)
  self.mobileConnection4 = mobile.MobileConnection(fileConnection)
  self.mobileSession4 = mobile_session.MobileSession(
    self, self.mobileConnection4, default_app_params4)
  event_dispatcher:AddConnection(self.mobileConnection4)
  self.mobileSession4:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection4:Connect()
  self.mobileSession4:StartService(7):Do(function()
    local correlationId = self.mobileSession4:SendRPC("RegisterAppInterface", default_app_params4)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {application = { appName = default_app_params4.appName}})
    self.mobileSession4:ExpectResponse(correlationId , { success = true, resultCode = "SUCCESS"})
    self.mobileSession4:ExpectNotification("OnHMIStatus",{hmiLevel = "NONE", 
         audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"}):Do(function(_, data)
      commonFunctions:userPrint(35, "4th App is successfully registered")
    end)
  end)
end

function Test:FifthConnection()
  local tcpConnection = tcp.Connection(device5, devicePort)
  local fileConnection = file_connection.FileConnection("mobile5.out", tcpConnection)
  self.mobileConnection5 = mobile.MobileConnection(fileConnection)
  self.mobileSession5 = mobile_session.MobileSession(
    self, self.mobileConnection5, default_app_params5)
  event_dispatcher:AddConnection(self.mobileConnection5)
  self.mobileSession5:ExpectEvent(events.connectedEvent, "Connection started")
  self.mobileConnection5:Connect()
 self.mobileSession5:StartService(7):Do(function()
    local correlationId = self.mobileSession5:SendRPC("RegisterAppInterface", default_app_params5)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {application = { appName = default_app_params5.appName}})
    self.mobileSession5:ExpectResponse(correlationId , { success = true, resultCode = "SUCCESS"})
    self.mobileSession5:ExpectNotification("OnHMIStatus",{hmiLevel = "NONE", 
         audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"}):Do(function(_, data)
      commonFunctions:userPrint(35, "5th App is successfully registered")
    end)
  end)
end

-- [[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postcondition")
function Test.Stop_SDL()
  StopSDL()
end

return Test