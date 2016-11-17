--This script contains common functions that are used in many script.
--How to use:
	--1. local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
	--2. testCasesForPolicyTable:createPolicyTableWithoutAPI()
---------------------------------------------------------------------------------------------
	
local testCasesForPolicyTable = {}
local mobile_session = require('mobile_session')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')


--Policy template
local PolicyTableTemplate = "user_modules/shared_testcases/PolicyTables/DefaultPolicyTableWith_group1.json"

local PolicyTableTemplate2 = "user_modules/shared_testcases/PolicyTables/DefaultPolicyTableWith_group1_2.json"

--New policy table
local PolicyTable = "user_modules/shared_testcases/PolicyTables/TestingPolicyTable.json"

local APINameKeyWord = "APIName"
local appID = "0000001"
local defaultFunctionGroupName = "group1"
testCasesForPolicyTable.time_trigger = 0
testCasesForPolicyTable.time_onstatusupdate = 0
testCasesForPolicyTable.time_policyupdate = 0
--testCasesForPolicyTable.PTS_elements = {{}}
testCasesForPolicyTable.preloaded_elements = {}
testCasesForPolicyTable.pts_elements = {}
testCasesForPolicyTable.seconds_between_retries = {}

---------------------------------------------------------------------------------------------
------------------------------------------ Functions ----------------------------------------
---------------------------------------------------------------------------------------------
--List of group functions:
--1. createPolicyTableWithoutAPI
--2. createPolicyTable
--2b. createPolicyTableFile
--3. updatePolicy
--4. userConsent
--5. updatePolicyAndAllowFunctionGroup
--6. flow_PTU_SUCCEESS_EXTERNAL_PROPRIETARY
--7. extract_preloaded_pt
--8 create_PTS
--9. get_data_from_PTS
--10. trigger_PTU_user_request_update_from_HMI
--11. trigger_PTU_getting_device_consent
--12. trigger_PTU_user_press_button_HMI
---------------------------------------------------------------------------------------------


--Create new policy table from a template without APIName
function testCasesForPolicyTable:createPolicyTableWithoutAPI(APIName)


	--New policy table with API
	local PolicyTable = "user_modules/shared_testcases/PolicyTables/TestingPolicyTable192837465.json"
	

	-- Opens a file in read mode
	local file = io.open(PolicyTableTemplate, "r")

	-- Opens a file in write mode
	local file2 = io.open(PolicyTable, "w")

	--Rename API if it is exist
	while true do

		local line = file:read()
		if line == nil then break end
		
		if string.find(line, APIName) ~= nil then
			--rename API name if it is esist in template policy table
			line  =  string.gsub(line, APIName, APIName .. "1")
		end
		
		--Write line to new policy table		
		file2:write(line)
	end

	file:close()
	file2:close()
	
	return PolicyTable

end

