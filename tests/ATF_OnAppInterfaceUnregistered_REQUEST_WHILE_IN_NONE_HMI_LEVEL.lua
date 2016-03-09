--Set "AppHMILevelNoneTimeScaleMaxRequests" = 1
-------------------------------------------------------------------------------------------------------------------
Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local module = require('testbase')
--------------------------------------------------------------------------------------------------
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')
-------------------------------------------------------------------------------------------------

local AppNotRegisteredReqCount = 0

function putFileAllParams()
	local temp = { 
		syncFileName ="icon.png",
		fileType ="GRAPHIC_PNG",
		persistentFile =false,
		systemFile = false,
		offset =0,
		length =11600
	} 
	return temp
end

----------------------------------------------------------------------------------------------------------
function Test:Precondition_SecondSession()
	
	self.mobileSession1 = mobile_session.MobileSession(
	self,
	self.mobileConnection)
	self.mobileSession1:StartService(7)
		
end		

---------------------------------------------------------------------------------------------------------------
--APPLINK-18426
--Verification: OnAppInterfaceUnregistered notification with REQUEST_WHILE_IN_NONE_HMI_LEVEL reason.
--------------------------------------------------------------------------------------------------------------
--TODO: This TC should be update when APPLINK-16147 is implemeted 
commonFunctions:newTestCasesGroup("TC_APPLINK_ APPLINK-18426: OnAppInterfaceUnregistered(REQUEST_WHILE_IN_NONE_HMI_LEVEL)")

commonSteps:ActivationApp()
commonSteps:UnregisterApplication()
commonSteps:RegisterAppInterface()
	
function Test:APPLINK_18426()
	for i = 1,10 do			
		--mobile side: sending PutFile request
		local cid = self.mobileSession:SendRPC("PutFile", putFileAllParams(), "files/icon.png")		
	end
	
	EXPECT_RESPONSE("PutFile")
	:ValidIf(function(exp,data)			
		if 
			data.payload.resultCode == "APPLICATION_NOT_REGISTERED" then
			AppNotRegisteredReqCount = AppNotRegisteredReqCount+1
			print(" \27[32m PutFile response came with resultCode APPLICATION_NOT_REGISTERED \27[0m")
			return true
		elseif				
		   exp.occurences  == 10 and AppNotRegisteredReqCount == 0 then			   
		  print(" \27[36m Response PutFile with resultCode APPLICATION_NOT_REGISTERED did not came \27[0m")
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
		:Times(9)
		--:Timeout(200000)

	--hmi side: expect BasicCommunication.OnAppUnregistered
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID =  self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  false})
			
	--mobile side: expect notification
	self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = "REQUEST_WHILE_IN_NONE_HMI_LEVEL"})
	
	--mobile side: expect notification when APPLINK-16147 is implemeted 
	--self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = "TOO_MANY_REQUEST"})
end	
