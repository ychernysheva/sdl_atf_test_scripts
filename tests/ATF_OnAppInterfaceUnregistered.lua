Test = require('user_modules/OnAppUnregistered_connecttest')
local mobile_session = require('mobile_session')
local mobile = require("mobile_connection")
local tcp = require("tcp_connection")
local file_connection = require("file_connection")
require('cardinalities')
local events = require('events')

---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
---------------------------------------------------------------------------------------------
------------------------------------ Common Functions ---------------------------------------
---------------------------------------------------------------------------------------------
local function startSession(self)

	self.mobileSession= mobile_session.MobileSession(self, self.mobileConnection)

	--configure HB and protocol
	self.mobileSession.version = 3
	self.mobileSession:SetHeartbeatTimeout(7000)
	
	--start session
	self.mobileSession:StartService(7)
	--start HB in case you need and protocol version is 3
    self.mobileSession:StartHeartbeat()
	 
end

local function StopSDL_StartSDL_InitHMI_ConnectMobile(TestCaseSubfix)
	--Postconditions: Stop SDL, start SDL again, start HMI, connect to SDL, start mobile, start new session.
	
	Test["StopSDL_" .. TestCaseSubfix]  = function(self)
	  StopSDL()
	end
	
	Test["StartSDL_" .. TestCaseSubfix]  = function(self)
	  StartSDL(config.pathToSDL, config.ExitOnCrash)
	end

	Test["InitHMI_" .. TestCaseSubfix]  = function(self)
	  self:initHMI()
	end

	Test["InitHMI_onReady_" .. TestCaseSubfix]  = function(self)
	  self:initHMI_onReady()
	end


	Test["ConnectMobile_" .. TestCaseSubfix]  = function(self)
	  self:connectMobile()
	end

	Test["StartSession_" .. TestCaseSubfix]  = function(self)
	  --self:startSession_WithoutRegisterApp()
		startSession(self)
	end
	
end


local function Register_App_Interface(TestCaseName)

	Test[TestCaseName] = function(self)
		
		local CorIdRegister = self.mobileSession:SendRPC("RegisterAppInterface", {
																					syncMsgVersion =
																					{
																					  majorVersion = 3,
																					  minorVersion = 1
																					},
																					appName = "SPT",
																					isMediaApplication = false,
																					languageDesired = 'EN-US',
																					hmiDisplayLanguageDesired = 'EN-US',
																					appHMIType = { "DEFAULT" },
																					appID = "1234567_05",
																					deviceInfo =
																					{
																					  os = "Android",
																					  carrier = "Megafon",
																					  firmwareRev = "Name: Linux, Version: 3.4.0-perf",
																					  osVersion = "4.4.2",
																					  maxNumberRFCOMMPorts = 1
																					}
																				  })

		--hmi side: expect BasicCommunication.OnAppRegistered request
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
		{
			application = 
			{
				appName = "SPT"
			}
		})
		:Do(function(_,data)
			self.applications["SPT"] = data.params.application.appID
		end)
		
		--mobile side: expect response
		self.mobileSession:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS"})

		--mobile side: expect notification
		self.mobileSession:ExpectNotification("OnHMIStatus", { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"})

	end

end

function Test: onAppInterfaceUnregistered(reason,case)
	--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
	self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", {reason = reason})
				
	if case==nil then
		--hmi side: expect BasicCommunication.OnAppUnregistered
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  false})
		--mobile side: expect notification
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = reason})
	end
	if case==4 then 
	
		--hmi side: expect BasicCommunication.OnAppUnregistered
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", 
																	{appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  false},
																	{appID = self.applications[config.application2.registerAppInterfaceParams.appName], unexpectedDisconnect =  false},
																	{appID = self.applications[config.application3.registerAppInterfaceParams.appName], unexpectedDisconnect =  false},
																	{appID = self.applications[config.application4.registerAppInterfaceParams.appName], unexpectedDisconnect =  false}
																	)
		
		:Times(4)	
		
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = reason})
		self.mobileSession1:ExpectNotification("OnAppInterfaceUnregistered", {reason = reason})
		self.mobileSession2:ExpectNotification("OnAppInterfaceUnregistered", {reason = reason})
		self.mobileSession3:ExpectNotification("OnAppInterfaceUnregistered", {reason = reason})
	end
	--hmi side: expect to BasicCommunication.OnSDLClose
	EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose",{})
