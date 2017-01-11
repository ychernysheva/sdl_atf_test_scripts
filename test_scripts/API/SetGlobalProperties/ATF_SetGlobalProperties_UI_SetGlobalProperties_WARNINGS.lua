---------------------------------------------------------------------------------------------
-- Requirement summary:
-- SDL must send WARNINGS (success:true) to mobile app in case HMI respond WARNINGS at least to one HMI-portions
--
-- Description:
-- test is intended to check that SDL sends WARNINGS (success:true) to mobile app in case HMI respond WARNINGS to at least one HMI-portions
-- in this test case when UI.SetGlobalProperties gets WARNINGS is checked
-- 1. Used preconditions: App is activated and registered SUCESSFULLY
-- 2. Performed steps: 
-- MOB -> SDL: sends SetGlobalProperties
-- SDL -> HMI: resends UI.SetGlobalProperties with imageType if vrHelp which is not supported by HMI, and TTS.SetGlobalProperties with all valid params
-- HMI -> SDL: VR.SetGlobalProperties (WARNINGS), TTS.SetGlobalProperties (SUCCESS)
--
-- Expected result:
-- SDL -> MOB: appID: (WARNINGS, success: true: SetGlobalProperties)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.SDLStoragePath = config.pathToSDL .. "storage/"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')

--[[ Local Variables ]]
local storagePath = config.SDLStoragePath..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"
local ServerAddress = commonFunctions.read_parameter_from_smart_device_link_ini("ServerAddress")

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_ActivationApp()
  local request_id = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
  EXPECT_HMIRESPONSE(request_id)
  :Do(function(_,data)
    if (data.result.isSDLAllowed ~= true) then
      local request_id1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
      EXPECT_HMIRESPONSE(request_id1)
      :Do(function(_,_)		
        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = ServerAddress}})
        EXPECT_HMICALL("BasicCommunication.ActivateApp")
        :Do(function(_,_)
          self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
        end)
        :Times(1)
      end)
    end
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"}) 
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_SetGlobalProperties_WARNINGS()
	--mobile side: sending SetGlobalProperties request
	local cid = self.mobileSession:SendRPC("SetGlobalProperties",
	{
		menuTitle = "Menu Title",
		timeoutPrompt = 
		{{
				text = "Timeout prompt",
				type = "TEXT"
			}},
		vrHelp = 
		{{
				position = 1,
				image = 
				{
					value = "action.png",
					imageType = "DYNAMIC"
				},
				text = "VR help item"
			}},
		menuIcon = 
		{
			value = "action.png",
			imageType = "DYNAMIC"
		},
		helpPrompt = 
		{{
				text = "Help prompt",
				type = "TEXT"
			}},
		vrHelpTitle = "VR help title",
		keyboardProperties = 
		{
			keyboardLayout = "QWERTY",
			language = "EN-US"
		}
	})
	--hmi side: expect TTS.SetGlobalProperties request
	EXPECT_HMICALL("TTS.SetGlobalProperties",
	{
		timeoutPrompt = 
		{{
				text = "Timeout prompt",
				type = "SAPI_PHONEMES"
			}},
		helpPrompt = 
		{{
				text = "Help prompt",
				type = "TEXT"
			}},
		appID = self.applications["Test Application"]
	})
	:Do(function(_,data)
		self.hmiConnection:SendResponse(data.id, "TTS.SetGlobalProperties", "SUCCESS", {})
	end)
	
	--hmi side: expect UI.SetGlobalProperties request
	EXPECT_HMICALL("UI.SetGlobalProperties",
	{
	    vrHelpTitle = "VR help title",
	    vrHelp = 
		{{
				position = 1,
				image = 
				{
					imageType = "STATIC",
					value = storagePath .. "action.png"
				},
				text = "VR help item"
			}},
		menuTitle = "Menu Title",
		menuIcon = 
		{
			imageType = "STATIC",
			value = storagePath .. "action.png"
		},
		keyboardProperties = 
		{
			keyboardLayout = "QWERTY",
			language = "EN-US"
		},
		appID = self.applications[config.application1.registerAppInterfaceParams.appName]
	})
	:Do(function(_,data)
		self.hmiConnection:SendResponse(data.id, "UI.SetGlobalProperties", "UNSUPPORTED_RESOURCE", {})
	end)
	--mobile side: expect SetGlobalProperties response
	EXPECT_RESPONSE(cid, { success = true, resultCode = "WARNINGS"})
	EXPECT_NOTIFICATION("OnHashChange")
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLStop()
  StopSDL()
end

return Test