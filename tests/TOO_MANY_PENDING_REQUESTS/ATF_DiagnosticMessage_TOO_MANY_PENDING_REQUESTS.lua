Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local config = require('config')

---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------

require('user_modules/AppTypes')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
APIName = "DiagnosticMessage" -- use for above required scripts.


---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

--Activate application
commonSteps:ActivationApp()

	
-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Begin Test case ResultCodeChecks
--Description: Check TOO_MANY_PENDING_REQUESTS resultCode

	--Requirement id in JAMA: SDLAQ-CRS-633

    --Verification criteria: The system has more than 1000 requests  at a time that haven't been responded yet. The system sends the responses with TOO_MANY_PENDING_REQUESTS error code for all the further requests until there are less than 1000 requests at a time that haven't been responded by the system yet.
	
	
	function Test:GetDTCs_VerifyResultCode_TOO_MANY_PENDING_REQUESTS()
	
		local numberOfRequest = 10
		for i = 1, numberOfRequest do
			--mobile side: send the request 	 	
			self.mobileSession:SendRPC(APIName, {
													targetID = 42,
													messageLength = 8,
													messageData = {1}
												}
										)				
		end
		

		commonTestCases:verifyResultCode_TOO_MANY_PENDING_REQUESTS(numberOfRequest)
	end	

	
	
--End Test case ResultCodeChecks













