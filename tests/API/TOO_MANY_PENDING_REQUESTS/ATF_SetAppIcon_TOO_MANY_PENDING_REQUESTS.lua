--Note: Update PendingRequestsAmount = 3 in .ini file

Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

local commonSteps = require('user_modules/shared_testcases/commonSteps')

require('user_modules/AppTypes')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
APIName = "SetAppIcon" -- use for above required scripts.

local TooManyPenReqCount = 0

function DelayedExp()
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, 5000)
end

--///////////////////////////////////////////////////////////////////////////--
--Script checks TOO_MANY_PENDING_REQUEST resultCode in SetAppIcon response from SDL
--///////////////////////////////////////////////////////////////////////////--


--1. Activate application
commonSteps:ActivationApp()
	
--2. PutFiles	
commonSteps:PutFile("FutFile_app_icon_png", "app_icon.png")


--///////////////////////////////////////////////////////////////////////////--
--Check TOO_MANY_PENDING_REQUEST resultCode in SetAppIcon response from HMI

--Begin test case ResultCodeCheck.4
--Description: Check resultCode: TOO_MANY_PENDING_REQUESTS

	--Requirement id in JAMA/or Jira ID: SDLAQ-CRS-733

	--Verification criteria: SDL response TOO_MANY_PENDING_REQUESTS resultCode
			
  function Test:CheckResultCode_TOO_MANY_PENDING_REQUESTS()

	--Sending many SetAppIcon requests

  	for i=1,100 do

		--mobile side: sending SetAppIcon request
		local cid = self.mobileSession:SendRPC("SetAppIcon",{ syncFileName = "app_icon.png" })
	end

    --expect response SetAppIcon
    EXPECT_RESPONSE("SetAppIcon")
    	:ValidIf(function(exp,data)
			if 
				data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
		    		TooManyPenReqCount = TooManyPenReqCount+1
		    		print(" \27[32m SetAppIcon response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
					return true
			elseif 
			   	exp.occurences == 100 and TooManyPenReqCount == 0 then 
			  		print(" \27[36m Response SetAppIcon with resultCode TOO_MANY_PENDING_REQUESTS did not came \27[0m")
		  			return false
			elseif 
		  		data.payload.resultCode == "GENERIC_ERROR" then
		    		print(" \27[32m SetAppIcon response came with resultCode GENERIC_ERROR \27[0m")
		    		return true
			else
		    	print(" \27[36m SetAppIcon response came with resultCode "..tostring(data.payload.resultCode .. "\27[0m" ))
		    	return false
			end
		end)
		:Times(100)
		:Timeout(15000)

    --expect absence of OnAppInterfaceUnregistered
    EXPECT_NOTIFICATION("OnAppInterfaceUnregistered")
    :Times(0)

    --expect absence of BasicCommunication.OnAppUnregistered
    EXPECT_HMICALL("BasicCommunication.OnAppUnregistered")
    :Times(0)

    DelayedExp()

    

  end

--End test case ResultCodeCheck.4
-----------------------------------------------------------------------------------------
