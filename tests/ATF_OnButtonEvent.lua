---------------------------------------------------------------------------------------------
--ATF version: 2.2
--Modified date: 01/Dec/2015
--Author: Ta Thanh Dong
---------------------------------------------------------------------------------------------
Test = require('user_modules/OnButtonEvent_connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')


---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
require('user_modules/AppTypes')

APIName = "OnButtonEvent" -- set API name

--List of app name and appid that used in script. appid will be set when registering application 
Apps = {}
Apps[1] = {}
Apps[1].appName = config.application1.registerAppInterfaceParams.appName 
Apps[2] = {}
Apps[2].appName = config.application2.registerAppInterfaceParams.appName 	
Apps[3] = {}
Apps[3].appName = config.application3.registerAppInterfaceParams.appName 	

				
local ButtonPressModes = {"SHORT", "LONG"}	
local CustomButtonIDs = {0, 65535}

--Set list of button for media/non-media application
local ButtonNames_WithoutCUSTOM_BUTTON
local ButtonNames_WithoutCUSTOM_BUTTON_OK
if config.application1.registerAppInterfaceParams.isMediaApplication then


	ButtonNames_WithoutCUSTOM_BUTTON = {
						"OK",
						"SEEKLEFT",
						"SEEKRIGHT",
						"TUNEUP",
						"TUNEDOWN",
						"PRESET_0",
						"PRESET_1",
						"PRESET_2",
						"PRESET_3",
						"PRESET_4",
						"PRESET_5",
						"PRESET_6",
						"PRESET_7",
						"PRESET_8",
						"PRESET_9",
						"SEARCH"
					}
										
	ButtonNames_WithoutCUSTOM_BUTTON_OK = {
						"SEEKLEFT",
						"SEEKRIGHT",
						"TUNEUP",
						"TUNEDOWN",
						"PRESET_0",
						"PRESET_1",
						"PRESET_2",
						"PRESET_3",
						"PRESET_4",
						"PRESET_5",
						"PRESET_6",
						"PRESET_7",
						"PRESET_8",
						"PRESET_9",
						"SEARCH"
					}
	-- group of media buttons, this group  should be update also with PRESETS 0-9 due to APPLINK-14516 (APPLINK-14503)
	MediaButtons = {
						"SEEKLEFT",
						"SEEKRIGHT",
						"TUNEUP",
						"TUNEDOWN",
						-- "PRESET_0",
						-- "PRESET_1",
						-- "PRESET_2",
						-- "PRESET_3",
						-- "PRESET_4",
						-- "PRESET_5",
						-- "PRESET_6",
						-- "PRESET_7",
						-- "PRESET_8",
						-- "PRESET_9"
					}			
else --Non-media app

	ButtonNames_WithoutCUSTOM_BUTTON = {
						"OK",
						"PRESET_0",
						"PRESET_1",
						"PRESET_2",
						"PRESET_3",
						"PRESET_4",
						"PRESET_5",
						"PRESET_6",
						"PRESET_7",
						"PRESET_8",
						"PRESET_9",
						"SEARCH"
					}
										
	ButtonNames_WithoutCUSTOM_BUTTON_OK = {
						"PRESET_0",
						"PRESET_1",
						"PRESET_2",
						"PRESET_3",
						"PRESET_4",
						"PRESET_5",
						"PRESET_6",
						"PRESET_7",
						"PRESET_8",
						"PRESET_9",
						"SEARCH"
					}		
end



	
---------------------------------------------------------------------------------------------
------------------------------------------Common functions-----------------------------------
---------------------------------------------------------------------------------------------

--Functions to simulate action press button on HMI and verification on Mobile and HMI
---------------------------------------------------------------------------------------------
--1. Press button
function Test.pressButton(Input_Name, Input_ButtonPressMode, modeDOWNValue, modeUPValue)

	if modeUPValue == nil then
		modeUPValue = "BUTTONUP"
	end
	if modeDOWNValue == nil then
		modeDOWNValue = "BUTTONDOWN"
	end
	

	--hmi side: send OnButtonEvent, OnButtonPress
	Test.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = Input_Name, mode = modeDOWNValue})
	
	if Input_ButtonPressMode == "SHORT" then
	
		Test.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = Input_Name, mode = modeUPValue})
		Test.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = Input_Name, mode = Input_ButtonPressMode})	
		
	else
	
		Test.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = Input_Name, mode = Input_ButtonPressMode})	
		Test.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = Input_Name, mode = modeUPValue})
		
	end
end	

--2. Press CUSTOM_BUTTON
function Test.pressButton_CUSTOM_BUTTON(Input_Name, Input_ButtonPressMode, Input_customButtonID, Input_appID)

	--hmi side: send OnButtonEvent, OnButtonPress
	Test.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = Input_Name, mode = "BUTTONDOWN", customButtonID = Input_customButtonID, appID = Input_appID})
	
	if Input_ButtonPressMode == "SHORT" then
	
		Test.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = Input_Name, mode = "BUTTONUP", customButtonID = Input_customButtonID, appID = Input_appID})
		Test.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = Input_Name, mode = Input_ButtonPressMode, customButtonID = Input_customButtonID, appID = Input_appID})	
		
	else
	
		Test.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = Input_Name, mode = Input_ButtonPressMode, customButtonID = Input_customButtonID, appID = Input_appID})	
		Test.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = Input_Name, mode = "BUTTONUP", customButtonID = Input_customButtonID, appID = Input_appID})
		
	end

end




--Functions to verify result on Mobile
---------------------------------------------------------------------------------------------
--1. Verify press button result on mobile
function Test.verifyPressButtonResult(Input_Name, Input_ButtonPressMode)
		
		local BUTTONDOWN = false
		local BUTTONUP = false
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", 
												{buttonName = Input_Name, buttonEventMode = "BUTTONUP"},
												{buttonName = Input_Name, buttonEventMode = "BUTTONDOWN"})
		:Times(2)
						
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = Input_Name, buttonPressMode = Input_ButtonPressMode})
end	


--2. Verify SDL ignores notification
function Test.verifySDLIgnoresNotification(OnButtonEventNumber)
		
		commonTestCases:DelayedExp(1000)
		
		if OnButtonEventNumber == nil then
			OnButtonEventNumber = 0
		end
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(OnButtonEventNumber)
					
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {})
		:Times(0)
