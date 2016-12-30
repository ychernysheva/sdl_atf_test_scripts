-- This script contains common functions to run REVSDL scripts

local revsdl_module = {}

--! @brief Adds to function_id.lua RPCs that are unknown for SDL but known to CANCooperation plugin
function revsdl_module.AddUnknownFunctionIDs()
	
	-- check if file was backed-up before; backup if was not
	local command_to_execute = "ls -l ./backup_atf_files/ | grep function_id.lua | wc -l"
	local execute = assert( io.popen(command_to_execute, 'r'))
	local result = tostring(execute:read( '*l' ))
	if result == "0" then -- if no back-up file
		command_to_execute = "mkdir backup_atf_files; cp ./modules/function_id.lua ./backup_atf_files/"
		os.execute(command_to_execute)
		
		-- read file
		command_to_execute = "./modules/function_id.lua"
		f = assert(io.open(command_to_execute, "r"))
		fileContent = f:read("*all")
		f:close()

		-- strings that should be add in function_id.lua
		local pattern = "return module.mobile_functions"
		local button_press_id = "module.mobile_functions[\"ButtonPress\"] = 100015"
		local get_interior_data_id = "module.mobile_functions[\"GetInteriorVehicleData\"] = 100017"
		local get_interior_capabilities_id = "module.mobile_functions[\"GetInteriorVehicleDataCapabilities\"] = 100016"
		local set_interior_data_id = "module.mobile_functions[\"SetInteriorVehicleData\"] = 100018"
		local on_interior_vehicle_data_id = "module.mobile_functions[\"OnInteriorVehicleData\"] = 100019"
		local replace = button_press_id .. "\n" .. 
						get_interior_data_id .. "\n" .. 
						get_interior_capabilities_id .. "\n" .. 
						set_interior_data_id .. "\n" .. 
						on_interior_vehicle_data_id .. "\n" ..
						pattern

		-- add unknown to SDL function IDs
		fileContent  =  string.gsub(fileContent, pattern, replace)
		f = assert(io.open(command_to_execute, "w+"))
		f:write(fileContent)
		f:close()
	end
end

--! @brief customizes InitHMI function in connecttest.lua to register RC interface
function revsdl_module.SubscribeToRcInterface()
	
	-- check if file was back-up before, backup if not
	local command_to_execute = "ls -l ./backup_atf_files/ | grep connecttest.lua | wc -l"
	local execute = assert( io.popen(command_to_execute, 'r'))
	local result = tostring(execute:read( '*l' ))
	if result == "0" then
		command_to_execute = "mkdir backup_atf_files; cp ./modules/connecttest.lua ./backup_atf_files/"
		os.execute(command_to_execute)
		-- read file
		command_to_execute = "./modules/connecttest.lua"
		f = assert(io.open(command_to_execute, "r"))

		fileContent = f:read("*all")
		f:close()

		local pattern = "registerComponent..VehicleInfo..\n"
		local to_add = "registerComponent(\"RC\")\n"
		local replace = "registerComponent(\"VehicleInfo\")\n\t\t\t" .. to_add
		fileContent  =  string.gsub(fileContent, pattern, replace)

		f = assert(io.open(command_to_execute, "w+"))
		f:write(fileContent)
		f:close()
	end
end

return revsdl_module