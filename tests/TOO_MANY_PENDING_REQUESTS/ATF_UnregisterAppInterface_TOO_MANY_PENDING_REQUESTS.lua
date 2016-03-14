Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

local commonSteps = require('user_modules/shared_testcases/commonSteps')

function DelayedExp()
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, 5000)
end

local sessions = {}
local TooManyPenReqCount = 0

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

function Test:Precondition_StartSession2()
  -- Connected expectation
  self.mobileSession2 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application2.registerAppInterfaceParams)
  table.insert(sessions,self.mobileSession)
  table.insert(sessions,self.mobileSession2)
end

function Test:RegisterAppSession2()
	self.mobileSession2:Start()
end

function Test:Precondition_StartSession3()
  -- Connected expectation
  self.mobileSession3 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application3.registerAppInterfaceParams)
  table.insert(sessions,self.mobileSession3)
end

function Test:RegisterAppSession3()
	self.mobileSession3:Start()
end

function Test:Precondition_StartSession4()
  -- Connected expectation
  self.mobileSession4 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application4.registerAppInterfaceParams)
  table.insert(sessions,self.mobileSession4)

end

function Test:RegisterAppSession4()
	self.mobileSession4:Start()
end

function Test:Precondition_StartSession5()
  -- Connected expectation
  self.mobileSession5 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application5.registerAppInterfaceParams)
  table.insert(sessions,self.mobileSession5)

end

function Test:RegisterAppSession5()
	self.mobileSession5:Start()
end

function Test:Precondition_StartSession6()
  -- Connected expectation
  self.mobileSession6 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application6.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession6)

end

function Test:RegisterAppSession6()
	self.mobileSession6:Start()
end

function Test:Precondition_StartSession7()
  -- Connected expectation
  self.mobileSession7 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application7.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession7)

end

function Test:RegisterAppSession7()
	self.mobileSession7:Start()
end

function Test:Precondition_StartSession8()
  -- Connected expectation
  self.mobileSession8 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application8.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession8)

end

function Test:RegisterAppSession8()
	self.mobileSession8:Start()
end

function Test:Precondition_StartSession9()
  -- Connected expectation
  self.mobileSession9 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application9.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession9)

end

function Test:RegisterAppSession9()
	self.mobileSession9:Start()
end

function Test:Precondition_StartSession10()
  -- Connected expectation
  self.mobileSession10 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application10.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession10)

end

function Test:RegisterAppSession10()
	self.mobileSession10:Start()
end

function Test:Precondition_StartSession11()
  -- Connected expectation
  self.mobileSession11 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application11.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession11)

end

function Test:RegisterAppSession11()
  self.mobileSession11:Start()
end

function Test:Precondition_StartSession12()
  -- Connected expectation
  self.mobileSession12 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application12.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession12)

end

function Test:RegisterAppSession12()
  self.mobileSession12:Start()
end

function Test:Precondition_StartSession13()
  -- Connected expectation
  self.mobileSession13 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application13.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession13)
end

function Test:RegisterAppSession13()
  self.mobileSession13:Start()
end

function Test:Precondition_StartSession14()
  -- Connected expectation
  self.mobileSession14 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application14.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession14)
end

function Test:RegisterAppSession14()
  self.mobileSession14:Start()
end

function Test:Precondition_StartSession15()
  -- Connected expectation
  self.mobileSession15 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application15.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession15)
end

function Test:RegisterAppSession15()
  self.mobileSession15:Start()
end

function Test:Precondition_StartSession16()
  -- Connected expectation
  self.mobileSession16 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application16.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession16)
end

function Test:RegisterAppSession16()
  self.mobileSession16:Start()
end

function Test:Precondition_StartSession17()
  -- Connected expectation
  self.mobileSession17 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application17.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession17)
end

function Test:RegisterAppSession17()
  self.mobileSession17:Start()
end

function Test:Precondition_StartSession18()
  -- Connected expectation
  self.mobileSession18 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application18.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession18)
end
function Test:RegisterAppSession18()
  self.mobileSession18:Start()
end
function Test:Precondition_StartSession19()
  -- Connected expectation
  self.mobileSession19 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application19.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession19)
end
function Test:RegisterAppSession19()
  self.mobileSession19:Start()
end
function Test:Precondition_StartSession20()
  -- Connected expectation
  self.mobileSession20 = mobile_session.MobileSession(
    self,
    self.mobileConnection,
    config.application20.registerAppInterfaceParams)
    table.insert(sessions,self.mobileSession20)
end
function Test:RegisterAppSession20()
  self.mobileSession20:Start()
end


----------------------------------------------------------------------------------------------
----------------------------------------IV TEST BLOCK-----------------------------------------
---------------------------------------Result codes check--------------------------------------
----------------------------------------------------------------------------------------------
--Begin Test suit ResultCodeCheck
--Description:TC check TOO_MANY_PENDING_REQUESTS resultCode

    --Requirement id in JAMA: SDLAQ-CRS-373

    --Verification criteria: The system has more than M (M defined in smartDeviceLink.ini) requests  at a timethat haven't been responded yet.

function Test:UnregisterAppInterface_TooManyPendingRequest()

    for i = 1 , #sessions do
      sessions[i]:SendRPC("UnregisterAppInterface", {})
    end

    EXPECT_ANY_SESSION_NOTIFICATION("UnregisterAppInterface")
    :ValidIf(function(exp,data)
      if 
        data.payload.resultCode == "TOO_MANY_PENDING_REQUESTS" then
          TooManyPenReqCount = TooManyPenReqCount+1
          print(" \27[32m UnregisterAppInterface response came with resultCode TOO_MANY_PENDING_REQUESTS \27[0m ")
          return true
      elseif exp.occurences == #sessions and TooManyPenReqCount == 0 then 
        print(" \27[36m Response UnregisterAppInterface with resultCode TOO_MANY_PENDING_REQUESTS did not came \27[0m ")
        return false
      elseif
        data.payload.resultCode == "SUCCESS" then
          print(" \27[32m UnregisterAppInterface response came with resultCode SUCCESS \27[0m ")
          return true
      else 
        print(" \27[36m Some unexpected message event ")
        print("  UnregisterAppInterface response came with resultCode "..tostring(data.payload.resultCode).."\27[0m")
        return false
      end
    end)
    :Times(AtLeast(#sessions))


    DelayedExp()

  end

--End Test suit ResultCodeCheck
