--Note: Update PendingRequestsAmount =3 in .ini file

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


--///////////////////////////////////////////////////////////////////////////--
--Script cheeks TOO_MANY_PENDING_REQUEST resultCode in SetGlobalProperties response from SDL
--///////////////////////////////////////////////////////////////////////////--

--1. Activate application
commonSteps:ActivationApp()
	
--2. PutFiles	
commonSteps:PutFile("FutFile_action_png", "action.png")


local function DelayedExp()
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, 100)
end

--///////////////////////////////////////////////////////////////////////////--
--Check TOO_MANY_PENDING_REQUEST resultCode in SetGlobalProperties response from HMI
  function Test:SetGlobalProperties_TooManyPendingRequest()

  	--Sending 15 SetGlobalProperties requests
  	for n = 1, 15 do
		--mobile side: SetGlobalProperties request  
		local cid = self.mobileSession:SendRPC("SetGlobalProperties",
		{
			menuTitle = "Menu Title",
			timeoutPrompt = 
			{
				{
					text = "Timeout prompt",
					type = "TEXT"
				}
			},
			vrHelp = 
			{
				{
					position = 1,
					image = 
					{
						value = "action.png",
						imageType = "DYNAMIC"
					},
					text = "VR help item"
				}
			},
			menuIcon = 
			{
				value = "action.png",
				imageType = "DYNAMIC"
			},
			helpPrompt = 
			{
				{
					text = "Help prompt",
					type = "TEXT"
				}
			},
			vrHelpTitle = "VR help title",
			keyboardProperties = 
			{
				keyboardLayout = "QWERTY",
				keypressMode = "SINGLE_KEYPRESS",
				limitedCharacterList = 
				{
					"a"
				},
				language = "EN-US",
				autoCompleteText = "Daemon, Freedom"
			}
		})
		
	  end

    --expect response SetGlobalProperties
    EXPECT_RESPONSE("SetGlobalProperties")
    	:ValidIf(function(exp,data)
			if 
				data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
		    		TooManyPenReqCount = TooManyPenReqCount+1
		    		print(" \27[32m SetGlobalProperties response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
					return true
			elseif 
			   	exp.occurences == 15 and TooManyPenReqCount == 0 then 
			  		print(" \27[36m Response SetGlobalProperties with resultCode TOO_MANY_PENDING_REQUESTS did not came \27[0m")
		  			return false
			elseif 
		  		data.payload.resultCode == "GENERIC_ERROR" then
		    		print(" \27[32m SetGlobalProperties response came with resultCode GENERIC_ERROR \27[0m")
		    		return true
			else
		    	print(" \27[36m SetGlobalProperties response came with resultCode "..tostring(data.payload.resultCode .. "\27[0m" ))
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















