----------------------------------------------------------------------------------------------------------
--These TCs are created by APPLINK-15427, APPLINK-15164, APPLINK-9891 and APPLINK-18854
--APPLINK-15164 is not implemeted now
----------------------------------------------------------------------------------------------------------
Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local module = require('testbase')

---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')

---------------------------------------------------------------------------------------------
------------------------------------ Common Variables ---------------------------------------
---------------------------------------------------------------------------------------------
local CorIdAlert
local AlertId
local SpeakId		

---------------------------------------------------------------------------------------------
----------------------------------- Common Fuctions------------------------------------------
function Test:onEventChanged(enable,hmiLevel, audioStreamingState,case)
	--hmi side: send OnEventChanged (ON/OFF) notification to SDL
	self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= enable, eventName="PHONE_CALL"})
	
	if enable==true then
		--Case: There are 3  applications
		if case== nil then
	
			--mobile side: expected OnHMIStatus 
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = hmilevel, audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
			self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
			 self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
		end
		
		--Case: There is one  application
		if case== 1 then 
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = hmiLevel, audioStreamingState = audioStreamingState, systemContext = "MAIN"})
		end
		
		
	end
	
	if enable==false then
	
		--Case: There are 3  applications
		if case==nil then 
			--mobile side: expected OnHMIStatus 	
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = hmilevel, audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end 
		
		--Case: There is one  application
		if case== 1 then 
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = hmilevel, audioStreamingState = audioStreamingState, systemContext = "MAIN"})
		end
	end
end
-----------------------------------------------------------------------------------------

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
-----------------------------------------------------------------------------------------

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
------------------------------------------------------------------------------------------------

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
------------------------------------------------------------------------------------------------

function Test: bring_App_To_LIMITED()
	local cid = self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated",
				{
					appID = self.applications[config.application1.registerAppInterfaceParams.appName],
					reason = "GENERAL"
				})

	self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})					
end
------------------------------------------------------------------------------------------------

function Test:start_VRSESSION(hmiLevel)
	self.hmiConnection:SendNotification("VR.Started")
	self.hmiConnection:SendNotification("UI.OnSystemContext", {systemContext = "VRSESSION",appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
		
	--mobile side: SDL send two notifications to mobile app
	self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = hmiLevel, audioStreamingState = "NOT_AUDIBLE", systemContext = "VRSESSION"})	
end
------------------------------------------------------------------------------------------------

function Test:stop_VRSESSION(hmiLevel)			
	--hmi side: send OnSystemContext
	self.hmiConnection:SendNotification("VR.Stopped")
	self.hmiConnection:SendNotification("UI.OnSystemContext", {systemContext = "MAIN",appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
	
	--mobile side: SDL send 1 notification to mobile app
	self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = hmiLevel, audioStreamingState = "AUDIBLE", systemContext = "MAIN"})					
end	
------------------------------------------------------------------------------------------------

