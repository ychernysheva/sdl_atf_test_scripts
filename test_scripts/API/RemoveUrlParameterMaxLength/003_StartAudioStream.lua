---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0200-Removing-URL-Param-Max-Length.md
--
-- Description: Check processing of Navigation.AudioStreamConsumer request with url length more than 500 characters
--
-- In case:
-- 1. AudioStreamConsumer is set to file value
-- 2. AudioStreamFile is sent to value with length in 255 characters
-- 3. Audio service starts
-- SDL does:
-- - sends Navigation.StartAudioStream(<pathToSDL/AppStorageFolder + file name>)
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('user_modules/sequences/actions')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false
config.defaultProtocolVersion = 3

--[[ Local Variables ]]
local longString = string.rep("u", 255)
common.getConfigAppParams(1).appHMIType = { "NAVIGATION" }

--[[ Local Functions ]]
local function iniFilePreparation()
  common.sdl.setSDLIniParameter("AudioStreamConsumer", "file")
  common.sdl.setSDLIniParameter("AudioStreamFile", longString)
end

local function StartAudioStream()
  common.getMobileSession():StartService(10)
  :Do(function()
      common.getHMIConnection():ExpectRequest("Navigation.StartAudioStream",
        {
          url = commonPreconditions:GetPathToSDL() ..
          common.sdl.getSDLIniParameter("AppStorageFolder") .. "/" .. longString
        })
      :Do(function(_, data)
          common.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
        end)
    end)
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Ini file preparation", iniFilePreparation)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)
runner.Step("RAI", common.registerApp)
runner.Step("Activate App", common.activateApp)

runner.Title("Test")

runner.Step("StartAudioStream", StartAudioStream)

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)

