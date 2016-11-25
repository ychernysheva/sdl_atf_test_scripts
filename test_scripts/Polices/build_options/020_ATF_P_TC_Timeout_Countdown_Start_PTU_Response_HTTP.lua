-- UNDONE:

-- Function function Test:TestStep_Sending_PTS_to_mobile_application() still not implemented,
-- error PANIC: unprotected error in call to Lua API (...0_ATF_P_TC_Timeout_Countdown_Start_PTU_Response_HTTP.lua:172: attempt to perform arithmetic on local 'time_2' (a nil value))
---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] "timeout" countdown start
-- [HMI API] SystemRequest request/response
--
-- Description:
--PoliciesManager must start timeout taken from "timeout_after_x_seconds" field of LocalPT
--right after OnSystemRequest is sent out to mobile app.
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: HTTP" flag
-- Application is registered.
-- PTU is requested.
-- 2. Performed steps
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- SDL->HMI:SDL.PolicyUpdate(file, timeout, retry[])
-- HMI -> SDL: SDL.GetURLs (<service>)
-- HMI->SDL: BasicCommunication.OnSystemRequest ('url', requestType:HTTP, appID="default")
-- SDL->app: OnSystemRequest ('url', requestType:HTTP, fileType="JSON", appID)
-- SDL->HMI: SDL.OnStatusUpdate(UPDATING)
--
-- Expected result:
--SDL waits for SystemRequest response from <app ID> within 'timeout' value,
--if no obtained, it starts retry sequence
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFileAndPolicyTable()
commonPreconditions:Connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp("connecttest_RAI.lua")

--TODO(mmihaylova-banska): Should be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_RAI')
require('cardinalities')
require('user_modules/AppTypes')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test.Precondition_remove_user_connecttest()
  os.execute( "rm -f ./user_modules/connecttest_RAI.lua" )
end

function Test:Precondition_ConnectMobile()
  self:connectMobile()
end

function Test:Precondition_StartNewSession()
  self.mobileSession = mobile_session.MobileSession( self, self.mobileConnection)
  self.mobileSession:StartService(7)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")
