local testCasesForRAI = {}

require('atf.util')
local events = require("events")

--[[@Connecttest_onlywith_StartSDL_InitHMIOnReady: replace original connecttest with new one
-- the uses only RunSDL and InitHMI
--! @parameters:
--! @FileName - new name of connecttest
--]]
function testCasesForRAI:Connecttest_onlywith_StartSDL_InitHMIOnReady(FileName)
  -- copy initial connecttest.lua to FileName
  os.execute( 'cp ./modules/connecttest.lua ./user_modules/' .. tostring(FileName))

  local f = assert(io.open('./user_modules/' .. tostring(FileName), "r"))

  local fileContent = f:read("*all")
  f:close()

  local pattertInitHMI_onReady = "function .?module%:InitHMI_onReady.-initHMI_onReady.-end"
  local pattertConnectMobileCall = "function .?module%:ConnectMobile.-connectMobile.-end"
  local patternStartSessionCall = "function .?module%:StartSession.-startSession.-end"

  local InitHMI_onReadyCall = fileContent:match(pattertInitHMI_onReady)
  local connectMobileCall = fileContent:match(pattertConnectMobileCall)
  local startSessionCall = fileContent:match(patternStartSessionCall)

  if InitHMI_onReadyCall == nil then
    print(" \27[31m initHMI_onReady functions is not found in /user_modules/" .. tostring(FileName) .. " \27[0m ")
  else
    fileContent = string.gsub(fileContent, pattertInitHMI_onReady, "")
  end

  if connectMobileCall == nil then
    print(" \27[31m ConnectMobile functions is not found in /user_modules/" .. tostring(FileName) .. " \27[0m ")
  else
    fileContent = string.gsub(fileContent, pattertConnectMobileCall, "")
  end

  if startSessionCall == nil then
    print(" \27[31m StartSession functions is not found in /user_modules/" .. tostring(FileName) .. " \27[0m ")
  else
    fileContent = string.gsub(fileContent, patternStartSessionCall, "")
  end

  local patternDisconnect = "print%(\"Disconnected%!%!%!\"%).-quit%(1%)"
  local DisconnectMessage = fileContent:match(patternDisconnect)
  if DisconnectMessage == nil then
    print(" \27[31m 'Disconnected!!!' message is not found in /user_modules/" .. tostring(FileName) .. " \27[0m ")
  else
    fileContent = string.gsub(fileContent, patternDisconnect, 'print("Disconnected!!!")')
  end

  f = assert(io.open('./user_modules/' .. tostring(FileName), "w+"))
  f:write(fileContent)
  f:close()
end