end

function Test:exitAppBy_DRIVER_DISTRACTION_VIOLATION(isExit)
	--HMI sends BasicCommunication.OnExitApplication("DRIVER_DISTRACTION_VIOLATION")
	self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {reason = "DRIVER_DISTRACTION_VIOLATION", appID=self.applications[config.application1.registerAppInterfaceParams.appName]})
	if isExit==true then		
		self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID=self.applications[config.application1.registerAppInterfaceParams.appName]})
		
		--mobile side: Expected OnHMIStatus() notification
		EXPECT_NOTIFICATION("OnHMIStatus",{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE" })
	end
	--mobile side: expect notification
	self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {})	
	:Times(0)
	--hmi side: expect BasicCommunication.OnAppUnregistered
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  true})
	:Times(0)
	commonTestCases:DelayedExp(1000) 

end
function Test:change_App_Params(app,appType,isMedia)
	local session
	
	if app==1 then 
		session = config.application1.registerAppInterfaceParams
	end

	if app==2 then 
		session = config.application2.registerAppInterfaceParams
	end

	if app==3 then 
		session = config.application3.registerAppInterfaceParams
	end
	
	session.isMediaApplication = isMedia
		
	if appType=="" then 
		session.appHMIType = nil 
	else 
		session.appHMIType = appType
	end
end

function Test:registerAppInterface2()
	--mobile side: sending request 
	local CorIdRegister = self.mobileSession1:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams)

	--hmi side: expect BasicCommunication.OnAppRegistered request
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
		{
			application = 
			{
				appName = config.application2.registerAppInterfaceParams.appName
			}
		})
		:Do(function(_,data)
			self.applications[config.application2.registerAppInterfaceParams.appName] = data.params.application.appID					
		end)

	--mobile side: expect response
	self.mobileSession1:ExpectResponse(CorIdRegister, 
		{
			syncMsgVersion = config.syncMsgVersion
		})
		:Timeout(2000)

	--mobile side: expect notification
	self.mobileSession1:ExpectNotification("OnHMIStatus", {systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"})
	:Timeout(2000)
end	

function Test:registerAppInterface3()
	--mobile side: sending request 
	local CorIdRegister = self.mobileSession2:SendRPC("RegisterAppInterface", config.application3.registerAppInterfaceParams)

	--hmi side: expect BasicCommunication.OnAppRegistered request
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
		{
			application = 
				{
					appName = config.application3.registerAppInterfaceParams.appName
				}
		})
		:Do(function(_,data)
			self.applications[config.application3.registerAppInterfaceParams.appName] = data.params.application.appID					
	end)

	--mobile side: expect response
	self.mobileSession2:ExpectResponse(CorIdRegister, 
		{
			syncMsgVersion = config.syncMsgVersion
		})
		:Timeout(2000)

	--mobile side: expect notification
	self.mobileSession2:ExpectNotification("OnHMIStatus", { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"})
		:Timeout(2000)
end		

function Test:registerAppInterface4()
	--mobile side: sending request 
	local CorIdRegister = self.mobileSession3:SendRPC("RegisterAppInterface", config.application4.registerAppInterfaceParams)

	--hmi side: expect BasicCommunication.OnAppRegistered request
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
		{
			application = 
				{
					appName = config.application4.registerAppInterfaceParams.appName
				}
		})
		:Do(function(_,data)
			self.applications[config.application4.registerAppInterfaceParams.appName] = data.params.application.appID					
	end)

	--mobile side: expect response
	self.mobileSession3:ExpectResponse(CorIdRegister, 
		{
			syncMsgVersion = config.syncMsgVersion
		})
		:Timeout(2000)

	--mobile side: expect notification
	self.mobileSession3:ExpectNotification("OnHMIStatus", { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"})
		:Timeout(2000)
end		

function Test:activate_App(app)
	--Activate the first app
	if app==1 then

		local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
		
		EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
					if data.result.code ~= 0 then
					quit()
					end
			end)
		
		self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	end
	
	
	--Activate the second app
	if app==2 then
		local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application2.registerAppInterfaceParams.appName]})
		EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
					if data.result.code ~= 0 then
					quit()
					end
			end)
		
		self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	end
	
	--Activate the third app
	if app==3 then
        
		local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application3.registerAppInterfaceParams.appName]})
		
		EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
					if data.result.code ~= 0 then
					quit()
					end
			end)
		
		self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	end
		
