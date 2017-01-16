---------------------------------------------------------------------------------------------
-- Requirement summary:
-- SDL must send WARNINGS (success:true) to mobile app in case HMI respond WARNINGS at least to one component of RPC
--
-- Description:
-- test is intended to check that SDL sends WARNINGS (success:true) to mobile app in case HMI respond WARNINGS to at least one HMI-portions
-- in this test case when VR.DeleteCommand gets WARNINGS is checked
-- 1. Used preconditions: App is registered and activated SUCCESSFULLY. AddCommand is sent SUCCESSFULLY
-- 2. Performed steps: 
-- MOB -> SDL: sends DeleteCommand
-- SDL -> HMI: resends VR.DeleteCommand
-- HMI -> SDL: VR.DeleteCommand (WARNINGS), UI.DeleteCommand (SUCCESS)
--
-- Expected result:
-- SDL -> MOB: DeleteCommand: (resultcode: WARNINGS, success: true)
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
  commonSteps:PutFile("Precondition_PutFile", "icon.png")
end 

function Test:Precondition_AddCommand()
  local cid_add_cmd = self.mobileSession:SendRPC("AddCommand",
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
      value = storagePath.."icon.png",
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
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)  

  EXPECT_HMICALL("VR.AddCommand", 
  { 
    cmdID = 11,
    type = "Command",
    vrCommands = { "VRCommandonepositive", "VRCommandonepositivedouble" }
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

  :Do(function(_,data) self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  
  EXPECT_RESPONSE(cid_add_cmd, { success = true, resultCode = "SUCCESS" })
  EXPECT_NOTIFICATION("OnHashChange")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_DeleteCommand_warning()
  local cid_del_cmd = self.mobileSession:SendRPC("DeleteCommand",
  {
    cmdID = 11
  })  

  EXPECT_HMICALL("UI.DeleteCommand", 
  { 
    cmdID = 11,
    appID = self.applications["Test Application"]
  })
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, "UI.DeleteCommand", "SUCCESS", {})
  end)  

  EXPECT_HMICALL("VR.DeleteCommand", 
  { 
    cmdID = 11,
    type = "Command",
    appID = self.applications[config.application1.registerAppInterfaceParams.appName]
  })
  :Do(function(_,data)
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