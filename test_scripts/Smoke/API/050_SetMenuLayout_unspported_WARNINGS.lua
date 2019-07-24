---------------------------------------------------------------------------------------------------
-- User story: Smoke
-- Use case: Set Menu Layout
-- Item: Happy path
--
-- Requirement summary:
-- [ReadDID] SUCCESS: getting SUCCESS:VehicleInfo.GetSystemCapabilities()
--
-- Description:
-- HMI Has capability to support a TILES menuLayout

-- Pre-conditions:
-- a. HMI and SDL are started
-- b. appID is registered and activated on SDL
-- c. appID is currently in Background, Full or Limited HMI level
-- d. HMI display capabilities member menuLayoutsAvailable contains TILES

-- Steps:
-- Mobile App calls SetGlobalProperties with menuLayout = TILES
-- Mobile App calls AddSubMenu with menuLayout = TILES

-- Expected:
-- SDL responds with (resultCode: SUCCESS, success:true) to mobile application for both requests
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonSmoke = require('test_scripts/Smoke/commonSmoke')
local hmi_values = require('user_modules/hmi_values')

--[[ Local Variables ]]
local function setMenuLayoutTiles(self)
  local cid = self.mobileSession1:SendRPC("SetGlobalProperties", { menuLayout = "TILES", menuTitle = "sickMenu" })
  
  EXPECT_HMICALL("UI.SetGlobalProperties", {})
  :Do(function(_, data)
    --util.printTable(data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
    self.mobileSession1:ExpectResponse(cid, {
      success = true,
      resultCode = "WARNINGS"
    })
  end)

  local _addSubMenuParams = { menuLayout = "TILES",
                              menuID = 44991234,
                              menuName = "sickMenu"
                            }

  local cid2 = self.mobileSession1:SendRPC("AddSubMenu", _addSubMenuParams)
  
  EXPECT_HMICALL("UI.AddSubMenu", {})
  :Do(function(_, data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
    self.mobileSession1:ExpectResponse(cid2, {
      success = true,
      resultCode = "WARNINGS"
    })
  end)
end

local function getHMIParams()
  local params = hmi_values.getDefaultHMITable()
  params.UI.GetCapabilities.params.displayCapabilities.menuLayoutsAvailable = { "LIST" }
  return params
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonSmoke.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonSmoke.start, { getHMIParams() })
runner.Step("RAI", commonSmoke.registerApp)
runner.Step("Activate App", commonSmoke.activateApp)

runner.Title("Test")
runner.Step("Attempting to use unsupported menu layout TILES", setMenuLayoutTiles)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonSmoke.postconditions)