end	


--3. Verify press button result on mobile
function Test.verifyPressButtonResult_IgnoreWrongButtonEventMode(Input_Name, Input_ButtonPressMode, modeDOWNValue, modeUPValue)

		if modeDOWNValue == "BUTTONDOWN" and modeUPValue ~= "BUTTONUP" then -- testing for wrong mode when SDL should send mode = BUTTONDOWN
			--mobile side: expected OnButtonEvent notification
			EXPECT_NOTIFICATION("OnButtonEvent", {buttonName = Input_Name, buttonEventMode = "BUTTONDOWN"})
			
		elseif modeDOWNValue ~= "BUTTONDOWN" and modeUPValue == "BUTTONUP" then -- testing for wrong mode when SDL should send mode = BUTTONUP
			--mobile side: expected OnButtonEvent notification
			EXPECT_NOTIFICATION("OnButtonEvent", {buttonName = Input_Name, buttonEventMode = "BUTTONUP"})
		else
			commonFunctions:printError("Error: in verifyPressButtonResult_IgnoreWrongButtonEventMode function")
		end
		
		
		
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = Input_Name, buttonPressMode = Input_ButtonPressMode})
end	


--4. Verify press button result on mobile for CUSTOM_BUTTON
function Test.verifyPressButtonResult_CUSTOM_BUTTON(Input_Name, Input_ButtonPressMode, Input_customButtonID, Input_appID)
		

		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", 
												{buttonName = Input_Name, buttonEventMode = "BUTTONDOWN", customButtonID = Input_customButtonID},
												{buttonName = Input_Name, buttonEventMode = "BUTTONUP", customButtonID = Input_customButtonID}
		)
		:Times(2)
					
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = Input_Name, buttonPressMode = Input_ButtonPressMode, customButtonID = Input_customButtonID})
end	




--Functions to create common test cases
---------------------------------------------------------------------------------------------

--1. Press button and SDL forwards the notification to Mobile
local function TC_SendOnButtonEvent_SUCCESS(Input_Name, Input_ButtonPressMode, TestCaseName)

	Test[TestCaseName .. "_name_" .. Input_Name .."_mode_" .. Input_ButtonPressMode] = function(self)
		
			--Press button on HMI
			self.pressButton(Input_Name, Input_ButtonPressMode)
			
			--Verify result on Mobile
			self.verifyPressButtonResult(Input_Name, Input_ButtonPressMode)
	end		

end	

--2. Press button and SDL ignores the notification
local function TC_SendOnButtonEvent_IsIgnored(Input_Name, Input_ButtonPressMode, TestCaseName, OnButtonEventNumber)
	Test[TestCaseName .. "_name_" .. Input_Name .."_mode_" .. Input_ButtonPressMode] = function(self)
		
		--Press button on HMI
		self.pressButton(Input_Name, Input_ButtonPressMode)
		
		--Verify result on Mobile
		self.verifySDLIgnoresNotification(OnButtonEventNumber)
		
	end
	
end	

--3. Press button and SDL ignores the notification
local function TC_SendOnButtonEvent_mode_IsInvalid_IsIgnored(Input_Name, Input_ButtonPressMode, TestCaseName, modeDOWNValue, modeUPValue)
	Test[TestCaseName .. "_name_" .. Input_Name .."_mode_" .. Input_ButtonPressMode .. "_Event1Mode_" .. modeDOWNValue .. "_Event2Mode_" .. modeUPValue] = function(self)
		
		--Press button on HMI
		self.pressButton(Input_Name, Input_ButtonPressMode, modeDOWNValue, modeUPValue)
		
		
		--Verify result on Mobile
		self.verifyPressButtonResult_IgnoreWrongButtonEventMode(Input_Name, Input_ButtonPressMode, modeDOWNValue, modeUPValue)
		
	end
	
end		




--4. Press CUSTOM_BUTTON and SDL forwards the notification to Mobile
local function TC_SendOnButtonEvent_CUSTOM_BUTTON_SUCCESS(Input_Name, Input_ButtonPressMode, Input_customButtonID, Input_appNumber, TestCaseName)
	Test[TestCaseName .. "_name_" .. Input_Name .."_mode_" .. Input_ButtonPressMode .. "_customButtonID_" .. Input_customButtonID] = function(self)
		
		--Press button on HMI
		self.pressButton_CUSTOM_BUTTON(Input_Name, Input_ButtonPressMode, Input_customButtonID, Apps[Input_appNumber].appID)
		
		--Verify result on Mobile
		self.verifyPressButtonResult_CUSTOM_BUTTON(Input_Name, Input_ButtonPressMode, Input_customButtonID, Apps[Input_appNumber].appID)
		
	end
	
end	

--5. Press CUSTOM_BUTTON and SDL ignores the notification
local function TC_SendOnButtonEvent_CUSTOM_BUTTON_IsIgnored(Input_Name, Input_ButtonPressMode, Input_customButtonID, Input_appNumber, TestCaseName)
	Test[TestCaseName .. "_name_" .. Input_Name .."_mode_" .. Input_ButtonPressMode .. "_customButtonID_" .. Input_customButtonID] = function(self)
		
		--Press button on HMI
		self.pressButton_CUSTOM_BUTTON(Input_Name, Input_ButtonPressMode, Input_customButtonID, Apps[Input_appNumber].appID)
		
		--Verify result on Mobile
		self.verifySDLIgnoresNotification()
		
	end
	
end	



---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

	commonSteps:DeleteLogsFileAndPolicyTable()
	
	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Preconditions")
	
	--1. Activate application
	commonSteps:ActivationApp()

	
	
	--2. Create PT that allowed OnButtonEvent in Base-4 group and update PT
	local PermissionLines_OnButtonEvent = 
[[					"OnButtonEvent": {
						"hmi_levels": [
						  "FULL"
						]
					  }]] .. ", \n"

	local PermissionLines_OnButtonPress = 
[[					"OnButtonPress": {
						"hmi_levels": [
						  "FULL"
						]
					  }]] .. ", \n"

	local PermissionLines_Show = 
