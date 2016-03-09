-- AppHMILevelNoneTimeScaleMaxRequests = 10
-- AppHMILevelNoneRequestsTimeScale = 1
-- AppTimeScaleMaxRequests = 1
-- AppRequestsTimeScale = 1000

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
------------------------------------------------------------------------------------------------
---------------------------------Common functions---------------------------------------------------
------------------------------------------------------------------------------------------------
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

function Test:send_Many_Request(request)
	AppNotRegisteredReqCount=0
	
	for i = 1,request do			
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
		   exp.occurences  ==request-1 and AppNotRegisteredReqCount == 0 then			   
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
	:Times(request-1)

	--hmi side: expect BasicCommunication.OnAppUnregistered
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID =  self.applications[config.application1.registerAppInterfaceParams.appName], unexpectedDisconnect =  false})
			
	--mobile side: expect notification
	self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", {reason = "TOO_MANY_REQUESTS"})

end	

function Test:change_App(appType,isMedia,appID)
	config.application1.registerAppInterfaceParams.appHMIType = appType
	config.application1.registerAppInterfaceParams.isMediaApplication = isMedia
	config.application1.registerAppInterfaceParams.appID=appID
end
--------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------
-- APPLINK-18427: Check when App is FULL
-- RequiremenID: APPLINK-16207 is not implemented
-- Verification: OnAppInterfaceUnregistered notification with TOO_MANY_REQUESTS reason.
----------------------------------------------------------------------------------------------------------

commonSteps:ActivationApp()

function Test:APPLINK_18427_Case_AppIsFULL()
	self:send_Many_Request(15)
end	

----------------------------------------------------------------------------------------------------------
-- APPLINK-18427: Check when App is LIMITED
-- RequiremenID: APPLINK-16207 is not implemented
-- Verification: OnAppInterfaceUnregistered notification with TOO_MANY_REQUESTS reason when app is LIMITED
------------------------------------------------------------------------------------------------------

function Test:Change_App_To_MEDIA()
	self:change_App({"MEDIA"},true,"02")
end

commonSteps:RegisterAppInterface()
commonSteps:ActivationApp()

function Test:Bring_App_To_Limited()
	local cid = self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated",
		{
			appID = self.applications[config.application1.registerAppInterfaceParams.appName],
			reason = "GENERAL"
		})
		
	self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
end

function Test:APPLINK_18427_Case_AppIsLIMITED()
	self:send_Many_Request(15)
end	
------------------------------------------------------------------------------------------------------------
-- APPLINK-18427: Check when App is BACKGROUND
-- RequiremenID: APPLINK-16207 is not implemented
-- Verification: OnAppInterfaceUnregistered notification with TOO_MANY_REQUESTS reason when app is BACKGROUND
--------------------------------------------------------------------------------------------------------

function Test:Change_App_To_NonMEDIA()
	self:change_App({"DEFAULT"},false,"03")
end

commonSteps:RegisterAppInterface()

commonSteps:ActivationApp()

function Test:Bring_App_To_Background()
	local cid = self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated",
		{
			appID = self.applications[config.application1.registerAppInterfaceParams.appName],
			reason = "GENERAL"
		})
		
	self.mobileSession:ExpectNotification("OnHMIStatus",{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
end

function Test:APPLINK_18427_Case_AppIsBACKGROUND()
	self:send_Many_Request(15)
end	
























