--Note: Update PendingRequestsAmount = 2 in .ini file

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

--///////////////////////////////////////////////////////////////////////////--
--Script cheks TOO_MANY_PENDING_REQUEST resultCode in SubscribeButton response from SDL
--///////////////////////////////////////////////////////////////////////////--

local buttonName = {"OK","SEEKLEFT","SEEKRIGHT","TUNEUP","TUNEDOWN", "PRESET_0","PRESET_1","PRESET_2","PRESET_3","PRESET_4","PRESET_5","PRESET_6","PRESET_7","PRESET_8","PRESET_9"}



--Precondition: app activation
commonSteps:ActivationApp()

--///////////////////////////////////////////////////////////////////////////--
--Check TOO_MANY_PENDING_REQUEST resultCode in SubscribeButton response from HMI
  function Test:SubscribeButton_TooManyPendingRequest()
  	--Sending 15 SubscribeButton requests
  	for i=1,#buttonName do
		--mobile side: sending SubscribeButton request
		local cid = self.mobileSession:SendRPC("SubscribeButton",
		{
			buttonName = buttonName[i]
		})		
	  end

    --expect response SubscribeButton
    EXPECT_RESPONSE("SubscribeButton")
    	:ValidIf(function(exp,data)
			if 
				data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
		    		TooManyPenReqCount = TooManyPenReqCount+1
		    		print(" \27[32m SubscribeButton response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
					return true
			elseif 
			   	exp.occurences == 15 and TooManyPenReqCount == 0 then 
			  		print(" \27[36m Response SubscribeButton with resultCode TOO_MANY_PENDING_REQUESTS did not came \27[0m")
		  			return false
			elseif 
		  		data.payload.resultCode == "SUCCESS" then
		    		print(" \27[32m SubscribeButton response came with resultCode SUCCESS \27[0m")
		    		return true
			else
		    	print(" \27[36m SubscribeButton response came with resultCode "..tostring(data.payload.resultCode .. "\27[0m" ))
		    	return false
			end
		end)
		:Times(15)
		:Timeout(5000)


    --expect absence of OnAppInterfaceUnregistered
    EXPECT_NOTIFICATION("OnAppInterfaceUnregistered")
    :Times(0)

    --expect absence of BasicCommunication.OnAppUnregistered
    EXPECT_HMICALL("BasicCommunication.OnAppUnregistered")
    :Times(0)

    DelayedExp()
  end

