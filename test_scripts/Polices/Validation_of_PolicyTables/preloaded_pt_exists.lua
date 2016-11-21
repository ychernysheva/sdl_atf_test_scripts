---------------------------------------------------------------------------------------------
-- Description:
-- Behavior of SDL during start SDL in case when PreloadedPT exist at the path defined in .ini file
-- 1. Used preconditions:
-- Delete files and policy table from previous ignition cycle if any
-- Do not start default SDL
-- 2. Performed steps:
-- Change path to PreloadedPolicyTable file defined in .ini file
-- Create correct PreloadedPolicyTable file at the path defined in .ini file
-- Start SDL

-- Requirement summary:
-- [Policy] Upon startup SDL must check PreloadPT existance
--
-- Expected result:
-- SDL started successfully
---------------------------------------------------------------------------------------------
--[[ General Settings for configuration ]]
Test = require('connecttest')
local config = require('config')

--[[ General configuration parameters ]]
config.defaultProtocolVersion = 2
local PPT_NEW_FOLDER = "newppt"
local PPT_FILE_NAME = "sdl_preloaded_pt.json"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local SDL = require('modules/SDL')

--[[ Preconditions ]]
local function set_value_in_sdl_ini(parameter_name, parameter_value)
  local sdl_ini_file_name = config.pathToSDL .. "smartDeviceLink.ini"
  local old_parameter_value
  local file = assert(io.open(sdl_ini_file_name, "r"))
  if file then
    local file_content = file:read("*a")
    file:close()
    old_parameter_value = string.match(file_content, parameter_name .. "%s*=%s*(%S+)")
    if old_parameter_value then
      file_content = string.gsub(file_content, parameter_name .. "%s*=%s*%S+", parameter_name .. " = " .. parameter_value)
    else
      local last_char_of_file = string.sub(file_content, string.len(file_content))
      if last_char_of_file == "\n" then
        last_char_of_file = ""
      else
        last_char_of_file = "\n"
      end
      file_content = table.concat({file_content, last_char_of_file, parameter_name, " = ", parameter_value, "\n"})
      old_parameter_value = nil
    end
    file = assert(io.open(sdl_ini_file_name, "w"))
    if file then
      file:write(file_content)
      file:close()
      return true, old_parameter_value
    else
      return false
    end
  else
    return false
  end
end

function Test.create_path_to_preloaded_pt(path)
  local full_path = config.pathToSDL .. path
  os.execute("mkdir " .. full_path)
  return table.concat({full_path, "/", PPT_FILE_NAME})
end

local function get_absolute_path(path)
  if path:match("^%./") then
    return config.pathToSDL .. path:match("^%./(.+)")
  end
  if path:match("^/") then
    return path
  end
  return config.pathToSDL .. path
end

function Test.move_preloaded_pt_file(source_path, destination_path)
  local absolute_source_path = get_absolute_path(source_path)
  local absolute_destination_path = get_absolute_path(destination_path)
  os.execute(table.concat({"mv -f ", absolute_source_path, " ", absolute_destination_path}))
end

function Test.change_ppt_path_in_sdl_ini(new_path)
  local result, old_path = set_value_in_sdl_ini("PreloadedPT", new_path)
  if not result then
    commonFunctions:userPrint(31, "Test can't change SDL .ini file")
  end
  return old_path
end

function Test:StopSDL_precondition()
  StopSDL(self)
end

function Test:Precondition()
  commonSteps:DeletePolicyTable()

  self.new_path_to_preloaded_pt = self.create_path_to_preloaded_pt(PPT_NEW_FOLDER)
  self.old_path_to_preloaded_pt = self.change_ppt_path_in_sdl_ini(self.new_path_to_preloaded_pt)
  self.move_preloaded_pt_file(self.old_path_to_preloaded_pt, self.new_path_to_preloaded_pt)

end

--[[ Test ]]
function Test.checkSdl()
  local status = SDL:CheckStatusSDL()
  if status ~= SDL.RUNNING then
    commonFunctions:userPrint(31, "Test failed: SDL aren't starting with Preloaded PT described in .ini file")
    return false
  end
  return true
end

function Test:StartSDL_test_step()
  StartSDL(config.pathToSDL, true, self)
end

function Test:Test()
  self.checkSdl()
end

--[[ Postconditions ]]
function Test.remove_path_to_preloaded_pt(path)
  local full_path = config.pathToSDL .. path
  os.execute("rm -r -f " .. full_path)
end

function Test:Postconditions()
  self.move_preloaded_pt_file(self.new_path_to_preloaded_pt, self.old_path_to_preloaded_pt)
  self.remove_path_to_preloaded_pt(PPT_NEW_FOLDER)
  self.change_ppt_path_in_sdl_ini(self.old_path_to_preloaded_pt)
end

commonFunctions:SDLForceStop()