[[					"Show": {
						"hmi_levels": [
						  "FULL"
						]
					  }]] .. ", \n"
	local PermissionLinesForBase4 = PermissionLines_OnButtonEvent .. PermissionLines_OnButtonPress .. PermissionLines_Show
	local PermissionLinesForGroup1 = nil
	local PermissionLinesForApplication = nil
	
	--TODO: PT is blocked by ATF defect APPLINK-19188
	--local PTName = testCasesForPolicyTable:createPolicyTableFile(PermissionLinesForBase4, PermissionLinesForGroup1, PermissionLinesForApplication, {"OnButtonEvent", "OnButtonPress", "Show"})	
	--testCasesForPolicyTable:updatePolicy(PTName)		
	
	
	--3. Get appID Value on HMI side
	function Test:GetAppID()
		Apps[1].appID = self.applications[Apps[1].appName]
	end

		
	--4. Send Show request with buttonIDs are lower and upper bounds
	Test["Show_buttonID_IsLowerUpperBound"] = function(self)
	
		--mobile side: request parameters
		local Request = 
		{
			softButtons = 
			{
				{
					text = "Button1",
					systemAction = "DEFAULT_ACTION",
					type = "TEXT",
					isHighlighted = false,																
					softButtonID = CustomButtonIDs[1]
				},
				{
					text = "Button2",
					systemAction = "DEFAULT_ACTION",
					type = "TEXT",
					isHighlighted = false,																
					softButtonID = CustomButtonIDs[2]
				}
			}
		}
		
		--mobile side: sending Show request
		local cid = self.mobileSession:SendRPC("Show", Request)
		
		--hmi side: expect UI.Show request
		EXPECT_HMICALL("UI.Show")
		:Do(function(_,data)
			--hmi side: sending UI.Show response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
	
		--mobile side: expect SetGlobalProperties response
		EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
		
	end

	

	--5. SubscribeButton
	for i=1,#ButtonNames_WithoutCUSTOM_BUTTON do					
		Test["SubscribeButton_" .. tostring(ButtonNames_WithoutCUSTOM_BUTTON[i])] = function(self)

			--mobile side: sending SubscribeButton request
			local cid = self.mobileSession:SendRPC("SubscribeButton",
			{
				buttonName = ButtonNames_WithoutCUSTOM_BUTTON[i]

			})

			--expect Buttons.OnButtonSubscription
			EXPECT_HMINOTIFICATION("Buttons.OnButtonSubscription", {appID = Apps[1].appID, isSubscribed = true, name = ButtonNames_WithoutCUSTOM_BUTTON[i]})

			--mobile side: expect SubscribeButton response
			EXPECT_RESPONSE(cid, {success = true, resultCode = "SUCCESS"})
			
			EXPECT_NOTIFICATION("OnHashChange", {})
			
		end
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
----------------------------------Check normal cases of HMI notification---------------------------
-----------------------------------------------------------------------------------------------
--Requirement id in JAMA or JIRA: 	
	--SDLAQ-CRS-171: OnButtonEvent_v2_0: Notifies application of LONG/SHORT press events for buttons to which the application is subscribed.
	--SDLAQ-CRS-3065: OnButtonEvent to media app in FULL
	--SDLAQ-CRS-3066: OnButtonEvent to media app in LIMITED

	
	--Verification criteria: 
		--1. The OnButtonEvent of DOWN and OnButtonEvent of UP is sent by SDL on each pressing of every subscribed hardware or software preset HMI button.
		--2. The OnButtonEvent of DOWN and OnButtonEvent of UP is sent by SDL on each pressing of every subscribed custom HMI button.
----------------------------------------------------------------------------------------------

	--List of parameters:
	--1. buttonName: type=ButtonName
	--2. buttonEventMode: type=ButtonEventMode
	--3. customButtonID: type=Integer, minvalue=0, maxvalue=65536 (If ButtonName is "CUSTOM_BUTTON", this references the integer ID passed by a custom button. (e.g. softButton ID))
----------------------------------------------------------------------------------------------
	
	
	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Test suite: Check normal cases of HMI notification")


----------------------------------------------------------------------------------------------
--Test case #1: Checks OnButtonEvent notification with valid values of buttonName, buttonPressMode and customButtonID parameters
----------------------------------------------------------------------------------------------

	--1.1. Verify buttonName and buttonEventMode (UP and DOWN) parameters with valid values
	for i =1, #ButtonNames_WithoutCUSTOM_BUTTON do
		for j =1, #ButtonPressModes do
			TC_SendOnButtonEvent_SUCCESS(ButtonNames_WithoutCUSTOM_BUTTON[i], ButtonPressModes[j], "OnButtonEvent")
		end
	end
	

	--1.2. Verify CUSTOM_BUTTON: customButtonID and mode parameters are valid values
	for j =1, #ButtonPressModes do
		for n = 1, #CustomButtonIDs do
			TC_SendOnButtonEvent_CUSTOM_BUTTON_SUCCESS("CUSTOM_BUTTON", ButtonPressModes[j], CustomButtonIDs[n], 1, "OnButtonEvent")
		end
	end

		
	
	
----------------------------------------------------------------------------------------------
--Test case #2: Checks OnButtonEvent is NOT sent to application after SDL received OnButtonEvent with invalid buttonName and buttonPressMode
----------------------------------------------------------------------------------------------

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Test suite: Check invalid buttonName")
	
	--2.1. Verify buttonName is invalid value
	local InvalidButtonNames = {
									{value = "", name = "IsEmtpy"},
									{value = "ANY", name = "NonExist"},
									{value = 123, name = "WrongDataType"}
								}
								
	for i =1, #InvalidButtonNames do
		for j =1, #ButtonPressModes do
			TestCaseName = "OnButtonEvent_buttonName_IsInvalid_" .. InvalidButtonNames[i].name
			TC_SendOnButtonEvent_IsIgnored(InvalidButtonNames[i].value, ButtonPressModes[j], TestCaseName)
		end
	end
	
	
	--2.2. Verify buttonEventMode is invalid value (not UP and DOWN)	
	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Test suite: Check invalid mode")
	
	local InvalidButtonEventModes = {
										{value = "", name = "IsEmtpy"},
										{value = "ANY", name = "NonExist"},
										{value = 123, name = "WrongDataType"}
									}
	
	
	for i =1, #ButtonNames_WithoutCUSTOM_BUTTON do
		for j =1, #ButtonPressModes do
			for n = 1, #InvalidButtonEventModes do
				
				--Invalid mode in OnButtonEvent when mode should be DOWN
				TestCaseName = "OnButtonEvent_mode_IsInvalidWhenItShouldBeDOWN_".. InvalidButtonEventModes[n].name
				TC_SendOnButtonEvent_mode_IsInvalid_IsIgnored(ButtonNames_WithoutCUSTOM_BUTTON[i], ButtonPressModes[j], TestCaseName, InvalidButtonEventModes[n].value, "BUTTONUP")
				
				--Invalid mode in OnButtonEvent when mode should be UP
				TestCaseName = "OnButtonEvent_mode_IsInvalidWhenItShouldBeUP_".. InvalidButtonEventModes[n].name
				TC_SendOnButtonEvent_mode_IsInvalid_IsIgnored(ButtonNames_WithoutCUSTOM_BUTTON[i], ButtonPressModes[j], TestCaseName, "BUTTONDOWN", InvalidButtonEventModes[n].value)
			end
		end
	end
	
			

	--2.3. Verify customButtonID is invalid value
	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Test suite: Check invalid CustomButtonID")
	
	local InvalidCustomButtonIDs = {
										{value = CustomButtonIDs[1]-1, name = "IsOutLowerBound"},
										{value = CustomButtonIDs[2] + 1, name = "IsOutUpperBound"},
										{value = "1", name = "WrongDataType"}
									}
	local appNumber = 1
	for j =1, #ButtonPressModes do
		for n = 1, #InvalidCustomButtonIDs do
			TestCaseName = "OnButtonEvent_customButtonID_IsInvalid_" .. InvalidCustomButtonIDs[n].name
			TC_SendOnButtonEvent_CUSTOM_BUTTON_IsIgnored("CUSTOM_BUTTON", ButtonPressModes[j], InvalidCustomButtonIDs[n].value, appNumber, TestCaseName)
		end
	end

	--2.4. Verify appID is invalid value.
	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Test suite: Check invalid appID")
	local Invalid_appIDs = {
										{value = 123456, name = "IsNonexistent"},
										{value = "1", name = "WrongDataType"}
									}
	for i  = 1, #Invalid_appIDs do
		Test["OnButtonEvent_appID_" .. Invalid_appIDs[i].name]  = function(self)
			
			commonTestCases:DelayedExp(1000)
			
			--hmi side: send OnButtonEvent, OnButtonPress
			self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "CUSTOM_BUTTON", mode = "BUTTONDOWN", customButtonID = CustomButtonIDs[1], appID = Invalid_appIDs[i].value})
			self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "CUSTOM_BUTTON", mode = "BUTTONUP", customButtonID = CustomButtonIDs[1], appID = Invalid_appIDs[i].value})
			self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "CUSTOM_BUTTON", mode = "SHORT", customButtonID = CustomButtonIDs[1], appID = Apps[1].appID})	
			
			--mobile side: expected OnButtonEvent notification
			EXPECT_NOTIFICATION("OnButtonEvent", {})
			:Times(0)
			
			--mobile side: expected OnButtonPress notification
			EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "CUSTOM_BUTTON", buttonPressMode = "SHORT"})	
			
		end
	end

	

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK IV----------------------------------------
----------------------------Check special cases of HMI notification---------------------------
----------------------------------------------------------------------------------------------
--Requirement id in JAMA or JIRA: 	
	--APPLINK-14765: SDL must cut off the fake parameters from requests, responses and notifications received from HMI

