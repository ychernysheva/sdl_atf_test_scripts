---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [PolicyTableUpdate] PoliciesManager changes status to “UP_TO_DATE”
--
-- Description:
-- PoliciesManager must change the status to “UP_TO_DATE” and notify HMI with OnStatusUpdate("UP_TO_DATE") 
-- right after successful validation of received PTU.
-- 
-- Steps:
-- 1. Register new app
-- 2. Trigger PTU
-- 3. SDL->HMI: Verify step of SDL.OnStatusUpdate(UP_TO_DATE) notification in PTU sequence 
-- 
-- Expected result:
-- SDL.OnStatusUpdate(UP_TO_DATE) notification is send right after successful validation of received PTU
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
  local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
  local commonSteps = require("user_modules/shared_testcases/commonSteps")    
  local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')    

--[[ Local Variables ]]  
  local expectedResult = {}
  expectedResult[1] = "UPDATE_NEEDED"
  expectedResult[16] = "UP_TO_DATE"
  local actualResult = {}
  local sequence = {}
  local idx = 0

--[[ Local Functions ]]
  local function logAdd(item)
    idx = idx + 1
    sequence[idx] = item
  end

  local function getIdx(table, value)
    for k, v in pairs(table) do
      if v == value then
        return k
      end
    end
    return nil
  end

--[[ General Precondition before ATF start ]]  
  testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTERNAL_PROPRIETARY")
  commonFunctions:SDLForceStop()  
  commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
  Test = require("connecttest")  
  require("user_modules/AppTypes")  

--[[ Specific Notifications ]]    
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
  :Do(function(_, d)    
    logAdd("SDL->HMI: SDL.OnStatusUpdate(" .. d.params.status .. ")")
    actualResult[idx] = d.params.status
  end)
  :Times(AnyNumber())
  :Pin()  

  EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
  :Do(function(_, _)    
    logAdd("SDL->HMI: BC.PolicyUpdate")
  end)
  :Times(AnyNumber())
  :Pin()

  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
  :Do(function(_, _)    
    logAdd("SDL->HMI: BC.OnAppRegistered")
  end)
  :Times(AnyNumber())
  :Pin()

--[[ Test ]]  
  commonFunctions:newTestCasesGroup("Test")       

  function Test:PTU()   
    local policy_file_path = "/tmp/fs/mp/images/ivsu_cache/"
    local policy_file_name = "PolicyTableUpdate"
    local file = "files/jsons/Policies/Policy_Table_Update/ptu_18803.json"
    local requestId = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
    logAdd("HMI->SDL: SDL.GetURLS")
    EXPECT_HMIRESPONSE(requestId)
    :Do(function(_, _)
      logAdd("SDL->HMI: SDL.GetURLS")
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest", {requestType = "PROPRIETARY", fileName = policy_file_name})
      logAdd("HMI->SDL: BC.OnSystemRequest")
      EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "PROPRIETARY"})
      :Do(function(_, _)
        logAdd("SDL->MOB: OnSystemRequest")
        local corIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {requestType = "PROPRIETARY", fileName = policy_file_name}, file)
        logAdd("MOB->SDL: SystemRequest")
        EXPECT_HMICALL("BasicCommunication.SystemRequest")        
        :Do(function(_, data)
          logAdd("SDL->HMI: BC.SystemRequest")
          self.hmiConnection:SendResponse(data.id, "BasicCommunication.SystemRequest", "SUCCESS", {})
          logAdd("HMI->SDL: BC.SystemRequest")
          self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate", {policyfile = policy_file_path .. policy_file_name}) 
          logAdd("HMI->SDL: SDL.OnReceivedPolicyUpdate")
        end)      
        EXPECT_RESPONSE(corIdSystemRequest, { success = true, resultCode = "SUCCESS"})  
        :Do(function(_, _)
          logAdd("SDL->MOB: SystemRequest")
          requestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"StatusUpToDate"}})                  
          logAdd("HMI->SDL: SDL.GetUserFriendlyMessage")
          EXPECT_HMIRESPONSE(requestId)        
          logAdd("SDL->HMI: SDL.GetUserFriendlyMessage")
        end)
      end)
    end)
  end

  function Test:ShowSequence()
    print("--- Sequence -------------------------------------")
    for k, v in pairs(sequence) do
      print(k .. ": " .. v)
    end
    print("--------------------------------------------------")
  end    

  function Test:ValidateResult()
    EXPECT_ANY()
    :ValidIf(function(_, _)
      for k in pairs(expectedResult) do
        if (actualResult[k] ~= expectedResult[k]) then
          return false, "Event: " .. sequence[k] .. ", expected step: " .. tostring(k) .. ", got: " .. tostring(getIdx(actualResult, expectedResult[k]))
        end
      end
      return true    
    end)
    :Times(1)
  end  

return Test