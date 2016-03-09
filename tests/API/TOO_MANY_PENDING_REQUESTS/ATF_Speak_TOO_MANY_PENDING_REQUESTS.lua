Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

local commonSteps = require('user_modules/shared_testcases/commonSteps')

---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------

require('user_modules/AppTypes')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
APIName = "Speak" -- use for above required scripts.


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
--Description:TC check TOO_MANY_PENDING_REQUESTS resultCode

	--Requirement id in JAMA: SDLAQ-CRS-507

    --Verification criteria: The system has more than M (M defined in smartDeviceLink.ini) requests  at a timethat haven't been responded yet.
	
	
	function Test:Speak_VerifyResultCode_TOO_MANY_PENDING_REQUESTS()
	
		local numberOfRequest = 10
		for i = 1, numberOfRequest do
			--mobile side: send Speak request 	 	
			self.mobileSession:SendRPC("Speak", {
													ttsChunks = 
													{ 
														{
															text ="a",
															type ="TEXT"
														}
													}
												}
										)				
		end
		

		commonTestCases:verifyResultCode_TOO_MANY_PENDING_REQUESTS(numberOfRequest)
	end	

	
	
--End Test case ResultCodeChecks













