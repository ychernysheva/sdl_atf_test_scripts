local actions = require("user_modules/sequences/actions")
local json = require("modules/json")
local test = require("user_modules/dummy_connecttest")

local commonCloudAppRPCs = actions

local function jsonFileToTable(file_name)
  local f = io.open(file_name, "r")
  local content = f:read("*all")
  f:close()
  return json.decode(content)
end

function commonCloudAppRPCs.getCloudAppConfig()
  return {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE",
    groups = { "Base-4" , "CloudApp" }
  }
end

function commonCloudAppRPCs.getCloudAppStoreConfig()
  return {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE",
    groups = { "Base-4" , "CloudAppStore" }
  }
end

function commonCloudAppRPCs:Request_PTU()
  local is_test_fail = false
  local hmi_app1_id = config.application1.registerAppInterfaceParams.appName
  commonCloudAppRPCs.getHMIConnection():SendNotification("SDL.OnPolicyUpdate", {} )
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})

  EXPECT_HMICALL("BasicCommunication.PolicyUpdate",{ file = "/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json" })
  :Do(function(_,data)
    commonCloudAppRPCs.getHMIConnection():SendResponse(data.id, data.method, "SUCCESS", {})
    end)
end

function commonCloudAppRPCs.test_assert(condition, msg)
  if not condition then
    test:FailTestCase(msg)
  end
end

function commonCloudAppRPCs.GetPolicySnapshot()
  return jsonFileToTable("/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json")
end

return commonCloudAppRPCs
