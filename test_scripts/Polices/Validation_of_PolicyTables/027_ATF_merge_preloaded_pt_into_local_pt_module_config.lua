---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] Merging rules for "module_config" section
--
-- Description:
-- Check of merging rules for "app_policies" section
-- 1. Used preconditions
-- Delete files and policy table from previous ignition cycle if any
-- Start SDL with PreloadedPT json file with "preloaded_date" parameter and one <appid> subsection and "default", "device", "pre_DataConsent" subsections
-- 2. Performed steps
-- Stop SDL
-- Start SDL with corrected PreloadedPT json file with "preloaded_date" parameter with bigger value
-- and one <appid> subsection and "default", "device", "pre_DataConsent" subsections with other data
--
-- Expected result:
-- SDL must add new fields (known to PM) & sub-sections if such are present in the updated PreloadedPT to database
-- leave fields and values of "vehicle_make", “model”, “year” params as they were in the database without changes
-- overwrite the values with the new ones from PreloadedPT for all other fields
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
Test = require('connecttest')
local config = require('config')
require('user_modules/AppTypes')
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require ('user_modules/shared_testcases/commonSteps')
local json = require("modules/json")

--[[ Local Variables ]]
local TESTED_DATA = {
  {
    module_config =
    {
      preloaded_pt = true,
      preloaded_date = "2016-02-02",
      exchange_after_x_ignition_cycles = 100,
      exchange_after_x_kilometers = 1800,
      exchange_after_x_days = 30,
      timeout_after_x_seconds = 60,
      seconds_between_retries = {1, 5, 25, 125, 625},
      endpoints =
      {
        ["0x07"] = {
          default = {"http://policies.telematics.ford.com/api/policies"}
        },
        ["0x04"] = {
          default = {"http://ivsu.software.ford.com/api/getsoftwareupdates"}
        },
        queryAppsUrl = {
          default = {"http://sdl.shaid.server"}
        },
        lock_screen_icon_url = {
          default = {"http://i.imgur.com/QwZ9uKG.png"}
        }
      },
      notifications_per_minute_by_priority =
      {
        EMERGENCY = 60,
        NAVIGATION = 15,
        VOICECOM = 20,
        COMMUNICATION = 6,
        NORMAL = 4,
        NONE = 0
      }
    }
  },
  {
    module_config =
    {
      preloaded_pt = true,
      preloaded_date = "2016-04-05",
      exchange_after_x_ignition_cycles = 150,
      exchange_after_x_kilometers = 2000,
      exchange_after_x_days = 60,
      timeout_after_x_seconds = 20,
      seconds_between_retries = {2, 10, 25, 125, 625},
      certificate = "MIIEpTCCA42gAwIBAgIKYSlrdAAAAAAAAjANBgkqhk",
      endpoints =
      {
        ["0x07"] = {
          default = {"http://policies.telematics.ford.com/api/policies"},
          new = {"http://policies.telematics.ford.com/api/policies2"}
        },
        ["0x04"] = {
          default = {"http://ivsu.software.ford.com/api/getSoftwareUpdates"}
        },
        queryAppsUrl = {
          default = {"http://sdl.shaid.server"}
        },
        lock_screen_icon_url = {
          default = {"http://i.imgur.com/QwZ9uKG.png"}
        }
      },
      notifications_per_minute_by_priority =
      {
        EMERGENCY = 90,
        NAVIGATION = 18,
        VOICECOM = 30,
        COMMUNICATION = 8,
        NORMAL = 5,
        NONE = 0
      }
    }
  },
  expected =
  {
    module_config =
    {
      preloaded_pt = true,
      exchange_after_x_ignition_cycles = 150,
      exchange_after_x_kilometers = 2000,
      exchange_after_x_days = 60,
      timeout_after_x_seconds = 20,
      vehicle_make = "Ford",
      vehicle_model = "Fiesta",
      vehicle_year = "2016",
      preloaded_date = "2016-04-05",
      certificate = "MIIEpTCCA42gAwIBAgIKYSlrdAAAAAAAAjANBgkqhk"
    },
    seconds_between_retries = {2, 10, 25, 125, 625},
    notifications_per_minute_by_priority =
    {
      EMERGENCY = 90,
      NAVIGATION = 18,
      VOICECOM = 30,
      COMMUNICATION = 8,
      NORMAL = 5,
      NONE = 0
    },
    endpoints =
    {
      ["0x07"] = {
        default = {"http://policies.telematics.ford.com/api/policies"},
        new = {"http://policies.telematics.ford.com/api/policies2"}
      },
      ["0x04"] = {
        default = {"http://ivsu.software.ford.com/api/getSoftwareUpdates"}
      },
      queryAppsUrl = {
        default = {"http://sdl.shaid.server"}
      },
      lock_screen_icon_url = {
        default = {"http://i.imgur.com/QwZ9uKG.png"}
      }
    }
  }
}
local PRELOADED_PT_FILE_NAME = "sdl_preloaded_pt.json"

