---------------------------------------------------------------------------------------------
-- Requirement summary:
-- SDL must send WARNINGS (success:true) to mobile app in case HMI respond WARNINGS at least to one HMI-portions
--
-- Description:
-- test is intended to check that SDL sends WARNINGS (success:true) to mobile app in case HMI respond WARNINGS to at least one HMI-portions
-- in this test case when VR.AddCommand gets WARNINGS is checked
-- 1. Used preconditions: App is activated and registered SUCESSFULLY
-- 2. Performed steps: 
-- MOB -> SDL: sends AddCommand
-- SDL -> HMI: resends VR.AddCommand with imageType of cmdIcon which is not supported by HMI and UI.AddCommand with all valid params
-- HMI -> SDL: VR.AddCommand (WARNINGS), UI.AddCommand (SUCCESS)
--
-- Expected result:
-- SDL -> MOB: appID: (WARNINGS, success: true: AddCommand)
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

commonSteps:PutFile("Precondition_PutFile", "icon.png")

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_AddCommand_VR_warning()
  local cid = self.mobileSession:SendRPC("AddCommand",
  {
    cmdID = 11,
    menuParams = 	
    { 
      parentID = 0,
      position = 0,
      menuName ="Commandpositive"
    }, 
    vrCommands = 
    { 
      "VRCommandonepositive",
      "VRCommandonepositivedouble"
    }, 
    cmdIcon = 	
    { 
      value ="icon.png",
      imageType ="DYNAMIC"
    }
  })
  EXPECT_HMICALL("UI.AddCommand", 
  { 
    cmdID = 11,
    cmdIcon = 
    {
      value = storagePath .."icon.png", 
      imageType = "DYNAMIC"
    },
    menuParams = 
    { 
      parentID = 0,	
      position = 0,
      menuName ="Commandpositive"
    }
  })
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, "UI.AddCommand", "SUCCESS", {})
  end)

  EXPECT_HMICALL("VR.AddCommand", 
  { 
    cmdID = 11,
    vrCommands = 
    {
      "VRCommandonepositive", 
      "VRCommandonepositivedouble"
    },
    type = "Command",
    --grammarID = 123
  })
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, "VR.AddCommand", "WARNINGS", {})
  end)
  
  EXPECT_RESPONSE(cid, { success = true, resultCode = "WARNINGS" })
  EXPECT_NOTIFICATION("OnHashChange")
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLStop()
  StopSDL()
end

return Test