end

------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Preconditions")

	--Delete Policy and Log Files
	commonSteps:DeleteLogsFileAndPolicyTable()
	
	--Add the second session
	function Test:Precondition_SecondSession()
	
		self.mobileSession1 = mobile_session.MobileSession(
		self,
		self.mobileConnection)
		self.mobileSession1:StartService(7)
		
	end		
	
	--Add the third Session
	function Test:Precondition_ThirdSession()
	
		self.mobileSession2 = mobile_session.MobileSession(
		self,
		self.mobileConnection)
		self.mobileSession2:StartService(7)
		
	end	
	
	--Add the fourth  Session
	function Test:Precondition_ThirdSession()
	
		self.mobileSession3 = mobile_session.MobileSession(
		self,
		self.mobileConnection)
		self.mobileSession3:StartService(7)
		
	end	
	
-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK I----------------------------------------
--------------------------------Check normal cases of Mobile request---------------------------
-----------------------------------------------------------------------------------------------

--Not Applicable

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK II----------------------------------------
-----------------------------Check special cases of Mobile request----------------------------
----------------------------------------------------------------------------------------------

--Not Applicable

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK III--------------------------------------
----------------------------------Check normal cases of HMI Response-----------------------
-----------------------------------------------------------------------------------------------

--Not Applicable
	
----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK V---------------------------------------
--------------------------------------Check All Result Codes-------------------------------------
---------------------------------------------------------------------------------------------

--Not Applicable

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VI----------------------------------------
-------------------------Sequence with emulating of user's action(s)--------------------------
----------------------------------------------------------------------------------------------	
--Skipped below TCs cause of ATF doesn't emulate USB and BT transport
----1.APPLINK-18425
----2.APPLINK-18424
----3.APPLINK-18423
----4.APPLINK-18422
----5.APPLINK-18421
----6.APPLINK-18420 

commonFunctions:newTestCasesGroup("TC_APPLINK_18538: Without OnAppInterfaceUnregistered if app is FULL and exited by DRIVER_DISTRACTION_VIOLATION ")

local function TC_APPLINK_18538_AppIsFULL()
	commonSteps:ActivationApp()
	
	function Test: ExitAppBy_DRIVER_DISTRACTION_VIOLATION()
		self:exitAppBy_DRIVER_DISTRACTION_VIOLATION(true)
	end
end

TC_APPLINK_18538_AppIsFULL()
-------------------------------------------------------------------------------------------------------------------------------------------------

commonFunctions:newTestCasesGroup("TC_APPLINK_18538: Without OnAppInterfaceUnregistered if app is LIMITED and exited by DRIVER_DISTRACTION_VIOLATION ")

local function TC_APPLINK_18538_AppIsLIMITED()
	 
	commonSteps:UnregisterApplication()
	
	function Test:Change_App_To_Media()
		self:change_App_Params(1,{"MEDIA"},true)
	end

	commonSteps:RegisterAppInterface()
	commonSteps:ActivationApp()
	
	function Test:Bring_App_To_LIMITED()
		local cid = self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated",
				{
					appID = self.applications[config.application1.registerAppInterfaceParams.appName],
					reason = "GENERAL"
				})

		self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	end
	
	function Test: ExitAppBy_DRIVER_DISTRACTION_VIOLATION()
		self:exitAppBy_DRIVER_DISTRACTION_VIOLATION(true)
	end
end

TC_APPLINK_18538_AppIsLIMITED()
-------------------------------------------------------------------------------------------------------------------------------------------------

commonFunctions:newTestCasesGroup("TC_APPLINK_18538: Without OnAppInterfaceUnregistered if app is BACKGROUND and exited by DRIVER_DISTRACTION_VIOLATION ")