local TestData = {
  path = config.pathToSDL .. "TestData",
  isExist = false,
  init = function(self)
    if not self.isExist then
      os.execute("mkdir ".. self.path)
      os.execute("echo 'List test data files files:' > " .. self.path .. "/index.txt")
      self.isExist = true
    end
  end,
  store = function(self, message, pathToFile, fileName)
    if self.isExist then
      local dataToWrite = message

      if pathToFile and fileName then
        os.execute(table.concat({"cp ", pathToFile, " ", self.path, "/", fileName}))
        dataToWrite = table.concat({dataToWrite, " File: ", fileName})
      end

      dataToWrite = dataToWrite .. "\n"
      local file = io.open(self.path .. "/index.txt", "a+")
      file:write(dataToWrite)
      file:close()
    end
  end,
  delete = function(self)
    if self.isExist then
      os.execute("rm -r -f " .. self.path)
      self.isExist = false
    end
  end,
  info = function(self)
    if self.isExist then
      commonFunctions:userPrint(35, "All test data generated by this test were stored to folder: " .. self.path)
    else
      commonFunctions:userPrint(35, "No test data were stored" )
    end
  end
}

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

local function executeSqliteQuery(rawQueryString, dbFilePath)
  if not dbFilePath then
    return nil
  end
  local queryExecutionResult = {}
  local queryString = table.concat({"sqlite3 ", dbFilePath, " '", rawQueryString, "'"})
  local file = io.popen(queryString, 'r')
  if file then
    local index = 1
    for line in file:lines() do
      queryExecutionResult[index] = line
      index = index + 1
    end
    file:close()
    return queryExecutionResult
  else
    return nil
  end
end

local function isValuesCorrect(actualValues, expectedValues)
  if #actualValues ~= #expectedValues then
    return false
  end

  local tmpExpectedValues = {}
  for i = 1, #expectedValues do
    tmpExpectedValues[i] = expectedValues[i]
  end

  local isFound
  for j = 1, #actualValues do
    isFound = false
    for key, value in pairs(tmpExpectedValues) do
      if value == actualValues[j] then
        isFound = true
        tmpExpectedValues[key] = nil
        break
      end
    end
    if not isFound then
      return false
    end
  end
  if next(tmpExpectedValues) then
    return false
  end
  return true
end

function Test.checkLocalPT(checkTable)
  local expectedLocalPtValues
  local queryString
  local actualLocalPtValues
  local comparationResult
  local isTestPass = true
  for _, check in pairs(checkTable) do
    expectedLocalPtValues = check.expectedValues
    queryString = check.query
    actualLocalPtValues = executeSqliteQuery(queryString, constructPathToDatabase())
    if actualLocalPtValues then
      comparationResult = isValuesCorrect(actualLocalPtValues, expectedLocalPtValues)
      if not comparationResult then
        TestData:store(table.concat({"Test ", queryString, " failed: SDL has wrong values in LocalPT"}))
        TestData:store("ExpectedLocalPtValues")
        commonFunctions:userPrint(31, table.concat({"Test ", queryString, " failed: SDL has wrong values in LocalPT"}))
        commonFunctions:userPrint(35, "ExpectedLocalPtValues")
        for _, values in pairs(expectedLocalPtValues) do
          TestData:store(values)
          print(values)
        end
        TestData:store("ActualLocalPtValues")
        commonFunctions:userPrint(35, "ActualLocalPtValues")
        for _, values in pairs(actualLocalPtValues) do
          TestData:store(values)
          print(values)
        end
        isTestPass = false
      end
    else
      TestData:store("Test failed: Can't get data from LocalPT")
      commonFunctions:userPrint(31, "Test failed: Can't get data from LocalPT")
      isTestPass = false
    end
  end
  return isTestPass
