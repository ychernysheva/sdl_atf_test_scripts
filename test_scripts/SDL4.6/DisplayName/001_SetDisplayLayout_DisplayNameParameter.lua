---------------------------------------------------------------------------------------------------
-- Proposal: https://github.com/smartdevicelink/sdl_evolution/blob/master/proposals/0063-display-name-parameter.md
--
-- Description:
-- Add displayName to the displayCapabiilities response. Mobile will expect this field to be populated
--
-- Steps: Send SetDisplayLayout request.
--
-- Expected result: 
-- SDL Core returns SUCCESS with displayCapabilities: displayName: "GENERIC_DISPLAY"
---------------------------------------------------------------------------------------------------

--[[ Required Shared libraries ]]
local runner = require('user_modules/script_runner')
local commonSmoke = require('test_scripts/Smoke/commonSmoke')

local function getRequestParams()
  return { 
    displayLayout = "ONSCREEN_PRESETS"
  }
end

local function getDisplayCapTextFieldsValues()
  -- some text fields are excluded due to SDL issue
  local names = {
    "alertText1",
    "alertText2",
    "alertText3",
    "audioPassThruDisplayText1",
    "audioPassThruDisplayText2",
    "ETA",
    "initialInteractionText",
    -- "phoneNumber",
    "mainField1",
    "mainField2",
    "mainField3",
    "mainField4",
    "mediaClock",
    "mediaTrack",
    "menuName",
    "menuTitle",
    -- "addressLines",
    -- "locationName",
    "navigationText1",
    "navigationText2",
    -- "locationDescription",
    "scrollableMessageBody",
    "secondaryText",
    "sliderFooter",
    "sliderHeader",
    "statusBar",
    "tertiaryText",
    "totalDistance",
    -- "notificationText",
    -- "navigationText",
    -- "timeToDestination",
    -- "turnText"
  }
  local values = { }
  for _, v in pairs(names) do
    local item = {
      characterSet = "TYPE2SET",
      name = v,
      rows = 1,
      width = 500
    }
    table.insert(values, item)
  end
  return values
end

local function getDisplayCapImageFieldsValues()
  local names = {
    "softButtonImage",
    "choiceImage",
    "choiceSecondaryImage",
    "vrHelpItem",
    "turnIcon",
    "menuIcon",
    "cmdIcon",
    "graphic",
    "showConstantTBTIcon",
    "showConstantTBTNextTurnIcon"
  }
  local values = { }
  for _, v in pairs(names) do
    local item = {
      imageResolution = {
        resolutionHeight = 64,
        resolutionWidth = 64
      },
      imageTypeSupported = {
        "GRAPHIC_BMP",
        "GRAPHIC_JPEG",
        "GRAPHIC_PNG"
      },
      name = v
    }
    table.insert(values, item)
  end
  return values
end

local function setDisplayWithDisplayNameSuccess(self)
  local responseParams = {
    displayCapabilities = {
      displayType = "GEN2_8_DMA",
      displayName = "GENERIC_DISPLAY",
      graphicSupported = true,
      imageFields = getDisplayCapImageFieldsValues(),
      mediaClockFormats = {
        "CLOCK1",
        "CLOCK2",
        "CLOCK3",
        "CLOCKTEXT1",
        "CLOCKTEXT2",
        "CLOCKTEXT3",
        "CLOCKTEXT4"
      },
      numCustomPresetsAvailable = 10,
      screenParams = {
        resolution = {
          resolutionHeight = 480,
          resolutionWidth = 800
        },
        touchEventAvailable = {
          doublePressAvailable = false,
          multiTouchAvailable = true,
          pressAvailable = true
        }
      },
      templatesAvailable = {
        "ONSCREEN_PRESETS"
      },
      textFields = getDisplayCapTextFieldsValues()
    }
  }
  local cid = self.mobileSession1:SendRPC("SetDisplayLayout", getRequestParams())
  EXPECT_HMICALL("UI.SetDisplayLayout", getRequestParams())
  :Do(function(_, data)
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", responseParams)
  end)
  self.mobileSession1:ExpectResponse(cid, {
    success = true,
    resultCode = "SUCCESS",
    displayCapabilities = {
      displayType = "GEN2_8_DMA",
      displayName = "GENERIC_DISPLAY",
      graphicSupported = true,
      imageFields = getDisplayCapImageFieldsValues(),
      mediaClockFormats = {
        "CLOCK1",
        "CLOCK2",
        "CLOCK3",
        "CLOCKTEXT1",
        "CLOCKTEXT2",
        "CLOCKTEXT3",
        "CLOCKTEXT4"
      },
      numCustomPresetsAvailable = 10,
      screenParams = {
        resolution = {
          resolutionHeight = 480,
          resolutionWidth = 800
        },
        touchEventAvailable = {
          doublePressAvailable = false,
          multiTouchAvailable = true,
          pressAvailable = true
        }
      },
      templatesAvailable = {
        "ONSCREEN_PRESETS"
      },
      textFields = getDisplayCapTextFieldsValues()
    }
  })
end

--[[ Scenario ]]
runner.Title("Preconditions")
runner.Step("Clean environment", commonSmoke.preconditions)
runner.Step("Start SDL, HMI, connect Mobile, start Session", commonSmoke.start)
runner.Step("RAI", commonSmoke.registerApp)
runner.Step("Activate App", commonSmoke.activateApp)

runner.Title("Test")
runner.Step("Set displayLayout with display name Positive Case 1", setDisplayWithDisplayNameSuccess)

runner.Title("Postconditions")
runner.Step("Stop SDL", commonSmoke.postconditions)
