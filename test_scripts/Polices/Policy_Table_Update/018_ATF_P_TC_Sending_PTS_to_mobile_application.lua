---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] Sending PTS to mobile application
-- [HMI API] SystemRequest request/response
--
-- Description:
-- SDL must forward OnSystemRequest(request_type=PROPRIETARY, url, appID) with encrypted PTS
-- snapshot as a hybrid data to mobile application with <appID> value. "fileType" must be
-- assigned as "JSON" in mobile app notification.
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: EXTERNAL_PROPRIETARY" flag
-- Application is registered.
-- PTU is requested.
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- SDL->HMI:SDL.PolicyUpdate(file, timeout, retry[])
-- HMI -> SDL: SDL.GetURLs (<service>)
-- 2. Performed steps
-- HMI->SDL:BasicCommunication.OnSystemRequest ('url', requestType:PROPRIETARY, appID)
--
-- Expected result:
-- SDL->app: OnSystemRequest ('url', requestType:PROPRIETARY, fileType="JSON", appID)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')

--[[ General Precondition before ATF start ]]
-- commonFunctions:SDLForceStop()
testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag("EXTENDED_POLICY", "EXTERNAL_PROPRIETARY")
testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild("EXTENDED_POLICY","EXTERNAL_PROPRIETARY")
commonSteps:DeleteLogsFileAndPolicyTable()
commonPreconditions:Connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp("connecttest_RAI.lua")

--ToDo: shall be removed when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_RAI')
require('cardinalities')
require('user_modules/AppTypes')
local mobile_session = require('mobile_session')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:Precondition_remove_user_connecttest()
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

function Test:TestStep_Sending_PTS_to_mobile_application()
  local is_test_fail = false
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  local hmi_app_id

  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = config.application1.appName } })
  :Do(function(_,data)
      hmi_app_id = data.params.application.appID
      EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})

      testCasesForPolicyTableSnapshot:create_PTS(true,
        {config.application1.registerAppInterfaceParams.appID},
        {config.deviceMAC},
        {hmi_app1_id})

      local timeout_after_x_seconds = testCasesForPolicyTableSnapshot:get_data_from_PTS("module_config.timeout_after_x_seconds")
      local seconds_between_retries = {}

      for i = 1, #testCasesForPolicyTableSnapshot.pts_seconds_between_retries do
        seconds_between_retries[i] = testCasesForPolicyTableSnapshot.pts_seconds_between_retries[i].value
      end

      --TODO(istoimenova): function for reading INI file should be implemented
      --local SystemFilesPath = commonSteps:get_data_form_SDL_ini("SystemFilesPath")
      local SystemFilesPath = "/tmp/fs/mp/images/ivsu_cache/"
      local file_pts = SystemFilesPath.."sdl_snapshot.json"

      EXPECT_HMICALL("BasicCommunication.PolicyUpdate", { file = file_pts, timeout = timeout_pts, retry = seconds_between_retries})
      :Do(function(_,data)
          self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
        end)

      local endpoints = {}
      local is_app_esxist = false

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

      local RequestId_GetUrls = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })

      EXPECT_HMIRESPONSE(RequestId_GetUrls,{result = {code = 0, method = "SDL.GetURLS", urls = endpoints} } )
      :Do(function(_,data)
          local app_urls = {}
          for i = 1, #data.result.urls do
            if(data.result.urls[i].appID == hmi_app_id) then
              app_urls = data.result.urls[i]
            end
          end

          self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",{
              requestType = "PROPRIETARY",
              url = app_urls.url,
              appID = app_urls.appID })

          EXPECT_NOTIFICATION("OnSystemRequest", {
              requestType = "PROPRIETARY",
              fileType = "JSON",
              url = app_urls.url,
              appID = config.application1.registerAppInterfaceParams.appID })
        end)

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