function Test:send_Alert(hmiLevel) 
	--mobile side: Alert request 	
	CorIdAlert = self.mobileSession:SendRPC("Alert",
		{
			alertText1 = "alertText1",
			alertText2 = "alertText2",
			alertText3 = "alertText3",
			ttsChunks = 
			{ 
				
				{ 
					text = "TTSChunk",
					type = "TEXT",
				} 
			}, 
			duration = 5000,
			playTone = false,
			progressIndicator = true
		})

	--hmi side: UI.Alert request 
	EXPECT_HMICALL("UI.Alert", 
		{	
			alertStrings = 
			{
				{fieldName = "alertText1", fieldText = "alertText1"},
				{fieldName = "alertText2", fieldText = "alertText2"},
				{fieldName = "alertText3", fieldText = "alertText3"}
			},
			alertType = "BOTH",
			duration = 5000,
			progressIndicator = true
		})
		:Do(function(_,data)
			self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = self.applications[config.application1.registerAppInterfaceParams.appName], systemContext="ALERT"})
		
		--store id for response in next Test.
		AlertId = data.id

	end)

	--hmi side: TTS.Speak request 
	EXPECT_HMICALL("TTS.Speak", 
			{	
				ttsChunks = 
				{ 
					
					{ 
						text = "TTSChunk",
						type = "TEXT"
					}
				},
				speakType = "ALERT"
			})
	:Do(function(_,data)
	
		--store id for response in next Test.
		SpeakId = data.id 
		
		local function TTS_Started()
			self.hmiConnection:SendNotification("TTS.Started")
		end

		RUN_AFTER(TTS_Started, 500)

	end)
	:ValidIf(function(_,data)
		if #data.params.ttsChunks == 1 then
			return true
		else
			print("ttsChunks array in TTS.Speak request has wrong element number. Expected 1, actual "..tostring(#data.params.ttsChunks))
			return false
		end
	end)

	--mobile side: Expected OnHMIStatus() notification
	EXPECT_NOTIFICATION("OnHMIStatus",
		{ systemContext = "ALERT", hmiLevel = hmiLevel, audioStreamingState = "AUDIBLE" },
		{ systemContext = "ALERT", hmiLevel = hmiLevel, audioStreamingState = "ATTENUATED"})
	:Times(2)								
end
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("****************************** Preconditions ******************************")
	
	--1.Delete Policy and Log Files
	commonSteps:DeleteLogsFileAndPolicyTable()
	
	--2.Unregister app
	commonSteps:UnregisterApplication()
	
	--3.Create second session
	function Test:Precondition_SecondSession()
		self.mobileSession1 = mobile_session.MobileSession(
		self,
		self.mobileConnection)
		self.mobileSession1:StartService(7)
	end	
	
	--4.Create third session
	function Test:Precondition_SecondSession()
		self.mobileSession2 = mobile_session.MobileSession(
		self,
		self.mobileConnection)
		self.mobileSession2:StartService(7)
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
----------------------------------Check normal cases of HMI notification-----------------------
-----------------------------------------------------------------------------------------------
--Begin test suit HMIResponseCheck

	--Description: Verify OnEventChanged():
		--1.with valid "isActive" values (true/false)
		--2.without "isActive" value
		--3.with "isActive" is invalid/not existed/empty/wrongtype
			
		--Write TEST BLOCK III to ATF log
		commonFunctions:newTestCasesGroup("****************************** TEST BLOCK III: Check normal cases of HMI notification ******************************")							
			
			--Description: After receiving BasicCommunication.OnEventChanged(PHONE_CALL,ON) from HMI:
				--1.SDL deactivates Navigation app from (FULL, AUDIBLE) to (FULL, NOT_AUDIBLE)
				--2.SDL deactivates another apps (Media/Communication) to (BACKGROUND, NOT_AUDIBLE)
				--3.Restore app's state when received OnEventChanged(PHONE_CALL, OFF).
			local testData ={
				{app = "NAVIGATION",			appType ={"NAVIGATION"},	isMedia=false,	hmiLevel="LIMITED", 	audioStreamingState="NOT_AUDIBLE"},
				{app= "MEDIA",					appType ={"MEDIA"},			isMedia=true,	hmiLevel="BACKGROUND", 	audioStreamingState="NOT_AUDIBLE"},
				{app="NON MEDIA COMMUNICATION",	appType ={"COMMUNICATION"}, isMedia=false,	hmiLevel="BACKGROUND", 	audioStreamingState="NOT_AUDIBLE"}
			}
			
			for i =1, #testData do
			
				commonFunctions:newTestCasesGroup(testData[i].app.." app is FULL. HMI sends OnEventChanged(PHONE_CALL) with isActive: true then false")
				
				local function App_IsFull_PhoneCall_IsOn()
				
					function Test:Change_App1_Params()
						self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
					end
					
					commonSteps:RegisterAppInterface()
					commonSteps:ActivationApp()
					
					function Test:PhoneCall_Event_ON()
						self:onEventChanged(true, testData[i].hmiLevel, testData[i].audioStreamingState,1)
					end
					
					function Test:PhoneCall_Event_OFF()
						self:onEventChanged(false, "FULL", "AUDIBLE",1)
					end
				end
				
				App_IsFull_PhoneCall_IsOn()
				
				--Poscontidion: Unregister app
				commonSteps:UnregisterApplication()
			end
			---------------------------------------------------------------------------------------------------------
			
			--Description: After receiving BasicCommunication.OnEventChanged(PHONE_CALL,ON) from HMI:
				--1.SDL deactivates Navigation app from (LIMITED, AUDIBLE) to (LIMITED, NOT_AUDIBLE)
				--2.SDL deactivates another apps (Media/Non Media Non Navigation) to (BACKGROUND, NOT_AUDIBLE)
				--3.Restore app's state after received OnEventChanged(PHONE_CALL, OFF).
			for i =1, #testData do
			
				commonFunctions:newTestCasesGroup(testData[i].app.." app is LIMITED. HMI sends OnEventChanged(PHONE_CALL) with isActive: true then false")
				
				local function App_IsFull_PhoneCall_IsOn()
			
					function Test:Change_App1_Params()
						self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
					end
					
					commonSteps:RegisterAppInterface()
					commonSteps:ActivationApp()
					
					function Test: Bring_App_To_LIMITED()
						self:bring_App_To_LIMITED()						
					end
					
					function Test:PhoneCall_Event_ON()
						self:onEventChanged(true, testData[i].hmiLevel, testData[i].audioStreamingState,1)
					end
					
					--Should be debug till APPLINK-15164 is DONE
					-- function Test: Activate_App_During_PHONE_CALL()
						-- local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})

						-- EXPECT_HMIRESPONSE(rid)
						-- :Do(function(_,data)
							-- if data.result.code ~= 0 then
							-- quit()
							-- end
						-- end)
						
						-- --HMI expectes to receive OnHMIStatus(FULL,NOT_AUDIBLE,MAIN) till APPLINK-15164 is DONE
						-- self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
					-- end
					
					function Test:PhoneCall_Event_OFF()
						--After APPLINK-15164 is DONE, the expected result should be
						--self:onEventChanged(false, "FULL", "AUDIBLE",1)
						self:onEventChanged(false, "LIMITED", "AUDIBLE",1)
						
						
					end
					
				end
				
				App_IsFull_PhoneCall_IsOn()
				
				--Poscontidion: Unregister app
				commonSteps:UnregisterApplication()
			end
			---------------------------------------------------------------------------------------------------------
			
			--Description: SDL doesn't deactivate Navigation app when receives BasicCommunication.OnEventChanged(PHONE_CALL) from HMI with invalid "isActive"
			local invalidValues = {	{value = nil,	name = "IsMissed"},
									{value = "", 	name = "IsEmtpy"},
									{value = "ANY", name = "NonExist"},
									{value = 123, 	name = "WrongDataType"}}
							
			for i = 1, #invalidValues  do
			
				for j=1,#testData do
				
					commonFunctions:newTestCasesGroup(testData[j].app.." app is FULL. HMI sends OnEventChanged(PHONE_CALL) with isActive is " ..invalidValues[i].name)
					
					function Test:Change_App1_Params()
						self:change_App_Params(1,testData[j].appType,testData[j].isMedia)
					end
						
					commonSteps:RegisterAppInterface()
					commonSteps:ActivationApp()
									
					Test["PhoneCall_Event_isActive_" .. invalidValues[i].name .."_IsIgnored"] = function(self)
						commonTestCases:DelayedExp(1000) 
						--hmi side: send OnExitApplication
						self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= invalidValues[i].value, eventName="PHONE_CALL"})
						
						--mobile side: not expected OnHMIStatus 
						self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel=testData[j].hmiLevel, audioStreamingState=testData[j].audioStreamingState, systemContext = "MAIN"})
						:Times(0)
					end
					
					--Poscontidion:Unregister app
					commonSteps:UnregisterApplication()
				end
			end
			---------------------------------------------------------------------------------------------------------
			
