--This script contains common functions that are used in many script.
--How to use:
	--1. local testCasesForBuildingSDLPolicyFlag = require('user_modules/shared_testcases/testCasesForBuildingSDLPolicyFlag')
	--2. testCasesForBuildingSDLPolicyFlag:createPolicyTableWithoutAPI()
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
------------------------------------------ Functions ----------------------------------------
---------------------------------------------------------------------------------------------
--1. Update_PolicyFlag
--2. CheckPolicyFlagAfterBuild
---------------------------------------------------------------------------------------------
local testCasesForBuildingSDLPolicyFlag = {}

function testCasesForBuildingSDLPolicyFlag:Update_PolicyFlag(flag, new_value_flag)

    print(" \27[31m Function Update_PolicyFlag is under review! \27[0m")	
    return false
end

function testCasesForBuildingSDLPolicyFlag:CheckPolicyFlagAfterBuild(flag, new_value_flag)
	print(" \27[31m Function CheckPolicyFlagAfterBuild is under review! \27[0m")							
    return false
end

return testCasesForBuildingSDLPolicyFlag