--[[@InitHMI_onReady_without_UI_GetCapabilities: replace original InitHMIOnReady from connecttest 
--! without expect UI.GetCapabilites
--! @parameters: NO
--]]
function testCasesForRAI:InitHMI_onReady_without_UI_GetCapabilities(self)

  local function ExpectRequest(name, mandatory, params)
    local event = events.Event()
    event.level = 2
    event.matches = function(_, data) return data.method == name end
    return
      EXPECT_HMIEVENT(event, name)
      :Times(mandatory and 1 or AnyNumber())
      :Do(function(_, data)
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", params)
      end)
    end

  ExpectRequest("BasicCommunication.MixingAudioSupported", true, { attenuatedSupported = true })
  ExpectRequest("BasicCommunication.GetSystemInfo", false, { ccpu_version = "ccpu_version", language = "EN-US", wersCountryCode = "wersCountryCode" })
  ExpectRequest("UI.GetLanguage", true, { language = "EN-US" })
  ExpectRequest("VR.GetLanguage", true, { language = "EN-US" })
  ExpectRequest("TTS.GetLanguage", true, { language = "EN-US" })
  ExpectRequest("UI.ChangeRegistration", false, { }):Pin()
  ExpectRequest("TTS.SetGlobalProperties", false, { }):Pin()
  ExpectRequest("BasicCommunication.UpdateDeviceList", false, { }):Pin()
  ExpectRequest("VR.ChangeRegistration", false, { }):Pin()
  ExpectRequest("TTS.ChangeRegistration", false, { }):Pin()
  ExpectRequest("VR.GetSupportedLanguages", true, {
      languages = {
        "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU",
        "TR-TR","PL-PL","FR-FR","IT-IT","SV-SE","PT-PT","NL-NL",
        "ZH-TW","JA-JP","AR-SA","KO-KR","PT-BR","CS-CZ","DA-DK",
        "NO-NO","NL-BE","EL-GR","HU-HU","FI-FI","SK-SK" }
    })
  ExpectRequest("TTS.GetSupportedLanguages", true, {
      languages = {
        "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU",
        "TR-TR","PL-PL","FR-FR","IT-IT","SV-SE","PT-PT","NL-NL",
        "ZH-TW","JA-JP","AR-SA","KO-KR","PT-BR","CS-CZ","DA-DK",
        "NO-NO","NL-BE","EL-GR","HU-HU","FI-FI","SK-SK" }
    })
  ExpectRequest("UI.GetSupportedLanguages", true, {
      languages = {
        "EN-US","ES-MX","FR-CA","DE-DE","ES-ES","EN-GB","RU-RU",
        "TR-TR","PL-PL","FR-FR","IT-IT","SV-SE","PT-PT","NL-NL",
        "ZH-TW","JA-JP","AR-SA","KO-KR","PT-BR","CS-CZ","DA-DK",
        "NO-NO","NL-BE","EL-GR","HU-HU","FI-FI","SK-SK" }
    })
  ExpectRequest("VehicleInfo.GetVehicleType", true, {
      vehicleType = {
        make = "Ford",
        model = "Fiesta",
        modelYear = "2013",
        trim = "SE"
      }
    })
  ExpectRequest("VehicleInfo.GetVehicleData", true, { vin = "52-452-52-752" })

  local function button_capability(name, shortPressAvailable, longPressAvailable, upDownAvailable)
    return
    {
      name = name,
      shortPressAvailable = shortPressAvailable == nil and true or shortPressAvailable,
      longPressAvailable = longPressAvailable == nil and true or longPressAvailable,
      upDownAvailable = upDownAvailable == nil and true or upDownAvailable
    }
  end

  local buttons_capabilities =
  {
    capabilities =
    {
      button_capability("PRESET_0"),
      button_capability("PRESET_1"),
      button_capability("PRESET_2"),
      button_capability("PRESET_3"),
      button_capability("PRESET_4"),
      button_capability("PRESET_5"),
      button_capability("PRESET_6"),
      button_capability("PRESET_7"),
      button_capability("PRESET_8"),
      button_capability("PRESET_9"),
      button_capability("OK", true, false, true),
      button_capability("SEEKLEFT"),
      button_capability("SEEKRIGHT"),
      button_capability("TUNEUP"),
      button_capability("TUNEDOWN")
    },
    presetBankCapabilities = { onScreenPresetsAvailable = true }
  }
  ExpectRequest("Buttons.GetCapabilities", true, buttons_capabilities)
  ExpectRequest("VR.GetCapabilities", true, { vrCapabilities = { "TEXT" } })
  ExpectRequest("TTS.GetCapabilities", true, {
      speechCapabilities = { "TEXT", "PRE_RECORDED" },
      prerecordedSpeechCapabilities =
      {
        "HELP_JINGLE",
        "INITIAL_JINGLE",
        "LISTEN_JINGLE",
        "POSITIVE_JINGLE",
        "NEGATIVE_JINGLE"
      }
    })

  ExpectRequest("VR.IsReady", true, { available = true })
  ExpectRequest("TTS.IsReady", true, { available = true })
  ExpectRequest("UI.IsReady", true, { available = true })
  ExpectRequest("Navigation.IsReady", true, { available = true })
  ExpectRequest("VehicleInfo.IsReady", true, { available = true })

  self.applications = { }
  ExpectRequest("BasicCommunication.UpdateAppList", false, { })
  :Pin()
  :Do(function(_, data)
      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { })
      self.applications = { }
      for _, app in pairs(data.params.applications) do
        self.applications[app.appName] = app.appID
      end
    end)

  self.hmiConnection:SendNotification("BasicCommunication.OnReady")
end

--[[@get_data_steeringWheelLocation: read steeringWheelLocation from hmi_capabilities
--! @parameters: NO
--]]
function testCasesForRAI.get_data_steeringWheelLocation()
  local value = nil
  local path_to_file = config.pathToSDL .. 'hmi_capabilities.json'
  local file  = io.open(path_to_file, "r")
  local json_data = file:read("*all") -- may be abbreviated to "*a";
  
  file:close()

  local json = require("modules/json")
         
  local data = json.decode(json_data)

  if( data.UI.hmiCapabilities.steeringWheelLocation ~= nil ) then
    value = data.UI.hmiCapabilities.steeringWheelLocation
  end

  return value
end

--[[@write_data_steeringWheelLocation: write value to steeringWheelLocation
--! in hmi_capabilities.json
--! @parameters: value
--! @value - new value for steeringWheelLocation
--]]
function testCasesForRAI.write_data_steeringWheelLocation(value)
  local path_to_file = config.pathToSDL .. 'hmi_capabilities.json'
  local file  = io.open(path_to_file, "r")
  local json_data = file:read("*all") -- may be abbreviated to "*a";
  
  file:close()

  local json = require("modules/json")
         
  local data = json.decode(json_data)

  if( data.UI.hmiCapabilities.steeringWheelLocation ~= nil ) then
    data.UI.hmiCapabilities.steeringWheelLocation = value
  end

  data = json.encode(data)
  
  file = io.open(path_to_file, "w")
  file:write(data)
  file:close()
end

return testCasesForRAI