--End Test suit PositiveRequestCheck	
----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK IV--------------------------------------
----------------------------------Check special cases of HMI notification-----------------------
-----------------------------------------------------------------------------------------------
--Begin test suit HMISpecialResponseCheck

	--Verify OnEventChanged() with:
		--1.InvalidJsonSyntax
		--2.InvalidStructure
		--3.Fake Params 
		--4.Fake Parameter Is From Another API
		--5.Missed mandatory Parameters
		--6.Missed All PArameters
		--7.Several Notifications with the same values
		--8.Several otifications with different values
		
		--Write TEST BLOCK IV to ATF log
		commonFunctions:newTestCasesGroup("****************************** TEST BLOCK IV: Check special cases of HMI notification ******************************")							
			
		    --Description: SDL must not deactive app when receives BasicCommunication.OnEventChanged(PHONE_CALL) from HMI with InvalidJSonSyntax
			for i =1, #testData do
			
				commonFunctions:newTestCasesGroup(testData[i].app.." app is FULL. HMI sends OnEventChanged(PHONE_CALL) is InvalidJSonSyntax")
					
				function Test:Change_App1_Params()
					self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
				end
					
				commonSteps:RegisterAppInterface()
				commonSteps:ActivationApp()

				function Test:PhoneCall_Event_ON_InvalidJSonSyntax()
					commonTestCases:DelayedExp(1000) 
					
					--self.hmiConnection:Send('{"jsonrpc":"2.0","method":"BasicCommunication.OnEventChanged","params":{"isActive":true,"eventName":"PHONE_CALL"}}')
					self.hmiConnection:Send('{"jsonrpc";"2.0","method":"BasicCommunication.OnEventChanged","params":{"isActive":true,"eventName":"PHONE_CALL"}}')
					
					--mobile side: not expected OnHMIStatus 
					self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel=testData[i].hmiLevel, audioStreamingState=testData[i].audioStreamingState, systemContext = "MAIN"})
					:Times(0)
				end
				
				--Postcondition: Unregister app
				commonSteps:UnregisterApplication()
			end
			---------------------------------------------------------------------------------------------------------
		
			--Description: SDL must not deactive app when receives BasicCommunication.OnEventChanged(PHONE_CALL) from HMI with InvalidStructure
			for i =1, #testData do
			
				commonFunctions:newTestCasesGroup(testData[i].app.." app is FULL. HMI sends OnEventChanged(PHONE_CALL) is InvalidStructure")
					
				function Test:Change_App1_Params()
					self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
				end
					
				commonSteps:RegisterAppInterface()
				commonSteps:ActivationApp()
				
				function Test:PhoneCall_Event_ON_InvalidStructure()
					commonTestCases:DelayedExp(1000) 
					
					--method is moved into params parameter
					--self.hmiConnection:Send('{"jsonrpc":"2.0","method":"BasicCommunication.OnEventChanged","params":{"isActive":true,"eventName":"PHONE_CALL"}}')
					self.hmiConnection:Send('{"jsonrpc":"2.0","params":{"method":"BasicCommunication.OnEventChanged","isActive":true,"eventName":"PHONE_CALL"}}')
					  
					--mobile side: not expected OnHMIStatus 
					self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel=testData[i].hmiLevel, audioStreamingState=testData[i].audioStreamingState, systemContext = "MAIN"})
					:Times(0)
				end
				
				--Postcondition: Unregister app
				commonSteps:UnregisterApplication()
			end
			---------------------------------------------------------------------------------------------------------
	
		    --Description: SDL must deactive app when receives BasicCommunication.OnEventChanged(PHONE_CALL,ON) from HMI with fake param
			for i =1, #testData do
			
				commonFunctions:newTestCasesGroup(testData[i].app.." app is FULL. HMI sends OnEventChanged(PHONE_CALL) with fake param")
				
				function Test:Change_App1_Params()
					self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
				end
					
				commonSteps:RegisterAppInterface()
				commonSteps:ActivationApp()
				
				function Test:PhoneCall_Event_ON_FakeParams()
					--HMI side: sending BasicCommunication.OnEventChanged with fake param
					self.hmiConnection:Send('{"jsonrpc":"2.0","method":"BasicCommunication.OnEventChanged","params":{"isActive":true,"eventName":"PHONE_CALL","fakeparam":123}}')
					  
					--mobile side: not expected OnHMIStatus 
					self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel=testData[i].hmiLevel, audioStreamingState=testData[i].audioStreamingState, systemContext = "MAIN"})
				end
				
				--Postcondition1: Send BC.OnEventChanged(PHONE_CALL,OFF)
				function Test:PostCondition_PhoneCall_OFF()
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= false, eventName="PHONE_CALL"})
					  
					--mobile side: not expected OnHMIStatus 
					self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
				end
				
				--Postcondition2: Unregister app
				commonSteps:UnregisterApplication()
			end
			---------------------------------------------------------------------------------------------------------
		
		    --Description: SDL must not put deactivates app when receives BasicCommunication.OnEventChanged() from HMI without any params
			for i =1, #testData do
			
				commonFunctions:newTestCasesGroup(testData[i].app.." app is FULL. HMI sends OnEventChanged(PHONE_CALL) without any params")
				
				function Test:Change_App1_Params()
					self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
				end
					
				commonSteps:RegisterAppInterface()
				commonSteps:ActivationApp()
				
				function Test:PhoneCall_Event_ON_Without_Any_Params()
					commonTestCases:DelayedExp(1000) 
					--HMI side: sending BasicCommunication.OnEventChanged without any params
					self.hmiConnection:Send('{"jsonrpc":"2.0","method":"BasicCommunication.OnEventChanged","params":{}}')
					 
					--mobile side: not expected OnHMIStatus 
					self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel=testData[i].hmiLevel, audioStreamingState=testData[i].audioStreamingState, systemContext = "MAIN"})
					:Times(0)
				end
				
				--Postcondition: Unregister app
				commonSteps:UnregisterApplication()
			end
			---------------------------------------------------------------------------------------------------------
			
		    --Description: After receiving several BasicCommunication.OnEventChanged(PHONE_CALL,ON) from HMI,SDL must deactivates app.Then SDL restores app when it receives several BasicCommunication.OnEventChanged(PHONE_CALL,OFF) from HMI
			for i =1, #testData do
			
				commonFunctions:newTestCasesGroup(testData[i].app.." app is FULL. HMI sends OnEventChanged(PHONE_CALL) with isActive:true/false")
				
				function Test:Change_App1_Params()
					self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
				end
					
				commonSteps:RegisterAppInterface()
				commonSteps:ActivationApp()
			
				--Send several BasicCommunication.OnEventChanged(PHONE_CALL,true)
				function Test:Several_PhoneCall_Event_ON_To_SDL()
					--HMI side: sending several BasicCommunication.OnEventChanged without any param
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= true, eventName="PHONE_CALL"})
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= true, eventName="PHONE_CALL"})
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= true, eventName="PHONE_CALL"})
					
					--mobile side: not expected OnHMIStatus 
					self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel=testData[i].hmiLevel, audioStreamingState=testData[i].audioStreamingState, systemContext = "MAIN"})
				end
				
				--Send several BasicCommunication.OnEventChanged(PHONE_CALL,false)			
				function Test:Several_PhoneCall_Event_OFF_To_SDL()
					--HMI side: sending several BasicCommunication.OnEventChanged
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= false, eventName="PHONE_CALL"})
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= false, eventName="PHONE_CALL"})
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= false, eventName="PHONE_CALL"})
					
					--mobile side: expect OnHMIStatus 
					self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
				end
			
				--Postcondition: Unregister app
				commonSteps:UnregisterApplication()
				
			end
			---------------------------------------------------------------------------------------------------------
			
		    --Description: SDL must put app to (LIMITED/BACKGROUND, NOT_AUDIBLE,MAIN) and restore to (FULL,AUDIBLE,MAIN) and then put (LIMITED/BACKGROUND, NOT_AUDIBLE,MAIN) again when it receives several different BasicCommunication.OnEventChanged(PHONE_CALL,ON/OFF/ON) from HMI
			for i =1, #testData do
			
				commonFunctions:newTestCasesGroup(testData[i].app.." app is FULL. HMI sends OnEventChanged(PHONE_CALL) with isActive:true/false/true")
		
				function Test:Change_App1_Params()
					self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
				end
					
				commonSteps:RegisterAppInterface()
				commonSteps:ActivationApp()
				
				--Send several BasicCommunication.OnEventChanged(PHONE_CALL) with different "isActive" param	
				function Test:Several_PhoneCall_Event_WithDifferentValues_To_SDL()
					--HMI side: sending several BasicCommunication.OnEventChanged
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= true, eventName="PHONE_CALL"})
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= false, eventName="PHONE_CALL"})
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= true, eventName="PHONE_CALL"})
						
					--mobile side: not expected OnHMIStatus 
					self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel=testData[i].hmiLevel, audioStreamingState=testData[i].audioStreamingState, systemContext = "MAIN"},
																		{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"},
																		{hmiLevel=testData[i].hmiLevel, audioStreamingState=testData[i].audioStreamingState, systemContext = "MAIN"})
																		:Times(3)												
				end
				
				--Postcondition1: Send BC.OnEventChanged(PHONE_CALL,false)
				function Test:PostCondition_PhoneCall_OFF()
					self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= false, eventName="PHONE_CALL"})
					  
					--mobile side: not expected OnHMIStatus 
					self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
				end
				
				--Postcondition2: Unregister app
				commonSteps:UnregisterApplication()
				
			end
			----------------------------------------------------------------------------------------------------------------------
				
