---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] External UCS: PreloadedPT without "disallowed_by_external_consent_entities_on" struct
--
-- Description:
-- In case:
-- SDL uploads PreloadedPolicyTable with "disallowed_by_external_consent_entities_on:
-- [entityType: <any_type_except_Integer>, entityId: <any_type_except_Integer>]"
-- -> of "<functional grouping>" -> from "functional_groupings" section
-- SDL must:
-- a. consider this PreloadedPT as invalid
-- b. log corresponding error internally
-- c. shut SDL down
--
-- Preconditions:
-- 1. Stop SDL
-- 2. Modify PreloadedPolicyTable (add 'disallowed_by_external_consent_entities_on' section)
-- Define not valid data type for entityType and entityId parameters
--
-- Steps:
-- 1. Start SDL
-- 2. Check SDL status
--
-- Expected result:
-- Status = 0 (SDL is stopped)
---------------------------------------------------------------------------------------------

--[[ General configuration parameters ]]
  config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared Libraries ]]
  local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
  local commonSteps = require('user_modules/shared_testcases/commonSteps')
  local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
  local sdl = require('SDL')
  local testCasesForExternalUCS = require('user_modules/shared_testcases/testCasesForExternalUCS')

--[[ Local variables ]]
  local grpId = "Location-1"
  local checkedSection = "disallowed_by_external_consent_entities_on"
  local params = { "entityId", "entityType" }
  local values = {
    { v = "1", desc = "String" },
    { v = 1.23, desc = "Float" },
    { v = {}, desc = "Empty table" },
    { v = { entityType = 1, entityID = 1 }, desc = "Non-empty table" },
    { v = -1, desc = "Below Min" },
    { v = 129, desc = "Beyond Max" },
    { v = "", desc = "Blank" },
    { v = nil, desc = "Null" }
  }

 --[[ Local Functions ]]
  local function getParamValues(p, i)
    if p == 1 then
      return values[i].v, 1
    else
      return 1, values[i].v
    end
  end

--[[ General Precondition before ATF start ]]
  commonFunctions:SDLForceStop()
  commonSteps:DeleteLogsFileAndPolicyTable()
  commonPreconditions:BackupFile("sdl_preloaded_pt.json")

--[[ General Settings for configuration ]]
  Test = require("user_modules/connecttest_resumption")
  require('user_modules/AppTypes')

--[[ Preconditions ]]
  commonFunctions:newTestCasesGroup("Preconditions")

  function Test:CheckSDLStatus()
    testCasesForExternalUCS.checkSDLStatus(self, sdl.RUNNING, "SDL is not running")
  end

--[[ Test ]]
  commonFunctions:newTestCasesGroup("Test")

  local n = 0

  for p = 1, #params do

    for i = 1, #values do

      n = n + 1
      local tcName = "TC[".. string.format("%02d", n) .. "] - [" .. params[p] .. ": " .. values[i].desc .. "] "
        .. string.rep("-", 20)

      Test[tcName] = function() end

      function Test:StopSDL()
        testCasesForExternalUCS.ignitionOff(self)
      end

      function Test:CheckSDLStatus()
        testCasesForExternalUCS.checkSDLStatus(self, sdl.STOPPED)
      end

      function Test.RemoveLPT()
        testCasesForExternalUCS.removeLPT()
      end

      function Test.UpdatePreloadedPT()
        local updateFunc = function(preloadedTable)
          local entityIdValue, entityTypeValue = getParamValues(p, i)
          preloadedTable.policy_table.functional_groupings[grpId][checkedSection] = {
            {
              entityID = entityIdValue,
              entityType = entityTypeValue
            }
          }
        end
        testCasesForExternalUCS.updatePreloadedPT(updateFunc)
      end

      function Test.StartSDL()
        StartSDL(config.pathToSDL, config.ExitOnCrash)
        os.execute("sleep 1")
      end

      function Test:CheckSDLStatus()
        testCasesForExternalUCS.checkSDLStatus(self, sdl.STOPPED)
      end

    end

  end

--[[ Postconditions ]]
  commonFunctions:newTestCasesGroup("Postconditions")

  function Test.StopSDL()
    StopSDL()
  end

  function Test.RestorePreloadedFile()
    commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
  end

return Test