end

function Test.backupPreloadedPT(backupPrefix)
  os.execute(table.concat({"cp ", config.pathToSDL, PRELOADED_PT_FILE_NAME, " ", config.pathToSDL, backupPrefix, PRELOADED_PT_FILE_NAME}))
end

function Test.restorePreloadedPT(backupPrefix)
  os.execute(table.concat({"mv ", config.pathToSDL, backupPrefix, PRELOADED_PT_FILE_NAME, " ", config.pathToSDL, PRELOADED_PT_FILE_NAME}))
end

function Test.updatePreloadedPt(updaters)
  local pathToFile = config.pathToSDL .. PRELOADED_PT_FILE_NAME
  local file = io.open(pathToFile, "r")
  local json_data = file:read("*a")
  file:close()

  local data = json.decode(json_data)
  if data then
    for _, updateFunc in pairs(updaters) do
      updateFunc(data)
    end
  end

  local dataToWrite = json.encode(data)
  file = io.open(pathToFile, "w")
  file:write(dataToWrite)
  file:close()
end

function Test:prepareInitialPreloadedPT()
  local initialUpdaters = {
    function(data)
      for key, value in pairs(data.policy_table.functional_groupings) do
        if not value.rpcs then
          data.policy_table.functional_groupings[key] = nil
        end
      end
    end,
    function(data)
      data.policy_table.module_config = TESTED_DATA[1].module_config
    end,
  }
  self.updatePreloadedPt(initialUpdaters)
end

function Test:prepareNewPreloadedPT()
  local newUpdaters = {
    function(data)
      data.policy_table.module_config = TESTED_DATA[2].module_config
    end
  }
  self.updatePreloadedPt(newUpdaters)
end

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:Precondition_StopSDL()
  TestData:init()
  StopSDL(self)
end

function Test:Precondition()
  commonSteps:DeletePolicyTable()
  self.backupPreloadedPT("backup_")

  self:prepareInitialPreloadedPT()
  TestData:store("Initial Preloaded PT is stored", config.pathToSDL .. PRELOADED_PT_FILE_NAME, "initial_" .. PRELOADED_PT_FILE_NAME)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:Test_FirstStartSDL()
  StartSDL(config.pathToSDL, true, self)
end

