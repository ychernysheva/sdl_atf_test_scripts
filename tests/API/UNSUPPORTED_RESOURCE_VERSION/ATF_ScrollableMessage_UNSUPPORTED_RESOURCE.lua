Test = require('user_modules/connecttestUIUnavailable')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')

local hmi_connection = require('hmi_connection')
local websocket      = require('websocket_connection')
local module         = require('testbase')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')


---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local policyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
require('user_modules/AppTypes')

APIName = "ScrollableMessage" -- set request name


---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------



	
	--1. Activate application
	commonSteps:ActivationApp()
	

	--2. PutFiles ("action.png")
	commonSteps:PutFile("PutFile_icon.png", "action.png")
	
	
	--3. Update policy to allow request
	local keep_context = true
	local steal_focus = true
	policyTable:updatePolicyAndAllowFunctionGroup({"FULL"}, keep_context, steal_focus)

	
	
-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Begin Test suit ResultCodeChecks
--Description: Check UNSUPPORTED_RESOURCE resultCode

	--Requirement id in JAMA: SDLAQ-CRS-1036

    --Verification criteria:  Used if UI isn't available now (not supported). General request result "success" should be "false".

		function Test:ScrollableMessage_UNSUPPORTED_RESOURCE()

			local Request =
			{
				scrollableMessageBody = "abc",
				softButtons = 
				{
					{
						softButtonID = 1,
						text = "Button1",
						type = "IMAGE",
						image = 
						{
							value = "action.png",
							imageType = "DYNAMIC"
						},
						isHighlighted = false,
						systemAction = "DEFAULT_ACTION"
					}
				},
				timeout = 5000
			}
		
		--request from mobile side
		local cid= self.mobileSession:SendRPC("ScrollableMessage", Request)
		
		--response on mobile side
		EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE", info = "Destination controller not found!"})
		:Timeout(12000)
	end 
--End Test suit ResultCodeChecks