local function TC_APPLINK_18538_AppIsBACKGROUND()
	 
	commonSteps:UnregisterApplication()
	
	function Test:Change_App_To_Media()
		self:change_App_Params(1,{"DEFAULT"},false)
	end

	commonSteps:RegisterAppInterface()
	commonSteps:ActivationApp()
	
	function Test:Bring_App_To_BACKGROUND()
		local cid = self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated",
				{
					appID = self.applications[config.application1.registerAppInterfaceParams.appName],
					reason = "GENERAL"
				})

		self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "BACKGROUN", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	end
	
	function Test: ExitAppBy_DRIVER_DISTRACTION_VIOLATION()
		self:exitAppBy_DRIVER_DISTRACTION_VIOLATION(true)
	end
end

TC_APPLINK_18538_AppIsBACKGROUND()	

-------------------------------------------------------------------------------------------------------------------------------------------------

commonFunctions:newTestCasesGroup("TC_APPLINK_18538: Without OnAppInterfaceUnregistered if app is NONE and exited by DRIVER_DISTRACTION_VIOLATION ")

local function TC_APPLINK_18538_AppIsNONE()
	 
	--commonSteps:UnregisterApplication()
	
	function Test: ExitAppBy_DRIVER_DISTRACTION_VIOLATION()
		self:exitAppBy_DRIVER_DISTRACTION_VIOLATION(false)
	end
end

TC_APPLINK_18538_AppIsNONE()	
---------------------------------------------------------------------------------------------------------------
----APPLINK-18414
----Verification: OnAppInterfaceUnregistered notification with IGNITION_OFF reason.
--------------------------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("TC_APPLINK_18414: OnAppInterfaceUnregistered(IGNITION_OFF) with one app")

local function TC_APPLINK_18414()

	function Test: TC_APPLINK_18414_OnAppInterfaceUnregistered_IGNITION_OFF()
		self:onAppInterfaceUnregistered("IGNITION_OFF")
	end
	
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18414_postcondition")
	
end 

TC_APPLINK_18414()

---------------------------------------------------------------------------------------------------------------

commonFunctions:newTestCasesGroup("TC_APPLINK_18414: OnAppInterfaceUnregistered(IGNITION_OFF) with 4 apps")
local function TC_APPLINK_18414_Case4Apps()

	function Test:Change_App1_To_Media()
		self:change_App_Params(1,{"MEDIA"},true)
	end
		
	commonSteps:RegisterAppInterface()
	commonSteps:ActivationApp()
	
	function Test:Register_NonMedia_App()
		self:change_App_Params(2,{"DEFAULT"},false)
		self:registerAppInterface2()
	end
	
	function Test:Activate_NonMedia_App()
	        self:activate_App(2)
	end
	
	function Test:Register_NAVIGATION_App()
		self:change_App_Params(3,{"NAVIGATION"},false)
		self:registerAppInterface3()
	end
	
	function Test:Active_NAVIGATION_App()
		self:activate_App(3)
	end
	
	function Test:Register_The_Fourth_App()
		self:registerAppInterface4()
	end
	
	function Test: TC_APPLINK_18414_OnAppInterfaceUnregistered_IGNITION_OFF()
		self:onAppInterfaceUnregistered("IGNITION_OFF",4)
	end
	
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18414_postcondition")
	
end 

TC_APPLINK_18414_Case4Apps()

---------------------------------------------------------------------------------------------------------------
----APPLINK-18416
----Verification: SDL doesn't send OnAppInterfaceUnregistered notification to mobile app when user press Ctrl+C in the console
--------------------------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("TC_APPLINK_18416: No OnAppInterfaceUnregistered when user press Ctrl+C in the console with one app")
 
local function TC_APPLINK_18416()

	commonSteps:RegisterAppInterface()

	function Test: TC_APPLINK_18416_without_OnAppInterfaceUnregistered()
		--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
		--self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", {reason = "IGNITION_OFF"})
		StopSDL()
		--hmi side: expect BasicCommunication.OnAppUnregistered
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  true})
				
		--mobile side: expect notification
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {})	
		:Times(0)
		
		--hmi side: expect to BasicCommunication.OnSDLClose
		EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose",{})
		
	   commonTestCases:DelayedExp(1000) 
	end

	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18416_postcondition")

end

TC_APPLINK_18416()
-------------------------------------------------------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("TC_APPLINK_18416: No OnAppInterfaceUnregistered when user press Ctrl+C in the console with 4 apps")
 