--TODO(mmihaylova-banska): Function still not implemented
function Test:TestStep_Sending_PTS_to_mobile_application()
  local time_update_needed = {}
  local time_system_request = {}
  local timeout_pts
  local seconds_between_retries = {}
  local endpoints = {}
  local is_app_esxist = false
  local is_test_fail = false
  --local is_first_cycle = 1

  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application1.appName } })
  :Do(function(exp_rai,data)
      if (exp_rai.occurences == 1) then

        local hmi_app_id = data.params.application.appID
        -- "SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"} is sent at receiving request RegisterAppInterface
        -- As result sequence is not executed. Debug file is created locally
        EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
        :Times(2) -- check first retry sequence
        :Do(function(exp_on_status_update,_)
            if (exp_on_status_update.occurences == 1) then
              time_update_needed[#time_update_needed + 1] = timestamp()

              testCasesForPolicyTableSnapshot:verify_PTS(true,
                {config.application1.registerAppInterfaceParams.appID},
                {config.deviceMAC},
                {hmi_app_id})

              timeout_pts = testCasesForPolicyTableSnapshot:get_data_from_PTS("module_config.timeout_after_x_seconds")
              for i = 1, #testCasesForPolicyTableSnapshot.pts_seconds_between_retries do
                seconds_between_retries[i] = testCasesForPolicyTableSnapshot.pts_seconds_between_retries[i].value
              end

              for i = 1, #testCasesForPolicyTableSnapshot.pts_endpoints do
                if (testCasesForPolicyTableSnapshot.pts_endpoints[i].service == "0x07") then
                  endpoints[#endpoints + 1] = { url = testCasesForPolicyTableSnapshot.pts_endpoints[i].value, appID = nil}
                end

                if (testCasesForPolicyTableSnapshot.pts_endpoints[i].service == "app1") then
                  endpoints[#endpoints + 1] = {
                    url = testCasesForPolicyTableSnapshot.pts_endpoints[i].value,
                    appID = testCasesForPolicyTableSnapshot.pts_endpoints[i].appID}
                  is_app_esxist = true
                end
              end

              if(is_app_esxist == false) then
                commonFunctions:printError("endpoints for application doesn't exist!")
                is_test_fail = true
                endpoints[#endpoints + 1] = { url = endpoints[#endpoints].value, appID = hmi_app_id}
              end

              --TODO(istoimenova): function for reading INI file should be implemented
              --local SystemFilesPath = commonSteps:get_data_form_SDL_ini("SystemFilesPath")
              local SystemFilesPath = "/tmp/fs/mp/images/ivsu_cache/"
              local file_pts = SystemFilesPath.."sdl_snapshot.json"

              EXPECT_HMICALL("BasicCommunication.PolicyUpdate", { file = file_pts, timeout = timeout_pts, retry = seconds_between_retries})
              :Do(function(_,_) self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {}) end)

              local RequestId_GetUrls = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })

              EXPECT_HMIRESPONSE(RequestId_GetUrls,{result = {code = 0, method = "SDL.GetURLS", urls = endpoints} } )
              :Do(function(_,_)
                  local app_urls = {}
                  if(data.result ~= nil) then
                    for i = 1, #data.result.urls do
                      if(data.result.urls[i].appID == hmi_app_id) then
                        app_urls = data.result.urls[i]
                      end
                    end
                  else
                    is_test_fail = true
                    commonFunctions:printError("Endpoints of GetUrls response are empty.")
                  end
                  --Left for debugging
                  --self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",{ requestType = "PROPRIETARY", fileName = "PolicyTableUpdate"})

                  self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",{
                      fileName = "PolicyTableUpdate",
                      requestType = "PROPRIETARY",
                      url = endpoints[1].url,
                      appID = "default" })

                  EXPECT_NOTIFICATION("OnSystemRequest", {
                      requestType = "PROPRIETARY",
                      fileType = "JSON",
                      url = endpoints[1].url,
                      appID = config.application1.registerAppInterfaceParams.appID })
                  :Do(function(_,_) time_system_request[#time_system_request + 1] = timestamp() end)

                  --first retry sequence
                  local time_wait = (timeout_pts*seconds_between_retries[1]*1000 + 10000)
                  commonTestCases:DelayedExp(time_wait) -- tolerance 10 sec
                end)
            else --if (exp_on_status_update.occurences == 1) then
              EXPECT_NOTIFICATION("OnSystemRequest",{})
              EXPECT_HMICALL("BasicCommunication.PolicyUpdate", { file = file_pts, timeout = timeout_pts, retry = seconds_between_retries})
              :Do(function(_,data1) self.hmiConnection:SendResponse(data1.id, data1.method, "SUCCESS", {}) end)

              time_update_needed[#time_update_needed + 1] = timestamp()
              local time_1 = time_update_needed[#time_update_needed]
              local time_2 = time_system_request[#time_system_request]
              local timeout = (time_1 - time_2)
              if(
                ( timeout > (timeout_pts*1000 + 2000) ) or
                ( timeout < (timeout_pts*1000 - 2000) )) then
                is_test_fail = true
                commonFunctions:printError("timeout for "..tostring(exp_rai.occurences - 1).." retry sequence is not as expected: "..timeout_pts.."msec(5sec tolerance). real: "..timeout.."ms")
              else
                print("timeout is as expected: "..timeout_pts.."ms. real: "..timeout)
              end
            end--if (exp_on_status_update.occurences == 1) then
          end)-- :Do(function(exp_on_status_update,data)

      end-- if exp_rai.occurences == 1 then
    end)
  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS"})

  if(is_test_fail == true) then
    self:FailTestCase("Test is FAILED. See prints.")
  end
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
function Test:Postcondition_Force_Stop_SDL()
  commonFunctions:SDLForceStop(self)
end

return Test
