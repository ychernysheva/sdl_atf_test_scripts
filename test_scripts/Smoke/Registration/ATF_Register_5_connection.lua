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

--[[ Local Functions ]]
local function createConnectionAndRegisterApp(self, device, filename, app, connection_name, session_name)
  local tcpConnection = tcp.Connection(device, devicePort)
  local fileConnection = file_connection.FileConnection(filename, tcpConnection)
  self.connection_name = mobile.MobileConnection(fileConnection)
  self.session_name = mobile_session.MobileSession(self, self.connection_name, app)
  event_dispatcher:AddConnection(self.connection_name)
  self.session_name:ExpectEvent(events.connectedEvent, "Connection started")
  self.connection_name:Connect()
  self.session_name:StartService(7):Do(function()
    local correlationId = self.session_name:SendRPC("RegisterAppInterface", app)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {application = { appName = app.appName}})
    self.session_name:ExpectResponse(correlationId , { success = true, resultCode = "SUCCESS"})
    self.session_name:ExpectNotification("OnHMIStatus",{hmiLevel = "NONE", 
          audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"}):Do(function(_, data)
      commonFunctions:userPrint(35, "1st App is successfully registered")
    end)
  end)
end

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
  createConnectionAndRegisterApp(self, device1, "mobile1.out", default_app_params1, mobileConnection1, mobileSession1)
end

function Test:SecondConnection()
  createConnectionAndRegisterApp(self, device2, "mobile2.out", default_app_params2, mobileConnection2, mobileSession2)
end

function Test:ThirdConnection()
  createConnectionAndRegisterApp(self, device3, "mobile3.out", default_app_params3, mobileConnection3, mobileSession3)
end

function Test:FourthConnection()
  createConnectionAndRegisterApp(self, device4, "mobile4.out", default_app_params4, mobileConnection4, mobileSession4)  
end

function Test:FifthConnection()
  createConnectionAndRegisterApp(self, device5, "mobile5.out", default_app_params5, mobileConnection5, mobileSession5)  
end

-- [[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postcondition")
function Test.Stop_SDL()
  StopSDL()
end

return Test