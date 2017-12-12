---------------------------------------------------------------------------------------------------
-- RC common module
---------------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.defaultProtocolVersion = 2
config.ValidateSchema = false

--[[ Required Shared libraries ]]
local commonFunctions = require("user_modules/shared_testcases/commonFunctions")
local commonSteps = require("user_modules/shared_testcases/commonSteps")
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local sdl = require("SDL")

--[[ Local Variables ]]
local commonDefect = {}

local function allowSdl(self)
  self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {
    allowed = true, source = "GUI", device = { id = config.deviceMAC, name = "127.0.0.1" }
  })
end

function commonDefect.preconditions()
  commonFunctions:SDLForceStop()
  commonSteps:DeletePolicyTable()
  commonSteps:DeleteLogsFiles()
end

function commonDefect.start(self)
  self:runSDL()
  commonFunctions:waitForSDLStart(self)
  :Do(function()
      self:initHMI(self)
      :Do(function()
          commonFunctions:userPrint(35, "HMI initialized")
          self:initHMI_onReady()
          :Do(function()
              commonFunctions:userPrint(35, "HMI is ready")
              self:connectMobile()
              :Do(function()
                  commonFunctions:userPrint(35, "Mobile connected")
                  allowSdl(self)
                end)
            end)
        end)
    end)
end

function commonDefect.postconditions()
  StopSDL()
end

function commonDefect.printSDLConfig()
  commonFunctions:printTable(sdl.buildOptions)
end

function commonDefect.ignitionOff(self)
  self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "SUSPEND" })
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
  :Do(function()
      self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "IGNITION_OFF" })
      self.mobileSession:ExpectNotification("OnAppInterfaceUnregistered", { reason = "IGNITION_OFF" })
      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", { unexpectedDisconnect = false })
      EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")
      :Do(function()
          sdl:DeleteFile()
        end)
    end)
end

function commonDefect.backupINIFile()
  commonPreconditions:BackupFile("smartDeviceLink.ini")
end

function commonDefect.restoreINIFile()
  commonPreconditions:RestoreFile("smartDeviceLink.ini")
end

return commonDefect