-----------------------------------------------------------------------------------------------

--List of test cases for special cases of HMI notification:
	--1. InvalidJsonSyntax
	--2. InvalidStructure
	--3. FakeParams 
	--4. FakeParameterIsFromAnotherAPI
	--5. MissedmandatoryParameters
	--6. MissedAllPArameters
	--7. SeveralNotifications with the same values
	--8. SeveralNotifications with different values
----------------------------------------------------------------------------------------------

local function SpecialResponseChecks()

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Test suite: Check special cases of HMI notification")


	
	--1. Verify OnButtonEvent with invalid Json syntax
	----------------------------------------------------------------------------------------------
	function Test:OnButtonEvent_InvalidJsonSyntax()
		
		commonTestCases:DelayedExp(1000)
		
		--hmi side: send OnButtonEvent 
		--":" is changed by ";" after "jsonrpc"
		self.hmiConnection:Send('{"jsonrpc";"2.0","params":{"mode":"UP","name":"PRESET_0"},"method":"Buttons.OnButtonEvent"}')
	
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(0)
					
	end
	
	
	--2. Verify OnButtonEvent with invalid structure
	----------------------------------------------------------------------------------------------	
	function Test:OnButtonEvent_InvalidStructure()
	
		commonTestCases:DelayedExp(1000)
		
		--hmi side: send OnButtonEvent 
		--method is moved into params parameter
		self.hmiConnection:Send('{"jsonrpc":"2.0","params":{"mode":"UP","name":"PRESET_0","method":"Buttons.OnButtonEvent"}}')
	
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(0)
	end
	
	
	
	--3. Verify OnButtonEvent with FakeParams
	----------------------------------------------------------------------------------------------
	function Test:OnButtonEvent_FakeParams()

		--hmi side: send OnButtonEvent, OnButtonPress
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONDOWN", fake = 123})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONUP", fake = 123})
		self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "PRESET_0", mode = "SHORT"})	
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {buttonName = "PRESET_0", buttonEventMode = "BUTTONDOWN"},
											{buttonName = "PRESET_0", buttonEventMode = "BUTTONUP"})
		:Times(2)
		:ValidIf(function(_,data)
								
			if data.payload.fake then
				commonFunctions:printError(" SDL forwards fake parameter to mobile ")
				return false
			else
				return true
			end
		end)
				
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "PRESET_0", buttonPressMode = "SHORT"})
		
	end
	
	
	--4. Verify OnButtonEvent with FakeParameterIsFromAnotherAPI
	function Test:OnButtonEvent_FakeParameterIsFromAnotherAPI()
	
		--hmi side: send OnButtonEvent, OnButtonPress
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONDOWN", sliderPosition = 1})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONUP", sliderPosition = 1})
		self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "PRESET_0", mode = "SHORT"})	
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {buttonName = "PRESET_0", buttonEventMode = "BUTTONDOWN"},
											{buttonName = "PRESET_0", buttonEventMode = "BUTTONUP"})
		:Times(2)
		:ValidIf(function(_,data)
								
			if data.payload.sliderPosition then
				commonFunctions:printError(" SDL forwards fake parameter to mobile ")
				return false
			else
				return true
			end
		end)
				
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "PRESET_0", buttonPressMode = "SHORT"})
		
	end
	
		
	
	--5. Verify OnButtonEvent misses mandatory parameter
	----------------------------------------------------------------------------------------------
	function Test:OnButtonEvent_name_IsMissed()
	
		commonTestCases:DelayedExp(1000)
		
		--hmi side: send OnButtonEvent, OnButtonPress
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{mode = "BUTTONDOWN"})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{mode = "BUTTONUP"})
		self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "PRESET_0", mode = "SHORT"})	
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(0)
		
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "PRESET_0", buttonPressMode = "SHORT"})
		
	end
	
	function Test:OnButtonEvent_mode_IsMissed()
	
		commonTestCases:DelayedExp(1000)
		
		--hmi side: send OnButtonEvent, OnButtonPress
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0"})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0"})
		self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "PRESET_0", mode = "SHORT"})	
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(0)
		
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "PRESET_0", buttonPressMode = "SHORT"})	
	end
	
	function Test:OnButtonEvent_appID_IsMissed()
		
		commonTestCases:DelayedExp(1000)
		
		--hmi side: send OnButtonEvent, OnButtonPress
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "CUSTOM_BUTTON", mode = "BUTTONDOWN", customButtonID = CustomButtonIDs[1]})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "CUSTOM_BUTTON", mode = "BUTTONUP", customButtonID = CustomButtonIDs[1]})
		self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "CUSTOM_BUTTON", mode = "SHORT", customButtonID = CustomButtonIDs[1], appID = Apps[1].appID})	
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(0)
		
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "CUSTOM_BUTTON", buttonPressMode = "SHORT"})	
		
	end

	function Test:OnButtonEvent_customButtonID_IsMissed()
		
		commonTestCases:DelayedExp(1000)
		
		--hmi side: send OnButtonEvent, OnButtonPress
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "CUSTOM_BUTTON", mode = "BUTTONDOWN", appID = Apps[1].appID})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "CUSTOM_BUTTON", mode = "BUTTONUP", appID = Apps[1].appID})
		self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "CUSTOM_BUTTON", mode = "SHORT", customButtonID = CustomButtonIDs[1], appID = Apps[1].appID})	
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(0)
		
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "CUSTOM_BUTTON", buttonPressMode = "SHORT"})	
		
	end
	
	function Test:OnButtonEvent_customButtonID_and_appID_AreMissed()
		
		commonTestCases:DelayedExp(1000)
		
		--hmi side: send OnButtonEvent, OnButtonPress
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "CUSTOM_BUTTON", mode = "BUTTONDOWN"})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "CUSTOM_BUTTON", mode = "BUTTONUP"})
		self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "CUSTOM_BUTTON", mode = "SHORT", customButtonID = CustomButtonIDs[1], appID = Apps[1].appID})	
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(0)
		
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "CUSTOM_BUTTON", buttonPressMode = "SHORT"})
		
	end
	
	
	--6. Verify OnButtonEvent MissedAllPArameters: The same as case 5.
	----------------------------------------------------------------------------------------------
	function Test:OnButtonEvent_AllParameters_AreMissed()
		
		commonTestCases:DelayedExp(1000)
		
		--hmi side: send OnButtonEvent, OnButtonPress
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{})
		self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "PRESET_0", mode = "SHORT"})	
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(0)
		
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "PRESET_0", buttonPressMode = "SHORT"})
		
	end
	
	--7. Verify OnButtonEvent with SeveralNotifications_WithTheSameValues
	----------------------------------------------------------------------------------------------	
	function Test:OnButtonEvent_SeveralNotifications_WithTheSameValues()
		--hmi side: send OnButtonEvent, OnButtonPress
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONDOWN"})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONDOWN"})
		self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "PRESET_0", mode = "SHORT"})

		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {buttonName = "PRESET_0", buttonEventMode = "BUTTONDOWN"})
		:Times(2)
		
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "PRESET_0", buttonPressMode = "SHORT"})
		
	end
	
		
	--8. Verify OnButtonEvent with SeveralNotifications_WithDifferentValues
	----------------------------------------------------------------------------------------------
	function Test:OnButtonEvent_SeveralNotifications_WithDifferentValues()
		--hmi side: send OnButtonEvent, OnButtonPress
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONDOWN"})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONUP"})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONDOWN"})
		self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONUP"})
		self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "PRESET_0", mode = "SHORT"})
		
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(4)
		
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "PRESET_0", buttonPressMode = "SHORT"})
		
	end
	
	
