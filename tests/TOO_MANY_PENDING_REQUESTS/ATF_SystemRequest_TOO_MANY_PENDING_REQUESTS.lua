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
APIName = "SystemRequest" -- use for above required scripts.


---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

commonSteps:DeleteLogsFileAndPolicyTable()


--Activate application
commonSteps:ActivationApp()


--2. Update policy table
local PermissionLines_SystemRequest = 
[[					"SystemRequest": {
						"hmi_levels": [
						  "BACKGROUND",
						  "FULL",
						  "LIMITED",
						  "NONE"
						]
					  }]]
	

local PermissionLinesForBase4 = PermissionLines_SystemRequest .. ",\n"
local PermissionLinesForGroup1 = nil
local PermissionLinesForApplication = nil
--TODO: PT is blocked by ATF defect APPLINK-19188
--local PTName = testCasesForPolicyTable:createPolicyTableFile(PermissionLinesForBase4, PermissionLinesForGroup1, PermissionLinesForApplication, {"SystemRequest"})	
--testCasesForPolicyTable:updatePolicy(PTName)

	
-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Begin Test case ResultCodeChecks
--Description: Check TOO_MANY_PENDING_REQUESTS resultCode

	--Requirement id in JAMA: APPLINK-19579

    --Verification criteria: TOO_MANY_PENDING_REQUESTS for the applications sending overlimit frames number
	
	
	function Test:SystemRequest_TOO_MANY_PENDING_REQUESTS()
	
		local numberOfRequest = 10
		for i = 1, numberOfRequest do
			--mobile side: send the request 	 	
			self.mobileSession:SendRPC(APIName, {fileName = "PolicyTableUpdate", requestType = "SETTINGS"}, "./files/PTU_ForSystemRequest.json")				
		end
		

		commonTestCases:verifyResultCode_TOO_MANY_PENDING_REQUESTS(numberOfRequest)
	end	

	
	
--End Test case ResultCodeChecks













