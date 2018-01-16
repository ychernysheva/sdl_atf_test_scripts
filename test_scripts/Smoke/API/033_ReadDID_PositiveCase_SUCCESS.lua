---------------------------------------------------------------------------------------------------
-- User story: Smoke
-- Use case: ReadDID
-- Item: Happy path
--
-- Requirement summary:
-- [ReadDID] SUCCESS: getting SUCCESS:VehicleInfo.ReadDID()
--
-- Description:
-- Mobile application sends valid ReadDID request and gets VehicleInfo.ReadDID "SUCCESS" response from HMI

-- Pre-conditions:
-- a. HMI and SDL are started
-- b. appID is registered and activated on SDL
-- c. appID is currently in Background, Full or Limited HMI level

-- Steps:
-- appID requests ReadDID with valid parameters

-- Expected:
-- SDL validates parameters of the request
-- SDL checks if VehicleInfo interface is available on HMI
-- SDL checks if ReadDID is allowed by Policies
-- SDL checks if all parameters are allowed by Policies
-- SDL transfers the VehicleInfo part of request with allowed parameters to HMI
-- SDL receives VehicleInfo part of response from HMI with "SUCCESS" result code
-- SDL responds with (resultCode: SUCCESS, success:true) to mobile application
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonSmoke = require('test_scripts/Smoke/commonSmoke')

--[[ Local Functions ]]
local function PTUpdateFunc(tbl)
  local ReadDIDgroup = {
    rpcs = {
      ReadDID = {
        hmi_levels = { "BACKGROUND", "FULL", "LIMITED" },
      }
    }
  }
  tbl.policy_table.functional_groupings.NewTestCaseGroup = ReadDIDgroup
  tbl.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID].groups =
  { "Base-4", "NewTestCaseGroup" }
end

local function setReadDIDRequest()
  local temp = {
    ecuName = 2000,
    didLocation = {
      56832
    }
  }
  return temp
end

local function setReadDIDSuccessResponse(didLocationValues)
  local temp = {
    didResult = {}
  }
  for i = 1, #didLocationValues do
    temp.didResult[i] = {
      resultCode = "SUCCESS",
      didLocation = didLocationValues[i],
      data = "123"
    }
  end
  return temp
end

local function readDID(self)
  local paramsSend = setReadDIDRequest()
  local response = setReadDIDSuccessResponse(paramsSend.didLocation)
  local cid = self.mobileSession1:SendRPC("ReadDID",paramsSend)
  paramsSend.appID = commonSmoke.getHMIAppId()
  EXPECT_HMICALL("VehicleInfo.ReadDID",paramsSend)
  :Do(function(_,data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", response)
  end)
  local expectedResult = response
  expectedResult.success = true
  expectedResult.resultCode = "SUCCESS"
  self.mobileSession1:ExpectResponse(cid, expectedResult)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonSmoke.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonSmoke.start)
runner.Step("RAI, PTU", commonSmoke.registerApplicationWithPTU, { 1, PTUpdateFunc})
runner.Step("Activate App", commonSmoke.activateApp)

runner.Title("Test")
runner.Step("ReadDID Positive Case", readDID)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonSmoke.postconditions)