end

SpecialResponseChecks()	

	
-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Description: Check all resultCodes

--Requirement id in JAMA: 
	--N/A
	
--Verification criteria: Verify SDL behaviors in different states of policy table: 
	--1. Notification is not exist in PT => DISALLOWED in policy table, SDL ignores the notification
	--2. Notification is exist in PT but it has not consented yet by user => DISALLOWED in policy table, SDL ignores the notification
	--3. Notification is exist in PT but user does not allow function group that contains this notification => USER_DISALLOWED in policy table, SDL ignores the notification
	--4. Notification is exist in PT and user allow function group that contains this notification
----------------------------------------------------------------------------------------------

	local function ResultCodeChecks()

		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup("Test suite: Checks All Result Codes")
		
		--Send notification and check it is ignored
		local function TC_OnButtonEvent_DISALLOWED_USER_DISALLOWED(TestCaseName)
			Test[TestCaseName] = function(self)
		
				commonTestCases:DelayedExp(1000)

				--hmi side: send OnButtonEvent, OnButtonPress
				self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONDOWN"})
				self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONUP"})
				self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "PRESET_0", mode = "SHORT"})	
				
				--mobile side: expected OnButtonEvent notification
				EXPECT_NOTIFICATION("OnButtonEvent", {})
				:Times(0)
									
				--mobile side: expected OnButtonPress notification
				EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "PRESET_0", buttonPressMode = "SHORT"})
			end
		end
		
	--1. Notification is not exist in PT => DISALLOWED in policy table, SDL ignores the notification
	----------------------------------------------------------------------------------------------
		--Precondition: Build policy table file
		local PTFileName = testCasesForPolicyTable:createPolicyTableWithoutAPI("OnButtonEvent")
		
		--Precondition: Update policy table
		testCasesForPolicyTable:updatePolicy(PTFileName)
		TC_OnButtonEvent_DISALLOWED_USER_DISALLOWED("OnButtonEvent_IsNotExistInPT_DISALLOWED")
		
	
	----------------------------------------------------------------------------------------------
		
		
	--2. Notification is exist in PT but it has not consented yet by user => DISALLOWED in policy table, SDL ignores the notification
	----------------------------------------------------------------------------------------------
		--Precondition: Build policy table file
		local PermissionLinesForBase4 = 