--Create new policy table from a template with API name and Hmi levels
function testCasesForPolicyTable:createPolicyTable(APIName, HmiLevels, keep_context, steal_focus, functionGroupName)

	if keep_context == nil then
		keep_context = false
	end
	if steal_focus == nil then
		steal_focus = false
	end
	
	if functionGroupName == nil then
		functionGroupName = defaultFunctionGroupName
	end

	
	local testCaseName = "CreatePolicyTable_AllowHmiLevels"
	for i = 1, #HmiLevels do
		testCaseName = testCaseName .. "_" .. HmiLevels[i]
	end
	
	testCaseName = testCaseName .. "_" .. "keep_context_is" .. tostring(keep_context) ..  "_steal_focus_is" .. tostring(steal_focus)
	
	Test[testCaseName] = function(self)


		-- Opens a file in read mode
		local file = io.open(PolicyTableTemplate, "r")

		-- Opens a file in write mode
		local file2 = io.open(PolicyTable, "w")

		--Read policy table template and create new policy table with API name and HMI Levels
		while true do

			local line = file:read()
			if line == nil then break end
			
			line  =  string.gsub(line, defaultFunctionGroupName, functionGroupName)
			
			if string.find(line, APINameKeyWord) == nil then
				--rename API name if it is exist in template policy table
				line  =  string.gsub(line, APIName, APIName .. "1")
				
				--Write line to new policy table
				file2:write(line)
				
				if string.find(line, appID) ~= nil then
					--update keep_context and steal_focus
					line = "\t\t\t\t\"keep_context\" : " .. tostring(keep_context).. ",\n"
					file:read()
					file2:write(line)
					line = "\t\t\t\t\"steal_focus\" : " .. tostring(steal_focus).. ",\n"
					file:read()
					file2:write(line)
					
				
				end
				
			else
				
				--Update API name
				line  =  string.gsub(line, APINameKeyWord, APIName)
				file2:write(line)
				
				--Copy next line
				line = file:read()
				file2:write(line)
				
				--skip a next line (HMI Level)
				line = file:read() 
				
				--Write HMI LEVELS
				if #HmiLevels >= 1 then
					for i = 1, #HmiLevels - 1 do
						line  =  "\t\t\t\t\t\t\t\"" .. HmiLevels[i] .. "\",\n"
						file2:write(line)
					end
					line  =  "\t\t\t\t\t\t\t\"" .. HmiLevels[#HmiLevels] .. "\"]\n"
					file2:write(line)
				else
					print("Error: HmiLevels should not be empty")
					break				
				end
				
			end
		end

		file:close()
		file2:close()
		
		return true

	end

	return PolicyTable
end

--Use for adding permission for Base-4, group1, application (new function)
function testCasesForPolicyTable:createPolicyTableFile(PermissionLinesForBase4, PermissionLinesForGroup1, PermissionLinesForApplication, RenameAPIs)

	if RenameAPIs == nil then
		RenameAPIs = {}
	end
	
	local TestCaseName = "CreatePolicyTable"
	if PermissionLinesForBase4 ~= nil then TestCaseName = TestCaseName .. "_Add_APIs_To_Base4_Group" end
	if PermissionLinesForGroup1 ~= nil then TestCaseName = TestCaseName .. "_Add_APIs_To_group1_Group" end
	if PermissionLinesForApplication ~= nil then TestCaseName = TestCaseName .. "_Assign_Groups_To_App" end  

	Test[TestCaseName] = function(self)

		-- Opens a file in read mode
		local file = io.open(PolicyTableTemplate2, "r")

		-- Opens a file in write mode
		local file2 = io.open(PolicyTable, "w")

	
		--1. Create PT with permission for group1 group
		if PermissionLinesForGroup1 ~= nil then
			while true do
				--look for '"user_consent_prompt" : "group1",' keyword and add permission for group1 group
				local keyword = '"user_consent_prompt" : "group1",'
				local line = file:read()
				if line == nil then break end
				
				--Write to new PT
				file2:write(line)
				
				if string.find(line, keyword) ~= nil then
					--Copy next line to new policy table
					line = file:read()  --"rpcs" : {
					file2:write(line)
					
					--ignore next 4 lines
					line = file:read()
					line = file:read()
					line = file:read()
					line = file:read()
					
					--Add new APIs to new policy table
					file2:write(PermissionLinesForGroup1)				
					break
				end			
			end
		end
				
		--2. Create PT with permission for Base-4 group
		if PermissionLinesForBase4 ~= nil then
			--look for Base keyword and add permission for Base-4 group
			local keyword = '"Base'
			while true do
				local line = file:read()
				if line == nil then break end
				
				--Write to new PT
				file2:write(line)
				
				if string.find(line, keyword) ~= nil then
					--Copy next line to new policy table
					line = file:read()  --"rpcs" : {
					file2:write(line)
					
					--Add new APIs to new policy table
					file2:write(PermissionLinesForBase4)				
					break
				end			
			end
		end
	
		--3. Create PT with permission for application
		if PermissionLinesForApplication ~= nil then
			--look for '"user_consent_prompt" : "group1",' keyword and add permission for group1 group
			local keyword = '"app_policies" : {'		
			while true do
			
				local line = file:read()
				if line == nil then break end
				
				for j = 1, #RenameAPIs do				
					if string.find(line, RenameAPIs[j]) ~= nil then
						--rename API name if it is esist in template policy table
						line  =  string.gsub(line, RenameAPIs[j], RenameAPIs[j] .. "_1")
					end
				end
					
				--Write to new PT
				file2:write(line)
				
				if string.find(line, keyword) ~= nil then
					
					--Add new APIs to new policy table
					file2:write(PermissionLinesForApplication)	
					break					
				end
			end
		end
		
		
		--4. Copy to the end of file
		while true do
			local line = file:read()
			if line == nil then break end
			
			for j = 1, #RenameAPIs do	
				if string.find(line, RenameAPIs[j]) ~= nil then
					--rename API name if it is esist in template policy table
					line  =  string.gsub(line, RenameAPIs[j], RenameAPIs[j] .. "_1")
				end
			end
			
			
			--Write to new PT
			file2:write(line)
		end

		file:close()
		file2:close()
		return true
	end

	return PolicyTable
	
end

--Precondition: update policy with specified policy file, policy group name and return groupID of consent group.
function testCasesForPolicyTable:updatePolicy(PTName, iappID)
	
	Test["UpdatePolicy"] = function(self)

		if not iappID then
			iappID = self.applications[config.application1.registerAppInterfaceParams.appName]
		end 
		
		--hmi side: sending SDL.GetURLS request
		local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
		
		--hmi side: expect SDL.GetURLS response from HMI
		EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
		:Do(function(_,data)
			--print("SDL.GetURLS response is received")
			--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
			self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
				{
					requestType = "PROPRIETARY",
					fileName = "filename"
				}
			)
			--mobile side: expect OnSystemRequest notification 
			EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
			:Do(function(_,data)
				--print("OnSystemRequest notification is received")
				--mobile side: sending SystemRequest request 
				local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
					{
						fileName = "PolicyTableUpdate",
						requestType = "PROPRIETARY",
						appID = iappID
					},
				PTName)
				
				local systemRequestId
				--hmi side: expect SystemRequest request
				EXPECT_HMICALL("BasicCommunication.SystemRequest")
				:Do(function(_,data)
					systemRequestId = data.id
					--print("BasicCommunication.SystemRequest is received")
					
					--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
					self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
						{
							policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
						}
					)
					function to_run()
						--hmi side: sending SystemRequest response
						self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
					end
					
					RUN_AFTER(to_run, 500)
				end)

				--hmi side: expect SDL.OnStatusUpdate
				EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
					:ValidIf(function(exp,data)
						if 
							exp.occurences == 1 and
							data.params.status == "UP_TO_DATE" then
								return true
						elseif
							exp.occurences == 1 and
							data.params.status == "UPDATING" then
								return true
						elseif
							exp.occurences == 2 and
							data.params.status == "UP_TO_DATE" then
								return true
						else 
							if 
								exp.occurences == 1 then
									print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in first occurrences status 'UP_TO_DATE' or 'UPDATING', got '" .. tostring(data.params.status) .. "' \27[0m")
							elseif exp.occurences == 2 then
									print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in second occurrences status 'UP_TO_DATE', got '" .. tostring(data.params.status) .. "' \27[0m")
							end
							return false
						end
					end)
					:Times(Between(1,2))
				
				--mobile side: expect SystemRequest response
				EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
				:Do(function(_,data)
					--print("SystemRequest is received")
					--hmi side: sending SDL.GetUserFriendlyMessage request to SDL
					local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"StatusUpToDate"}})
					
					--hmi side: expect SDL.GetUserFriendlyMessage response
					--EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{line1 = "Up-To-Date", messageCode = "StatusUpToDate", textBody = "Up-To-Date"}}}})
					-- textBody = "Up-To-Date" is not sent in SDL snapshot
					EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
				end)
				
			end)
		end)		
		
		
	end
	
