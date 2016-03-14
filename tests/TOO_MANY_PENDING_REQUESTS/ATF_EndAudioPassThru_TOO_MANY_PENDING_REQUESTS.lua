Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')


---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------

require('user_modules/AppTypes')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')

APIName = "EndAudioPassThru" -- use for above required scripts.


---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

--1. Activate application
commonSteps:ActivationApp()
	

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Begin Test suit ResultCodeChecks
--Description:TC check TOO_MANY_PENDING_REQUESTS resultCode

	--Requirement id in JAMA: SDLAQ-CRS-567

    --Verification criteria: The system has more than 1000 requests at a time that haven't been responded yet. The system sends the responses with TOO_MANY_PENDING_REQUESTS error code for all further requests until there are less than 1000 requests at a time that haven't been responded by the system yet.

	
	function Test:EndAudioPassThru_SendsTooManyPendingRequest()
		
		local numberOfRequest = 10
		
		for i = 1, numberOfRequest do
			--mobile side: send EndAudioPassThru request 	 	
			self.mobileSession:SendRPC("EndAudioPassThru", {})				
		end
		
		commonTestCases:verifyResultCode_TOO_MANY_PENDING_REQUESTS(numberOfRequest)
	end	

	
	
--End Test suit ResultCodeChecks