Test = require('user_modules/connecttest_ShowConstantTBT')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

local commonSteps = require('user_modules/shared_testcases/commonSteps')
---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------
	--Begin Precondition.1
	--Description: Activation App by sending SDL.ActivateApp	
		commonSteps:ActivationApp()
	--End Precondition.1
	
---------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------IV TEST BLOCK-----------------------------------------
---------------------------------------Result codes check--------------------------------------
----------------------------------------------------------------------------------------------

--Begin Test suit ResultCodeCheck
--Description:TC check UNSUPPORTED_RESOURCE resultCode

	--Requirement id in JAMA: SDLAQ-CRS-1033

    --Verification criteria:  Used if UI isn't available now (not supported). General request result "success" should be "false".

		function Test:ShowConstantTBT_UNSUPPORTED_RESOURCE()

			--request from mobile side
			local cid= self.mobileSession:SendRPC("ShowConstantTBT",
			{
				navigationText1 = "NavigationText1"
			})
			
			--response on mobile side
			EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE"})
			:Timeout(2000)
		end 
--End Test suit ResultCodeCheck