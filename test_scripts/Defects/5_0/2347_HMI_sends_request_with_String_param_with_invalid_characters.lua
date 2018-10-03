---------------------------------------------------------------------------------------------------
-- User story: https://github.com/SmartDeviceLink/sdl_core/issues/2347
--
-- Description:
-- HMI sends request with String param with invalid characters.
--
-- Precondition:
-- SDL and HMI are started.
-- App is registered and activated.
--
-- In case:
-- 1) HMI sends *request to SDL (please see list of impacted RPCs below) 
-- and this request has at least one String param with '\n' and/or '\t' and/or 'whitespace' as the only symbol(s).
--
--  SDL.GetUserFriendlyMessage 
--  SDL.GetDeviceConnectionStatus - NO STRING PARAMS (NOT VERIFIED)
--  SDL.ActivateApp - NO STRING PARAMS (NOT VERIFIED)
--  SDL.GetListOfPermissions - NO STRING PARAMS (NOT VERIFIED)
--  SDL.UpdateSDL - NO STRING PARAMS (NOT VERIFIED)
--  SDL.GetStatusUpdate - NO STRING PARAMS (NOT VERIFIED)
--  SDL.GetURLs - NO STRING PARAMS (NOT VERIFIED)
--
-- Expected result:
-- 1) Log corresponding error internally respond with 'INVALID_DATA' to HMI.
--
-- Actual result:
-- N/A
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local common = require('user_modules/sequences/actions')

--[[ Test Configuration ]]
runner.testSettings.isSelfIncluded = false

--[[ Local Functions ]]
local function testGetUserFriendlyMessageValidParams()
	local rqIdValid = common.getHMIConnection():SendRequest("SDL.GetUserFriendlyMessage", {
		language = "EN-US", 
		messageCodes = {"DataConsent"}
	})
	common.getHMIConnection():ExpectResponse(rqIdValid, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
end

local function testGetUserFriendlyMessageRequest(pRqParams)
	local rqIdFull = common.getHMIConnection():SendRequest("SDL.GetUserFriendlyMessage", pRqParams)
	common.getHMIConnection():ExpectResponse(rqIdFull, {error = {code = 11, data = {method = "SDL.GetUserFriendlyMessage"}}})
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", common.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", common.start)

runner.Title("Test")
runner.Step("GetUserFriendlyMessage valid params", testGetUserFriendlyMessageValidParams)
runner.Step("GetUserFriendlyMessage madatory endline", testGetUserFriendlyMessageRequest, { 
	{ 
		messageCodes = {"\n"} 
	} 
})
runner.Step("GetUserFriendlyMessage madatory tab", testGetUserFriendlyMessageRequest, { 
	{ 
		messageCodes = {"\t"} 
	} 
})
runner.Step("GetUserFriendlyMessage madatory whitespace", testGetUserFriendlyMessageRequest, { 
	{ 
		messageCodes = {" "} 
	} 
})
runner.Step("GetUserFriendlyMessage full endline", testGetUserFriendlyMessageRequest, {  
	{ 
		language = "EN-US", 
		messageCodes = {"\n"} 
	}  
})
runner.Step("GetUserFriendlyMessage full tab", testGetUserFriendlyMessageRequest, {  
	{ 
		language = "EN-US", 
		messageCodes = {"\t"} 
	} 
})
runner.Step("GetUserFriendlyMessage full whitespace", testGetUserFriendlyMessageRequest, {  
	{ 
		language = "EN-US", 
		messageCodes = {" "} 
	}  
})

runner.Title("Postconditions")
runner.Step("Stop SDL", common.postconditions)
