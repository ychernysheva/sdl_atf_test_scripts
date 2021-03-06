---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0216-widget-support.md
--
-- Description: Check SDL rejects request with "INVALID_ID" result code if app tries to delete a window with not exist
-- WindowID  in request
--
-- Precondition:
-- 1) SDL and HMI are started
-- 2) DeleteWindow is allowed by policies
-- 3) App is registered and activated
-- Steps:
-- 1) App send DeleteWindow request with Not exist WindowID to SDL
-- SDL does:
--  - send DeleteWindow response with (success = false, resultCode = INVALID_ID") to App
--  - not send UI.DeleteWindow(WindowID) request to HMI
--  - not send OnSystemCapabilityUpdated notification to App
---------------------------------------------------------------------------------------------------
--[[ Required Shared libraries ]]
local common = require('test_scripts/WidgetSupport/common')

--[[ Scenario ]]
common.Title("Preconditions")
common.Step("Clean environment and Back-up/update PPT", common.precondition)
common.Step("Start SDL, init HMI", common.start)
common.Step("Register App", common.registerAppWOPTU)
common.Step("Activate App", common.activateApp)

common.Title("Test")
common.Step("Delete Widget with Not exist WindowID", common.deleteWindowUnsuccess, { 10, "INVALID_ID" })

common.Title("Postconditions")
common.Step("Stop SDL, restore SDL settings and PPT", common.postcondition)
