---------------------------------------------------------------------------------------------
-- Policy: AppID Management common module
---------------------------------------------------------------------------------------------

local common = {}  

  local policy_file_path = "/tmp/fs/mp/images/ivsu_cache/"
  local policy_file_name = "PolicyTableUpdate"

  local function checkOnStatusUpdate(test)  
    EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
    :ValidIf(function(exp, data)
      if (exp.occurences == 1 and data.params.status == "UPDATING") or
        (data.params.status == "UP_TO_DATE") then
        return true
      else
        local reason = "SDL.OnStatusUpdate came with wrong values. "
        if exp.occurences == 1 then
          reason = reason .. "Expected in first occurrences status 'UP_TO_DATE' or 'UPDATING', got '" .. tostring(data.params.status) .. "'"
        elseif exp.occurences == 2 then
          reason = reason .. "Expected in second occurrences status 'UP_TO_DATE', got '" .. tostring(data.params.status) .. "'"
        end
        return false, reason
      end
    end)
    :Times(Between(1,2))
  end  

  function common:updatePolicyTable(test, file)     
    -- Check SDL.OnStatusUpdate
    checkOnStatusUpdate(test)
    -- HMI->SDL: SDL.GetURLs(service_type = 7)
    local requestId = test.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })      
    -- SDL->HMI: GetURLs(SUCCESS, urls: [appId, url])
    EXPECT_HMIRESPONSE(requestId, {result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
    :Do(function(_, _)
      -- HMI->SDL: BC.OnSystemRequest(request_type=PROPRIETARY, url, appId, fileName)
      test.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
        {
          requestType = "PROPRIETARY",
          fileName = policy_file_name
        }
      )
    end)
    -- SDL->MOB: OnSystemRequest(request_type=PROPRIETARY, url, binary_header + policies_snapshot)
    EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" }) 
    :Do(function(_, _)       
      -- MOB->SDL: SystemRequest(request_type=PROPRIETARY, fileName + policies update)      
      local corIdSystemRequest = test.mobileSession:SendRPC("SystemRequest",
        {     
          requestType = "PROPRIETARY",
          fileName = policy_file_name
        },
        file)          
      -- SDL->HMI: SystemRequest(request_type=PROPRIETARY, PTUFileName, appId)
      EXPECT_HMICALL("BasicCommunication.SystemRequest")      
      :Do(function(_, data)       
        -- HMI->SDL: SUCCESS: SystemRequest
        test.hmiConnection:SendResponse(data.id, "BasicCommunication.SystemRequest", "SUCCESS", {})
        -- HMI->SDL: SDL.OnReceivedPolicyTable(PTUFileName)
        test.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
          {          
            policyfile = policy_file_path .. policy_file_name
          }
        )             
      end)
      
      EXPECT_RESPONSE(corIdSystemRequest, { success = true, resultCode = "SUCCESS"})  
      :Do(function(_, _)
        requestId = test.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"StatusUpToDate"}})        
        EXPECT_HMIRESPONSE(requestId)        
      end)
    end)    
  end

return common