local function TC_APPLINK_18416_Case4Apps()

	commonSteps:UnregisterApplication()
	function Test:Change_App1_To_Media()
		self:change_App_Params(1,{"MEDIA"},true)
	end
		
	commonSteps:RegisterAppInterface()
	commonSteps:ActivationApp()
	
	function Test:Register_NonMedia_App()
		self:change_App_Params(2,{"DEFAULT"},false)
		self:registerAppInterface2()
	end
	
	function Test:Activate_NonMedia_App()
	        self:activate_App(2)
	end
	
	function Test:Register_NAVIGATION_App()
		self:change_App_Params(3,{"NAVIGATION"},false)
		self:registerAppInterface3()
	end
	
	function Test:Active_NAVIGATION_App()
		self:activate_App(3)
	end
	
	function Test:Register_The_Fourth_App()
		self:registerAppInterface4()
	end
	
	function Test: TC_APPLINK_18416_without_OnAppInterfaceUnregistered()
		--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
		--self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", {reason = "IGNITION_OFF"})
		StopSDL()
		--hmi side: expect BasicCommunication.OnAppUnregistered
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  true},
																		{appID = self.applications[config.application2.registerAppInterfaceParams.appName], unexpectedDisconnect =  true},
																		{appID = self.applications[config.application3.registerAppInterfaceParams.appName], unexpectedDisconnect =  true},
																		{appID = self.applications[config.application4.registerAppInterfaceParams.appName], unexpectedDisconnect =  true})
																		:Times(4)
				
		--mobile side: expect notification
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {})	
		:Times(0)
		self.mobileSession1:ExpectNotification("OnAppInterfaceUnregistered", {})	
		:Times(0)
		self.mobileSession2:ExpectNotification("OnAppInterfaceUnregistered", {})	
		:Times(0)
		self.mobileSession3:ExpectNotification("OnAppInterfaceUnregistered", {})	
		
		--hmi side: expect to BasicCommunication.OnSDLClose
		EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose",{})
		
	   commonTestCases:DelayedExp(1000) 
	end

	
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18416_postcondition")
	
end 

TC_APPLINK_18416_Case4Apps()

---------------------------------------------------------------------------------------------------------------
----APPLINK-18417
----Verification: OnAppInterfaceUnregistered notification with FACTORY_DEFAULTS reason.
--------------------------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("TC_APPLINK_18417: OnAppInterfaceUnregistered(FACTORY_DEFAULTS) with one app")

local function TC_APPLINK_18417()
	
	commonSteps:RegisterAppInterface()
	
	function Test: TC_APPLINK_18414_OnAppInterfaceUnregistered_FACTORY_DEFAULTS()
		self:onAppInterfaceUnregistered("FACTORY_DEFAULTS")
	end
	
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18417_postcondition")
	
end 

TC_APPLINK_18417()
---------------------------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("TC_APPLINK_APPLINK-18417: OnAppInterfaceUnregistered(FACTORY_DEFAULTS) with 4 apps")

local function TC_APPLINK_APPLINK_18417_Case4Apps()

	commonSteps:UnregisterApplication()
	function Test:Change_App1_To_Media()
		self:change_App_Params(1,{"MEDIA"},true)
	end
		
	commonSteps:RegisterAppInterface()
	commonSteps:ActivationApp()
	
	function Test:Register_NonMedia_App()
		self:change_App_Params(2,{"DEFAULT"},false)
		self:registerAppInterface2()
	end
	
	function Test:Activate_NonMedia_App()
	        self:activate_App(2)
	end
	
	function Test:Register_NAVIGATION_App()
		self:change_App_Params(3,{"NAVIGATION"},false)
		self:registerAppInterface3()
	end
	
	function Test:Active_NAVIGATION_App()
		self:activate_App(3)
	end
	
	function Test:Register_The_Fourth_App()
		self:registerAppInterface4()
	end
	
	function Test: TC_APPLINK_18414_OnAppInterfaceUnregistered_FACTORY_DEFAULTS()
		self:onAppInterfaceUnregistered("FACTORY_DEFAULTS",4)
	end
	
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18417_postcondition")
	
end 

TC_APPLINK_APPLINK_18417_Case4Apps()

---------------------------------------------------------------------------------------------------------------
----APPLINK-18419
----Verification: OnAppInterfaceUnregistered notification with LANGUAGE_CHANGE reason.
--------------------------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("TC_APPLINK_18419: OnAppInterfaceUnregistered (LANGUAGE_CHANGE) when change TTS +VR language on HMI with one app")

