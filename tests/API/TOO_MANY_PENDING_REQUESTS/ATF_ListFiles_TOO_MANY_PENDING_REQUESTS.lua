Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

require('user_modules/AppTypes')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
APIName = "ListFiles" -- use for above required scripts.

function DelayedExp()
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, 5000)
end

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

--1. Activate application
commonSteps:ActivationApp()

---------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------IV TEST BLOCK-----------------------------------------
---------------------------------------Result codes check--------------------------------------
----------------------------------------------------------------------------------------------

--Begin Test suit ResultCodeCheck
--Description:TC check TOO_MANY_PENDING_REQUESTS resultCode

	--Begin Test case resultCodeCheck.1
	--Description: Check resultCode: TOO_MANY_PENDING_REQUESTS

		--Requirement id in JAMA/or Jira ID: SDLAQ-CRS-725

		--Verification criteria: The system has more than 1000 requests  at a time that haven't been responded yet.The system sends the responses with TOO_MANY_PENDING_REQUESTS error code for all further requests, until there are less than 1000 requests at a time that have not been responded by the system yet.
		

		function Test:ListFiles_TooManyPendingRequest()
			local n = 0
			local numberOfRequest = 20
			for n = 1, numberOfRequest do
				--mobile side: sending ListFiles request
				local cid = self.mobileSession:SendRPC("ListFiles", {} )
			end

			EXPECT_RESPONSE("ListFiles")
			:ValidIf(function(exp,data)
				
				if data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
					n = n + 1
					print(" \27[32m ListFiles response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
					return true
				elseif exp.occurences == numberOfRequest and n == 0 then 
					print(" \27[36m Response ListFiles with resultCode TOO_MANY_PENDING_REQUESTS did not came \27[0m")
					return false
				elseif data.payload.resultCode == "SUCCESS" then
					print(" \27[32m ListFiles response came with resultCode SUCCESS \27[0m")
					return true
				else
					print(" \27[36m ListFiles response came with resultCode "..tostring(data.payload.resultCode) .. "\27[0m" )
					return false
				end
			end)
			:Times(AtLeast(numberOfRequest))
			:Timeout(15000)

			--expect absence of OnAppInterfaceUnregistered
			EXPECT_NOTIFICATION("OnAppInterfaceUnregistered")
			:Times(0)

			--expect absence of BasicCommunication.OnAppUnregistered
			EXPECT_HMICALL("BasicCommunication.OnAppUnregistered")
			:Times(0)

			DelayedExp()
		end

		
	--End Test case resultCodeCheck.1

--End Test suit ResultCodeCheck	

