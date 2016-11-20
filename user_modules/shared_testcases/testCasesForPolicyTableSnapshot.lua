local testCasesForPolicyTableSnapshot = {}
local mobile_session = require('mobile_session')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')

testCasesForPolicyTableSnapshot.preloaded_elements = {}
testCasesForPolicyTableSnapshot.pts_elements = {}
testCasesForPolicyTableSnapshot.seconds_between_retries = {}
testCasesForPolicyTableSnapshot.preloaded_pt = {}

-- --local data_dictionary = {}

local json_elements = {}

local function extract_json(pathToFile)
	json_elements = {}
	if( commonSteps:file_exists(pathToFile) ) then
	
		local file  = io.open(pathToFile, "r")
		local json_data = file:read("*all") 
		file:close()

		local json = require("modules/json")
		local data = json.decode(json_data)
		local i = 1

		for index_level1, value_level1 in pairs(data.policy_table) do
			if(type(value_level1) ~= "table") then
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

function testCasesForPolicyTableSnapshot:extract_preloaded_pt()
	testCasesForPolicyTableSnapshot.preloaded_elements = {}
	testCasesForPolicyTableSnapshot.seconds_between_retries = {}
	local preloaded_pt = 'SDL_bin/sdl_preloaded_pt.json'	
	extract_json(preloaded_pt)
	local k = 1
	for i = 1, #json_elements do
		testCasesForPolicyTableSnapshot.preloaded_elements[i] = { name = json_elements[i].name, value = json_elements[i].value }
		if( string.sub(json_elements[i].name,1,string.len("module_config.seconds_between_retries.")) == "module_config.seconds_between_retries." ) then
			testCasesForPolicyTableSnapshot.seconds_between_retries[k] = { name = json_elements[i].name, value = json_elements[i].value}
			k = k + 1
		end
	end
end
local preloaded_pt_endpoints = {}