end

--Precondition: update policy with specified policy file on Genivi
function testCasesForPolicyTable:updatePolicyGenivi(self, PTName, iappID)
	
	-- Test["UpdatePolicy"] = function(self)

		if not iappID then
			iappID = self.applications[config.application1.registerAppInterfaceParams.appName]
		end 
		
		--print("OnSystemRequest notification is received")
		--mobile side: sending SystemRequest request 
		local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
			{
				fileName = "PolicyTableUpdate",
				requestType = "PROPRIETARY",
				appID = iappID
			},
		PTName)
		
		local systemRequestId
		--hmi side: expect SystemRequest request
		EXPECT_HMICALL("BasicCommunication.SystemRequest")
		:Do(function(_,data)
			systemRequestId = data.id
			--print("BasicCommunication.SystemRequest is received")
			
			--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
			self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
				{
					policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
				}
			)
			function to_run()
				--hmi side: sending SystemRequest response
				self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
			end
			
			RUN_AFTER(to_run, 500)
		end)

		--hmi side: expect SDL.OnStatusUpdate
		EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
			:ValidIf(function(exp,data)
				if 
					exp.occurences == 1 and
					data.params.status == "UP_TO_DATE" then
						return true
				elseif
					exp.occurences == 1 and
					data.params.status == "UPDATE_NEEDED" then
						return true
				elseif
					(exp.occurences == 1 or
					exp.occurences == 2 )and
					data.params.status == "UPDATING" then
						return true
				elseif
					(exp.occurences == 2 or
					exp.occurences == 3) and
					data.params.status == "UP_TO_DATE" then
						return true
				else 
					if 
						exp.occurences == 1 then
							print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in first occurrences status 'UP_TO_DATE' or 'UPDATING', 'UPDATE_NEEDED', got '" .. tostring(data.params.status) .. "' \27[0m")
					elseif exp.occurences == 2 then
							print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in second occurrences status 'UP_TO_DATE' or 'UPDATING', got '" .. tostring(data.params.status) .. "' \27[0m")
					elseif
						exp.occurences == 3 then
							print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in third occurrences status 'UP_TO_DATE', got '" .. tostring(data.params.status) .. "' \27[0m")
					end
					return false
				end
			end)
			:Times(Between(1,3))
		
		--mobile side: expect SystemRequest response
		EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
		:Do(function(_,data)
			--print("SystemRequest is received")
			--hmi side: sending SDL.GetUserFriendlyMessage request to SDL
			local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"StatusUpToDate"}})
			
			--hmi side: expect SDL.GetUserFriendlyMessage response
			EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{line1 = "Up-To-Date", messageCode = "StatusUpToDate", textBody = "Up-To-Date"}}}})
		end)
		
	-- end
	
end

--User allowed or disallowed group policy
function testCasesForPolicyTable:userConsent(IsConsent, functionGroupName)
	
	
	Test["UserConsent_".. tostring(IsConsent)] = function(self)
	
		if functionGroupName == nil then
			functionGroupName = defaultFunctionGroupName
		end
		
		--Get GetListOfPermissions		
		--hmi side: sending SDL.GetListOfPermissions request to SDL
		local RequestIdGetListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", {appID = self.applications["Test Application"]})
		
		
		-- hmi side: expect SDL.GetListOfPermissions response
		--EXPECT_HMIRESPONSE(RequestIdGetListOfPermissions,{result = {code = 0, method = "SDL.GetListOfPermissions", allowedFunctions = {{name = functionGroupName}}}})
		EXPECT_HMIRESPONSE(RequestIdGetListOfPermissions)
			:Do(function(_,data)
					
					--Get groupID
					local groupID
					for i = 1, #data.result.allowedFunctions do
						if data.result.allowedFunctions[i].name == functionGroupName then
							groupID = data.result.allowedFunctions[i].id
							break
						end					

					end
					
					if groupID == nil then
						commonFunctions:printError("Error: userConsent function: function group name is not exist")					
					end
									
					
					--hmi side: sending SDL.OnAppPermissionConsent
					self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent", { appID =  self.applications["Test Application"], consentedFunctions = {{ allowed = IsConsent, id = groupID, name = functionGroupName}}, source = "GUI"})
					
					EXPECT_NOTIFICATION("OnPermissionsChange", {})                   
			end)
			
			
	end
end

--Print user consent group in policy table
function testCasesForPolicyTable:printUserConsent()
	
	
	Test["PrintUserConsent"] = function(self)
	
		local groupName = "group1"
		
		--Get GetListOfPermissions		
		--hmi side: sending SDL.GetListOfPermissions request to SDL
		local RequestIdGetListOfPermissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions", {appID = self.applications["Test Application"]})
		
		
		-- hmi side: expect SDL.GetListOfPermissions response
		EXPECT_HMIRESPONSE(RequestIdGetListOfPermissions,{result = {code = 0, method = "SDL.GetListOfPermissions", allowedFunctions = {{name = groupName}}}})
			
	end
end


--Verify DISALLOWED resultCode when API is not assigned to app
function testCasesForPolicyTable:checkPolicyWhenAPIIsNotExist()
	
	--Precondition: Build policy table file
	local PTName = testCasesForPolicyTable:createPolicyTableWithoutAPI(APIName)
	
	--Precondition: Update policy table
	testCasesForPolicyTable:updatePolicy(PTName)
		
	--Send request and check DISALLOWED resultCode
	Test[APIName .."_resultCode_DISALLOWED"] = function(self)

		--mobile side: sending the request
		local RequestParams = self.createRequest()
		local cid = self.mobileSession:SendRPC(APIName, RequestParams)
													
		--mobile side: expect response 
		self.mobileSession:ExpectResponse(cid, {  success = false, resultCode = "DISALLOWED"})
		
	end	
	

