---------------------------------------------------------------------------------------------
-- Requirement summary:
-- SDL must send WARNINGS (success:true) to mobile app in case HMI respond WARNINGS at least to one component of RPC
--
-- Description:
-- test is intended to check that SDL sends WARNINGS (success:true) to mobile app in case HMI respond WARNINGS to at least one HMI-portions
-- in this test case when UI.AddCommand gets WARNINGS is checked
-- 1. Used preconditions: App is activated and registered SUCESSFULLY
-- 2. Performed steps: 
-- MOB -> SDL: sends AddCommand
-- SDL -> HMI: resends VR.AddCommand with all valid params, UI.AddCommand with imageType of cmdIcon which is not supported by HMI
-- HMI -> SDL: VR.AddCommand (SUCCESS), UI.AddCommand (WARNINGS)
--
-- Expected result:
-- SDL -> MOB: appID: (WARNINGS, success: true: AddCommand)
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
-- ToDo (vvvakulenko): remove after issue "ATF does not stop HB timers by closing session and connection" is resolved
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')

--[[ Local Variables ]]
local storagePath = config.pathToSDL .. "storage/" 
local grammarIDValue

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_ActivationApp()			
  local request_id = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})
  EXPECT_HMIRESPONSE(request_id)
  :Do(function(_,data)
    if
    data.result.isSDLAllowed ~= true then
      local request_id1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
      EXPECT_HMIRESPONSE(request_id1)
      :Do(function(_,_)						
        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
        EXPECT_HMICALL("BasicCommunication.ActivateApp")
        :Do(function(_,_)
          self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
        end)
        :Times(2)
      end)
    end
  end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"}) 
end

function Test:Precondition_PutFile()
  local cid = self.mobileSession:SendRPC("PutFile",
  {			
    syncFileName = "icon.png",
    fileType	= "GRAPHIC_PNG",
    persistentFile = false,
    systemFile = false
  }, "files/icon.png")
  
  EXPECT_RESPONSE(cid, { success = true})			
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_AddCommand_VR_warning()
  local cid = self.mobileSession:SendRPC("AddCommand",
  {
    cmdID = 11,
    menuParams = 	
    { 
      parentID = 1,
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
      imageType ="STATIC"
    }
  })
  EXPECT_HMICALL("UI.AddCommand", 
  { 
    cmdID = 11,
    cmdIcon = 
    {
      value = storagePath .."icon.png", 
      imageType = "STATIC"
    },
    menuParams = 
    { 
      parentID = 1,	
      position = 0,
      menuName ="Commandpositive"
    }
  })
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, "UI.AddCommand", "WARNINGS", {})
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
    grammarID = grammarIDValue
  })
  :Do(function(_,data)
    grammarIDValue = data.params.grammarID
    self.hmiConnection:SendResponse(data.id, "VR.AddCommand", "SUCCESS", {})
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