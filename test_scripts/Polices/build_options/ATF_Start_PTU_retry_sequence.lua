-- UNREADY:
--function Test:TestStep_Start_Retry_Sequence is not developed
--function testCasesForPolicyTable.flow_PTU_SUCCEESS_PROPRIETARY
---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] Local Policy Table retry sequence start
--
-- Description:
--      In case PoliciesManager does not receive the Updated PT during time defined in
--      "timeout_after_x_seconds" section of Local PT, it must start the retry sequence.
-- 1. Used preconditions
--      SDL is built with "-DEXTENDED_POLICY: PROPRIETARY" flag
--      Application is registered
--      PTU is requested
--      PTU omits "consumer_friendly_messages" section
--      SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
--      SDL->HMI:SDL.PolicyUpdate(file, timeout, retry[])
--      HMI -> SDL: SDL.GetURLs (<service>)
--      HMI->SDL: BasicCommunication.OnSystemRequest ('url', requestType: PROPRIETARY)
-- 2. Performed steps
--      SDL->app: OnSystemRequest ('url', requestType:PROPRIETARY, fileType="JSON")
-- Expected result:
--      Timeout expires and retry sequence started
--      SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--[TODO: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForPolicyTableSnapshot = require ('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
--[TODO: Function should be implmented
function Test:TestStep_Start_Retry_Sequence ()
  testCasesForPolicyTable:flow_PTU_SUCCEESS_PROPRIETARY(self, app_id, device_id, hmi_app_id, ptu_file_path, ptu_file_name, ptu_file)
  if (app_id == nil) then app_id = config.application1.registerAppInterfaceParams.appID end
  if (device_id == nil) then device_id = config.deviceMAC end
  if (hmi_app_id == nil) then hmi_app_id = self.applications[config.application1.registerAppInterfaceParams.appName] end
  if (ptu_file_path == nil) then ptu_file_path = "files/" end
  if (ptu_file_name == nil) then ptu_file_name = "PolicyTableUpdate" end
  if (ptu_file == nil) then ptu_file = "ptu.json" end
  --[[Start get data from PTS]]
  --TODO(istoimenova): function for reading INI file should be implemented
  --local SystemFilesPath = commonSteps:get_data_from_SDL_ini("SystemFilesPath")
  local SystemFilesPath = "/tmp/fs/mp/images/ivsu_cache/"

  -- Check SDL snapshot is created correctly and get needed data
  testCasesForPolicyTableSnapshot:verify_PTS(true, {app_id}, {device_id}, {hmi_app_id})
  local endpoints = {}
  for i = 1, #testCasesForPolicyTableSnapshot.pts_endpoints do
    if (testCasesForPolicyTableSnapshot.pts_endpoints[i].service == "0x07") then
      endpoints[1] = { url = testCasesForPolicyTableSnapshot.pts_endpoints[i].value, appID = nil}
    end
  end
  local RequestId_GetUrls = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestId_GetUrls,{result = {code = 0, method = "SDL.GetURLS", urls = endpoints} } )
  :Do(function(_,_)
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
        { requestType = "PROPRIETARY", fileName = ptu_file_name})
      EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "PROPRIETARY"})
      :Do(function(_,_)
          EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate",
            {status = "UPDATING"})
            :Times(1)
          local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest", {requestType = "PROPRIETARY", fileName = ptu_file_name, appID = app_id}, ptu_file_path..ptu_file)
          EXPECT_HMICALL("BasicCommunication.SystemRequest",{ requestType = "PROPRIETARY", fileName = SystemFilesPath..ptu_file_name })
          :Do(function(_,_data1)
              self.hmiConnection:SendResponse(_data1.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
            end)
          EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate",
            {status = "UPDATE_NEEDED"}):Times(1)
        end)
    end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test:Postcondition_Force_Stop_SDL()
  commonFunctions:SDLForceStop(self)
end