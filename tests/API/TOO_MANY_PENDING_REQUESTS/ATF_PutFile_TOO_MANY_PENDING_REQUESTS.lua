Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

local commonSteps = require('user_modules/shared_testcases/commonSteps')

local TooManyPenReqCount = 0

function DelayedExp()
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, 5000)
end
function putFileAllParams()
	local temp = { 
		syncFileName ="icon.png",
		fileType ="GRAPHIC_PNG",
		-- persistentFile =false,
		-- systemFile = false,
		-- offset =0,
		-- length =11600
	} 
	return temp
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

	--Requirement id in JAMA: SDLAQ-CRS-708

    --Verification criteria: The system has more than M (M defined in smartDeviceLink.ini) requests  at a time that haven't been responded yet.	
	function Test:PutFile_TooManyPendingRequests()
		for i = 1, 100 do			
			--mobile side: sending PutFile request
			local cid = self.mobileSession:SendRPC("PutFile", putFileAllParams(), "files/binaryFile")		
		end
		
		EXPECT_RESPONSE("PutFile")
	      :ValidIf(function(exp,data)			
	      	if 
	      		data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
	            TooManyPenReqCount = TooManyPenReqCount+1
	            print(" \27[32m PutFile response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
	      		return true
	        elseif				
	           exp.occurences  == 100 and TooManyPenReqCount == 0 then			   
	          print(" \27[36m Response PutFile with resultCode TOO_MANY_PENDING_REQUESTS did not came \27[0m")
	          return false
	        elseif 
	          data.payload.resultCode == "SUCCESS" then
	            print(" \27[32m PutFile response came with resultCode SUCCESS \27[0m")
	            return true
	        else
	            print(" \27[36m PutFile response came with resultCode "..tostring(data.payload.resultCode .. "\27[0m" ))
				return false
	        end
	      end)
			:Times(100)
			:Timeout(150000)

		--expect absence of OnAppInterfaceUnregistered
		EXPECT_NOTIFICATION("OnAppInterfaceUnregistered")
		:Times(0)

		--expect absence of BasicCommunication.OnAppUnregistered
		EXPECT_HMICALL("BasicCommunication.OnAppUnregistered")
		:Times(0)

		DelayedExp()
	end	
--End Test suit ResultCodeCheck














