Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

local commonSteps = require('user_modules/shared_testcases/commonSteps')

local TooManyPenReqCount = 0
--///////////////////////////////////////////////////////////////////////////--
--Script cheks TOO_MANY_PENDING_REQUEST resultCode in DialNumber response from SDL
--///////////////////////////////////////////////////////////////////////////--

--Precondition: app activation
commonSteps:ActivationApp()

local function DelayedExp()
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, 5000)
end


local requestCount = 0
local IDsArray = {}
local CorIdDialNumber = {}
--///////////////////////////////////////////////////////////////////////////--
--Check TOO_MANY_PENDING_REQUEST resultCode in DialNumber response from HMI
  function Test:DialNumber_TooManyPendingRequest()

    --sending 300 requests DialNumber
    for n =1,100 do 
        self.mobileSession:SendRPC("DialNumber",
            {
              number = "#3804567654*qwersdcvbnm1234567890"..tostring(n)
            })
    end
    --expect response DialNumber
    EXPECT_RESPONSE("DialNumber")
      :ValidIf(function(exp,data)
        if 
          data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
              TooManyPenReqCount = TooManyPenReqCount+1
              print(" \27[32m DialNumber response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m")
            return true
        elseif 
            exp.occurences == 100 and TooManyPenReqCount == 0 then 
              print(" \27[36m Response DialNumber with resultCode TOO_MANY_PENDING_REQUESTS did not came \27[0m")
              return false
        elseif 
            data.payload.resultCode == "SUCCESS" then
              print(" \27[32m DialNumber response came with resultCode SUCCESS \27[0m")
              return true
        else
            print(" \27[36m DialNumber response came with resultCode "..tostring(data.payload.resultCode .. "\27[0m" ))
            return false
        end
      end)
      :Times(100)
      :Timeout(5000)


    EXPECT_HMICALL("BasicCommunication.DialNumber")
    :Times(Between(1,100))
    :Do(function(exp,data)

        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

    end)

    --mobile side: expect absence of OnAppInterfaceUnregistered
    EXPECT_NOTIFICATION("OnAppInterfaceUnregistered")
    :Times(0)

    --hmi side: expect absence of BasicCommunication.OnAppUnregistered
    EXPECT_HMICALL("BasicCommunication.OnAppUnregistered")
    :Times(0)

    DelayedExp()
  end


