end	


--Verify DISALLOWED resultCode when API is assigned to app but the group has not yet received user's consents.
--Verify USER_DISALLOWED resultCode
function testCasesForPolicyTable:checkPolicyWhenUserDisallowed(HmiLevels, keep_context, steal_focus)

	
	--Case 1: Verify DISALLOWED resultCode when API is assigned to app but the group has not yet received user's consents.

	
	--Precondition: Build policy table file
	local PTName = testCasesForPolicyTable:createPolicyTable(APIName, HmiLevels, keep_context, steal_focus)
	
	--Precondition: Update policy table
	testCasesForPolicyTable:updatePolicy(PTName)

	--Send request and check DISALLOWED resultCode
	Test[APIName .."_resultCode_DISALLOWED"] = function(self)

		--mobile side: sending the request
		local RequestParams = self.createRequest()
		local cid = self.mobileSession:SendRPC(APIName, RequestParams)
													
		--mobile side: expect response 
		self.mobileSession:ExpectResponse(cid, {  success = false, resultCode = "DISALLOWED"})
		
	end	
	
	
	--Case 2: Verify USER_DISALLOWED resultCode
	
	--Precondition: User does not allow function group
	testCasesForPolicyTable:userConsent(false)		
	
	--Send request and check USER_DISALLOWED resultCode
	Test[APIName .."_resultCode_USER_DISALLOWED"] = function(self)
		--mobile side: sending the request
		local Request = self.createRequest()
		local cid = self.mobileSession:SendRPC(APIName, Request)
													
		--mobile side: expect response 
		self.mobileSession:ExpectResponse(cid, {  success = false, resultCode = "USER_DISALLOWED"})		
	end
	
	--Postcondition: User allows function group
	testCasesForPolicyTable:userConsent(true)	
end	

--Update policy and user consent 
function testCasesForPolicyTable:updatePolicyAndAllowFunctionGroup(HmiLevels, keep_context, steal_focus, consentGroup)

	if consentGroup == nil then
		consentGroup = defaultFunctionGroupName
	end
	
	--Precondition: Build policy table file
	local PTName = testCasesForPolicyTable:createPolicyTable(APIName, HmiLevels, keep_context, steal_focus, consentGroup)
	
	--Precondition: Update policy table
	testCasesForPolicyTable:updatePolicy(PTName)
		
	--Postcondition: User allows function group
	testCasesForPolicyTable:userConsent(true, consentGroup)	
end	

--Update PT for precondition of each test case.
function testCasesForPolicyTable:precondition_updatePolicyAndAllowFunctionGroup(HmiLevels, keep_context, steal_focus)
	
	local consentGroupName = "group_precondition"

	testCasesForPolicyTable:updatePolicyAndAllowFunctionGroup(HmiLevels, keep_context, steal_focus, consentGroupName)
	
end	

--testCasesForPolicyTable:precondition_updatePolicy_AllowFunctionInHmiLeves({"BACKGROUND", "FULL", "LIMITED", "NONE"})
function testCasesForPolicyTable:precondition_updatePolicy_AllowFunctionInHmiLeves(HmiLevels)

	local temp = "\"" .. HmiLevels[1] .. "\""
	
	for i=2, #HmiLevels do
		temp = temp .. "," .. "\"" .. HmiLevels[i] .. "\""	
	end
	
	local PermissionLines = "\""..APIName.. "\": { \"hmi_levels\": [" .. temp .. "]}"

	local PermissionLinesForBase4 = PermissionLines .. ",\n"
	local PermissionLinesForGroup1 = nil
	local PermissionLinesForApplication = nil
	local PTName = testCasesForPolicyTable:createPolicyTableFile_temp(PermissionLinesForBase4, PermissionLinesForGroup1, PermissionLinesForApplication, {APIName})
	testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt(PTName)

end

function testCasesForPolicyTable:createPolicyTableFile_temp(PermissionLinesForBase4, PermissionLinesForGroup1, PermissionLinesForApplication, RenameAPIs)

	if RenameAPIs == nil then
		RenameAPIs = {}
	end
	
	local TestCaseName = "CreatePolicyTable"
	if PermissionLinesForBase4 ~= nil then TestCaseName = TestCaseName .. "_Add_APIs_To_Base4_Group" end
	if PermissionLinesForGroup1 ~= nil then TestCaseName = TestCaseName .. "_Add_APIs_To_group1_Group" end
	if PermissionLinesForApplication ~= nil then TestCaseName = TestCaseName .. "_Assign_Groups_To_App" end  