--End Test suit PositiveRequestCheck	
----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Not Applicable
	
----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VI----------------------------------------
-------------------------Sequence with emulating of user's action(s)--------------------------
----------------------------------------------------------------------------------------------	

--Not Applicable

-----------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VII---------------------------------------
--------------------------------------Different HMIStatus-------------------------------------
----------------------------------------------------------------------------------------------

	--Begin Check with Different HMIStatus
	--Description:Check when HMILevel is
		--1.(FULL,AUDIBLE,MAIN): Already checked by HMIResponseCheck3.1
		--2.(LIMITED,AUDIBLE,MAIN): Already checked by HMIResponseCheck3.2
		--3.(FULL,NOT_AUDIBLE,VRSESSION)
		--4.(LIMITED,NOT_AUDIBLE,VRSESSION)
		--5.(FULL,ATTENUATED,ALERT)
		--6.(LIMITED,ATTENUATED,ALERT)
		--7.(BACKGROUND,NOT_AUDIBLE,MAIN)
		--8.Three apps are at (LIMITED,AUDIBLE,MAIN)
		--9.Two apps are at (LIMITED,AUDIBLE,MAIN), one app is at (FULL,AUDIBLE,MAIN)
	
		--Write TEST BLOCK VII to ATF log
		commonFunctions:newTestCasesGroup("****************************** TEST BLOCK VII: Check with Different HMIStatus ******************************")				

		--Description: Navi app is at(FULL,NOT_AUDIBLE,VRSESSION), SDL must deactives navigation app to LIMITED and restore app to FULL when it receices OnEventChanged(PHONE_CALL,ON/OFF) from HMI
		
		for i =1, #testData do
		
			commonFunctions:newTestCasesGroup(testData[i].app.." app is (FULL,NOT_AUDIBLE,VRSESSION). HMI sends OnEventChanged(PHONE_CALL) with isActive:true/false")
			
			function Test:Change_App1_Params()
				self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
			end
				
			commonSteps:RegisterAppInterface()
			commonSteps:ActivationApp()
	
			function Test:Start_VRSession()
				self:start_VRSESSION("FULL")
			end
		
			--Send OnventChanged(PHONE_CALL,ON) to SDL: App is changed to (LIMITED/BACKGROUND,NOT_AUDIBLE,VRSESSION)
			function Test:Step3_Send_PhoneCall_Event_ON_While_VRSESSION()
			
				self:onEventChanged(true,testData[i].hmiLevel, testData[i].audioStreamingState,1)
				
			end
		
			--Send OnventChanged(PHONE_CALL,OFF) to SDL: App is changed to (FULL,NOT_AUDIBLE,VRSESSION)
			function Test:Step3_Send_PhoneCall_Event_OFF_While_VRSESSION()
			
				self:onEventChanged(false,"FULL","NOT_AUDIBLE",1)
				
			end
		
			function Test:Stop_VRSession()
				self:stop_VRSESSION("FULL")
			end
					
			--Postcondition: Unregister app
			commonSteps:UnregisterApplication()			
		end
		----------------------------------------------------------------------------------------------------------
		
		--Description: Media/Commnucation app is at (LIMITED,NOT_AUDIBLE,VRSESSION), SDL must change app to(BACKGROUND,NOT_AUDIBLE,VRSESSION) and restore when it receices OnEventChanged(PHONE_CALL,ON/OFF) from HMI
		
		for i =2, #testData do
		
			commonFunctions:newTestCasesGroup(testData[i].app.." app is (LIMITED,NOT_AUDIBLE,VRSESSION). HMI sends OnEventChanged(PHONE_CALL) with isActive:true/false")
				
			function Test:Change_App1_Params()
				self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
			end
				
			commonSteps:RegisterAppInterface()
			commonSteps:ActivationApp()
			
			function Test: Bring_App_To_LIMITED()	
				self:bring_App_To_LIMITED()						
			end
					
			function Test:Start_VRSESSION()
				self:start_VRSESSION("LIMITED")
			end
			
			--Send OnventChanged(PHONE_CALL,ON) to SDL: App is changed to (BACKGROUND,NOT_AUDIBLE,VRSESSION)
			function Test:Step3_Send_PhoneCall_Event_ON_While_VRSESSION()
				
				--commonTestCases:DelayedExp(1000) 
				self:onEventChanged(true,testData[i].hmiLevel, testData[i].audioStreamingState,1)
				
			end
			
			--Send OnventChanged(PHONE_CALL,OFF) to SDL: App still be at (LIMITED,NOT_AUDIBLE,VRSESSION)
			function Test:Step3_Send_PhoneCall_Event_OFF_While_VRSESSION()
			
				self:onEventChanged(false,"LIMITED", "NOT_AUDIBLE",1)
				
			end
			
			function Test:Stop_VRSESSION()
				self:stop_VRSESSION("LIMITED")
			end
					
			--Postcondition: Unregister app
			commonSteps:UnregisterApplication()			
			
		end
		-----------------------------------------------------------------------------------------------------------
		
		--Description: Navigation app is at (LIMITED,NOT_AUDIBLE,VRSESSION), SDL must not change app's state when it receices OnEventChanged(PHONE_CALL,ON/OFF) from HMI
		
		commonFunctions:newTestCasesGroup("Navigation app is at (LIMITED,NOT_AUDIBLE,VRSESSION)")
	
		function Test:Change_App1_Params()
			self:change_App_Params(1,{"NAVIGATION"},false)
		end
		
		commonSteps:RegisterAppInterface()
		commonSteps:ActivationApp()
		
		function Test: Bring_App_To_LIMITED()
			self:bring_App_To_LIMITED()							
		end
		
		--Start VRSESSION: App is changed to (LIMITED,NOT_AUDIBLE,VRSESSION)
		function Test:Start_VRSession()
			self:start_VRSESSION("LIMITED")
		end
		
		--Send OnventChanged(PHONE_CALL,ON) to SDL: App is changed to (BACKGROUND,NOT_AUDIBLE,VRSESSION)
		function Test:Step3_Send_PhoneCall_Event_ON_While_VRSESSION()
			--hmi side:send Emergency_Event (ON) notification to SDL
			self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= true, eventName="PHONE_CALL"})
								
			--mobile side: SDL doesn't send any notifications to mobile app
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE", systemContext = "VRSESSION"})
			:Times(0)
			commonTestCases:DelayedExp(1000) 
		end
		
		--Send OnventChanged(PHONE_CALL,OFF) to SDL: App is changed to (LIMITED,NOT_AUDIBLE,VRSESSION)
		function Test:Step3_Send_PhoneCall_Event_OFF_While_VRSESSION()
			--hmi side:send Emergency_Event (ON) notification to SDL
			self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= false, eventName="PHONE_CALL"})
								
			--mobile side: SDL doesn't send any notifications to mobile app
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "NOT_AUDIBLE", systemContext = "VRSESSION"})
			:Times(0)
			commonTestCases:DelayedExp(1000) 
		end
		
		function Test:Stop_VRSESSION()
			self:stop_VRSESSION("LIMITED")			
		end	
				
		--Postcondition: Unregister app
		commonSteps:UnregisterApplication()			
		-----------------------------------------------------------------------------------------------------------
	
		--Description: App (FULL,ATTENUATED,ALERT), SDL must not change app's state to (LIMITED/BACKGROUND,NOT_AUDIBLE,ALERT)  when it receices OnEventChanged(PHONE_CALL,ON/OFF) from HMI
		for i =1, #testData do
			
			commonFunctions:newTestCasesGroup(testData[i].app.." app is (FULL,ATTENUATED,ALERT). HMI sends OnEventChanged(PHONE_CALL) with isActive:true/false")
				
			function Test:Change_App1_Params()
				self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
			end
				
			commonSteps:RegisterAppInterface()
			commonSteps:ActivationApp()
			
			--Send Alert() to bring app to (FULL,ATTENUATED,ALERT)
			function Test:Send_Alert() 
				--mobile side: Alert request 	
				CorIdAlert = self.mobileSession:SendRPC("Alert",
							{
								alertText1 = "alertText1",
								alertText2 = "alertText2",
								alertText3 = "alertText3",
								ttsChunks = 
								{ 
									
									{ 
										text = "TTSChunk",
										type = "TEXT",
									} 
								}, 
								duration = 5000,
								playTone = false,
								progressIndicator = true
							})

				
				--hmi side: UI.Alert request 
				EXPECT_HMICALL("UI.Alert", 
							{	
								alertStrings = 
								{
									{fieldName = "alertText1", fieldText = "alertText1"},
									{fieldName = "alertText2", fieldText = "alertText2"},
									{fieldName = "alertText3", fieldText = "alertText3"}
								},
								alertType = "BOTH",
								duration = 5000,
								progressIndicator = true
							})
					:Do(function(_,data)
						self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = self.applications[config.application1.registerAppInterfaceParams.appName], systemContext="ALERT"})
						
						--store id for response in next Test.
						AlertId = data.id

					end)
				
				--hmi side: TTS.Speak request 
				EXPECT_HMICALL("TTS.Speak", 
							{	
								ttsChunks = 
								{ 
									
									{ 
										text = "TTSChunk",
										type = "TEXT"
									}
								},
								speakType = "ALERT"
							})
					:Do(function(_,data)
					
						--store id for response in next Test.
						SpeakId = data.id 
						
						local function TTS_Started()
							self.hmiConnection:SendNotification("TTS.Started")
						end

						RUN_AFTER(TTS_Started, 500)

					end)
					:ValidIf(function(_,data)
						if #data.params.ttsChunks == 1 then
							return true
						else
							print("ttsChunks array in TTS.Speak request has wrong element number. Expected 1, actual "..tostring(#data.params.ttsChunks))
							return false
						end
					end)
			 
				--mobile side: Expected OnHMIStatus() notification
				EXPECT_NOTIFICATION("OnHMIStatus",
					{ systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "AUDIBLE" },
					{ systemContext = "ALERT", hmiLevel = "FULL", audioStreamingState = "ATTENUATED"})
					:Times(2)								
			end

			--Send OnEventChanged(PHONE_CALL,ON) during Alert(): App is changed to (LIMITED,NOT_AUDIBLE,ALERT) or (BACKGROUND,NOT_AUDIBLE,ALERT)
			function Test:Send_OnEventChanged_PHONE_CALL_ON_During_Alert() 
					
				self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= true, eventName="PHONE_CALL"})	
				
				--mobile side: Expected OnHMIStatus() notification
				EXPECT_NOTIFICATION("OnHMIStatus", { systemContext = "ALERT", hmiLevel=testData[i].hmiLevel,audioStreamingState=testData[i].audioStreamingState})
							
			end
			
			--Send Response to Alert(): App is changed to (LIMITED,NOT_AUDIBLE,MAIN) or (BACKGROUND,NOT_AUDIBLE,MAIN)
			function Test:HMI_Response_Alert() 
				--UI response
				self.hmiConnection:SendResponse(AlertId, "UI.Alert", "SUCCESS", { })
				
				self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = self.applications[config.application1.registerAppInterfaceParams.appName], systemContext="MAIN"})
				--SendOnSystemContext(self,"MAIN")


				--TTS response
				self.hmiConnection:SendResponse(SpeakId, "TTS.Speak", "SUCCESS", { })

				self.hmiConnection:SendNotification("TTS.Stopped")
				
				--HMI receiced StopSpeaking
				EXPECT_HMICALL("TTS.StopSpeaking")
				:Do(function(_,data)
												
						 --TTS StopSpeaking response
						self.hmiConnection:SendResponse(data.id,"TTS.StopSpeaking", "SUCCESS",{})
					end)
				
				--mobile side: Expected OnHMIStatus() notification
				EXPECT_NOTIFICATION("OnHMIStatus", { systemContext = "MAIN", hmiLevel=testData[i].hmiLevel,audioStreamingState=testData[i].audioStreamingState})

				--mobile side: Alert response
				EXPECT_RESPONSE(CorIdAlert, { success = true, resultCode = "SUCCESS" })	
			end
			
			--Send --Send OnEventChanged(PHONE_CALL,OFF): App is changed to (FULL,AUDIBLE,MAIN)
			function Test:Send_OnEventChanged_PHONE_CALL_OFF()
				self:onEventChanged(false,"FULL", "AUDIBLE",1)
			end
			
			--Postcondition: Unregister app
			commonSteps:UnregisterApplication()		
		end	
		--------------------------------------------------------------------------------------------------------------------
	
		--Description: App (LIMITED,ATTENUATED,ALERT), SDL must not change app's state to (LIMITED/BACKGROUND,NOT_AUDIBLE,ALERT)  when it receices OnEventChanged(PHONE_CALL,ON/OFF) from HMI
		
		for i =1, #testData do
			
			commonFunctions:newTestCasesGroup(testData[i].app.." app is (LIMITED,ATTENUATED,ALERT). HMI sends OnEventChanged(PHONE_CALL) with isActive:true/false")
	
			function Test:Change_App1_Params()
				self:change_App_Params(1,testData[i].appType,testData[i].isMedia)
			end
				
			commonSteps:RegisterAppInterface()
			commonSteps:ActivationApp()
			
			function Test: Bring_App_To_LIMITED()
				self:bring_App_To_LIMITED()							
			end
			
			--Send Alert() to bring app to (LIMITED,ATTENUATED,ALERT)
			function Test:Send_Alert() 
				--mobile side: Alert request 	
				CorIdAlert = self.mobileSession:SendRPC("Alert",
							{
								alertText1 = "alertText1",
								alertText2 = "alertText2",
								alertText3 = "alertText3",
								ttsChunks = 
								{ 
									
									{ 
										text = "TTSChunk",
										type = "TEXT",
									} 
								}, 
								duration = 5000,
								playTone = false,
								progressIndicator = true
							})

				
				--hmi side: UI.Alert request 
				EXPECT_HMICALL("UI.Alert", 
							{	
								alertStrings = 
								{
									{fieldName = "alertText1", fieldText = "alertText1"},
									{fieldName = "alertText2", fieldText = "alertText2"},
									{fieldName = "alertText3", fieldText = "alertText3"}
								},
								alertType = "BOTH",
								duration = 5000,
								progressIndicator = true
							})
					:Do(function(_,data)
						self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = self.applications[config.application1.registerAppInterfaceParams.appName], systemContext="ALERT"})
						
						--store id for response in next Test.
						AlertId = data.id

					end)
				
				--hmi side: TTS.Speak request 
				EXPECT_HMICALL("TTS.Speak", 
							{	
								ttsChunks = 
								{ 
									
									{ 
										text = "TTSChunk",
										type = "TEXT"
									}
								},
								speakType = "ALERT"
							})
					:Do(function(_,data)
					
						--store id for response in next Test.
						SpeakId = data.id 
						
						local function TTS_Started()
							self.hmiConnection:SendNotification("TTS.Started")
						end

						RUN_AFTER(TTS_Started, 500)

					end)
					:ValidIf(function(_,data)
						if #data.params.ttsChunks == 1 then
							return true
						else
							print("ttsChunks array in TTS.Speak request has wrong element number. Expected 1, actual "..tostring(#data.params.ttsChunks))
							return false
						end
					end)
			 
				--mobile side: Expected OnHMIStatus() notification
				EXPECT_NOTIFICATION("OnHMIStatus",
					{ systemContext = "ALERT", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE" },
					{ systemContext = "ALERT", hmiLevel = "LIMITED", audioStreamingState = "ATTENUATED"})
					:Times(2)								
			end

			--Send Emergency_Event(ON) during Alert(): App is changed to (LIMITED,NOT_AUDIBLE,ALERT) or (BACKGROUND,NOT_AUDIBLE,ALERT)
			function Test:Send_Emergency_Event_ON_During_Alert() 
				self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= true, eventName="PHONE_CALL"})	
				
				--mobile side: Expected OnHMIStatus() notification
				EXPECT_NOTIFICATION("OnHMIStatus", { systemContext = "ALERT", hmiLevel=testData[i].hmiLevel,audioStreamingState=testData[i].audioStreamingState})	
			end
			
			--Send Response to Alert(): App is changed to (LIMITED,NOT_AUDIBLE,MAIN) or (BACKGROUND,NOT_AUDIBLE,MAIN)
			function Test:HMI_Response_Alert() 
				--UI response
				self.hmiConnection:SendResponse(AlertId, "UI.Alert", "SUCCESS", { })
				
				self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = self.applications[config.application1.registerAppInterfaceParams.appName], systemContext="MAIN"})
				--SendOnSystemContext(self,"MAIN")


				--TTS response
				self.hmiConnection:SendResponse(SpeakId, "TTS.Speak", "SUCCESS", { })

				self.hmiConnection:SendNotification("TTS.Stopped")
				
				--HMI receiced StopSpeaking
				EXPECT_HMICALL("TTS.StopSpeaking")
				:Do(function(_,data)
												
						 --TTS StopSpeaking response
						self.hmiConnection:SendResponse(data.id,"TTS.StopSpeaking", "SUCCESS",{})
					end)
				
				--mobile side: Expected OnHMIStatus() notification
				EXPECT_NOTIFICATION("OnHMIStatus", { systemContext = "MAIN", hmiLevel=testData[i].hmiLevel,audioStreamingState=testData[i].audioStreamingState})

				--mobile side: Alert response
				EXPECT_RESPONSE(CorIdAlert, { success = true, resultCode = "SUCCESS" })
						
			end
			
			--Send Emergency_Event(OFF): App is changed to (FULL,AUDIBLE,MAIN)
			function Test:Send_Emergency_Event_OFF()
				self:onEventChanged(false,"LIMITED", "AUDIBLE",1)
			end
			
			--Postcondition: Unregister app
			commonSteps:UnregisterApplication()		
		end	
		--------------------------------------------------------------------------------------------------------------------
		
		--Description:  App is at BACKGROUND, SDL must not send OnHMIStatus() to  app when it receices OnEventChanged(PHONE_CALL,ON/OFF) from HMI
		commonFunctions:newTestCasesGroup("App is at (BACKGROUND,NOT_AUDIBLE,MAIN)")
		
		function Test:Change_App1_Params()
			self:change_App_Params(1,{"SOCIAL"},false)
		end
		
		commonSteps:RegisterAppInterface()
		commonSteps:ActivationApp()
	
		function Test:Change_App1_To_BACKGROUND()
			local cid = self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated",
				{
					appID = self.applications[config.application1.registerAppInterfaceParams.appName],
					reason = "GENERAL"
				})

			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})	
		end
		
		function Test:PhoneCall_Event_On_In_BACKGROUND()	
			--hmi side: send OnEventChanged(Phone_Call, isActive= true) notification to SDL
			self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= true, eventName="PHONE_CALL"})
			
			--Expect OnHMIStatus notification is not sent to BACKGROUND app
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
			:Times(0)
			commonTestCases:DelayedExp(1000) 
		end
	
		function Test:PhoneCall_Event_OFF_In_BACKGROUND()	
			--hmi side: send OnEventChanged(Phone_Call, isActive= true) notification to SDL
			self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= false, eventName="PHONE_CALL"})
			
			--Expect OnHMIStatus notification is not sent to BACKGROUND app
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
			:Times(0)
			commonTestCases:DelayedExp(1000) 
		end
		
		--Postcondition: Unregister app
		commonSteps:UnregisterApplication()		
		------------------------------------------------------------------------------------------------------------------
	
		--Description: Navi,Media and VOICE COM apps are at LIMITED and SDL receices OnEventChanged(PHONE_CALL,ON) from HMI, SDL will bring Navi app to (LIMITED,NOT_AUDIBLE,MAIN),Media and VOICE COM apps to (BACKGROUND,NOT_AUDIBLE,MAIN). When user tries to activate Navi app, SDL sends (FULL,NOT_AUDIBLE,MAIN) to navi app. After PHONE_CALL if OFF, SDL sends (FULL,AUDIBLE,MAIN) to Navi, and (LIMITED,AUDIBLE,MAIN)to Media and VOICE COM apps.
		commonFunctions:newTestCasesGroup("Navi,Media and Communication apps are at (LIMITED,AUDIBLE,MAIN) and try to activate Navi app during PHONE CALL")
		
		function Test:Change_App1_Params()
			self:change_App_Params(1,{"NAVIGATION"},false)
		end
		
		commonSteps:RegisterAppInterface()
		commonSteps:ActivationApp()
		
		function Test: Register_Communication_App()
			self:change_App_Params(2,{"COMMUNICATION"},false)
			self:registerAppInterface2()
		end
		
		function Test: Activate_Communication_App()
		
			local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application2.registerAppInterfaceParams.appName]})

			EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
				if data.result.code ~= 0 then
				quit()
				end
			end)
			
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			
		end
		
		function Test: Register_Media_App()
			self:change_App_Params(3,{"MEDIA"},true)
			self:registerAppInterface3()
		end
		
		function Test: Activate_Media_App()
			local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application3.registerAppInterfaceParams.appName]})

			EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
				if data.result.code ~= 0 then
				quit()
				end
			end)
		
			self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end
		
		function Test: Bring_App_To_LIMITED()
			local cid = self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated",
			{
				appID = self.applications[config.application3.registerAppInterfaceParams.appName],
				reason = "GENERAL"
			})

			self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end
		
		
		function Test:PhoneCall_Event_ON()
			self:onEventChanged(true,"LIMITED", "AUDIBLE")
		end
		
		--Should be debug till APPLINK-15164 is DONE
		-- function Test: Activate_Navigation_App_During_PHONE_CALL()
			-- local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})

			-- EXPECT_HMIRESPONSE(rid)
			-- :Do(function(_,data)
				-- if data.result.code ~= 0 then
				-- quit()
				-- end
			-- end)
			
			-- --HMI expectes to receive OnHMIStatus(FULL,NOT_AUDIBLE,MAIN) till APPLINK-15164 is DONE
			-- self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
		-- end
		
		
		function Test:PhoneCall_Event_OFF()
			--After APPLINK-15164 is DONE, the expected result should be
			--self:onEventChanged(false, "FULL", "AUDIBLE")
			self:onEventChanged(false,"LIMITED", "AUDIBLE")
		end
		
		--PostCondition: Unregister all apps
		function Test:Postcondition_Unregister_All_Apps()
				local cid = self.mobileSession:SendRPC("UnregisterAppInterface",{})
				self.mobileSession:ExpectResponse(cid, { success = true, resultCode = "SUCCESS"})
				:Timeout(2000)
				
		
				local cid = self.mobileSession1:SendRPC("UnregisterAppInterface",{})
				self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS"})
				:Timeout(2000)
				
				local cid = self.mobileSession2:SendRPC("UnregisterAppInterface",{})
				self.mobileSession2:ExpectResponse(cid, { success = true, resultCode = "SUCCESS"})
				:Timeout(2000)
		end
		--------------------------------------------------------------------------------------------------
		
		--Description: Navi app is at (FULL, AUDIBLE,MAIN), VOICE COM and MEDIA apps are at (LIMITED, AUDIBLE,MAIN). SDL receices OnEventChanged(PHONE_CALL,ON) from HMI, SDL will bring Navi app to (LIMITED,NOT_AUDIBLE,MAIN),other apps to (BACKGROUND,NOT_AUDIBLE,MAIN). When user tries to activate Media app, SDL sends (FULL, NOT_AUDIBLE,MAIN) to this app. After PHONE CALL is OFF, SDL sends FULL, AUDIBLE,MAIN) to media app and (LIMITED,AUDIBLE,MAIN) to Navi and VOICE COM apps
		
		commonFunctions:newTestCasesGroup("Media and Communication apps are at (LIMITED,AUDIBLE,MAIN). Navi app is at(FULL, AUDIBLE,MAIN) and try to activate Media app during PHONE CALL.")
		
		function Test:Change_App1_Params()
			self:change_App_Params(1,{"NAVIGATION"},false)
		end
		
		commonSteps:RegisterAppInterface()
				
		function Test: Register_Communication_App()
			self:change_App_Params(2,{"COMMUNICATION"},false)
			self:registerAppInterface2()
		end
		
		function Test: Activate_Communication_App()
			local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application2.registerAppInterfaceParams.appName]})

			EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
				if data.result.code ~= 0 then
				quit()
				end
			end)
			
			self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end
		
		function Test: Register_MEDIA_App()
			self:change_App_Params(3,{"MEDIA"},true)
			self:registerAppInterface3()
		end
		
		function Test: Activate_MEDIA_App()
			local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application3.registerAppInterfaceParams.appName]})

			EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
				if data.result.code ~= 0 then
				quit()
				end
			end)
		
			self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end
		
		function Test: Activate_NAVIGATION_App()
			local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})

			EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
				if data.result.code ~= 0 then
				quit()
				end
			end)
		
			self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end
		
		function Test:PhoneCall_Event_ON()
			self:onEventChanged(true,"LIMITED", "AUDIBLE")
		end
		
		--Should be debug till APPLINK-15164 is DONE
		-- function Test: Activate_Media_App_During_PHONE_CALL()
			-- local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application3.registerAppInterfaceParams.appName]})

			-- EXPECT_HMIRESPONSE(rid)
			-- :Do(function(_,data)
				-- if data.result.code ~= 0 then
				-- quit()
				-- end
			-- end)
			
			-- --HMI expectes to receive OnHMIStatus(FULL,NOT_AUDIBLE,MAIN) till APPLINK-15164 is DONE
			-- self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
		-- end
		
		
		function Test:PhoneCall_Event_OFF()
			self:onEventChanged(false,"FULL", "AUDIBLE")
			
			--After APPLINK-15164 is DONE, the expected result should be
			-- self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= false, eventName="PHONE_CALL"})
			
			--Expect notifications on mobile sides
			-- self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			-- self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			-- self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end
		--------------------------------------------------------------------------------------------------
		--Description: Navi app is at (FULL, AUDIBLE,MAIN), Com app and Medid app are at (LIMITED, AUDIBLE,MAIN). SDL receices OnEventChanged(PHONE_CALL,ON/OFF) from HMI, SDL will bring Navi app to (LIMITED,NOT_AUDIBLE,MAIN),other apps to (BACKGROUND,NOT_AUDIBLE,MAIN) then resttore
		
		commonFunctions:newTestCasesGroup("Media and Communication apps are at (LIMITED,AUDIBLE,MAIN). Navi app is at(FULL, AUDIBLE,MAIN) and try to activate VOICE COM app during PHONE CALL.")
		
		function Test:Change_App1_Params()
			self:change_App_Params(1,{"NAVIGATION"},false)
		end
		
		commonSteps:RegisterAppInterface()
		
		function Test: Register_COMMUNICATION_App()
			self:change_App_Params(2,{"COMMUNICATION"},false)
			self:registerAppInterface2()
		end
		
		function Test: Activate_COMMUNICATION_App()
			local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application2.registerAppInterfaceParams.appName]})

			EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
				if data.result.code ~= 0 then
				quit()
				end
			end)
			
			self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end
		
		function Test: Register_MEDIA_App()
			self:change_App_Params(3,{"MEDIA"},true)
			self:registerAppInterface3()
		end
		
		function Test: Activate_MEDIA_App()
			local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application3.registerAppInterfaceParams.appName]})

			EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
				if data.result.code ~= 0 then
				quit()
				end
			end)
		
			self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end
		
		function Test: Activate_NAVIGATION_App()
			local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})

			EXPECT_HMIRESPONSE(rid)
			:Do(function(_,data)
				if data.result.code ~= 0 then
				quit()
				end
			end)
		
			self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end
		
		function Test:PhoneCall_Event_ON()
			self:onEventChanged(true,"LIMITED", "AUDIBLE")
		end
		
		--Should be debug till APPLINK-15164 is DONE
		-- function Test: Activate_VOICECOM_App_During_PHONE_CALL()
			-- local rid = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application2.registerAppInterfaceParams.appName]})

			-- EXPECT_HMIRESPONSE(rid)
			-- :Do(function(_,data)
				-- if data.result.code ~= 0 then
				-- quit()
				-- end
			-- end)
			
			-- --HMI expectes to receive OnHMIStatus(FULL,NOT_AUDIBLE,MAIN) till APPLINK-15164 is DONE
			-- self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
		-- end
		

		function Test:PhoneCall_Event_OFF()
			self:onEventChanged(false,"FULL", "AUDIBLE")
			
			--After APPLINK-15164 is DONE, the expected result should be
			-- self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged",{isActive= false, eventName="PHONE_CALL"})
			
			--Expect notifications on mobile sides
			--self.mobileSession1:ExpectNotification("OnHMIStatus",{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			--self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
			-- self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
		end
		--------------------------------------------------------------------------------------------------
		
	--End Test suit Different HMIStatus
-----------------------------------------------------------------------------------------------------------------