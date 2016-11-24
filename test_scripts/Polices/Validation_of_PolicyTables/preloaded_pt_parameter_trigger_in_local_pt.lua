---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies]: New trigger for changing the value of "preloaded_pt" field to 'false'
-- --
-- Description:
-- Behavior of SDL with "preloaded_pt" field (Boolean) is "true" in LocalPT when was performed UpdatedPolicyTable procedure
-- 1. Used preconditions
-- Delete files and policy table from previous ignition cycle if any
-- Start SDL with PreloadedPT json file (the value of "preloaded_pt" field to "true")
-- 2. Performed steps
-- SDL sends the first Snapshot to mobile app
-- SDL receives UpdatedPolicyTable via SystemRequest from mobile app
--
-- Expected result:
-- SDL must change the value of "preloaded_pt" field to "false"
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
Test = require('connecttest')
local config = require('config')
require('user_modules/AppTypes')
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')

--[[ Local Variables ]]
local PATH_TO_POLICY_FILE = "files/jsons/Policies/validationPT/ptu_012.json"
local DB_FALSE_VALUE = "0"

--[[ Local Functions ]]
local function constructPathToDatabase()
  if commonSteps:file_exists(config.pathToSDL .. "storage/policy.sqlite") then
    return config.pathToSDL .. "storage/policy.sqlite"
  elseif commonSteps:file_exists(config.pathToSDL .. "policy.sqlite") then
    return config.pathToSDL .. "policy.sqlite"
  else
    commonFunctions:userPrint(31, "policy.sqlite is not found" )
    return nil
  end
end

local function executeSqliteQuery(raw_query_string, db_file_path)
  if not db_file_path then
    return nil
  end
  local query_execution_result = {}
  local query_string = table.concat({"sqlite3 ", db_file_path, " '", raw_query_string, "'"})
  local file = io.popen(query_string, 'r')
  if file then
    local index = 1
    for line in file:lines() do
      query_execution_result[index] = line
      index = index + 1
    end
    file:close()
    return query_execution_result
  else
    return nil
  end
end

local function isValuesCorrect(actual_values, expected_values)
  if #actual_values ~= #expected_values then
    return false
  end

  local tmp_expected_values = {}
  for i = 1, #expected_values do
    tmp_expected_values[i] = expected_values[i]
  end

  local is_found
  for j = 1, #actual_values do
    is_found = false
    for key, value in pairs(tmp_expected_values) do
      if value == actual_values[j] then
        is_found = true
        tmp_expected_values[key] = nil
        break
      end
    end
    if not is_found then
      return false
    end
  end
  if next(tmp_expected_values) then
    return false
  end
  return true
end

function Test.checkLocalPT()
  local expected_local_pt_request_type_values = {DB_FALSE_VALUE}
  local query_string = 'SELECT preloaded_pt FROM module_config'
  local actual_local_pt_request_type_values = executeSqliteQuery(query_string, constructPathToDatabase())
  if actual_local_pt_request_type_values then
    local result = isValuesCorrect(actual_local_pt_request_type_values, expected_local_pt_request_type_values)
    if not result then
      commonFunctions:userPrint(31, "Test failed: SDL don't change the value of preloaded_pt field to false after PTU")
    end
    return result
  else
    commonFunctions:userPrint(31, "Test failed: Can't get data from LocalPT")
    return false
  end
end

function Test:updatePolicyTable(pathToPolicyFile)
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
  :ValidIf(function(exp, data)
      if (exp.occurences == 1 and data.params.status == "UPDATING") or
      (data.params.status == "UP_TO_DATE") then
        return true
      else
        local reason = "SDL.OnStatusUpdate came with wrong values. "
        if exp.occurences == 1 then
          reason = reason .. "Expected in first occurrences status 'UP_TO_DATE' or 'UPDATING', got '" .. tostring(data.params.status) .. "'"
        elseif exp.occurences == 2 then
          reason = reason .. "Expected in second occurrences status 'UP_TO_DATE', got '" .. tostring(data.params.status) .. "'"
        end
        return false, reason
      end
    end)
  :Times(Between(1,2))

  local requestId = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })

  EXPECT_HMIRESPONSE(requestId, {result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
  :Do(function(_, _)
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
        {
          requestType = "PROPRIETARY",
          fileName = "PolicyTableUpdate"
        }
      )
    end)

  EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
  :Do(function(_, _)
      local corIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          requestType = "PROPRIETARY",
          fileName = "PolicyTableUpdate"
        },
        pathToPolicyFile)

      EXPECT_HMICALL("BasicCommunication.SystemRequest")
      :Do(function(_, data)
          self.hmiConnection:SendResponse(data.id, "BasicCommunication.SystemRequest", "SUCCESS", {})
          self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
            {
              policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
            }
          )
        end)

      EXPECT_RESPONSE(corIdSystemRequest, { success = true, resultCode = "SUCCESS"})
      :Do(function(_, _)
          requestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"StatusUpToDate"}})
          EXPECT_HMIRESPONSE(requestId)
        end)
    end)
end

--[[ General Precondition before ATF start ]]
commonFunctions:SDLForceStop()

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:Precondition()
  self:updatePolicyTable(PATH_TO_POLICY_FILE)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Test()
  os.execute("sleep 3")
  self.checkLocalPT()
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

function Test:Postcondition()
  commonSteps:DeletePolicyTable(self)
end

commonFunctions:SDLForceStop()
return Test