--	Test[TestCaseName] = function(self)

		-- Opens a file in read mode
		local file = io.open(PolicyTableTemplate2, "r")

		-- Opens a file in write mode
		local file2 = io.open(PolicyTable, "w")

	
		--1. Create PT with permission for group1 group
		if PermissionLinesForGroup1 ~= nil then
			while true do
				--look for '"user_consent_prompt" : "group1",' keyword and add permission for group1 group
				local keyword = '"user_consent_prompt" : "group1",'
				local line = file:read()
				if line == nil then break end
				
				--Write to new PT
				file2:write(line)
				
				if string.find(line, keyword) ~= nil then
					--Copy next line to new policy table
					line = file:read()  --"rpcs" : {
					file2:write(line)
					
					--ignore next 4 lines
					line = file:read()
					line = file:read()
					line = file:read()
					line = file:read()
					
					--Add new APIs to new policy table
					file2:write(PermissionLinesForGroup1)				
					break
				end			
			end
		end
				
		--2. Create PT with permission for Base-4 group
		if PermissionLinesForBase4 ~= nil then
			--look for Base keyword and add permission for Base-4 group
			local keyword = '"Base'
			while true do
				local line = file:read()
				if line == nil then break end
				
				--Write to new PT
				file2:write(line)
				
				if string.find(line, keyword) ~= nil then
					--Copy next line to new policy table
					line = file:read()  --"rpcs" : {
					file2:write(line)
					
					--Add new APIs to new policy table
					file2:write(PermissionLinesForBase4)				
					break
				end			
			end
		end
	
		--3. Create PT with permission for application
		if PermissionLinesForApplication ~= nil then
			--look for '"user_consent_prompt" : "group1",' keyword and add permission for group1 group
			local keyword = '"app_policies" : {'		
			while true do
			
				local line = file:read()
				if line == nil then break end
				
				for j = 1, #RenameAPIs do				
					if string.find(line, RenameAPIs[j]) ~= nil then
						--rename API name if it is esist in template policy table
						line  =  string.gsub(line, RenameAPIs[j], RenameAPIs[j] .. "_1")
					end
				end
					
				--Write to new PT
				file2:write(line)
				
				if string.find(line, keyword) ~= nil then
					
					--Add new APIs to new policy table
					file2:write(PermissionLinesForApplication)	
					break					
				end
			end
		end
		
		
		--4. Copy to the end of file
		while true do
			local line = file:read()
			if line == nil then break end
			
			for j = 1, #RenameAPIs do	
				if string.find(line, RenameAPIs[j]) ~= nil then
					--rename API name if it is esist in template policy table
					line  =  string.gsub(line, RenameAPIs[j], RenameAPIs[j] .. "_1")
				end
			end
			
			
			--Write to new PT
			file2:write(line)
		end

		file:close()
		file2:close()
		--return true
	--end

	return PolicyTable
	
end


function testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt(PTName)
	
		local pt_fileName = "sdl_preloaded_pt.json"
		
		--Backup sdl_preloaded_pt.json file
		commonPreconditions:BackupFile(pt_fileName)

		--Copy new policy table to /sdl/bin folder
		os.execute(" cp -f " .. PTName .. " " .. config.pathToSDL .. pt_fileName)
		
		--Delete policy table
		commonSteps:DeletePolicyTable()
end	

function testCasesForPolicyTable:Restore_preloaded_pt()
	
	Test["PostCondition_Restore_preloaded_pt"] = function(self)
	
		local pt_fileName = "sdl_preloaded_pt.json"
		commonPreconditions:RestoreFile(pt_fileName)
	end
end	

function testCasesForPolicyTable:flow_PTU_SUCCEESS_EXTERNAL_PROPRIETARY()
	function Test:Flow_PTU_SUCCEESS_EXTERNAL_PROPRIETARY()
	    print(" \27[31m Test step Flow_PTU_SUCCEESS_EXTERNAL_PROPRIETARY is not implemented! \27[0m")							
		return false
    end 
end

local data_dictionary = 
{
	{ name = "module_meta.pt_exchanged_at_odometer_x", elem_required = "required"},
	{ name = "module_meta.pt_exchanged_x_days_after_epoch", elem_required = "required"},
	{ name = "module_meta.ignition_cycles_since_last_exchange", elem_required = "required"}	,

	{ name = "module_config.preloaded_pt", elem_required = "optional"},
	{ name = "module_config.preloaded_date", elem_required = "optional"},
	{ name = "module_config.exchange_after_x_ignition_cycles", elem_required = "required"},
	{ name = "module_config.exchange_after_x_kilometers", elem_required = "required"},
	{ name = "module_config.exchange_after_x_days", elem_required = "required"},
	{ name = "module_config.timeout_after_x_seconds", elem_required = "required"},
	{ name = "module_config.endpoints.0x04.default.priority", elem_required = "required"},
	{ name = "module_config.endpoints.0x04.default.groups", elem_required = "required"},
	{ name = "module_config.endpoints.0x04.default.AppHMIType", elem_required = "optional"},
	{ name = "module_config.endpoints.0x04.default.memory_kb", elem_required = "optional"},
	{ name = "module_config.endpoints.0x04.default.heart_beat_timeout_ms", elem_required = "optional"},
	{ name = "module_config.endpoints.0x04.default.RequestType", elem_required = "optional"},
	{ name = "module_config.endpoints.0x07.default.priority", elem_required = "required"},
	{ name = "module_config.endpoints.0x07.default.groups", elem_required = "required"},
	{ name = "module_config.endpoints.0x07.default.AppHMIType", elem_required = "optional"},
	{ name = "module_config.endpoints.0x07.default.memory_kb", elem_required = "optional"},
	{ name = "module_config.endpoints.0x07.default.heart_beat_timeout_ms", elem_required = "optional"},
	{ name = "module_config.endpoints.0x07.default.RequestType", elem_required = "optional"},
	{ name = "module_config.notifications_per_minute_by_priority.EMERGENCY", elem_required = "required"},
	{ name = "module_config.notifications_per_minute_by_priority.NAVIGATION", elem_required = "required"},
	{ name = "module_config.notifications_per_minute_by_priority.VOICECOM", elem_required = "required"},
	{ name = "module_config.notifications_per_minute_by_priority.COMMUNICATION", elem_required = "required"},
	{ name = "module_config.notifications_per_minute_by_priority.NORMAL", elem_required = "required"},
	{ name = "module_config.notifications_per_minute_by_priority.NONE", elem_required = "required"},
	{ name = "module_config.certificate", elem_required = "optional"},
	{ name = "module_config.vehicle_make", elem_required = "optional"},
	{ name = "module_config.vehicle_model", elem_required = "optional"},
	{ name = "module_config.vehicle_year", elem_required = "optional"},
	{ name = "module_config.display_order", elem_required = "optional"},

	{ name = "consumer_friendly_messages.version", elem_required = "required"},

	{ name = "app_policies.default.priority", elem_required = "required"},
	{ name = "app_policies.default.groups", elem_required = "required"},
	{ name = "app_policies.default.AppHMIType", elem_required = "optional"},
	{ name = "app_policies.default.memory_kb", elem_required = "optional"},
	{ name = "app_policies.default.heart_beat_timeout_ms", elem_required = "optional"},
	{ name = "app_policies.default.RequestType", elem_required = "optional"},
	{ name = "app_policies.pre_DataConsent.priority", elem_required = "required"},
	{ name = "app_policies.pre_DataConsent.groups", elem_required = "required"},
	{ name = "app_policies.pre_DataConsent.AppHMIType", elem_required = "optional"},
	{ name = "app_policies.pre_DataConsent.memory_kb", elem_required = "optional"},
	{ name = "app_policies.pre_DataConsent.heart_beat_timeout_ms", elem_required = "optional"},
	{ name = "app_policies.pre_DataConsent.RequestType", elem_required = "optional"}

}
local json_elements = {}

local function extract_json(pathToFile)
	json_elements = {}
	if( commonSteps:file_exists(pathToFile) ) then
		print("file exist")
	
		local file  = io.open(pathToFile, "r")
		local json_data = file:read("*all") 
		file:close()

		local json = require("modules/json")
		local data = json.decode(json_data)
		local i = 1

		for index_level1, value_level1 in pairs(data.policy_table) do
			if(type(value_level1) == false) then
		      json_elements[i] = { name = index_level1 , elem_required = nil, value = value_level1}
		      i = i + 1
			else
				for index_level2, value_level2 in pairs(value_level1) do
					if( type(value_level2) ~= "table" ) then 
				      json_elements[i] = { name = index_level1.."."..index_level2, elem_required = nil, value = value_level2 }
				      i = i + 1
					else
						for index_level3, value_level3 in pairs(value_level2) do

							if(type(value_level3) ~= "table") then 
						      json_elements[i] = { name = index_level1 .. "."..index_level2.."."..index_level3 , elem_required = nil, value = value_level3 }
						      i = i + 1
							else
								for index_level4, value_level4 in pairs(value_level3) do
									
									if(type(value_level4) ~= "table") then 
						      			json_elements[i] = { name = index_level1 .. "."..index_level2 .. "."..index_level3.."."..index_level4, elem_required = nil, value = value_level4 }
						      			i = i + 1
						      		else
						      			for index_level5, value_level5 in pairs(value_level4) do
						      				if(type(value_level5) ~= "table") then
						      					json_elements[i] = { name = index_level1 .. "."..index_level2 .. "."..index_level3.. "."..index_level4.."."..index_level5, elem_required = nil, value = value_level5 }
						      					i = i + 1
						      				else
						      					for index_level6, value_level6 in pairs(value_level5) do
						      						if(type(value_level6) ~= "table") then
						      							json_elements[i] = { name = index_level1 .. "."..index_level2 .. "."..index_level3.. "."..index_level4  .. "."..index_level5.."."..index_level6, elem_required = nil, value = value_level6 }
						      							i = i + 1
						      						end
						      					end
						      				end
						      			end
									end
								end
							end
						end
					end
				end
		   end
		end
	else
		print("file doesn't exist: " ..pathToFile)
	end
end

function testCasesForPolicyTable:extract_preloaded_pt()
	preloaded_pt = 'SDL_bin/sdl_preloaded_pt.json'	
	extract_json(preloaded_pt)
	k = 1
	for i = 1, #json_elements do
		testCasesForPolicyTable.preloaded_elements[i] = { name = json_elements[i].name, value = json_elements[i].value }
		if( string.sub(json_elements[i].name,1,string.len("module_config.seconds_between_retries.")) == "module_config.seconds_between_retries." ) then
			testCasesForPolicyTable.seconds_between_retries[k] = { name = json_elements[i].name, value = json_elements[i].value}
			k = k + 1
		end
	end
end

function testCasesForPolicyTable:create_PTS(is_created, app_IDs, device_IDs)
	if(is_created == false) then
		if ( commonSteps:file_exists( '/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json') ) then
			print(" \27[31m /tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json is created \27[0m")	
		end
	else
		testCasesForPolicyTable:extract_preloaded_pt()
		local j = 1
		local k = 1
		local length_data_dict = #data_dictionary
		for i = 1, #json_elements do
			local str_1 = json_elements[i].name
			if( string.sub(str_1,1,string.len("functional_groupings.")) == "functional_groupings." ) then
				data_dictionary[length_data_dict + j] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }
				j = j + 1
			end

			if( string.sub(str_1,1,string.len("module_config.seconds_between_retries.")) == "module_config.seconds_between_retries." ) then
				testCasesForPolicyTable.seconds_between_retries[k] = { name = json_elements[i].name, value = json_elements[i].value}
				k = k + 1
				data_dictionary[length_data_dict + j] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }
				j = j + 1
			end

			if( string.sub(str_1,1,string.len("app_policies.pre_DataConsent.groups.")) == "app_policies.pre_DataConsent.groups." ) then
				data_dictionary[length_data_dict + j] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }
				j = j + 1
			end

			if( string.sub(str_1,1,string.len("app_policies.default.groups.")) == "app_policies.default.groups." ) then
				data_dictionary[length_data_dict + j] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }
				j = j + 1
			end

			if( string.sub(str_1,1,string.len("module_config.endpoints.0x07.default.")) == "module_config.endpoints.0x07.default." ) then
				data_dictionary[length_data_dict + j] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }
				j = j + 1
			end

			if( string.sub(str_1,1,string.len("module_config.endpoints.0x04.default.")) == "module_config.endpoints.0x04.default." ) then
				data_dictionary[length_data_dict + j] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }
				j = j + 1
			end
		end	

		if(app_IDs ~= nil) then
			for i = 1, #app_IDs do
				local length_data_dict = #data_dictionary
				data_dictionary[length_data_dict + 1] = { name = "module_config.endpoints."..tostring(app_IDs[i])..".nicknames", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 2] = { name = "module_config.endpoints."..tostring(app_IDs[i])..".priority", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 3] = { name = "module_config.endpoints."..tostring(app_IDs[i])..".groups", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 4] = { name = "module_config.endpoints."..tostring(app_IDs[i])..".AppHMIType", value = nil, elem_required = "optional" }
				data_dictionary[length_data_dict + 5] = { name = "module_config.endpoints."..tostring(app_IDs[i])..".memory_kb", value = nil, elem_required = "optional" }
				data_dictionary[length_data_dict + 6] = { name = "module_config.endpoints."..tostring(app_IDs[i])..".heart_beat_timeout_ms", value = nil, elem_required = "optional" }
				data_dictionary[length_data_dict + 7] = { name = "module_config.endpoints."..tostring(app_IDs[i])..".RequestType", value = nil, elem_required = "optional" }

				data_dictionary[length_data_dict + 8] = { name = "usage_and_error_counts."..tostring(app_IDs[i])..".count_of_tls_errors", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 9] = { name = "usage_and_error_counts."..tostring(app_IDs[i])..".nicknames", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 10] = { name = "usage_and_error_counts."..tostring(app_IDs[i])..".priority", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 11] = { name = "usage_and_error_counts."..tostring(app_IDs[i])..".groups", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 12] = { name = "usage_and_error_counts."..tostring(app_IDs[i])..".AppHMIType", value = nil, elem_required = "optional" }
				data_dictionary[length_data_dict + 13] = { name = "usage_and_error_counts."..tostring(app_IDs[i])..".memory_kb", value = nil, elem_required = "optional" }
				data_dictionary[length_data_dict + 14] = { name = "usage_and_error_counts."..tostring(app_IDs[i])..".heart_beat_timeout_ms", value = nil, elem_required = "optional" }
				data_dictionary[length_data_dict + 15] = { name = "usage_and_error_counts."..tostring(app_IDs[i])..".RequestType", value = nil, elem_required = "optional" }
				
				data_dictionary[length_data_dict + 16] = { name = "app_policies."..tostring(app_IDs[i])..".count_of_tls_errors", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 17] = { name = "app_policies."..tostring(app_IDs[i])..".nicknames", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 18] = { name = "app_policies."..tostring(app_IDs[i])..".priority", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 19] = { name = "app_policies."..tostring(app_IDs[i])..".groups", value = nil, elem_required = "required" }
				data_dictionary[length_data_dict + 20] = { name = "app_policies."..tostring(app_IDs[i])..".AppHMIType", value = nil, elem_required = "optional" }
				data_dictionary[length_data_dict + 21] = { name = "app_policies."..tostring(app_IDs[i])..".memory_kb", value = nil, elem_required = "optional" }
				data_dictionary[length_data_dict + 22] = { name = "app_policies."..tostring(app_IDs[i])..".heart_beat_timeout_ms", value = nil, elem_required = "optional" }
				data_dictionary[length_data_dict + 23] = { name = "app_policies."..tostring(app_IDs[i])..".RequestType", value = nil, elem_required = "optional" }
				data_dictionary[length_data_dict + 24] = { name = "app_policies."..tostring(app_IDs[i]), value = nil, elem_required = "optional" }
			end
		else
			data_dictionary[#data_dictionary + 1] = { name = "usage_and_error_counts", elem_required = "required"}
		end


		if(device_IDs ~= nil) then
			for i =1 , #device_IDs do
				local length_data_dict = #data_dictionary
				data_dictionary[length_data_dict + 1] = { name = "device_data."..tostring(device_IDs[i])..".usb_transport_enabled", value = nil, elem_required = "required" }
			end
		else
			data_dictionary[#data_dictionary + 1] = { name = "device_data", elem_required = "required"}
		end

		pts = '/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json'
		if ( commonSteps:file_exists(pts) ) then
			extract_json(pts)
			local k = 1
			for i = 1, #json_elements do
				testCasesForPolicyTable.pts_elements[k] = {
					name = json_elements[i].name, 
					value = json_elements[i].value
				}
				k = k + 1
			end	
		else
			print("/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json doesn't exits! ")
		end
		
		--Check for ommited parameters
		for i = 1, #testCasesForPolicyTable.pts_elements do
			local str_1 = testCasesForPolicyTable.pts_elements[i].name
			local is_existing = false
			for j = 1, #data_dictionary do
				local str_2 = data_dictionary[j].name
				if( str_1 == str_2 ) then
					is_existing = true
					for k = 1, #testCasesForPolicyTable.preloaded_elements do
						if(testCasesForPolicyTable.preloaded_elements[k].name == str_2) then
							if(testCasesForPolicyTable.pts_elements[i].value ~= testCasesForPolicyTable.preloaded_elements[k].value) then
								print(testCasesForPolicyTable.pts_elements[i].name .." = " .. tostring(testCasesForPolicyTable.pts_elements[i].value) .. ". Should be " ..tostring(testCasesForPolicyTable.preloaded_elements[k].value) )
							end
						end
					end
					break
				end
			end
			if (is_existing == false) then
				print(testCasesForPolicyTable.pts_elements[i].name .. ": should not exist")
			end
		end

		--Check for mandatory elements
		for i = 1, #data_dictionary do
			if(data_dictionary[i].elem_required == "required") then
				local str_2 = data_dictionary[i].name
				local is_existing = false
				for j = 1, #testCasesForPolicyTable.pts_elements do
					local str_1 = testCasesForPolicyTable.pts_elements[j].name
					if( str_1 == str_2 ) then
						is_existing = true
						break
					end
				end
				if (is_existing == false) then
					print(data_dictionary[i].name .. ": mandatory parameter does not exist in PTS")
				end
			end
		end
	end --if(is_created == false) then
end

function testCasesForPolicyTable:get_data_from_PTS(pts_element)
	local value
	local is_found = false
	for i = 1, #testCasesForPolicyTable.pts_elements do
		if (pts_element == testCasesForPolicyTable.pts_elements[i].name) then
			value = testCasesForPolicyTable.pts_elements[i].value
			is_found = true
			break
		end
	end		
	if(is_found == false) then 
		print(" \27[31m Element "..pts_element.." is not found in PTS! \27[0m")
	end
	if (value == nil)	then
		print(" \27[31m Value of "..pts_element.." is nil \27[0m")
		value = 0
	end

	return value
end

function testCasesForPolicyTable:trigger_PTU_user_request_update_from_HMI()
	function Test:TestStep_trigger_PTU_user_request_update_from_HMI()
		testCasesForPolicyTable.time_trigger = 0
		testCasesForPolicyTable.time_onstatusupdate = 0
		testCasesForPolicyTable.time_policyupdate = 0

		self.hmiConnection:SendNotification("SDL.OnPolicyUpdate", {} )
		
		testCasesForPolicyTable.time_trigger = timestamp()

	    EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
	    :Do(function(_,data) 
	    	testCasesForPolicyTable.time_onstatusupdate = timestamp()
	    end)

	    testCasesForPolicyTable:create_PTS(true)
	      
	    local timeout_after_x_seconds = testCasesForPolicyTable:get_data_from_PTS("timeout_after_x_seconds")
	    local seconds_between_retry = testCasesForPolicyTable:get_data_from_PTS("seconds_between_retry")
	    EXPECT_HMICALL("BasicCommunication.PolicyUpdate", 
	        {
	          file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate", 
	          timeout = timeout_after_x_seconds, 
	          retry = seconds_between_retry 
	        })
	    :Do(function(_,data)
	    	testCasesForPolicyTable.time_policyupdate = timestamp()
	        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	    end)

    end
end

function testCasesForPolicyTable:trigger_PTU_getting_device_consent(app_name, device_ID)
	function Test:TestStep_trigger_PTU_getting_device_consent()
		testCasesForPolicyTable.time_trigger = 0
		testCasesForPolicyTable.time_onstatusupdate = 0
		testCasesForPolicyTable.time_policyupdate = 0
		local ServerAddress = commonSteps:get_data_form_SDL_ini("ServerAddress")
		    
		--hmi side: sending SDL.ActivateApp request
		local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[app_name]})
			      
		EXPECT_HMIRESPONSE(RequestId)
		:Do(function(_,data)
		      
		    EXPECT_HMICALL("SDL.OnSDLConsentNeeded", { device = { name = ServerAddress, id = device_ID, isSDLAllowed = false } })
		      
		    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
		    
		    --hmi side: expect SDL.GetUserFriendlyMessage message response
		    EXPECT_HMIRESPONSE( RequestId, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
		    :Do(function(_,data)   
		        testCasesForPolicyTable.time_trigger = timestamp()
		        
		        --hmi side: send request SDL.OnAllowSDLFunctionality
		        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
		          {allowed = true, source = "GUI", device = {id = device_ID, name = ServerAddress, isSDLAllowed = true}})
		       
		        EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", { status = "UPDATE_NEEDED" })
		        :Do(function(_,data) 
		          	testCasesForPolicyTable.time_onstatusupdate = timestamp()
		        end)

		        testCasesForPolicyTable:create_PTS(true)

		        local timeout_after_x_seconds = testCasesForPolicyTable:get_data_from_PTS("timeout_after_x_seconds")
		        local seconds_between_retry = testCasesForPolicyTable:get_data_from_PTS("seconds_between_retry")
		        EXPECT_HMICALL("BasicCommunication.PolicyUpdate", 
		        {
		            file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate", 
		            timeout = timeout_after_x_seconds,
		            retry = seconds_between_retry
		        })
		        :Do(function(_,data)
		          	testCasesForPolicyTable.time_policyupdate = timestamp()
		            self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		        end)
		    end)

		    --hmi side: expect BasicCommunication.ActivateApp request
		    EXPECT_HMICALL("BasicCommunication.ActivateApp")
		    :Do(function(_,data)
		      --hmi side: sending BasicCommunication.ActivateApp response
		      self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
		    end)
		    :Times(1)
		end)

		--mobile side: expect notification
		EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"}) 
	end
