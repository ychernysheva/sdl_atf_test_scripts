---------------------------------------------------------------------------------------------------
-- User story: Smoke
-- Use case: OnSeekMediaClockTimer
-- Item: Happy path
--
-- Requirement summary:
-- [OnSeekMediaClockTimer]: getting SUCCESS:UI.SetMediaClockTimer()

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonSmoke = require('test_scripts/Smoke/commonSmoke')

--[[ Local Variables ]]
local requestParams = {
  startTime = {
    hours = 0,
    minutes = 1,
    seconds = 33
  },
  endTime = {
    hours = 0,
    minutes = 59 ,
    seconds = 35
  },
  updateMode = "COUNTUP",
  enableSeek = true
}

--[[ Local Functions ]]
local function SetMediaClockTimer(self)
  local cid = self.mobileSession1:SendRPC("SetMediaClockTimer", requestParams)

  requestParams.appID = commonSmoke.getHMIAppId()
  EXPECT_HMICALL("UI.SetMediaClockTimer", requestParams)
  :Do(function(_, data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
  end)
  self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS" })
end

local function OnSeekMediaClockTimer(self)
  self.hmiConnection:SendNotification("UI.OnSeekMediaClockTimer",{
    seekTime = {
      hours = 0,
      minutes = 2,
      seconds = 25
    },
    appID = commonSmoke.getHMIAppId()
  })

  self.mobileSession1:ExpectNotification("OnSeekMediaClockTimer", {seekTime = {hours = 0, minutes = 2, seconds = 25 }})
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonSmoke.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonSmoke.start)
runner.Step("RAI", commonSmoke.registerApp)
runner.Step("Activate App", commonSmoke.activateApp)

runner.Title("Test")
runner.Step("App sends SetMediaClockTimer with enableSeek", SetMediaClockTimer)
runner.Step("Mobile app received OnSetMediaClockTimer notification", OnSeekMediaClockTimer)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonSmoke.postconditions)