[[					"OnButtonPress": {
						"hmi_levels": [
						  "FULL"
						]
					  }]] .. ",\n"
					  
		local PermissionLinesForGroup1 = 	
[[					"OnButtonEvent": {
						"hmi_levels": [
						  "FULL"
						]
					  }]] .. "\n"
					  
		local appID = config.application1.registerAppInterfaceParams.appID
		local PermissionLinesForApplication = 
		[[			"]]..appID ..[[" : {
						"keep_context" : false,
						"steal_focus" : false,
						"priority" : "NONE",
						"default_hmi" : "NONE",
						"groups" : ["Base-4", "group1"]
					},
		]]
		
		local PTName = testCasesForPolicyTable:createPolicyTableFile(PermissionLinesForBase4, PermissionLinesForGroup1, PermissionLinesForApplication, {"OnButtonEvent", "OnButtonPress"})	
		
		testCasesForPolicyTable:updatePolicy(PTName)		
		
		--Send notification and check it is ignored		
		TC_OnButtonEvent_DISALLOWED_USER_DISALLOWED("OnButtonEvent_UserHasNotConsentedYet_DISALLOWED")
		
	----------------------------------------------------------------------------------------------
	
		
	--3. Notification is exist in PT but user does not allow function group that contains this notification => USER_DISALLOWED in policy table, SDL ignores the notification
	----------------------------------------------------------------------------------------------	
		--Precondition: User does not allow function group
		testCasesForPolicyTable:userConsent(false, "group1")		
		
		--Send notification and check it is ignored
		TC_OnButtonEvent_DISALLOWED_USER_DISALLOWED("OnButtonEvent_USER_DISALLOWED")
		
	----------------------------------------------------------------------------------------------
	
	--4. Notification is exist in PT and user allow function group that contains this notification
	----------------------------------------------------------------------------------------------
		--Precondition: User allows function group
		testCasesForPolicyTable:userConsent(true, "group1")		
		
		function Test:OnButtonEvent_USER_ALLOWED()
	
			commonTestCases:DelayedExp(1000)

			--hmi side: send OnButtonEvent, OnButtonPress
			self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONDOWN"})
			self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "PRESET_0", mode = "BUTTONUP"})
			self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "PRESET_0", mode = "SHORT"})	
			
			--mobile side: expected OnButtonEvent notification
			EXPECT_NOTIFICATION("OnButtonEvent", 
												{buttonName = "PRESET_0", buttonEventMode = "BUTTONUP"},
												{buttonName = "PRESET_0", buttonEventMode = "BUTTONDOWN"})
			:Times(2)
								
			--mobile side: expected OnButtonPress notification
			EXPECT_NOTIFICATION("OnButtonPress", {buttonName = "PRESET_0", buttonPressMode = "SHORT"})
		end


	----------------------------------------------------------------------------------------------	
	end
	
	--TODO: PT is blocked by ATF defect APPLINK-19188
	--ResultCodeChecks()
	
	
	
----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VI----------------------------------------
-------------------------Sequence with emulating of user's action(s)--------------------------
----------------------------------------------------------------------------------------------

--Description: TC's checks SDL behavior by processing
	-- different request sequence with timeout
	-- with emulating of user's actions	

