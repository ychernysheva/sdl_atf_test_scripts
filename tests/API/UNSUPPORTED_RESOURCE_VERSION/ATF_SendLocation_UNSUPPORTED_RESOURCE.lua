Test = require('user_modules/connecttest_SendLocation_Unsupported')
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

	--Requirement id in JAMA: APPLINK-9735

    --Verification criteria:  In case UI is not supported (UI.IsReady returned 'available:false') SDL must respond with UNSUPPORTED_RESOURCE 'success:false' to mobile app and not transfer the RPC to HMI.

		function Test:SendLocation_UNSUPPORTED_RESOURCE()

			--request from mobile side
			local CorIdSendLocation= self.mobileSession:SendRPC("SendLocation",
			{
				longitudeDegrees = 1.1,
			latitudeDegrees = 1.1
			})
			
			--response on mobile side
			EXPECT_RESPONSE(CorIdSendLocation, { success = false, resultCode = "UNSUPPORTED_RESOURCE"})
			:Timeout(2000)
		end 
--End Test suit ResultCodeCheck