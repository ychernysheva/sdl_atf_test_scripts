Test = require('user_modules/connecttestRAIUnsupportedVersion')
require('cardinalities')
local events = require('events')
-- local mobile_session = require('user_modules/mobile_sessionRAI')
local mobile_session = require('mobile_session')



local hmi_connection = require('hmi_connection')
local websocket      = require('websocket_connection')
local module         = require('testbase')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

	--Requirement id in JAMA/or Jira ID: SDLAQ-CRS-365

	--Verification criteria: In case app sends RegisterAppInterface (syncMsgVersion {majorVersion=1. minorVersion=1}) SDL must respond UNSUPPORTED_VERSION via RegisterAppInterface response

	--Begin Test case ResultCodeCheck
	--Description: Check UNSUPPORTED_VERSION resultCode in case TTS isn't supported on current HMI

		function module:ConnectMobileStartSession()
			local tcpConnection = tcp.Connection(config.mobileHost, config.mobilePort)
			local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
			self.mobileConnection = mobile.MobileConnection(fileConnection)
			self.mobileSession= mobile_session.MobileSession(
			self,
			self.mobileConnection)
			self.mobileSession.version = 1
			event_dispatcher:AddConnection(self.mobileConnection)
			self.mobileSession:ExpectEvent(events.connectedEvent, "Connection started")
			self.mobileConnection:Connect()
			self.mobileSession:StartService(7)
		end

		function Test:RegisterAppInterface_ttsUnsupportedUnsupportedResource() 

			--mobile side: RegisterAppInterface request 
			local CorIdRAI = self.mobileSession:SendRPC("RegisterAppInterface",
														{
														  	 
															syncMsgVersion = 
															{ 
																majorVersion = 1,
																minorVersion = 1,
															}, 
															appName ="SyncProxyTester",
															ttsName = 
															{ 
																 
																{ 
																	text ="SyncProxyTester",
																	type ="TEXT",
																}, 
															}, 
															ngnMediaScreenAppName ="SPT",
															vrSynonyms = 
															{ 
																"VRSyncProxyTester",
															}, 
															isMediaApplication = true,
															languageDesired ="EN-US",
															hmiDisplayLanguageDesired ="EN-US",
															appHMIType = 
															{ 
																"DEFAULT",
															}, 
															appID ="123456",
															deviceInfo = 
															{
																hardware = "hardware",
																firmwareRev = "firmwareRev",
																os = "os",
																osVersion = "osVersion",
																carrier = "carrier",
																maxNumberRFCOMMPorts = 5
															}
														
														})
			


			--mobile side: RegisterAppInterface response 
			EXPECT_RESPONSE(CorIdRAI, { success = false, resultCode = "UNSUPPORTED_VERSION"})

		end

	--End Test case ResultCodeCheck