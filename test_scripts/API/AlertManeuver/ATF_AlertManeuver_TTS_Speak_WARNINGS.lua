---------------------------------------------------------------------------------------------
-- Requirement summary:
-- SDL must send WARNINGS (success:true) to mobile app in case HMI respond WARNINGS at least to one component of RPC
--
-- Description:
-- test is intended to check that SDL sends WARNINGS (success:true) to mobile app in case HMI respond WARNINGS to at least one HMI-portions
-- in this particular test it is checked case when HMI sends WARNINGS to TTS.Speak 
-- 1. Used preconditions: App is registered and activated SUCCESSFULLY
-- 2. Performed steps: 
-- MOB -> SDL: AlertManeuver
-- SDL -> HMI: resends AlertManeuver
-- HMI -> SDL: Navi.AlertManeuver (SUCCESS), TTS.Speak (WARNINGS)
--
-- Expected result:
-- SDL -> MOB: AlertManeuver (result code: WARNINGS, success: true)
---------------------------------------------------------------------------------------------
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
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()

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

function Test:TestStep_AlertManeuver_TTS_Speak_WARNINGS()
  local cor_id_alertmaneuver = self.mobileSession:SendRPC("AlertManeuver",
  {ttsChunks = 
    {{ 
        text ="FirstAlert",
        type ="TEXT",
      },      
      { 
        text ="SecondAlert",
        type ="TEXT",
      }}, 
    softButtons = 
    {{ 
        type = "BOTH",
        text = "Close",
        image =         
          { 
            value = "icon.png",
            imageType = "DYNAMIC",
          }, 
        isHighlighted = true,
        softButtonID = 821,
        systemAction = "DEFAULT_ACTION",
      }}													
  })
 
  EXPECT_HMICALL("Navigation.AlertManeuver", 
  {	
    softButtons = 
    {{ 
        type = "BOTH",
        text = "Close",
        image = 					
          { 
            value = storagePath .. "/icon.png",
            imageType = "DYNAMIC",
          },
        isHighlighted = true,
        softButtonID = 821,
        systemAction = "DEFAULT_ACTION",
      }},
    appID = self.applications["Test Application"]
  })
  :Do(function(_,data) self.hmiConnection:SendResponse(data.id, "Navigation.AlertManeuver", "SUCCESS", { })
  end)

  EXPECT_HMICALL("TTS.Speak", 
  {ttsChunks = 
    {{
      text ="FirstAlert", type ="TEXT"}, 
      {text ="SecondAlert", type ="TEXT"}},
    speakType = "ALERT_MANEUVER", 
    appID = self.applications["Test Application"]    
  })
  :Do(function(_,data) self.hmiConnection:SendError(data.id, "TTS.Speak", "WARNINGS")    
  end)

  EXPECT_RESPONSE(cor_id_alertmaneuver, { success = true, resultCode = "WARNINGS"})
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLStop()
  StopSDL()
end

return Test