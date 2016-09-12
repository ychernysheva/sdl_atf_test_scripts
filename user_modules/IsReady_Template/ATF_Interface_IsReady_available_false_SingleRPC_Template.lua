config.defaultProtocolVersion = 2
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
config.SDLStoragePath = config.pathToSDL .. "storage/"
---------------------------------------------------------------------------------------------
---------------------------- Required Shared libraries --------------------------------------
---------------------------------------------------------------------------------------------

	local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
	local commonSteps = require('user_modules/shared_testcases/commonSteps')
	local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
	local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')

	DefaultTimeout = 3
	local iTimeout = 2000
	local commonPreconditions = require ('/user_modules/shared_testcases/commonPreconditions')


---------------------------------------------------------------------------------------------
------------------------- General Precondition before ATF start -----------------------------
---------------------------------------------------------------------------------------------
	-- Precondition: remove policy table and log files
	commonSteps:DeleteLogsFileAndPolicyTable()


---------------------------------------------------------------------------------------------
---------------------------- General Settings for configuration----------------------------
---------------------------------------------------------------------------------------------
	Test = require('connecttest')

	require('cardinalities')
	local events = require('events')  
	local mobile_session = require('mobile_session')
	require('user_modules/AppTypes')
	local isReady = require('user_modules/IsReady_Template/isReady')

---------------------------------------------------------------------------------------------
------------------------------------ Common variables ---------------------------------------
---------------------------------------------------------------------------------------------
	local RPCs = commonFunctions:cloneTable(isReady.RPCs)
	local mobile_request = commonFunctions:cloneTable(isReady.mobile_request)

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

--Not applicable

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK I----------------------------------------
--------------------------------Check normal cases of Mobile request---------------------------
-----------------------------------------------------------------------------------------------

-- Not applicable for '..tested_method..' HMI API.



----------------------------------------------------------------------------------------------
----------------------------------------TEST BLOCK II-----------------------------------------
-----------------------------Check special cases of Mobile request----------------------------
----------------------------------------------------------------------------------------------

-- Not applicable for '..tested_method..' HMI API.

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK III--------------------------------------
----------------------------------Check normal cases of HMI response---------------------------
-----------------------------------------------------------------------------------------------

--List of CRQs:
	--APPLINK-20918: [GENIVI] VR interface: SDL behavior in case HMI does not respond to IsReady_request or respond with "available" = false
		-- 1. HMI respond IsReady (false) -> SDL must return 'UNSUPPORTED_RESOURCE, success:false' to all single Interface-related RPC
		-- 2. HMI respond IsReady (false) and app sends RPC that must be spitted -> SDL must NOT transfer Interface portion of spitted RPC to HMI
		-- 3. HMI does NOT respond to IsReady_request -> SDL must transfer received RPC to HMI even to non-responded Interface module

--List of parameters in '..tested_method..' response:
	--Parameter 1: correlationID: type=Integer, mandatory="true"
	--Parameter 2: method: type=String, mandatory="true" (method = IsReady) 
	--Parameter 3: resultCode: type=String Enumeration(Integer), mandatory="true" 
	--Parameter 4: info/message: type=String, minlength="1" maxlength="10" mandatory="false" 
	--Parameter 5: available: type=Boolean, mandatory="true"
-----------------------------------------------------------------------------------------------

	
	