function testCasesForPolicyTableSnapshot:create_PTS(is_created, app_IDs, device_IDs, app_names)
	preloaded_pt_endpoints = {}
	local data_dictionary = {}
	--local data_dictionary = {}
	-- Data dictionary according to which PTS should be created. Will be automated export from xls.
	local origin_data_dictionary = 
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
		{ name = "app_policies.default.AppHMIType", elem_required = "optional"},
		{ name = "app_policies.default.memory_kb", elem_required = "optional"},
		{ name = "app_policies.default.heart_beat_timeout_ms", elem_required = "optional"},
		{ name = "app_policies.default.RequestType", elem_required = "optional"},
		{ name = "app_policies.pre_DataConsent.priority", elem_required = "required"},
		{ name = "app_policies.pre_DataConsent.AppHMIType", elem_required = "optional"},
		{ name = "app_policies.pre_DataConsent.memory_kb", elem_required = "optional"},
		{ name = "app_policies.pre_DataConsent.heart_beat_timeout_ms", elem_required = "optional"},
		{ name = "app_policies.pre_DataConsent.RequestType", elem_required = "optional"},
		{ name = "app_policies.device.priority", elem_required = "required"},

	}
	data_dictionary = origin_data_dictionary
	
	testCasesForPolicyTableSnapshot.preloaded_elements = {}
	testCasesForPolicyTableSnapshot.pts_elements = {}
	testCasesForPolicyTableSnapshot.seconds_between_retries = {}
	testCasesForPolicyTableSnapshot.preloaded_pt = {}

	if(is_created == false) then
		if ( commonSteps:file_exists( '/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json') ) then
			print(" \27[31m /tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json is created \27[0m")	
		end
	else
		testCasesForPolicyTableSnapshot:extract_preloaded_pt()

		local k = 1
		
		for i = 1, #json_elements do
			local length = #preloaded_pt_endpoints
			if( string.sub(json_elements[i].name,1,string.len("module_config.endpoints.")) == "module_config.endpoints." ) then
				local substr = {}
				local j = 1
				for each_element in string.gmatch(json_elements[i].name,"[^.]*") do
					substr[j] = each_element
					j = j+1
				end
				preloaded_pt_endpoints[length + 1] = substr[5]
			end
		end
		for i = 1, #preloaded_pt_endpoints do
		   testCasesForPolicyTableSnapshot.preloaded_pt[i] = preloaded_pt_endpoints[i]
		end

		for i = 1, #json_elements do
			local length_data_dict = #data_dictionary
			local str_1 = json_elements[i].name
			if( string.sub(str_1,1,string.len("functional_groupings.")) == "functional_groupings." ) then
				data_dictionary[length_data_dict + 1] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }

			end
			
			if( string.sub(str_1,1,string.len("app_policies.default.groups.")) == "app_policies.default.groups." ) then
				data_dictionary[length_data_dict + 1] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }
			end

			if( string.sub(str_1,1,string.len("app_policies.pre_DataConsent.groups.")) == "app_policies.pre_DataConsent.groups." ) then
				data_dictionary[length_data_dict + 1] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }
			end

			if( string.sub(str_1,1,string.len("module_config.seconds_between_retries.")) == "module_config.seconds_between_retries." ) then
				testCasesForPolicyTableSnapshot.seconds_between_retries[k] = { name = json_elements[i].name, value = json_elements[i].value}
				k = k + 1
				data_dictionary[length_data_dict + 1] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }

			end
			
			for cnt = 1, #preloaded_pt_endpoints do
				length_data_dict = #data_dictionary
				if( string.sub(str_1,1,string.len("module_config.endpoints."..preloaded_pt_endpoints[cnt]..".default.")) == "module_config.endpoints."..preloaded_pt_endpoints[cnt]..".default." ) then
					local element_default = "module_config.endpoints."..preloaded_pt_endpoints[cnt]..".default."
					data_dictionary[length_data_dict + 1] = { name = json_elements[i].name, value = json_elements[i].value, elem_required = "required" }
					data_dictionary[length_data_dict + 2] = { name = element_default.."priority", value = json_elements[i].value, elem_required = "required" }
					data_dictionary[length_data_dict + 3] = { name = element_default.."groups", value = json_elements[i].value, elem_required = "required" }
					data_dictionary[length_data_dict + 4] = { name = element_default.."AppHMIType", value = json_elements[i].value, elem_required = "optional" }
					data_dictionary[length_data_dict + 5] = { name = element_default.."memory_kb", value = json_elements[i].value, elem_required = "optional" }
					data_dictionary[length_data_dict + 6] = { name = element_default.."heart_beat_timeout_ms", value = json_elements[i].value, elem_required = "optional" }
					data_dictionary[length_data_dict + 7] = { name = element_default.."RequestType", value = json_elements[i].value, elem_required = "optional" }

				end
			end
		end	--for i = 1, #json_elements do

		if(app_IDs ~= nil) then
			for i = 1, #app_IDs do
				--app_policies.0000001

				data_dictionary[#data_dictionary + 1] = { name = "usage_and_error_counts.app_level."..tostring(app_IDs[i])..".count_of_tls_errors", value = nil, elem_required = "required" }
				data_dictionary[#data_dictionary + 1] = { name = "usage_and_error_counts.app_level."..tostring(app_IDs[i])..".nicknames", value = nil, elem_required = "required" }
				data_dictionary[#data_dictionary + 1] = { name = "usage_and_error_counts.app_level."..tostring(app_IDs[i])..".priority", value = nil, elem_required = "required" }
				--TODO(istoimenova): should be updated in future, due to luck of time
				--data_dictionary[#data_dictionary + 1 + 11] = { name = "usage_and_error_counts.app_level."..tostring(app_IDs[i])..".groups", value = nil, elem_required = "required" }
				data_dictionary[#data_dictionary + 1] = { name = "usage_and_error_counts.app_level."..tostring(app_IDs[i])..".AppHMIType", value = nil, elem_required = "optional" }
				data_dictionary[#data_dictionary + 1] = { name = "usage_and_error_counts.app_level."..tostring(app_IDs[i])..".memory_kb", value = nil, elem_required = "optional" }
				data_dictionary[#data_dictionary + 1] = { name = "usage_and_error_counts.app_level."..tostring(app_IDs[i])..".heart_beat_timeout_ms", value = nil, elem_required = "optional" }
				data_dictionary[#data_dictionary + 1] = { name = "usage_and_error_counts.app_level."..tostring(app_IDs[i])..".RequestType", value = nil, elem_required = "optional" }
				
				--TODO(istoimenova): should be updated in future, due to luck of time
				data_dictionary[#data_dictionary + 1] = { name = "app_policies."..tostring(app_IDs[i]), value = nil, elem_required = "optional" }
				data_dictionary[#data_dictionary + 1] = { name = "app_policies."..tostring(app_IDs[i])..".count_of_tls_errors", value = nil, elem_required = "required" }
				data_dictionary[#data_dictionary + 1] = { name = "app_policies."..tostring(app_IDs[i])..".nicknames", value = nil, elem_required = "required" }
				data_dictionary[#data_dictionary + 1] = { name = "app_policies."..tostring(app_IDs[i])..".priority", value = nil, elem_required = "required" }
				--TODO(istoimenova): should be updated in future, due to luck of time
				--data_dictionary[#data_dictionary + 1 + 19] = { name = "app_policies."..tostring(app_IDs[i])..".groups", value = nil, elem_required = "required" }
				data_dictionary[#data_dictionary + 1] = { name = "app_policies."..tostring(app_IDs[i])..".AppHMIType", value = nil, elem_required = "optional" }
				data_dictionary[#data_dictionary + 1] = { name = "app_policies."..tostring(app_IDs[i])..".memory_kb", value = nil, elem_required = "optional" }
				data_dictionary[#data_dictionary + 1] = { name = "app_policies."..tostring(app_IDs[i])..".heart_beat_timeout_ms", value = nil, elem_required = "optional" }
				data_dictionary[#data_dictionary + 1] = { name = "app_policies."..tostring(app_IDs[i])..".RequestType", value = nil, elem_required = "optional" }
				data_dictionary[#data_dictionary + 1] = { name = "app_policies."..tostring(app_IDs[i]), value = nil, elem_required = "optional" }
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

		local pts = '/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json'
		if ( commonSteps:file_exists(pts) ) then
			testCasesForPolicyTableSnapshot:extract_pts(app_names)
		else
			print("/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json doesn't exits! ")
		end
		
		--Check for ommited parameters
		for i = 1, #testCasesForPolicyTableSnapshot.pts_elements do
			local str_1 = testCasesForPolicyTableSnapshot.pts_elements[i].name
			local is_existing = false
			for j = 1, #data_dictionary do
				local str_2 = data_dictionary[j].name
				if( str_1 == str_2 ) then
					is_existing = true
					for k = 1, #testCasesForPolicyTableSnapshot.preloaded_elements do
						if(testCasesForPolicyTableSnapshot.preloaded_elements[k].name == str_2) then
							if(testCasesForPolicyTableSnapshot.pts_elements[i].value ~= testCasesForPolicyTableSnapshot.preloaded_elements[k].value) then
								print(testCasesForPolicyTableSnapshot.pts_elements[i].name .." = " .. tostring(testCasesForPolicyTableSnapshot.pts_elements[i].value) .. ". Should be " ..tostring(testCasesForPolicyTableSnapshot.preloaded_elements[k].value) )
							end
						end
					end
					break
				end
			end
			if (is_existing == false) then
				print(testCasesForPolicyTableSnapshot.pts_elements[i].name .. ": should NOT exist")
			end
		end

		--Check for mandatory elements
		for i = 1, #data_dictionary do
			if(data_dictionary[i].elem_required == "required") then
				local str_2 = data_dictionary[i].name
				local is_existing = false
				for j = 1, #testCasesForPolicyTableSnapshot.pts_elements do
					local str_1 = testCasesForPolicyTableSnapshot.pts_elements[j].name
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


testCasesForPolicyTableSnapshot.pts_endpoints = {}
testCasesForPolicyTableSnapshot.pts_endpoints_apps = {}
testCasesForPolicyTableSnapshot.pts_seconds_between_retries = {}

function testCasesForPolicyTableSnapshot:extract_pts(appID)
	testCasesForPolicyTableSnapshot.pts_endpoints = {}
	testCasesForPolicyTableSnapshot.pts_endpoints_apps = {}
	testCasesForPolicyTableSnapshot.pts_seconds_between_retries = {}
	local pts_json = '/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json'	
	extract_json(pts_json)
	local length_pts

	for i = 1, #json_elements do
		length_pts = #testCasesForPolicyTableSnapshot.pts_elements
		testCasesForPolicyTableSnapshot.pts_elements[length_pts + 1] = {
			name = json_elements[i].name, 
			value = json_elements[i].value
		}
	end

	local length_seconds_between_retries
	local length_service_endpoints
	local length_app_endpoints
	local is_app_endpoints_found = {}
	for i = 1, #appID do
		is_app_endpoints_found[i] = false
	end

	for i = 1, #json_elements do
		length_seconds_between_retries = #testCasesForPolicyTableSnapshot.pts_seconds_between_retries
		length_service_endpoints = #testCasesForPolicyTableSnapshot.pts_endpoints
		--length_app_endpoints = #testCasesForPolicyTableSnapshot.pts_endpoints_apps
		testCasesForPolicyTableSnapshot.pts_elements[i] = { name = json_elements[i].name, value = json_elements[i].value }

		if( string.sub(json_elements[i].name,1,string.len("module_config.seconds_between_retries.")) == "module_config.seconds_between_retries." ) then
			testCasesForPolicyTableSnapshot.pts_seconds_between_retries[length_seconds_between_retries + 1] = { name = json_elements[i].name, value = json_elements[i].value}
		end
		for j = 1, #preloaded_pt_endpoints do		
			if( string.sub(json_elements[i].name,1,string.len("module_config.endpoints."..tostring(preloaded_pt_endpoints[j])..".default.")) == "module_config.endpoints."..tostring(preloaded_pt_endpoints[j])..".default." ) then
				testCasesForPolicyTableSnapshot.pts_endpoints[length_service_endpoints + 1] = { name = json_elements[i].name, value = json_elements[i].value, service = preloaded_pt_endpoints[j]}
			end

			--hmi appid
			for j = 1, #appID do
				if(preloaded_pt_endpoints[j] == "0x07") then
					if( string.sub(json_elements[i].name,1,string.len("module_config.endpoints.0x07.".. appID[j] .. ".")) == "module_config.endpoints.0x07.".. appID[j] .. "." ) then
						length_service_endpoints = #testCasesForPolicyTableSnapshot.pts_endpoints
						testCasesForPolicyTableSnapshot.pts_endpoints[length_service_endpoints + 1] = { name = json_elements[i].name, value = json_elements[i].value, app_id = appID[j], service = "app1" }
						--print("appID: " ..testCasesForPolicyTableSnapshot.pts_endpoints_apps[length_app_endpoints + 1].value)
						is_app_endpoints_found[i] = true
					end
				end
			end
		end

		
	end

	-- Check for section apps endpoint exist
	for i = 1, #appID do
		if (is_app_endpoints_found[i] == false ) then
			print(" \27[31m module_config.endpoints.0x07.".. appID[i] .. " doesn't exist!\27[0m")	
		end
	end
end

function testCasesForPolicyTableSnapshot:get_data_from_PTS(pts_element)
	local value
	local is_found = false
	for i = 1, #testCasesForPolicyTableSnapshot.pts_elements do
		if (pts_element == testCasesForPolicyTableSnapshot.pts_elements[i].name) then
			value = testCasesForPolicyTableSnapshot.pts_elements[i].value
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


return testCasesForPolicyTableSnapshot