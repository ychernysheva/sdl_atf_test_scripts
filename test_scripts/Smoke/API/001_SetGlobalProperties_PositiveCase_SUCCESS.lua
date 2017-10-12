---------------------------------------------------------------------------------------------------
-- User story: Smoke
-- Use case: SetGlobalProperties
-- Item: Happy path
--
-- Requirement summary:
-- [SetGlobalProperties] SUCCESS on TTS.SetGlobalProperties and UI.SetGlobalProperties
--
-- Description:
-- In case mobile application sends valid SetGlobalproperties_request with "timeoutPrompt"
-- and/or "helpPrompt" and at least one other valid parameter, SDL must transfer from mobile
-- app to HMI the both UI.SetGlobalProperties and TTS.SetGlobalProperties. On getting "SUCCESS"
-- result code from the both HMI-portions, SDL must transfer "resutCode:SUCCESS", success:"true"
-- to mobile application.

-- Pre-conditions:
-- a. HMI and SDL are started
-- b. appID is registered and on SDL
-- c. appID is in Background, Full or Limited HMI level

-- Steps:
-- appID requests SetGlobalproperties with timeoutPrompt, helpPrompt and other valid parameters

-- Expected:

-- SDL validates parameters of the request
-- SDL checks if UI interface is available on HMI
-- SDL checks if TTS interface is available on HMI
-- SDL checks if SetGlobalproperties is allowed by Policies
-- SDL checks if all parameters is allowed by Policies
-- SDL transfers the UI part of request with allowed parameters to HMI
-- SDL transfers the TTS part of request with allowed parameters to HMI
-- SDL receives UI and TTS part of response from HMI with "SUCCESS" result code
-- SDL transfers response to mobile app
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonSmokeApi = require('test_scripts/Smoke/commonSmokeApi')

--[[ Local Variables ]]
local requestParams = {
	helpPrompt = {
		{
			text = "Help prompt",
			type = "TEXT"
		}
	},
	timeoutPrompt =	{
		{
			text = "Timeout prompt",
			type = "TEXT"
		}
	},
	vrHelpTitle = "VR help title",
	vrHelp = {
		{
			position = 1,
			image = {
				value = "icon.png",
				imageType = "DYNAMIC"
			},
			text = "VR help item"
		}
	},
	menuTitle = "Menu Title",
	menuIcon = {
		value = "icon.png",
		imageType = "DYNAMIC"
	},
	keyboardProperties = {
		keyboardLayout = "QWERTY",
		keypressMode = "SINGLE_KEYPRESS",
		limitedCharacterList = {"a"},
		language = "EN-US",
		autoCompleteText = "Daemon, Freedom"
	}
}

--[[ Local Functions ]]
local function put_file(fileName, self)
    local cid = self.mobileSession1:SendRPC("PutFile", {
                    syncFileName = fileName,
                    fileType = "GRAPHIC_PNG",
                    persistentFile = false,
                    systemFile = false},
                "files/icon.png")

    self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS"})
end

local function setGlobalProperties(params, self)
	local cid = self.mobileSession1:SendRPC("SetGlobalProperties", params)

	local deviceID = commonSmokeApi.getDeviceMAC()
	params.vrHelp[1].image.value = commonSmokeApi.getPathToSDL() .. "storage/"
		.. commonSmokeApi.getMobileAppId() .. "_" .. deviceID .. "/icon.png"
	params.menuIcon.value = params.vrHelp[1].image.value

	EXPECT_HMICALL("TTS.SetGlobalProperties", {
		timeoutPrompt = params.timeoutPrompt,
		helpPrompt = params.helpPrompt
	})
	:Do(function(_,data)
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)

	EXPECT_HMICALL("UI.SetGlobalProperties", {
		vrHelpTitle = params.vrHelpTitle,
		vrHelp = params.vrHelp,
		menuTitle = params.menuTitle,
		menuIcon = params.menuIcon,
		keyboardProperties = params.keyboardProperties
	})
	:Do(function(_,data)
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)

	self.mobileSession1:ExpectResponse(cid, { success = true, resultCode = "SUCCESS"})

	self.mobileSession1:ExpectNotification("OnHashChange")
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonSmokeApi.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonSmokeApi.start)
runner.Step("RAI, PTU", commonSmokeApi.registerApplicationWithPTU)
runner.Step("Activate App", commonSmokeApi.activateApp)
runner.Step("Upload icon file", put_file, {"icon.png"})

runner.Title("Test")
runner.Step("SetGlobalProperties Positive Case", setGlobalProperties, {requestParams})

runner.Title("Postconditions")
runner.Step("Stop SDL", commonSmokeApi.postconditions)
