require('atf.util')
local module = require('testbase')
local mobile = require("mobile_connection")
local tcp = require("tcp_connection")
local file_connection = require("file_connection")
local websocket = require('websocket_connection')
local hmi_connection = require('hmi_connection')
local events = require("events")
local expectations = require('expectations')
local SDL = require('SDL')
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local load_schema = require('load_schema')

local hmi_schema = load_schema.hmi_schema

local Event = events.Event
local Expectation = expectations.Expectation
local SUCCESS = expectations.SUCCESS
local FAILED = expectations.FAILED

module.hmiConnection = hmi_connection.Connection(websocket.WebSocketConnection(config.hmiUrl, config.hmiPort))
local tcpConnection = tcp.Connection(config.mobileHost, config.mobilePort)
local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
module.mobileConnection = mobile.MobileConnection(fileConnection)
event_dispatcher:AddConnection(module.hmiConnection)
event_dispatcher:AddConnection(module.mobileConnection)
module.notification_counter=1

function module.hmiConnection:EXPECT_HMIRESPONSE(id, args)
  local event = events.Event()
  event.matches = function(self, data) return data.id == id end
  local ret = Expectation("HMI response " .. id, self)
  ret:ValidIf(function(self, data)
  local arguments
  if self.occurences > #args then
    arguments = args[#args]
  else
    arguments = args[self.occurences]
  end
  xmlReporter.AddMessage("EXPECT_HMIRESPONSE", {["Id"] = tostring(id),["Type"] = "EXPECTED_RESULT"},arguments)
  xmlReporter.AddMessage("EXPECT_HMIRESPONSE", {["Id"] = tostring(id),["Type"] = "AVALIABLE_RESULT"},data)
  local func_name = data.method
  local results_args = arguments
  local results_args2 = arguments
  if(table2str(arguments):match('result')) then
    results_args = arguments.result
    results_args2 = arguments.result
  end
  if results_args2 and results_args2.code then
    results_args2 = table.removeKey(results_args2, 'code')
  end
  if results_args2 and results_args2.method then
    results_args2 = table.removeKey(results_args2, 'method')
  end
  if func_name == nil and type(data.result) == 'table' then
    func_name = data.result.method
  end
  local _res, _err
  _res = true
  if not (table2str(arguments):match('error')) then
    _res, _err = hmi_schema:Validate(func_name, load_schema.response, data.params)
  end
  if (not _res) then
    return _res,_err
  end
  if func_name and results_args and data.result then
    return compareValues(results_args, data.result, "result")
  else
    return compareValues(results_args, data.params, "params")
  end
  end)
  ret.event = event
  event_dispatcher:AddEvent(module.hmiConnection, event, ret)
  module:AddExpectation(ret)
  return ret
end

function EXPECT_HMIRESPONSE(id,...)
  local args = table.pack(...)
  return module.hmiConnection:EXPECT_HMIRESPONSE(id, args)
end

function EXPECT_HMIEVENT(event, name)
  xmlReporter.AddMessage(debug.getinfo(1, "n").name, name)
  local ret = Expectation(name, module.hmiConnection)
  ret.event = event
  event_dispatcher:AddEvent(module.hmiConnection, event, ret)
  module:AddExpectation(ret)
  return ret
end

function StartSDL(SDLPathName, ExitOnCrash)
  return SDL:StartSDL(SDLPathName, config.SDL, ExitOnCrash)
end

function StopSDL()
  event_dispatcher:ClearEvents()
  module.expectations_list:Clear()
  return SDL:StopSDL()
end

function module:RunSDL()
  self:runSDL()
end

function module:InitHMI()
  critical(true)
  self:initHMI()
end

function module:InitHMI_onReady()
  critical(true)
  self:initHMI_onReady()
end

function module:runSDL()
  if config.autorunSDL ~= true then
    SDL.autoStarted = false
    return
  end
  local result, errmsg = SDL:StartSDL(config.pathToSDL, config.SDL, config.ExitOnCrash)
  if not result then
    SDL:DeleteFile()
    quit(1)
  end
  SDL.autoStarted = true
end

function module:initHMI()
  local function registerComponent(name, subscriptions)
    local rid = module.hmiConnection:SendRequest("MB.registerComponent", { componentName = name })
    local exp = EXPECT_HMIRESPONSE(rid)
    if subscriptions then
      for _, s in ipairs(subscriptions) do
        exp:Do(function()
        local rid = module.hmiConnection:SendRequest("MB.subscribeTo", { propertyName = s })
        EXPECT_HMIRESPONSE(rid)
        end)
      end
    end
  end

  EXPECT_HMIEVENT(events.connectedEvent, "Connected websocket")
  :Do(function()
  registerComponent("Buttons", {"Buttons.OnButtonSubscription"})
  registerComponent("TTS")
  registerComponent("VR")
  registerComponent("BasicCommunication",
  {
    "BasicCommunication.OnPutFile",
    "SDL.OnStatusUpdate",
    "SDL.OnAppPermissionChanged",
    "BasicCommunication.OnSDLPersistenceComplete",
    "BasicCommunication.OnFileRemoved",
    "BasicCommunication.OnAppRegistered",
    "BasicCommunication.OnAppUnregistered",
    "BasicCommunication.PlayTone",
    "BasicCommunication.OnSDLClose",
    "SDL.OnSDLConsentNeeded",
    "BasicCommunication.OnResumeAudioSource"
  })
  registerComponent("UI",
  {
    "UI.OnRecordStart"
  })
  registerComponent("VehicleInfo")
  registerComponent("Navigation",
  {
    "Navigation.OnAudioDataStreaming",
    "Navigation.OnVideoDataStreaming"
  })
  end)
  self.hmiConnection:Connect()
end

function module:initHMI_onReady()
  local function ExpectRequest(name, mandatory, params)
    local event = events.Event()
    event.level = 2
    event.matches = function(self, data) return data.method == name end
    return
    EXPECT_HMIEVENT(event, name)
    :Times(mandatory and 1 or AnyNumber())
    :Do(function(_, data)
    xmlReporter.AddMessage("hmi_connection","SendResponse",
    {
      ["methodName"] = tostring(name),
      ["mandatory"] = mandatory ,
      ["params"]= params
    })
    self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", params)
    end)
  end

  local function ExpectNotification(name, mandatory)
    xmlReporter.AddMessage(debug.getinfo(1, "n").name, tostring(name))
    local event = events.Event()
    event.level = 2
    event.matches = function(self, data) return data.method == name end
    return
    EXPECT_HMIEVENT(event, name)
    :Times(mandatory and 1 or AnyNumber())
  end

  ExpectRequest("VehicleInfo.GetVehicleType", true, {
    vehicleType =
    {
      make = "Ford",
      model = "Fiesta",
      modelYear = "2013",
      trim = "SE"
    }
  })
  
  ExpectRequest("VehicleInfo.GetVehicleData", true, { vin = "55-555-66-777" })
  :Do(function()
  commonFunctions:userPrint(33, "HMI sends vin=55-555-66-777" )
  end)

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

return module
