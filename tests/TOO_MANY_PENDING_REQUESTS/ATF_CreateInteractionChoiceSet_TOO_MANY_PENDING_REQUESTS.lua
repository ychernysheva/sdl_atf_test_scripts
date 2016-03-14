Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

local commonSteps = require('user_modules/shared_testcases/commonSteps')

local n = 0

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
--Description:TC check TOO_MANY_PENDING_REQUESTS resultCode

    --Requirement id in JAMA: SDLAQ-CRS-462

    --Verification criteria: The system has more than M (M defined in smartDeviceLink.ini) requests  at a timethat haven't been responded yet.

    function Test:CreateInteractionChoiceSet_TooManyPendingRequests()

    	local Times = 15
		for i = 1, Times do
			--sending CreateInteractionChoiceSet request
			self.mobileSession:SendRPC("CreateInteractionChoiceSet",
										{
											interactionChoiceSetID = 1001+i,
											choiceSet = 
											{ 
												
												{ 
													choiceID = 1001+i,
													menuName ="Choice1001"..i,
													vrCommands = 
													{ 
														"Choice1001"..i,
													}
												}
											}
										})
		end
		
		--expect response CreateInteractionChoiceSet
		EXPECT_RESPONSE("CreateInteractionChoiceSet")
		:ValidIf(function(exp,data)
			if 
				data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
				n = n + 1
				print(" \27[32m CreateInteractionChoiceSet response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
				return true
			elseif n == 0 and exp.occurences == Times then 
				print(" \27[36m Any CreateInteractionChoiceSet response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
				return false
			elseif data.payload.resultCode == "GENERIC_ERROR" then
				print(" \27[32m CreateInteractionChoiceSet response came with resultCode GENERIC_ERROR \27[0m")
				return true
			else
				print(" \27[36m CreateInteractionChoiceSet response came with wrong resultCode \27[0m"..tostring(data.payload.resultCode))
				return false
			end
		end)
		:Times(Times)
		:Timeout(30000)
				
		--mobile side: expect absence of OnAppInterfaceUnregistered
		EXPECT_NOTIFICATION("OnAppInterfaceUnregistered")
		:Times(0)

		--hmi side: expect absence of BasicCommunication.OnAppUnregistered
		EXPECT_HMICALL("BasicCommunication.OnAppUnregistered")
		:Times(0)   
		
		DelayedExp()
	end
		


--End Test suit ResultCodeCheck













