Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

local TooManyPenReqCount = 0

function DelayedExp()
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, 5000)
end

---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
local commonSteps = require('user_modules/shared_testcases/commonSteps')

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

	--Requirement id in JAMA: SDLAQ-CRS-556

    --Verification criteria: The system has more than M (M defined in smartDeviceLink.ini) requests  at a time that haven't been responded yet.

	function Test:PerformAudioPassThru_TooManyPendingRequests()
		for i = 1, 20 do								
			--mobile side: sending PerformAudioPassThru request
			local cid = self.mobileSession:SendRPC("PerformAudioPassThru",{
																samplingRate ="8KHZ",
																maxDuration = 2000,
																bitsPerSample ="8_BIT",
																audioType = "PCM"
															})
		end
		
		EXPECT_RESPONSE("PerformAudioPassThru")
			:ValidIf(function(exp,data)
				if 
					data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
			    		TooManyPenReqCount = TooManyPenReqCount+1
			    		print(" \27[32m PerformAudioPassThru response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
						return true
				elseif 
				   	exp.occurences == 20 and TooManyPenReqCount == 0 then 
				  		print(" \27[36m Response PerformAudioPassThru with resultCode TOO_MANY_PENDING_REQUESTS did not came \27[0m")
			  			return false
				elseif 
			  		data.payload.resultCode == "GENERIC_ERROR" then
			    		print(" \27[32m PerformAudioPassThru response came with resultCode GENERIC_ERROR \27[0m")
			    		return true				
				else
			    	print(" \27[36m PerformAudioPassThru response came with resultCode "..tostring(data.payload.resultCode .. "\27[0m" ))
			    	return false
				end
			end)
			:Times(20)
			:Timeout(15000)

		--expect absence of OnAppInterfaceUnregistered
		EXPECT_NOTIFICATION("OnAppInterfaceUnregistered")
		:Times(0)

		--expect absence of BasicCommunication.OnAppUnregistered
		EXPECT_HMICALL("BasicCommunication.OnAppUnregistered")
		:Times(0)

		DelayedExp()
	end
--End Test suit ResultCodeCheck