--Requirement id in JAMA:
	--1. SDLAQ-CRS-2908: OnButtonEvent with unknown buttonID from HMI
	--2. SDLAQ-CRS-3065: OnButtonEvent to media app in FULL
	--3. SDLAQ-CRS-3066: OnButtonEvent to media app in LIMITED


	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Test suite: Sequence with emulating of user's action(s)")
	----------------------------------------------------------------------------------------------
	
	--1. OnButtonEvent with unknown buttonID from HMI
	function Test:OnButtonEvent_WithUnknownButtonID()
	
		commonTestCases:DelayedExp(1000)
		
		local UnknowButtonID = 2
		
		--hmi side: send OnButtonEvent, OnButtonPress
		Test.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "CUSTOM_BUTTON", mode = "BUTTONDOWN", customButtonID = UnknowButtonID, appID = Apps[1].appID})
		Test.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = "CUSTOM_BUTTON", mode = "BUTTONUP", customButtonID = UnknowButtonID, appID = Apps[1].appID})
		Test.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = "CUSTOM_BUTTON", mode = "SHORT", customButtonID = UnknowButtonID, appID = Apps[1].appID})	
		
		--mobile side: expected OnButtonEvent notification
		EXPECT_NOTIFICATION("OnButtonEvent", {})
		:Times(0)
		
		--mobile side: expected OnButtonPress notification
		EXPECT_NOTIFICATION("OnButtonPress", {})
		:Times(0)
		
	end
	
	----------------------------------------------------------------------------------------------

	
	--2. SDLAQ-CRS-3065: OnButtonEvent to media app in FULL
	
	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Test suite: OnButtonEvent notification is only sent to FULL media application")

	-- Precondition 1: Opening new session
	function Test:AddNewSession2()
		
	  -- Connected expectation
		self.mobileSession2 = mobile_session.MobileSession(Test,Test.mobileConnection)
		
		self.mobileSession2:StartService(7)
	end	
	
	function Test:Register_Media_App2()

		--mobile side: RegisterAppInterface request 
		config.application2.registerAppInterfaceParams.isMediaApplication = true
		config.application2.registerAppInterfaceParams.appHMIType = nil

		local CorIdRAI = self.mobileSession2:SendRPC("RegisterAppInterface", config.application2.registerAppInterfaceParams) 
	 
		--hmi side: expect BasicCommunication.OnAppRegistered request
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
		{
			application = 
			{
				appName = config.application2.registerAppInterfaceParams.appName,
				isMediaApplication = true
			}
		})
		:Do(function(_,data)
			Apps[2].appID = data.params.application.appID
			self.applications[Apps[2].appName] = data.params.application.appID
		end)
		
		--mobile side: RegisterAppInterface response 
		self.mobileSession2:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
		:Timeout(2000)

		self.mobileSession2:ExpectNotification("OnHMIStatus",{hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	end

	function Test:Activation_Media_App2()
						
		--hmi side: sending SDL.ActivateApp request
		local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = Apps[2].appID})
		EXPECT_HMIRESPONSE(RequestId)
		
		--mobile side: expect notification
		self.mobileSession2:ExpectNotification("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"}) 
	end
	
	local function SubscribeMediaButton(TestCaseName, ButtonName, session)
		Test[TestCaseName] = function(self)

			if session == 2 then
				--mobile side: sending SubscribeButton request
				cid = self.mobileSession2:SendRPC("SubscribeButton",{ buttonName = ButtonName})

				--expect Buttons.OnButtonSubscription
				EXPECT_HMINOTIFICATION("Buttons.OnButtonSubscription", {appID = Apps[2].appID, isSubscribed = true, name = ButtonName})
				:Times(1)

				--mobile side: expect SubscribeButton response
				self.mobileSession2:ExpectResponse(cid, {success = true, resultCode = "SUCCESS"})
				
				self.mobileSession2:ExpectNotification("OnHashChange", {})
				:Times(1)
			end

			if session == 3 then
			    --mobile side: sending SubscribeButton request
				cid = self.mobileSession3:SendRPC("SubscribeButton",{ buttonName = ButtonName})

				--expect Buttons.OnButtonSubscription
				EXPECT_HMINOTIFICATION("Buttons.OnButtonSubscription", {appID = Apps[3].appID, isSubscribed = true, name = ButtonName})
				:Times(1)

				--mobile side: expect SubscribeButton response
				self.mobileSession3:ExpectResponse(cid, {success = true, resultCode = "SUCCESS"})
			
				self.mobileSession3:ExpectNotification("OnHashChange", {})
				:Times(1)
			end
		end
		
	end

	for i=1, #MediaButtons do
		SubscribeMediaButton("App2SubscribeButton"..MediaButtons[i], MediaButtons[i], 2)
	end

	-- function Test:Deactivate_App2_To_Background()
	
	-- 	--hmi side: sending BasicCommunication.OnAppDeactivated notification
	-- 	self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = Apps[2].appID, reason = "AUDIO"})

	-- 	self.mobileSession2:ExpectNotification("OnHMIStatus", { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})
	-- end
	
	
	function Test:AddNewSession3()
	
	  -- Connected expectation
		self.mobileSession3 = mobile_session.MobileSession(Test,Test.mobileConnection)
		
		self.mobileSession3:StartService(7)
	end	
		
	function Test:Register_Media_App3()

		--mobile side: RegisterAppInterface request 
		config.application3.registerAppInterfaceParams.isMediaApplication = true
		config.application3.registerAppInterfaceParams.appHMIType = nil
		
		local CorIdRAI = self.mobileSession3:SendRPC("RegisterAppInterface", config.application3.registerAppInterfaceParams) 
	 
		--hmi side: expect BasicCommunication.OnAppRegistered request
		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
		{
			application = 
			{
				appName = config.application3.registerAppInterfaceParams.appName,
				isMediaApplication = true
			}
		})
		:Do(function(_,data)
			Apps[3].appID = data.params.application.appID
			self.applications[Apps[3].appName] = data.params.application.appID
		end)
		
		--mobile side: RegisterAppInterface response 
		self.mobileSession3:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
		:Timeout(2000)

		self.mobileSession3:ExpectNotification("OnHMIStatus",{hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	end
	
	function Test:Activation_Media_App3()
						
		--hmi side: sending SDL.ActivateApp request
		local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = Apps[3].appID})
		EXPECT_HMIRESPONSE(RequestId)
		
		--mobile side: expect notification
		self.mobileSession3:ExpectNotification("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"}) 

	end
	
	for i=1, #MediaButtons do
		SubscribeMediaButton("App3SubscribeButton"..MediaButtons[i], MediaButtons[i], 3)
	end

	function Test:Deactivate_App3_To_None_Hmi_Level()

		--hmi side: sending BasicCommunication.OnExitApplication notification
		self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = Apps[3].appID, reason = "USER_EXIT"})

		self.mobileSession3:ExpectNotification("OnHMIStatus", { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"})
	end	
	
	
	function Test:Activation_App1()
						
		--hmi side: sending SDL.ActivateApp request
		local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = Apps[1].appID})
		EXPECT_HMIRESPONSE(RequestId)
		
		--mobile side: expect notification
		EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"}) 		
		--self.mobileSession3:ExpectNotification("OnHMIStatus", {hmiLevel = "BACKGROUND", systemContext = "MAIN"})
	end
		

	local function OnButtonEvent_OnlyComesToFullOrLimitedHmiLevelApplication(TestCaseName, ButtonName)
		Test[TestCaseName] = function(self)
			
			commonTestCases:DelayedExp(1000)
			
			--hmi side: send OnButtonEvent, OnButtonEvent
			self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = ButtonName, mode = "BUTTONDOWN"})
			self.hmiConnection:SendNotification("Buttons.OnButtonEvent",{name = ButtonName, mode = "BUTTONUP"})
			self.hmiConnection:SendNotification("Buttons.OnButtonPress",{name = ButtonName, mode = "SHORT"})	
			
			--Verify result on Mobile for app1
			self.verifyPressButtonResult(ButtonName, "SHORT")
			
			
			--Verify result on Mobile for app2 in NONE
			
			--mobile side: expected OnButtonEvent notification
			self.mobileSession2:ExpectNotification("OnButtonEvent", {})
			:Times(0)
						
			--mobile side: expected OnButtonPress notification
			self.mobileSession2:ExpectNotification("OnButtonPress", {})
			:Times(0)
			
			
			--Verify result on Mobile for app3 in BACKGROUND
			
			--mobile side: expected OnButtonEvent notification
			self.mobileSession3:ExpectNotification("OnButtonEvent", {})
			:Times(0)
						
			--mobile side: expected OnButtonPress notification
			self.mobileSession3:ExpectNotification("OnButtonPress", {})
			:Times(0)
			
		end
	end	
	
	for i=1,#MediaButtons do
		OnButtonEvent_OnlyComesToFullOrLimitedHmiLevelApplication("OnlyFullApplicationReceivesOnButtonEvent" .. MediaButtons[i], MediaButtons[i])
	end
	----------------------------------------------------------------------------------------------
	
	--3. SDLAQ-CRS-3066: OnButtonEvent to media app in LIMITED
	if commonFunctions:isMediaApp() then	
		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup("Test suite: OnButtonEvent notification is only sent to LIMITED media application")
	
		--Change app1 to LIMITED
		commonSteps:ChangeHMIToLimited()
		
		for i=1,#MediaButtons do
			OnButtonEvent_OnlyComesToFullOrLimitedHmiLevelApplication("OnlyLimitedApplicationReceivesOnButtonEvent"..MediaButtons[i], MediaButtons[i])
		end
	end
	
		
