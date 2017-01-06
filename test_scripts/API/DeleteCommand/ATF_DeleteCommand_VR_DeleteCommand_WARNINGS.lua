---------------------------------------------------------------------------------------------
-- Requirement summary:
-- SDL must send WARNINGS (success:true) to mobile app in case HMI respond WARNINGS at least to one component of RPC
--
-- Description:
-- test is intended to check that SDL sends WARNINGS (success:true) to mobile app in case HMI respond WARNINGS to at least one HMI-portions
-- in this test case when VR.DeleteCommand gets WARNINGS is checked
-- 1. Used preconditions: App is activated and registered SUCESSFULLY
-- 2. Performed steps: 
-- MOB -> SDL: sends DeleteCommand
-- SDL -> HMI: resends VR.DeleteCommand with imageType of cmdIcon which is not supported by HMI and UI.DeleteCommand with all valid params
-- HMI -> SDL: VR.DeleteCommand (WARNINGS), UI.DeleteCommand (SUCCESS)
--
-- Expected result:
-- SDL -> MOB: appID: (WARNINGS, success: true: DeleteCommand
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')

--[[ Local Variables ]]
local storagePath = config.pathToSDL .. "storage/"

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
  local cid_put_file = self.mobileSession:SendRPC("PutFile",
  {			
    syncFileName = "icon.png",
    fileType	= "GRAPHIC_PNG",
    persistentFile = false,
    systemFile = false
  }, "files/icon.png")
  
  EXPECT_RESPONSE(cid_put_file, { success = true})			
end

function Test:Precondition_AddSubMenu()
  --mobile side: sending AddSubMenu request
  local cor_id_add_submenu = self.mobileSession:SendRPC("AddSubMenu",
  {
    menuID = 1000,
    position = 0,
    menuName ="Commandpositive"
  })
  --hmi side: expect UI.AddSubMenu request
  EXPECT_HMICALL("UI.AddSubMenu", 
  { 
    menuID = 1000,
    menuParams = {
      position = 0,
      menuName ="Commandpositive"
    }
  })
  :Do(function(_,data)
    --hmi side: sending UI.AddSubMenu response
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)		
  --mobile side: expect AddSubMenu response
  EXPECT_RESPONSE(cor_id_add_submenu, { success = true, resultCode = "SUCCESS" })
  --mobile side: expect OnHashChange notification
  EXPECT_NOTIFICATION("OnHashChange")
end

function Test:Precondition_AddCommand()
  --mobile side: sending AddCommand request
  local cid_add_cmd = self.mobileSession:SendRPC("AddCommand",
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
      imageType ="DYNAMIC"
    }
  })
  --hmi side: expect UI.AddCommand request
  EXPECT_HMICALL("UI.AddCommand", 
  { 
    cmdID = 11,
    cmdIcon = 
    {
      value = storagePath.."icon.png",
      imageType = "DYNAMIC"
    },
    menuParams = 
    { 
      parentID = 1,	
      position = 0,
      menuName ="Commandpositive"
    }
  })
  :Do(function(_,data)
    --hmi side: sending UI.AddCommand response
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)	
  --hmi side: expect VR.AddCommand request
  EXPECT_HMICALL("VR.AddCommand", 
  { 
    cmdID = 11,
    type = "Command",
    vrCommands = 
    {
      "VRCommandonepositive", 
      "VRCommandonepositivedouble"
    },
    grammarID = 123
  })
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  
  EXPECT_RESPONSE(cid_add_cmd, { success = true, resultCode = "SUCCESS" })
  EXPECT_NOTIFICATION("OnHashChange")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_DeleteCommand()
  --mobile side: sending DeleteCommand request
  local cid_del_cmd = self.mobileSession:SendRPC("DeleteCommand",
  {
    cmdID = 11
  })	
  --hmi side: expect UI.DeleteCommand request
  EXPECT_HMICALL("UI.DeleteCommand", 
  { 
    cmdID = 11,
    appID = self.applications["Test Application"]
  })
  :Do(function(_,data)
    --hmi side: sending UI.DeleteCommand response
    self.hmiConnection:SendResponse(data.id, "UI.DeleteCommand", "SUCCESS", {})
  end)	
  --hmi side: expect VR.DeleteCommand request
  EXPECT_HMICALL("VR.DeleteCommand", 
  { 
    cmdID = 11,
    type = "Choice",
    grammarID = 123,
    appID = self.applications["Test Application"]
  })
  :Do(function(_,data)
    --hmi side: sending VR.DeleteCommand response
    self.hmiConnection:SendResponse(data.id, "VR.DeleteCommand", "WARNINGS", {})
  end)				
  EXPECT_RESPONSE(cid_del_cmd, { success = true, resultCode = "WARNINGS" })
  EXPECT_NOTIFICATION("OnHashChange")
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test.Postcondition_SDLStop()
  StopSDL()
end

return Test