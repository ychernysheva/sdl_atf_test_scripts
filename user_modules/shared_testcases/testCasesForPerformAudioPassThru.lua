--This script contains common functions that are used in CRQs:
-- [GENIVI] PerformAudioPassThru: SDL must support new "audioPassThruIcon" parameter
--How to use:
  --1. local testCasesForMenuIconMenuTitleParameters = require('user_modules/shared_testcases/testCasesForPerformAudioPassThru')

local testCasesForPerformAudioPassThru = {}

function testCasesForPerformAudioPassThru:ActivateAppDiffPolicyFlag(self, app_name, device_ID)
  local ServerAddress = "127.0.0.1"--commonSteps:get_data_from_SDL_ini("ServerAddress")

  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", 
  	{ appID = self.applications[app_name]})

  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,data)
		if(data.result.isSDLAllowed == false) then
	    local RequestId1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
	    --hmi side: expect SDL.GetUserFriendlyMessage message response
	    EXPECT_HMIRESPONSE( RequestId1, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
	    :Do(function(_,_)
	      self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
	        {allowed = true, source = "GUI", device = {id = device_ID, name = ServerAddress, isSDLAllowed = true}})
	    end)
		  EXPECT_HMICALL("BasicCommunication.ActivateApp")
	    :Do(function() self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {}) end)
	  end

  end)

  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
end

return testCasesForPerformAudioPassThru