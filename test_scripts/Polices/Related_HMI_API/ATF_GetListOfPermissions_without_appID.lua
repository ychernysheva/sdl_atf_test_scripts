---------------------------------------------------------------------------------------------
-- Description: 
--     1. Preconditions: SDL and HMI are running. Local PT contains in "appID_1" section: "groupName_11", "groupName_12" groups; 
--        and in "appID_2" section: "groupName_21", "groupName_22" groups;
--     2. Performed steps: 1. Send SDL.GetListOfPermissions {appID_1}, From HMI: SDL->HMI: GetListOfPermissions {allowedFunctions:
--
-- Requirement summary: 
--     GetListOfPermissions without appID
--
-- Expected result:
--     On getting SDL.GetListOfPermissions without appID parameter, PoliciesManager must respond with the list of <groupName>s 
--     that have the field "user_consent_prompt" in corresponding <functional grouping> and are assigned to the currently registered applications (section "<appID>" -> "groups")
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
require('user_modules/AppTypes')

--[[ Local Functions ]]
local function getFunctionGroupsName()  
  local sql_select = "sqlite3 " .. tostring(SDLStoragePath) .. "policy.sqlite \"SELECT functional_group.name FROM app_group JOIN functional_group ON app_group.functional_group_id = functional_group.id WHERE app_group.application_id in ('0000001', '0000002')\""
    local aHandle = assert( io.popen( sql_select , 'r'))
    sql_output = aHandle:read( '*l' )   
    local retvalue = tonumber(sql_output)    
    if (retvalue == nil) then
       self:FailTestCase("device id can't be read")
    else 
      return retvalue
    end
end

--[[ Preconditions ]]
--commonFunctions:newTestCasesGroup("Preconditions")
commonSteps:DeleteLogsFileAndPolicyTable()

function Test:CloseConnection()
  self.mobileConnection:Close()
  commonTestCases:DelayedExp(3000)
    
end

commonPreconditions:BackupFile("sdl_preloaded_pt.json")
testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/PTU_GetListOfPermissions.json")

function Test:ConnectDevice()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
          {
            deviceList = {
              {
                id = config.deviceMAC,
                isSDLAllowed = true,
                name = "127.0.0.1",
                transportType = "WIFI"
              }
            }
          }
  ):Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  :Times(AtLeast(1))
end

function Test:RegisterApp()
  commonTestCases:DelayedExp(3000)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
    local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
    :Do(function(_,data)
      self.HMIAppID = "0000001"
      --self.HMIAppID = data.params.application.appID
    end)
    self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
    self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
  end)
end

--[[ Test ]]
--commonFunctions:newTestCasesGroup("Test")
function Test:GetListOfPermissions_without_appID()
  --hmi side: sending SDL.GetURLS request
  local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  --hmi side: expect SDL.GetURLS response from HMI
  EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
  :Do(function(_,data)
  --print("SDL.GetURLS response is received")
  --hmi side: sending BasicCommunication.OnSystemRequest request to SDL
  self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
    {
      requestType = "PROPRIETARY",
      fileName = "filename"
    })
  --mobile side: expect OnSystemRequest notification
  EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
  :Do(function(_,data)
    --mobile side: sending SystemRequest request
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
    {
      fileName = "PolicyTableUpdate",
      requestType = "PROPRIETARY"
    },
    "files/PTU_GetListOfPermissions.json")
      local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Do(function(_,data)
    systemRequestId = data.id
      --hmi side: sending BasicCommunication.OnSystemRequest request to SDL
      self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
        {
        policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
        })
        function to_run()
          --hmi side: sending SystemRequest response
          self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
        end
        RUN_AFTER(to_run, 500)
      end)
      --hmi side: expect SDL.OnStatusUpdate
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
        :ValidIf(function(exp,data)
          if  exp.occurences == 1 and
            data.params.status == "UP_TO_DATE" then
              return true
          elseif
            exp.occurences == 1 and
            data.params.status == "UPDATING" then
              return true
          elseif
            exp.occurences == 2 and
            data.params.status == "UP_TO_DATE" then
              return true
          else
            if exp.occurences == 1 then
                print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in first occurrences status 'UP_TO_DATE' or 'UPDATING', got '" .. tostring(data.params.status) .. "' \27[0m")
            elseif exp.occurences == 2 then
                print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in second occurrences status 'UP_TO_DATE', got '" .. tostring(data.params.status) .. "' \27[0m")
            end
            return false
          end
        end)
        :Times(Between(1,2))
    --mobile side: expect SystemRequest response
    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
    :Do(function(_,data)
    --hmi side: sending SDL.GetUserFriendlyMessage request to SDL
    local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"StatusUpToDate"}})
      --hmi side: expect SDL.GetUserFriendlyMessage response
    EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{line1 = "Up-To-Date", messageCode = "StatusUpToDate", textBody = "Up-To-Date"}}}})
    :Do(function(_,data)
      --hmi side: sending SDL.GetListOfPermissions request to SDL
      local RequestIdGetListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", {appID = "0000001"})
      -- hmi side: expect SDL.GetListOfPermissions response
      -- ToDo(VVVakulenko): update after resolving APPLINK-16094
      -- EXPECT_HMIRESPONSE(RequestIdGetListOfPermissions,{result = {code = 0, method = "SDL.GetListOfPermissions", allowedFunctions = {{ id = 686787169, name = "New"}}}})
      EXPECT_HMIRESPONSE(RequestIdGetListOfPermissions)
        :Do(function(_,data)
          print("SDL.GetListOfPermissions response is received")

          idGroup = data.result.allowedFunctions[1].id                
          --hmi side: sending SDL.OnAppPermissionConsent
          self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent", { appID =  self.applications["Test Application"], consentedFunctions = {{ allowed = false, id = idGroup, name = "New"}}, source = "GUI"})
          end)        
        end)
      end)
      :Timeout(500)
    end)
  end)
end

function checkNamesOfGroups()
  func_group_name = getFunctionGroupsName(self)
  commonFunctions:userPrint(34, "func_group_name")
    if func_group_name == "Base-4" and "Location-1" and "DrivingCharacteristics-3" and "VehicleInfo-3" and "Emergency-1" and "PropriataryData-1" then
      commonFunctions:userPrint(34, "Group name in database was not updated")
      return true
    else
      self:FailTestCase("Group name in database was not updated")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
commonFunctions:SDLForceStop()
testCasesForPolicyTable:Restore_preloaded_pt()

return Test 