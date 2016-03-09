Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

local commonSteps = require('user_modules/shared_testcases/commonSteps')

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
	
	-----------------------------------------------------------------------------------------
	
	--Begin Precondition.2
	--Description: PutFile		
		function Test:PutFile()			
			local cid = self.mobileSession:SendRPC("PutFile",
					{			
						syncFileName = "icon.png",
						fileType	= "GRAPHIC_PNG",
						persistentFile = false,
						systemFile = false
					}, "files/icon.png")	
					EXPECT_RESPONSE(cid, { success = true})
		end
	--End Precondition.2
	

---------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------IV TEST BLOCK-----------------------------------------
---------------------------------------Result codes check--------------------------------------
----------------------------------------------------------------------------------------------

--Begin Test suit ResultCodeCheck
--Description:TC check TOO_MANY_PENDING_REQUESTS resultCode

	--Requirement id in JAMA: SDLAQ-CRS-431

    --Verification criteria: The system has more than M (M defined in smartDeviceLink.ini) requests  at a timethat haven't been responded yet.	
	
	function Test:AddSubMenu_TooManyPendingRequests()
		for i = 1, 20 do
			--mobile side: sending AddSubMenu request
			local cid = self.mobileSession:SendRPC("AddSubMenu",
												{
													menuID = i,
													menuName ="SubMenu"..tostring(i)
												})
		end
		
		--hmi side: expect AddSubMenu request
		EXPECT_RESPONSE("AddSubMenu")
		:ValidIf(function(_,data)
			if 
				data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
				return true
			else
				print("AddSubMenu response came with wrong resultCode "..tostring(data.payload.resultCode))
				return false
			end
		end)
		:Times(AtLeast(5))

		--expect absence of OnAppInterfaceUnregistered
		EXPECT_NOTIFICATION("OnAppInterfaceUnregistered")
		:Times(0)

		--expect absence of BasicCommunication.OnAppUnregistered
		EXPECT_HMICALL("BasicCommunication.OnAppUnregistered")
		:Times(0)

		DelayedExp()
	end	
	
--End Test suit ResultCodeCheck	













