---------------------------------------------------------------------------------------------
-- CRQ: APPLINK-28163 [GENIVI] SDL must retrieve the value of 'menuIcon' and 'menuTitle' 
--                             parameters from .ini file
--
-- Requirement: APPLINK-20657: [ResetGlobalProperties] "MENUICON" reset 
-- Requirement: APPLINK-20656: [ResetGlobalProperties] "MENUNAME" reset 
-- Requirement: APPLINK-22706: [INI file] [ApplicationManager] MenuTitle 
-- Requirement: APPLINK-22707: [INI file] [ApplicationManager] MenuIcon
-- GOAL: Goal of the test is to verify that SDL correctly retrievs menuIcon and menuTitle 
--       from INI file in
--       case ResetGlobalProperties is sent with MENUICON and MENUNAME in Properties array.
--       SetGlobalProperties is sent as precondition.
--       menuIcon is used from INI file with relative path
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
----------------------------General Settings for configuration-------------------------------
---------------------------------------------------------------------------------------------
	config.deviceMAC      = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

	-----------------------------------------------------------------------------------------
	-- This function returns output in console as result of specific shell command.
	-- parameters:
	-- cmd - shell command
	-- raw - single raw of command
	-----------------------------------------------------------------------------------------
	function os.capture(cmd, raw)
  		local f = assert(io.popen(cmd, 'r'))
  		local s = assert(f:read('*a'))
		f:close()
		if raw then return s end
		s = string.gsub(s, '^%s+', '')
		s = string.gsub(s, '%s+$', '')
		s = string.gsub(s, '[\n\r]+', ' ')
		return s
	end

---------------------------------------------------------------------------------------------
---------------------------- Required Shared libraries --------------------------------------
---------------------------------------------------------------------------------------------
	local commonPreconditions     = require ('user_modules/shared_testcases/commonPreconditions')
	local commonSteps             = require ('user_modules/shared_testcases/commonSteps')
	local testCasesForPolicyTable = require ('user_modules/shared_testcases/testCasesForPolicyTable')

---------------------------------------------------------------------------------------------
------------------------------- Local Variables ---------------------------------------------
---------------------------------------------------------------------------------------------
	local strAppFolder  = config.pathToSDL .. "storage/" ..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"
	local SDLini        = config.pathToSDL .. tostring("smartDeviceLink.ini")
	local absolute_path = os.capture("pwd")
	local new_menuIcon  = "menuIcon = storage"
	local icon_to_check
	local title_to_check = "MENU"
	local SGP_path      = absolute_path .. "/SDL_bin/./".. "storage/" ..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"
	local SGP_path1    = absolute_path .. "/SDL_bin/".. "storage/" ..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"