-----------------------------------------------------------------------------------------------				
-- Cases 1: HMI sends IsReady response (available = false)
-----------------------------------------------------------------------------------------------
		
	local TestCaseName = TestedInterface .."_IsReady_response_availabe_false"
		
	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(TestCaseName)
		
		
	isReady:StopStartSDL_HMI_MOBILE(self, 0, TestCaseName)
		
	-----------------------------------------------------------------------------------------------
	--CRQ #2) 
	-- VR:  APPLINK-20931: [VR Interface] Conditions for SDL to respond 'UNSUPPORTED_RESOURCE, success:false' to mobile app <= SDL receives IsReady(available=false) from HMI 
	-- UI:  APPLINK-25045
	-- TTS: APPLINK-25140
	-- VehicleInfo: APPLINK-25224
	-- Navigation:  APPLINK-25184
	-- Verification criteria:
		-- In case SDL receives Interface (available=false) from HMI and mobile app sends any single interface-related RPC
		-- SDL must respond "UNSUPPORTED_RESOURCE, success=false, info: "Interface is not supported by system" to mobile app
		-- SDL must NOT transfer this Interface-related RPC to HMI
	-----------------------------------------------------------------------------------------------	
	commonSteps:RegisterAppInterface("Precondition_RegisterAppInterface_" .. TestCaseName)
		
	-- Description: Activation app for precondition
	commonSteps:ActivationApp(nil, "Precondition_ActivationApp_" .. TestCaseName)

	local function Interface_IsReady_response_availabe_false_check_single_related_RPC(TestCaseName)
			for count_RPC = 1, #RPCs do
				-- All applicable RPCs
				Test["TC01_".. RPCs[count_RPC].name .. "_UNSUPPORTED_RESOURCE_false" ..TestCaseName] = function(self)
					local menuparams = ""
					local vrCmd = ""
					print("=============== Test: "..TestedInterface.."."..RPCs[count_RPC].name)
					local mob_request = mobile_request[count_RPC]
					local hmi_call = RPCs[count_RPC]
					local hmi_method_call = TestedInterface.."."..hmi_call.name

					if ( hmi_call.params.appID ~= nil ) then hmi_call.params.appID = self.applications[config.application1.registerAppInterfaceParams.appName] end
					
					
					if ( TestedInterface == "VR") then 
						-- APPLINK-19333: AddCommand should not to be splitted to UI.AddCommand
						if (mob_request.params.menuParams ~= nil ) then 
							menuparams = mob_request.params.menuParams 
							mob_request.params.menuParams =  nil 
						end
					end
					if( TestedInterface == "UI") then
						-- APPLINK-19329: AddCommand should not to be splitted to VR.AddCommand
						if ( mob_request.params.vrCommands ~= nil ) then 
							vrCmd = mob_request.params.vrCommands
							mob_request.params.vrCommands = nil
						end
					end

					commonTestCases:DelayedExp(iTimeout)
			
					--mobile side: sending AddCommand request
					local cid = self.mobileSession:SendRPC(mob_request.name, mob_request.params)
						
					--hmi side: expect SDL does not send Interface.RPC request
					EXPECT_HMICALL(hmi_method_call, {})
					:Times(0)

					if(mob_request.name == "DeleteCommand") then
						-- According to APPLINK-27079
						--mobile side: expect RPC response
						EXPECT_RESPONSE(cid, {success = false, resultCode = "INVALID_ID"})
					
					elseif(mob_request.name == "UnsubscribeVehicleData") then
						-- According to APPLINK-27872 and APPLINK-20043
						-- mobile side: expect RPC response
						EXPECT_RESPONSE(cid, {success = false, resultCode = "IGNORED"})

					else
						--mobile side: expect RPC response
						EXPECT_RESPONSE(cid, {success = false, resultCode = "UNSUPPORTED_RESOURCE", info =  TestedInterface .." is not supported by system"})
					
					end

					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Times(0)

					--In some reason when assign global variable to local one and local var becomes nil, global var also becomes nil!!!! The solution is temporary until resolving the problem. 
					if(menuparams ~= "") then mob_request.params.menuParams = menuparams end
					if(vrCmd ~= "") 	 then mob_request.params.vrCommands = vrCmd end
				end			
			end -- for count_RPC = 1, #RPCs do
	end
		
	Interface_IsReady_response_availabe_false_check_single_related_RPC(TestedInterface .."_IsReady_response_availabe_false_single_"..TestedInterface.."_related_RPC")

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK IV----------------------------------------
------------------------------Check special cases of HMI response-----------------------------
----------------------------------------------------------------------------------------------

-- These cases are merged into TEST BLOCK III
	
-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Not applicable

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VI----------------------------------------
-------------------------Sequence with emulating of user's action(s)--------------------------
----------------------------------------------------------------------------------------------

--Not applicable

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VII---------------------------------------
--------------------------------------Different HMIStatus-------------------------------------
----------------------------------------------------------------------------------------------

-- Not applicable for '..tested_method..' HMI API.

return Test