local function TC_APPLINK_18419_Change_TTS_VR()
	
	commonSteps:RegisterAppInterface()
	
	function Test: TC_APPLINK_18414_OnAppInterfaceUnregistered_TTSVR_LANGUAGE_CHANGE()
	
		--hmi side: sending TTS.OnLanguageChange/VR.OnLanguageChange request to SDL
		self.hmiConnection:SendNotification("TTS.OnLanguageChange", {language="FR-FR"})
		self.hmiConnection:SendNotification("VR.OnLanguageChange", {language="FR-FR"})
		
		--hmi side: expect OnLanguageChange
		self.mobileSession:ExpectNotification("OnLanguageChange", {language="FR-FR"})	
				
		--hmi side: expect BasicCommunication.OnAppUnregistered
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  false})
				
		--mobile side: expect notification
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})	
		
	end
	
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18419_postcondition")
	
end 

 TC_APPLINK_18419_Change_TTS_VR()
---------------------------------------------------------------------------------------------------------------

commonFunctions:newTestCasesGroup("TC_APPLINK_18419: OnAppInterfaceUnregistered (LANGUAGE_CHANGE) when change TTS +VR language on HMI with 4 apps")

local function TC_APPLINK_18419_Change_TTS_VR_Case4Apps()
	
	function Test:Change_App1_To_Media()
		self:change_App_Params(1,{"MEDIA"},true)
	end
		
	commonSteps:RegisterAppInterface()
	commonSteps:ActivationApp()
	
	function Test:Register_NonMedia_App()
		self:change_App_Params(2,{"DEFAULT"},false)
		self:registerAppInterface2()
	end
	
	function Test:Activate_NonMedia_App()
	        self:activate_App(2)
	end
	
	function Test:Register_NAVIGATION_App()
		self:change_App_Params(3,{"NAVIGATION"},false)
		self:registerAppInterface3()
	end
	
	function Test:Active_NAVIGATION_App()
		self:activate_App(3)
	end
	
	function Test:Register_The_Fourth_App()
		self:registerAppInterface4()
	end
	
	function Test: TC_APPLINK_18414_OnAppInterfaceUnregistered_TTSVR_LANGUAGE_CHANGE()
	
		--hmi side: sending TTS.OnLanguageChange/VR.OnLanguageChange request to SDL
		self.hmiConnection:SendNotification("TTS.OnLanguageChange", {language="FR-FR"})
		self.hmiConnection:SendNotification("VR.OnLanguageChange", {language="FR-FR"})
		
		--hmi side: expect OnLanguageChange
		self.mobileSession:ExpectNotification("OnLanguageChange", {language="FR-FR"})	
				
		--hmi side: expect BasicCommunication.OnAppUnregistered
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  false},
																		{appID = self.applications[config.application2.registerAppInterfaceParams.appName], unexpectedDisconnect =  false},
																		{appID = self.applications[config.application3.registerAppInterfaceParams.appName], unexpectedDisconnect =  false},
																		{appID = self.applications[config.application4.registerAppInterfaceParams.appName], unexpectedDisconnect =  false})
																		:Times(4)
				
		--mobile side: expect notification
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})	
		self.mobileSession1:ExpectNotification("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})	
		self.mobileSession2:ExpectNotification("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})	
		self.mobileSession3:ExpectNotification("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})	
		
	end
	
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18419_postcondition")
	
end 

TC_APPLINK_18419_Change_TTS_VR_Case4Apps()
---------------------------------------------------------------------------------------------------------------

commonFunctions:newTestCasesGroup("TC_APPLINK_18419: OnAppInterfaceUnregistered(LANGUAGE_CHANGE) when changed UI language on HMI with one app")

local function TC_APPLINK_18419_Change_UI_Language()
	
	commonSteps:RegisterAppInterface()
	
	function Test: TC_APPLINK_18414_OnAppInterfaceUnregistered_UI_LANGUAGE_CHANGE()
	
		--hmi side: sending TTS.OnLanguageChange/VR.OnLanguageChange request to SDL
		self.hmiConnection:SendNotification("UI.OnLanguageChange", {language="FR-FR"})
		
		--hmi side: expect OnLanguageChange
		self.mobileSession:ExpectNotification("OnLanguageChange", {language="FR-FR"})	
				
		--hmi side: expect BasicCommunication.OnAppUnregistered
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  false})
				
		--mobile side: expect notification
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})	
		
	end
	
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18419_UI_Language_Change_postcondition")
	