---------------------------------------------------------------------------------------------
------------------------------- Local Functions ---------------------------------------------
---------------------------------------------------------------------------------------------
	
	-----------------------------------------------------------------------------------------
	-- This function update BASE-4 functional group with ResetGlobalProperties
	-- parameters: NO
	-----------------------------------------------------------------------------------------
	local function UpdatePolicy()
		local PermissionForResetGlobalProperties = 
													[[				
													"ResetGlobalProperties": {
														"hmi_levels": [
														"BACKGROUND",
														"FULL",
														"LIMITED"
														]
													}
													]].. ", \n"
		local PermissionLinesForBase4 = PermissionForResetGlobalProperties
		local PTName = testCasesForPolicyTable:createPolicyTableFile_temp(PermissionLinesForBase4, nil, nil, {"ResetGlobalProperties"})	
		testCasesForPolicyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt(PTName)
	end
	-----------------------------------------------------------------------------------------
	--This function update INI file according to specified parameter
	-- parameters: 
	-- type_path: absolute, relative, empty
	-----------------------------------------------------------------------------------------
	local function UpdateINI(type_path)
		if type_path == nil then type_path = "relative" end
		
		f = assert(io.open(SDLini, "r"))

	 	local fileContentUpdated = false
		local fileContent = f:read("*all")
		local menuIconContent = fileContent:match('menuIcon%s*=%s*[a-zA-Z%/0-9%_.]+[^\n]')
		local default_path
	 	
	 	-- Check menuIcon
		if not menuIconContent then
			--APPLINK-29383 => APPLINK-13145, comment from Stefan
			print ("\27[31m ERROR: menuIcon is not found in smartDeviceLink.ini \27[0m " )
		else	
			--for split_menuicon in string.gmatch(menuIconContent,"[^=]*") do
			for split_menuicon in string.gmatch(menuIconContent,"[^%s]+") do
				if( (split_menuicon ~= nil) and (#split_menuicon > 1) ) then
					default_path = split_menuicon
				end
			end
			icon_to_check = default_path
			absolute_path = absolute_path .."/SDL_bin/".. default_path
			--By default parameters in INI file are defined as relative values
			if (type_path == "absolute") then
				icon_to_check = absolute_path
				fileContentUpdated = string.gsub(fileContent, menuIconContent, tostring("menuIcon = " ..absolute_path) )
			end
		end

		-- Check menuTitle
		local menuTitleContent = fileContent:match('menuTitle%s*=%s*[a-zA-Z%/0-9%_.]+[^\n]')
		local default_title
	 	
		if not menuTitleContent then
			--APPLINK-29383 => APPLINK-13145, comment from Stefan
			print ("\27[31m ERROR: menuTitle is not found in smartDeviceLink.ini \27[0m " )
		else	
			--for split_menuicon in string.gmatch(menuTitleContent,"[^=]*") do
			for split_menuicon in string.gmatch(menuTitleContent,"[^%s]+") do
				if( (split_menuicon ~= nil) and (#split_menuicon > 1) ) then
					default_title = split_menuicon
				end
			end
		end

		if (default_title ~= "MENU") then
			print ("\27[31m ERROR: menuTitle is not equal to MENU in smartDeviceLink.ini \27[0m " )
			return false
		end

		if fileContentUpdated then
			f = assert(io.open(SDLini, "w"))
			f:write(fileContentUpdated)
		else 
			print ("\27[31m menuIcon can't be added to smartDeviceLink.ini \27[0m " )
		end
		f:close()
	end

---------------------------------------------------------------------------------------------
------------------------- General Precondition before ATF start -----------------------------
---------------------------------------------------------------------------------------------
	commonSteps:DeleteLogsFileAndPolicyTable()

	commonPreconditions:BackupFile("sdl_preloaded_pt.json")
	commonPreconditions:BackupFile("smartDeviceLink.ini")
	
	UpdatePolicy()
	UpdateINI("relative")

---------------------------------------------------------------------------------------------
---------------------------- General Settings for configuration----------------------------
---------------------------------------------------------------------------------------------
	Test = require('connecttest')
	require('cardinalities')
	local events = require('events')  
	local mobile_session = require('mobile_session')

---------------------------------------------------------------------------------------------
------------------------------------ Preconditions ------------------------------------------
---------------------------------------------------------------------------------------------
	commonSteps:ActivationApp(_, "Precondition_ActivateApp")	
	commonSteps:PutFile("Precondition_PutFile_action.png", "action.png")
	Test["Precondition_SetGlobalProperties_menuIcon_menuTitle"] = function(self)

		--mobile side: sending SetGlobalProperties request
		local cid = self.mobileSession:SendRPC("SetGlobalProperties",{	
																		menuIcon = { value = "action.png", imageType = "DYNAMIC" },
																		menuTitle = "Menu Title"
																	 })
					
		--hmi side: expect UI.SetGlobalProperties request
		EXPECT_HMICALL("UI.SetGlobalProperties", { 
													menuIcon = { imageType = "DYNAMIC"},--, value = SGP_path .. "action.png"},
													menuTitle = "Menu Title"
												})
		:Do(function(_,data)
			--hmi side: sending UI.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		:ValidIf(function(_,data)
			if(data.params.menuIcon.value ~= nil) then 
				if( (data.params.menuIcon.value == SGP_path .. "action.png") or (data.params.menuIcon.value == SGP_path1 .. "action.png") ) then
					return true
				else
					commonFunctions:printError("menuIcon.value is: " ..data.params.menuIcon.value ..". Expected: " .. SGP_path1 .. "action.png")
					return false	
				end
			else
				commonFunctions:printError("menuIcon.value has a nil value")
				return false
			end
		end)
		

		--hmi side: expect TTS.SetGlobalProperties request
		EXPECT_HMICALL("TTS.SetGlobalProperties",{})
		:Times(0)
				
		--mobile side: expect SetGlobalProperties response
		EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
			
		--mobile side: expect OnHashChange notification
		EXPECT_NOTIFICATION("OnHashChange")
		:Do(function(_, data)
						
			self.currentHashID = data.payload.hashID
		end)
	end

---------------------------------------------------------------------------------------------
------------------------------------------- Test --------------------------------------------
---------------------------------------------------------------------------------------------
	Test["TC16_menuIcon_relative_path_menuTitle_INI_PrecSGP"] = function(self)

		local cid = self.mobileSession:SendRPC("ResetGlobalProperties",{ properties = { 
																						"MENUICON",
																						"MENUNAME"
																						}})
			  			
		EXPECT_HMICALL("UI.SetGlobalProperties",{
													menuIcon = {
																	imageType = "DYNAMIC",
																	value = icon_to_check
																},
													menuTitle = title_to_check
												})
		:Do(function(_,data)
			--hmi side: sending UI.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)

		--hmi side: TTS.SetGlobalProperties request is not expected
		EXPECT_HMICALL("TTS.SetGlobalProperties",{})
		:Times(0)			

		--mobile side: expect ResetGlobalProperties response
		EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
					
		--mobile side: expect OnHashChange notification
		EXPECT_NOTIFICATION("OnHashChange")
		:Do(function(_, data)
			
			self.currentHashID = data.payload.hashID
		end)					
	end

---------------------------------------------------------------------------------------------
------------------------------------ Postconditions -----------------------------------------
---------------------------------------------------------------------------------------------
	function Test:Postcondition_RestoreConfigFile()
		commonPreconditions:RestoreFile("smartDeviceLink.ini")
		commonPreconditions:RestoreFile("sdl_preloaded_pt.json")
	end

	Test["ForceKill"] = function (self)
		print("-------------------- Postconditions -------------------------")
		os.execute("ps aux | grep smart | awk \'{print $2}\' | xargs kill -9")
		os.execute("sleep 1")
	end

return Test	