----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VII---------------------------------------
--------------------------------------Different HMIStatus-------------------------------------
----------------------------------------------------------------------------------------------

--Description: Check different HMIStatus

--Requirement id in JAMA: 	
	--SDLAQ-CRS-1302: HMI Status Requirements for OnButtonEvent(FULL, LIMITED)
	
--Verification criteria: 
	--1. None of the applications receives onButtonEvent notification in HMI BACKGROUND or NONE.
	--2. In case  the app is of non-media type and HMI Level is FULL the app obtains OnButtonEvent notifications from all subscribed buttons.
	--3. In case  the app is of media type HMI Level is FULL the app obtains OnButtonEvent notifications from all subscribed buttons.
	--4. In case  the app is of media type and HMI Level is LIMITED the app obtains OnButtonEvent notifications from media subscribed HW buttons only (all except OK).


	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Test suite: Different HMI Level Checks")
	----------------------------------------------------------------------------------------------
	

	--1. HMI level is NONE
	--Precondition: Deactivate app to NONE HMI level	
	commonSteps:DeactivateAppToNoneHmiLevel()
	
	local function verifyOnButtonEventNotification_IsIgnored(TestCaseName)

		
		--Verify buttonName and buttonPressMode parameters
		for i =1, #ButtonNames_WithoutCUSTOM_BUTTON do
			for j =1, #ButtonPressModes do
				
				Test[TestCaseName .. "_name_" .. ButtonNames_WithoutCUSTOM_BUTTON[i] .."_mode_" .. ButtonPressModes[j]] = function(self)
					
					commonTestCases:DelayedExp(1000)
					
					--Press button on HMI
					self.pressButton(ButtonNames_WithoutCUSTOM_BUTTON[i], ButtonPressModes[j])
					
					--mobile side: expected OnButtonEvent notification
					EXPECT_NOTIFICATION("OnButtonEvent", {})
					:Times(0)
								
					--mobile side: expected OnButtonPress notification
					EXPECT_NOTIFICATION("OnButtonPress", {})
					:Times(0)
					
				end

			end
		end


		--Verify customButtonID parameter
		for j =1, #ButtonPressModes do
			for n = 1, #CustomButtonIDs do

				Test[TestCaseName .. "_name_CUSTOM_BUTTON_mode_" .. ButtonPressModes[j] .. "_customButtonID_" .. CustomButtonIDs[n]] = function(self)
					
					commonTestCases:DelayedExp(1000)
					
					--Press button on HMI
					self.pressButton_CUSTOM_BUTTON("CUSTOM_BUTTON", ButtonPressModes[j], CustomButtonIDs[n], Apps[1].appID)
					
					--mobile side: expected OnButtonEvent notification
					EXPECT_NOTIFICATION("OnButtonEvent", {})
					:Times(0)
								
					--mobile side: expected OnButtonPress notification
					EXPECT_NOTIFICATION("OnButtonPress", {})
					:Times(0)
					
				end
			end
		end
		
	end

	verifyOnButtonEventNotification_IsIgnored("OnButtonEvent_InNoneHmiLevel_IsIgnored")
	
	--Postcondition
	commonSteps:ActivationApp()
	----------------------------------------------------------------------------------------------

	--2. HMI level is LIMITED
	
	if commonFunctions:isMediaApp() then
		-- Precondition: Change app to LIMITED
		commonSteps:ChangeHMIToLimited()
			
		
		--Verify buttonName and buttonPressMode parameters
		for i =1, #ButtonNames_WithoutCUSTOM_BUTTON_OK do
			for j =1, #ButtonPressModes do
				TC_SendOnButtonEvent_SUCCESS(ButtonNames_WithoutCUSTOM_BUTTON_OK[i], ButtonPressModes[j], "OnButtonEvent_InLimitedHmilLevel")
			end
		end
		
		--4. In case the app is of media type and HMI Level is LIMITED the app obtains OnButtonEvent notifications from media subscribed HW buttons only (all except OK).
		for j =1, #ButtonPressModes do
			TC_SendOnButtonEvent_IsIgnored("OK", ButtonPressModes[j], "OnButtonEvent_InLimitedHmilLevel_OK_ButtonIsIgnored")
		end



		--Verify customButtonID parameter
		for j =1, #ButtonPressModes do
			for n = 1, #CustomButtonIDs do
				TC_SendOnButtonEvent_CUSTOM_BUTTON_SUCCESS("CUSTOM_BUTTON", ButtonPressModes[j], CustomButtonIDs[n], 1, "OnButtonEvent_InLimitedHmilLevel")
			end
		end
		
		
	end
	----------------------------------------------------------------------------------------------

	
	--3. HMI level is BACKGROUND
	commonTestCases:ChangeAppToBackgroundHmiLevel()
	verifyOnButtonEventNotification_IsIgnored("OnButtonEvent_InBackgoundHmiLevel_IsIgnored")

----------------------------------------------------------------------------------------------

return Test