end 

TC_APPLINK_18419_Change_UI_Language()

---------------------------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("TC_APPLINK_18419: OnAppInterfaceUnregistered(LANGUAGE_CHANGE) when changed UI language on HMI with 4 apps")

local function TC_APPLINK_18419_Change_UI_Language_Case4Apps()

	
	function Test:Change_App1_To_Media()
		self:change_App_Params(1,{"MEDIA"},true)
	end
		
	commonSteps:RegisterAppInterface()
	commonSteps:ActivationApp()
	
	function Test:Register_NonMedia_App()
		self:change_App_Params(2,{"DEFAULT"},false)
		self:registerAppInterface2()
	end
	
	function Test:Activate_NonMedia_App()
	        self:activate_App(2)
	end
	
	function Test:Register_NAVIGATION_App()
		self:change_App_Params(3,{"NAVIGATION"},false)
		self:registerAppInterface3()
	end
	
	function Test:Active_NAVIGATION_App()
		self:activate_App(3)
	end
	
	function Test:Register_The_Fourth_App()
		self:registerAppInterface4()
	end
	
	function Test: TC_APPLINK_18419_OnAppInterfaceUnregistered_UI_LANGUAGE_CHANGE()
	
		--hmi side: sending UI.OnLanguageChange request to SDL
		self.hmiConnection:SendNotification("UI.OnLanguageChange", {language="FR-FR"})
		
		--hmi side: expect OnLanguageChange
		self.mobileSession:ExpectNotification("OnLanguageChange", {language="FR-FR"})	
				
		--hmi side: expect BasicCommunication.OnAppUnregistered
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  false},
																		{appID = self.applications[config.application2.registerAppInterfaceParams.appName], unexpectedDisconnect =  false},
																		{appID = self.applications[config.application3.registerAppInterfaceParams.appName], unexpectedDisconnect =  false},
																		{appID = self.applications[config.application4.registerAppInterfaceParams.appName], unexpectedDisconnect =  false})
																		:Times(4)
				
		--mobile side: expect notification
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})	
		self.mobileSession1:ExpectNotification("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})	
		self.mobileSession2:ExpectNotification("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})	
		self.mobileSession3:ExpectNotification("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})	
		

	end
	
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18419_postcondition")
	
end 

TC_APPLINK_18419_Change_UI_Language_Case4Apps()

---------------------------------------------------------------------------------------------------------------
----APPLINK-18428
----Verification: OnAppInterfaceUnregistered notification with APP_UNAUTHORIZED  reason.
--------------------------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("TC_APPLINK_18428: OnAppInterfaceUnregistered(APP_UNAUTHORIZED ) after PTU")

local function TC_APPLINK_18428()
	
	commonSteps:RegisterAppInterface()
	commonSteps:ActivationApp()
	
	local PermissionLinesForApplication = 
			[[			"]].."0000001" ..[[" : {
							"keep_context" : false,
							"steal_focus" : false,
							"priority" : "NONE",
							"default_hmi" : "NONE",
							"groups" : ["Base-4"],
							"AppHMIType": ["NAVIGATION"],
							"RequestType": ["TRAFFIC_MESSAGE_CHANNEL", "PROPRIETARY", "HTTP", "FILE_RESUME"],
							"nicknames": ["HappyApp"],
							
						},
			]]
	
	local PTName =  testCasesForPolicyTable:createPolicyTableFile(nil, nil, PermissionLinesForApplication)	
	--testCasesForPolicyTable:updatePolicy(PTName)	
	
	function Test: TC_APPLINK_18428_OnAppInterfaceUnregistered_APP_UNAUTHORIZED()
	
		--mobile side: sending SystemRequest request 
		local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
																				{
																					fileName = "PolicyTableUpdate",
																					requestType = "HTTP"
																				},
																				PTName)
				

		--hmi side: expect SystemRequest request
		EXPECT_HMICALL("BasicCommunication.SystemRequest", {requestType = "HTTP",  fileName = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"})
		:Do(function(_,data)
			systemRequestId = data.id
			
			--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
			self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate", {policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"})
			
			function to_run()
				--hmi side: sending SystemRequest response
				self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
			end
			
			RUN_AFTER(to_run, 500)
		end)
				
		--hmi side: expect SDL.OnAppPermissionChanged	
		EXPECT_HMINOTIFICATION("SDL.OnAppPermissionChanged", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], appUnauthorized =  true, priority = "NONE"})
		:Do(function(_,data)

			--hmi side: sending SDL.GetUserFriendlyMessage request to SDL
			local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"AppUnauthorized"}})
			
			--hmi side: expect SDL.GetUserFriendlyMessage response
			EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{
												line1 = "Not Authorized", 
												messageCode = "AppUnauthorized", 
												textBody = "This version of %appName% is no longer authorized to work with Applink. Please update to the latest version of %appName%.",
												ttsString = "This version of %appName% is not authorized and will not work with SYNC."}}}})
		end)
		
		--hmi side: expect BasicCommunication.OnAppUnregistered
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  false})
				
		
		--mobile side: expect notification
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = "APP_UNAUTHORIZED"})
		
		EXPECT_HMICALL("BasicCommunication.UpdateAppList")
		:Do(function(_, data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { })
		end)
		:ValidIf (function(_,data)
			for _, app in pairs(data.params.applications) do
				if app.appID == self.applications[config.application1.registerAppInterfaceParams.appName] then	
					commonFunctions:printError(" Application is not removed on AppsList ")
					return false
				end				
			end
			
			return true
			
		end)			
		
	end
	
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18428")
	
