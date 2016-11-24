---------------------------------------------------------------------------------------------
-- Requirement summary:
--    [Policies] Application groups checking order

-- Description:
--     Application registers on device for which there's no User permissions
--     1. Used preconditions:
--			Delete log files and policy table from previous ign cycle
--			Overwrite preloaded PT with specific grups in pre_consented
--			Connect device
--
--     2. Performed steps
--		    Register application
--
-- Expected result:
--     App should have only "pre_DataConsent" groups allowed
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('user_modules/connecttest_resumption')
require('cardinalities')
local mobile_session = require('mobile_session')

--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')

--[[ Local variables:
--@arrayRegisterNewApp - pre_consented premissions ]]
local arrayRegisterNewApp = {
  permissionItem =
  {
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "ChangeRegistration"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "DeleteFile"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "EncodedSyncPData"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "ListFiles"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "OnAppInterfaceUnregistered"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "OnEncodedSyncPData"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "OnHMIStatus"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "OnHashChange"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "OnLanguageChange"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "OnPermissionsChange"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "OnSystemRequest"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "PutFile"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "RegisterAppInterface"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "ResetGlobalProperties"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "SetAppIcon"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "SetDisplayLayout"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "SetGlobalProperties"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "SystemRequest"
    },
    {
      hmiPermissions = {
        userDisallowed = {},
        allowed = { "BACKGROUND", "FULL", "LIMITED", "NONE" }
      },
      parameterPermissions = {
        userDisallowed = {},
        allowed = {}
      },
      rpcName = "UnregisterAppInterface"
    }
  }
}

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

commonSteps:DeleteLogsFileAndPolicyTable()

function Test:Precondition_CloseConnection()
  self.mobileConnection:Close()
  commonTestCases:DelayedExp(3000)
end

function Test:Precondition_ConnectDevice()
  commonTestCases:DelayedExp(2000)
  self:connectMobile()
  EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
  {
    deviceList = {
      {
        id = config.deviceMAC,
        isSDLAllowed = true,
        name = "127.0.0.1",
        transportType = "WIFI"
      }
    }
  }
  ):Do(function(_,data)
  self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  :Times(AtLeast(1))
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:RegisterApp_PreConsented_group()
  commonTestCases:DelayedExp(3000)
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
  :Do(function()
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
  :Do(function(_,data)
  self.HMIAppID = data.params.application.appID
  end)
  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
  self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
  self.mobileSession:ExpectNotification("OnPermissionsChange", arrayRegisterNewApp )
  end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postcondition")

function Test.ForceStopSDL()
  commonFunctions:SDLForceStop()
end