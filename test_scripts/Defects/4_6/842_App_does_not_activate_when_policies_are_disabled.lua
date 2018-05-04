--------------------------------------------------------------------------------
-- User story: https://github.com/smartdevicelink/sdl_core/issues/842

-- Pre-conditions:
-- 1. SDL is started (EnablePolicy = false)
-- 2. HMI is started 

-- Steps to reproduce:
-- 1. Activate App

-- Expected:
-- The application was activated.
--------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('test_scripts/Defects/commonDefects')
local mobile_session = require("mobile_session")
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")

--[[ Local Variables ]]
local kSuccess = 0
local hmiAppIds = {}

--[[ Local Functions ]]
local function rai(self)
    self, id = common.getSelfAndParams(1, self)
    if not id then id = 1 end
    self["mobileSession" .. id] = mobile_session.MobileSession(self, self.mobileConnection)
    self["mobileSession" .. id]:StartService(7)
    :Do(function()
        local corId = self["mobileSession" .. id]:SendRPC
        ("RegisterAppInterface", config["application" .. id].registerAppInterfaceParams)
        EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered",
            { application = { appName = config["application" .. id].registerAppInterfaceParams.appName } })
        :Do(function(_, d1)
            hmiAppIds[config["application" .. id].registerAppInterfaceParams.appID] = d1.params.application.appID
            end)
        self["mobileSession" .. id]:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
        :Do(function()
            self["mobileSession" .. id]:ExpectNotification("OnHMIStatus",
                { hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN" })
            :Times(AtLeast(1))
            end)
        end)
end    

local function disablingPolicy()
    enablePolicyBackup = commonFunctions:read_parameter_from_smart_device_link_ini("EnablePolicy")
    if not commonFunctions:write_parameter_to_smart_device_link_ini("EnablePolicy", "false") then
        test:FailTestCase("Value is not set.")
    end
end

local function activateApp(expectedCode, self)
    local requestId = self.hmiConnection:SendRequest("SDL.ActivateApp", 
        { appID = hmiAppIds[config["application" .. id].registerAppInterfaceParams.appID] })
    EXPECT_HMIRESPONSE(requestId)
    :ValidIf(function(_, data)
        local actualCode = 
            (data.error ~= nil and data.error.code or data.result.code)
        if(expectedCode == actualCode) then
            return true
        end
        return false, "Expected value:" .. tostring(expectedCode) .. 
            "\nActual value: " .. tostring(actualCode)
    end)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Disabling Policy", disablingPolicy)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI", rai)

runner.Title("Test")
runner.Step("ActivateApp", activateApp, { kSuccess })

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
