
--------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------

local commonSteps   = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.defaultProtocolVersion = 2
local storagePath = config.pathToSDL .. config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"

commonFunctions:userPrint(33, "================= Precondition ==================")
Test = require('connecttest')


function Test:ATF_Certificate_PolicyTable_EmptyValue()
commonFunctions:userPrint(33, "================= Test Case ======================")
local PolicyDBPath = nil
  if commonSteps:file_exists(tostring(config.pathToSDL) .. "/policy.sqlite") == true then
    PolicyDBPath = tostring(config.pathToSDL) .. "/policy.sqlite"
  end
  if commonSteps:file_exists(tostring(config.pathToSDL) .. "/policy.sqlite") == false then
    commonFunctions:userPrint(31, "policy.sqlite file is not found")
    self:FailTestCase("PolicyTable is not avaliable" .. tostring(PolicyDBPath))
  end
  os.execute(" sleep 2 ")
   local certificate = "sqlite3 " .. tostring(PolicyDBPath) .. " \"SELECT certificate FROM module_config WHERE rowid = 1\""
   local aHandle = assert( io.popen( certificate, 'r'))
   local certificateValue = aHandle:read( '*l' )
   if certificateValue ~= "" then
     self:FailTestCase("certificate value in DB is unexpected value " .. tostring(certificateValue))
   end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

Test["ForceKill"] = function (self)
os.execute("ps aux | grep smart | awk \'{print $2}\' | xargs kill -9")
os.execute("sleep 1")

return Test
end