end 

TC_APPLINK_18428()

---------------------------------------------------------------------------------------------------------------
----APPLINK-18415
----Verification: OnAppInterfaceUnregistered notification with MASTER_RESET reason.
--------------------------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("TC_APPLINK_18415: OnAppInterfaceUnregistered(reason:MASTER_RESET)")

local function TC_APPLINK_18415()
	Register_App_Interface ("TC_APPLINK_18415")

	function Test: TC_APPLINK_18415_OnAppInterfaceUnregistered_MASTER_RESET()
		--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
		self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", {reason = "MASTER_RESET"})
				
		--hmi side: expect BasicCommunication.OnAppUnregistered
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  false})
				
		--mobile side: expect notification
		self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = "MASTER_RESET"})	
		
		--hmi side: expect to BasicCommunication.OnSDLClose
		EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose",{})
	end
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18415_postcondition")
end

TC_APPLINK_18415()
--------------------------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("TC_APPLINK_18415: OnAppInterfaceUnregistered(MASTER_RESET) with case 4 apps")

local function TC_APPLINK_18415_Case4Apps()

	function Test:Change_App1_To_Media()
		self:change_App_Params(1,{"MEDIA"},true)
	end
		
	commonSteps:RegisterAppInterface()
	commonSteps:ActivationApp()
	
	function Test:Register_NonMedia_App()
		self:change_App_Params(2,{"DEFAULT"},false)
		self:registerAppInterface2()
	end
	
	function Test:Activate_NonMedia_App()
	        self:activate_App(2)
	end
	
	function Test:Register_NAVIGATION_App()
		self:change_App_Params(3,{"NAVIGATION"},false)
		self:registerAppInterface3()
	end
	
	function Test:Active_NAVIGATION_App()
		self:activate_App(3)
	end
	
	function Test:Register_The_Fourth_App()
		self:registerAppInterface4()
	end

	function Test: TC_APPLINK_18415_OnAppInterfaceUnregistered_MASTER_RESET()
		self:onAppInterfaceUnregistered("MASTER_RESET",4)
	end
	StopSDL_StartSDL_InitHMI_ConnectMobile("TC_APPLINK_18415_postcondition")
end

TC_APPLINK_18415_Case4Apps()
	
--Write TEST_BLOCK_VI_End to ATF log	
commonFunctions:newTestCasesGroup("****************************** END TEST BLOCK VI ******************************")	

---------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VII---------------------------------------
--------------------------------------Different HMIStatus-------------------------------------
----------------------------------------------------------------------------------------------
--All HMILevel is checked on TCs on TEST BLOCK VI