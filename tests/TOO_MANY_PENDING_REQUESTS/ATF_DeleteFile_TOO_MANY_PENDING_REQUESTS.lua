--Note: Update PendingRequestsAmount = 3 in .ini file

Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')


require('user_modules/AppTypes')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
APIName = "DeleteFile" -- use for above required scripts.
local TooManyPenReqCount = 0

function DelayedExp()
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, 5000)
end

function putfile(sefl, strFileName, strFileType, blnPersistentFile, blnSystemFile, strFileNameOnMobile)

	local strTestCaseName, strSyncFileName, strFileNameOnLocal1	
	if type(strFileName) == "table" then
		strTestCaseName = "PutFile_"..strFileName.reportName
		strSyncFileName = strFileName.fileName
	elseif type(strFileName) == "string" then
		strTestCaseName = "PutFile_"..strFileName
		strSyncFileName = strFileName
	else 
		print("Error: putfile function, strFileName is wrong value type: " .. tostring(strFileName))
	end
	
	if strFileNameOnMobile ==nil then
		strFileNameOnMobile = "action.png"
	end
	
	Test["PutFile_"..strTestCaseName] = function(self)
	
		--mobile side: sending Futfile request
		local cid = self.mobileSession:SendRPC("PutFile",
												{
													syncFileName = strSyncFileName,
													fileType	= strFileType, 
													persistentFile = blnPersistentFile,
													systemFile = blnSystemFile
												},
												"files/"..strFileNameOnMobile)

		--mobile side: expect Futfile response
		EXPECT_RESPONSE(cid, { success = true})
		
	end
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
--Begin test case ResultCodeCheck
--Description:TC check TOO_MANY_PENDING_REQUESTS resultCode

    --Requirement id in JAMA: SDLAQ-CRS-717

    --Verification criteria: The system has more than 1000 requests  at a time that haven't been responded yet. The system sends the responses with TOO_MANY_PENDING_REQUESTS error code for all futher requests, until there are less than 1000 requests at a time that have not been responded by the system yet.

	--Precondition: PutFile
	for n = 1,15 do
		putfile(self, "test.png"..tostring(n), "GRAPHIC_PNG")
	end
	

	  function Test:DeleteFile_TooManyPendingRequest()
		for i = 1, 15 do
			--mobile side: DeleteFile request  
			local cid = self.mobileSession:SendRPC("DeleteFile",
			{
				syncFileName = "test.png"..tostring(i)
			})
		end
		
		EXPECT_RESPONSE("DeleteFile")
			:ValidIf(function(exp,data)
				if 
					data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
			    		TooManyPenReqCount = TooManyPenReqCount+1
			    		print(" \27[32m DeleteFile response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
						return true
				elseif 
				   	exp.occurences == 15 and TooManyPenReqCount == 0 then 
				  		print(" \27[36m Response DeleteFile with resultCode TOO_MANY_PENDING_REQUESTS did not came \27[0m")
			  			return false
				elseif 
			  		data.payload.resultCode == "SUCCESS" then
			    		print(" \27[32m DeleteFile response came with resultCode SUCCESS \27[0m")
			    		return true
				else
			    	print(" \27[36m DeleteFile response came with resultCode "..tostring(data.payload.resultCode .. "\27[0m" ))
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
	  
  
--End test case ResultCodeCheck

return Test