end

function testCasesForPolicyTable:trigger_PTU_user_press_button_HMI()
	function Test:TestStep_trigger_PTU_user_press_button_HMI()
		testCasesForPolicyTable.time_trigger = 0
		testCasesForPolicyTable.time_onstatusupdate = 0
		testCasesForPolicyTable.time_policyupdate = 0

		self.hmiConnection:SendNotification("SDL.UpdateSDL", {} )
		
		testCasesForPolicyTable.time_trigger = timestamp()

	    EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
	    :Do(function(_,data) 
	    	testCasesForPolicyTable.time_onstatusupdate = timestamp()
	    end)

	    testCasesForPolicyTable:create_PTS(true)
	      
	    local timeout_after_x_seconds = testCasesForPolicyTable:get_data_from_PTS("timeout_after_x_seconds")
	    local seconds_between_retry = testCasesForPolicyTable:get_data_from_PTS("seconds_between_retry")
	    EXPECT_HMICALL("BasicCommunication.PolicyUpdate", 
	        {
	          file = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate", 
	          timeout = timeout_after_x_seconds, 
	          retry = seconds_between_retry 
	        })
	    :Do(function(_,data)
	    	testCasesForPolicyTable.time_policyupdate = timestamp()
	        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	    end)

    end
end


return testCasesForPolicyTable