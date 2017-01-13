---------------------------------------------------------------------------------------------
-- Requirement summary:
-- SDL must send WARNINGS (success:true) to mobile app in case HMI respond WARNINGS at least to one component of RPC
--
-- Description:
-- test is intended to check that SDL sends WARNINGS (success:true) to mobile app in case HMI respond WARNINGS to at least one HMI-portions
-- in this test case when TTS.SetGlobalProperties gets WARNINGS is checked
-- 1. Used preconditions: App is registered and activated SUCCESSFULLY
-- 2. Performed steps: 
-- MOB -> SDL: sends SetGlobalProperties
-- SDL -> HMI: resends UI.SetGlobalProperties
-- HMI -> SDL: VR.SetGlobalProperties (SUCCESS), TTS.SetGlobalProperties (WARNINGS)
--
-- Expected result:
-- SDL -> MOB: SetGlobalProperties (resultcode: WARNINGS, success: true)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.SDLStoragePath = config.pathToSDL .. "storage/"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')

--[[ Local Variables ]]
local storagePath = config.SDLStoragePath..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"
local ServerAddress = commonFunctions:read_parameter_from_smart_device_link_ini("ServerAddress")

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
        :Do(function(_,data1)
          self.hmiConnection:SendResponse(data1.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
        end)
      end)
    end
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"}) 
end

function Test.Precondition_PutFile()
  commonSteps:PutFile("Precondition_PutFile", "action.png")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestSTep_SetGlobalProperties_WARNINGS()
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
        type = "TEXT"
    }},
    helpPrompt = 
      {{
        text = "Help prompt",
        type = "TEXT"
    }},
    appID = self.applications[config.application1.registerAppInterfaceParams.appName]
  })

  :ValidIf(function(_,data)
    local value_Icon = storagePath .. "action.png"
    if (string.match(data.params.cmdIcon.value, "%S*" .. "("..string.sub(storagePath, 2).."action.png)" .. "$") == nil ) then
      print("\27[31m value of menuIcon is WRONG. Expected: ~".. value_Icon .. "; Real: " .. data.params.cmdIcon.value .. "\27[0m")
    return false
    else
    return true
    end
  end)

  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, "TTS.SetGlobalProperties", "WARNINGS", {})
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
          imageType = "DYNAMIC",
          value = storagePath .. "action.png"
        },
        text = "VR help item"
    }},
    menuTitle = "Menu Title",
    menuIcon = 
    {
      imageType = "DYNAMIC",
      value = storagePath .. "action.png"
    },
    keyboardProperties = 
    {
      keyboardLayout = "QWERTY",
      language = "EN-US"
    },
    appID = self.applications["Test Application"]
  })

  :ValidIf(function(_,data)
    local value_Icon = storagePath .. "action.png"
    if (string.match(data.params.cmdIcon.value, "%S*" .. "("..string.sub(storagePath, 2).."action.png)" .. "$") == nil ) then
      print("\27[31m value of menuIcon is WRONG. Expected: ~".. value_Icon .. "; Real: " .. data.params.cmdIcon.value .. "\27[0m")
    return false
    else
    return true
    end
  end)
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, "UI.SetGlobalProperties", "SUCCESS", {})
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