function Test:Test_InitialLocalPT()
  os.execute("sleep 3")
  TestData:store("Initial Local PT is stored", constructPathToDatabase(), "initial_policy.sqlite")

  local function evalBoolean(val)
    if not val then
      return 0
    else
      return 1
    end
  end

  local checks = {
    {
      query = table.concat({
          'update module_config set vehicle_make = "', TESTED_DATA.expected.module_config.vehicle_make,
          '", vehicle_model = "', TESTED_DATA.expected.module_config.vehicle_model,
          '", vehicle_year = "', TESTED_DATA.expected.module_config.vehicle_year, '"',
          'where preloaded_pt = 1'
        }),
      expectedValues = {}
    },
    {
      query = 'select preloaded_pt,exchange_after_x_ignition_cycles,exchange_after_x_kilometers,exchange_after_x_days,timeout_after_x_seconds,vehicle_make,vehicle_model,vehicle_year,preloaded_date,certificate from module_config',
      expectedValues = (function(structure)
          return {table.concat({
                evalBoolean(structure[1].module_config.preloaded_pt), "|",
                structure[1].module_config.exchange_after_x_ignition_cycles, "|",
                structure[1].module_config.exchange_after_x_kilometers, "|",
                structure[1].module_config.exchange_after_x_days, "|",
                structure[1].module_config.timeout_after_x_seconds, "|",
                structure.expected.module_config.vehicle_make, "|",
                structure.expected.module_config.vehicle_model, "|",
                structure.expected.module_config.vehicle_year, "|",
                structure[1].module_config.preloaded_date, "|"
            })}
          end)(TESTED_DATA)
      },
      {
        query = 'select value from seconds_between_retry',
        expectedValues = (function(structure)
            local result = {}
            for i = 1, #structure do
              table.insert(result, tostring(structure[i]))
            end
            return result
            end)(TESTED_DATA[1].module_config.seconds_between_retries)
        },
        {
          query = 'select priority_value, value from notifications_by_priority',
          expectedValues = (function(structure)
              local result = {}
              for key, value in pairs(structure) do
                table.insert(result, table.concat({tostring(key), "|", value}))
              end
              return result
              end)(TESTED_DATA[1].module_config.notifications_per_minute_by_priority)
          },
          {
            query = 'select service, url, application_id from endpoint',
            expectedValues = (function(structure)
                local function toInt(string)
                  local num = tonumber(string)
                  if num then
                    return num
                  else
                    return 0
                  end
                end

                local result = {}
                for service, value in pairs(structure) do
                  for appId, url in pairs(value) do
                    table.insert(result, table.concat({toInt(tostring(service)), "|", url[1], "|", tostring(appId)}))
                  end
                end
                return result
                end)(TESTED_DATA[1].module_config.endpoints)
            }
          }
          if not self.checkLocalPT(checks) then
            self:FailTestCase("SDL has wrong values in LocalPT")
          end
        end

        function Test:Test_FirstStopSDL()
          StopSDL(self)
        end

        function Test:Test_NewPreloadedPT()
          self:prepareNewPreloadedPT()
          TestData:store("New Preloaded PT is stored", config.pathToSDL .. PRELOADED_PT_FILE_NAME, "new_" .. PRELOADED_PT_FILE_NAME)
        end

        function Test:Test_SecondStartSDL()
          StartSDL(config.pathToSDL, true, self)
        end

        function Test:Test_NewLocalPT()
          os.execute("sleep 3")
          TestData:store("New Local PT is stored", constructPathToDatabase(), "new_policy.sqlite")

          local function evalBoolean(val)
            if not val then
              return 0
            else
              return 1
            end
          end

          local checks = {
            {
              query = 'select preloaded_pt,exchange_after_x_ignition_cycles,exchange_after_x_kilometers,exchange_after_x_days,timeout_after_x_seconds,vehicle_make,vehicle_model,vehicle_year,preloaded_date,certificate from module_config',
              expectedValues = (function(structure)
                  return {table.concat({
                        evalBoolean(structure.preloaded_pt), "|",
                        structure.exchange_after_x_ignition_cycles, "|",
                        structure.exchange_after_x_kilometers, "|",
                        structure.exchange_after_x_days, "|",
                        structure.timeout_after_x_seconds, "|",
                        structure.vehicle_make, "|",
                        structure.vehicle_model, "|",
                        structure.vehicle_year, "|",
                        structure.preloaded_date, "|",
                        structure.certificate
                    })}
                  end)(TESTED_DATA.expected.module_config)
              },
              {
                query = 'select value from seconds_between_retry',
                expectedValues = (function(structure)
                    local result = {}
                    for i = 1, #structure do
                      table.insert(result, tostring(structure[i]))
                    end
                    return result
                    end)(TESTED_DATA.expected.seconds_between_retries)
                },
                {
                  query = 'select priority_value, value from notifications_by_priority',
                  expectedValues = (function(structure)
                      local result = {}
                      for key, value in pairs(structure) do
                        table.insert(result, table.concat({tostring(key), "|", value}))
                      end
                      return result
                      end)(TESTED_DATA.expected.notifications_per_minute_by_priority)
                  },
                  {
                    query = 'select service, url, application_id from endpoint',
                    expectedValues = (function(structure)
                        local function toInt(string)
                          local num = tonumber(string)
                          if num then
                            return num
                          else
                            return 0
                          end
                        end
                        local result = {}
                        for service, value in pairs(structure) do
                          for appId, url in pairs(value) do
                            table.insert(result, table.concat({toInt(tostring(service)), "|", url[1], "|", tostring(appId)}))
                          end
                        end
                        return result
                        end)(TESTED_DATA.expected.endpoints)
                    }
                  }
                  if not self.checkLocalPT(checks) then
                    self:FailTestCase("SDL has wrong values in LocalPT")
                  end
                end

                --[[ Postconditions ]]
                commonFunctions:newTestCasesGroup("Postconditions")

                function Test:Postcondition()
                  commonSteps:DeletePolicyTable()
                  self.restorePreloadedPT("backup_")
                  StopSDL()
                  TestData:info()
                end

                commonFunctions:SDLForceStop()
                return Test
