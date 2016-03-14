--Note: Update PendingRequestsAmount =3 in .ini file

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
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

--1. Activate application
commonSteps:ActivationApp()
	
----------------------------------------------------------------------------------------------
----------------------------------------IV TEST BLOCK-----------------------------------------
---------------------------------------Result codes check--------------------------------------
----------------------------------------------------------------------------------------------
--Begin Test suit ResultCodeCheck
--Description:TC check TOO_MANY_PENDING_REQUESTS resultCode

    --Requirement id in JAMA: SDLAQ-CRS-397

    --Verification criteria: The system has more than M (M defined in smartDeviceLink.ini) requests  at a timethat haven't been responded yet. The system sends the responses with TOO_MANY_PENDING_REQUESTS error code for all futher requests, until there are less than M requests at a time that have not been responded by the system yet.
	

--///////////////////////////////////////////////////////////////////////////--
--Check TOO_MANY_PENDING_REQUEST resultCode in ResetGlobalProperties response from HMI
  function Test:ResetGlobalProperties_TooManyPendingRequest()

  	--Sending 15 ResetGlobalProperties requests
  	 for n = 1, 15 do
		--mobile side: ResetGlobalProperties request  
		local cid = self.mobileSession:SendRPC("ResetGlobalProperties",
		{
			properties = 
			{
				"VRHELPTITLE",
				"MENUNAME",
				"MENUICON",
				"KEYBOARDPROPERTIES",
				"VRHELPITEMS",
				"HELPPROMPT",
				"TIMEOUTPROMPT"
			}
		})		
	  end

    --expect response ResetGlobalProperties
    EXPECT_RESPONSE("ResetGlobalProperties")
    	:ValidIf(function(exp,data)
			if 
				data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
		    		TooManyPenReqCount = TooManyPenReqCount+1
		    		print(" \27[32m ResetGlobalProperties response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
					return true
			elseif 
			   	exp.occurences == 15 and TooManyPenReqCount == 0 then 
			  		print(" \27[36m Response ResetGlobalProperties with resultCode TOO_MANY_PENDING_REQUESTS did not came \27[0m")
		  			return false
			elseif 
		  		data.payload.resultCode == "GENERIC_ERROR" then
		    		print(" \27[32m ResetGlobalProperties response came with resultCode GENERIC_ERROR \27[0m")
		    		return true
			else
		    	print(" \27[36m ResetGlobalProperties response came with resultCode "..tostring(data.payload.resultCode .. "\27[0m" ))
		    	return false
			end
		end)
		:Times(15)
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