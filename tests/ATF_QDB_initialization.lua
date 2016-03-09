-- Script is developed by Byanova Irina
-- for ATF version 2.2

Test = require('user_modules/connecttest_QDB_initialization')
require('cardinalities')
require('user_modules/AppTypes')

----------------------------------------------------------------------------
-- User required files

require('user_modules/AppTypes')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')

function DelayedExp(time)
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  :Timeout(time+1000)
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, time)
end

-- Check direcrory existence 
local function Directory_exist(DirectoryPath)
	local returnValue

	local Command = assert( io.popen(  "[ -d " .. tostring(DirectoryPath) .. " ] && echo \"Exist\" || echo \"NotExist\"" , 'r'))
	local CommandResult = tostring(Command:read( '*l' ))

	if 
		CommandResult == "NotExist" then
			returnValue = false
	elseif 
		CommandResult == "Exist" then
		returnValue =  true
	else 
		commonFunctions:userPrint(31," Some unexpected result in Directory_exist function, CommandResult = " .. tostring(CommandResult))
		returnValue = false
	end

	return returnValue
end

local function SetNewValuesInIniFile(self, paramName, value)

	local SDLini = config.pathToSDL .. tostring("smartDeviceLink.ini")
	f = assert(io.open(SDLini, "r"))
	if f then
		fileContent = f:read("*all")

		fileContentUpdated  =  string.gsub(fileContent, "%p?" .. tostring(paramName) .. "%s-=%s?[%d;]-\n", "" .. tostring(paramName) .. " = " .. tostring(value) .. "\n")

		if fileContentUpdated then
			f = assert(io.open(SDLini, "w"))
			f:write(fileContentUpdated)
		else 
			commonFunctions:userPrint(31, "Finding of 'ApplicationResumingTimeout = value' is failed. Expect string finding and replacing of value to true")
		end
		f:close()
	else
		commonFunctions:userPrint(31, "File smartDeviceLink.ini is not opened.")
	end
end

----------------------------------------------------------------------------
--======================================================================================--
-- SDL shuts down after 5 attemps to open PT with interval 500 ms in case SDL can not open PT
--======================================================================================--

function Test:Precondition_StopSDL()
	StopSDL()
end

function Test:Precondition_RemovePermissionsFromPT()

	local RemovePermissionsFromPT = assert(os.execute("chmod 000  " .. tostring(config.pathToSDL) .. "/storage/policy.sqlite"))

	if not RemovePermissionsFromPT then
		self:FailTestCase(" Command of removing permissions for policy.sqlite is not success")
	end

end

function Test:Precondition_StartSDL()
		StartSDL(config.pathToSDL, false)
end

function Test:SDL_shuts_down_after_5Attemps_toOpenPT()
	commonFunctions:userPrint(33, " Check SDL log. Must contain 5 atteps of connection to PT with the interval of 500ms between retries ")
	commonFunctions:userPrint(33, " Expected result of test case is 'FAIL' because SDL is shuted down ")

	os.execute(" sleep 2 ")

	local GetPIDsmartDeviceLinkCore = assert(io.popen("pidof smartDeviceLinkCore"))

	local Result = GetPIDsmartDeviceLinkCore:read( '*l' )
	if 
		Result and
		Result ~= "" then
		self:FailTestCase(" smartDeviceLinkCore process is not stopped ")
	end 
end

--======================================================================================--
-- SDL continues work in case opens PT after some unsuccessful attempts
--======================================================================================--

function Test:Precondition_SetOpenAttemptTimeoutMs_1500() 
	SetNewValuesInIniFile(self, "OpenAttemptTimeoutMs", "1500") 
end

function Test:StartSDL_GivePermissionsToPTAfterSDLStart()
	StartSDL(config.pathToSDL, false)

	local RemovePermissionsFromPT = assert(os.execute("chmod 600  " .. tostring(config.pathToSDL) .. "/storage/policy.sqlite"))
	os.execute("date")
	commonFunctions:userPrint(33, " Check the printed time of command execution and time of attemps to open PT. Time of command execution must be between attemps. ")


	if not RemovePermissionsFromPT then
		self:FailTestCase(" Command of adding permissions for policy.sqlite is not success")
	end

end

function Test:CheckProcess_smartDeviceLinkCore_StilLive_GivePermissionsToPTAfterSDLStart()
	function GetPID()
		local GetPIDsmartDeviceLinkCore = assert(io.popen("pidof smartDeviceLinkCore"))

		local Result = tostring(GetPIDsmartDeviceLinkCore:read( '*l' ))
		if 
			Result and
			Result == "" then
			self:FailTestCase(" smartDeviceLinkCore process is stopped ")
		end 
	end

	RUN_AFTER(GetPID, 10000)

	DelayedExp(12000)

end

--======================================================================================--
-- SDL applies custom values of AttemptsToOpenPolicyDB, OpenAttemptTimeoutMs from .ini file
--======================================================================================--

function Test:Precondition_StopSDL_CustomValuesOf_AttemptsToOpenPolicyDBTo10_OpenAttemptTimeoutMsTo1500()
	StopSDL()
end

function Test:RemovePermissionsFromPT_SetAttemptsToOpenPolicyDBTo10_OpenAttemptTimeoutMs1500()

	local RemovePermissionsFromPT = assert(os.execute("chmod 000  " .. tostring(config.pathToSDL) .. "/storage/policy.sqlite"))

	if not RemovePermissionsFromPT then
		self:FailTestCase(" Command of removing permissions for policy.sqlite is not success")
	end

	SetNewValuesInIniFile(self, "AttemptsToOpenPolicyDB", "10") 
	SetNewValuesInIniFile(self, "OpenAttemptTimeoutMs", "1500") 
end

function Test:Precondition_StartSDL_CustomValuesOf_AttemptsToOpenPolicyDBTo10_OpenAttemptTimeoutMs()
		StartSDL(config.pathToSDL, false)
end

function Test:SDL_shuts_down_after_10AttempsWithInterval1500_toOpenPT()
	commonFunctions:userPrint(33, " Check SDL log. Must contain 10 atteps of connection to PT with the interval of 1500ms between retries ")
	commonFunctions:userPrint(33, " Expected result of test case is 'FAIL' because SDL is shuted down ")

	os.execute(" sleep 15 ")

	local GetPIDsmartDeviceLinkCore = assert(io.popen("pidof smartDeviceLinkCore"))

	local Result = GetPIDsmartDeviceLinkCore:read( '*l' )
	if 
		Result and
		Result ~= "" then
		self:FailTestCase(" smartDeviceLinkCore process is not stopped ")
	end 
end

--======================================================================================--
-- SDL applies default values for AttemptsToOpenPolicyDB, OpenAttemptTimeoutMs in case .ini file values are empty
--======================================================================================--

function Test:Precondition_StopSDL_DefaultValuesOf_AttemptsToOpenPolicyDBTo10_OpenAttemptTimeoutMs()
	local GetPIDsmartDeviceLinkCore = assert(io.popen("pidof smartDeviceLinkCore"))

	local Result = GetPIDsmartDeviceLinkCore:read( '*l' )
	if 
		Result and
		Result ~= "" then
			StopSDL()
	end 

end

function Test:RemovePermissionsFromPT_SetEmptyValuesToAttemptsToOpenPolicyDBTo_OpenAttemptTimeoutMs()

	local RemovePermissionsFromPT = assert(os.execute("chmod 000  " .. tostring(config.pathToSDL) .. "/storage/policy.sqlite"))

	if not RemovePermissionsFromPT then
		self:FailTestCase(" Command of removing permissions for policy.sqlite is not success")
	end

	SetNewValuesInIniFile(self, "AttemptsToOpenPolicyDB", "") 
	SetNewValuesInIniFile(self, "OpenAttemptTimeoutMs", "") 
end

function Test:Precondition_StartSDL_DefaultValuesOf_AttemptsToOpenPolicyDB_5_OpenAttemptTimeoutMs_500()
		StartSDL(config.pathToSDL, false)
end

function Test:SDL_shuts_down_after_5AttempsWithInterval500_toOpenPT_DefaultValues()
	commonFunctions:userPrint(33, " Check SDL log. Must contain 5 atteps of connection to PT with the interval of 500ms between retries ")
	commonFunctions:userPrint(33, " Expected result of test case is 'FAIL' because SDL is shuted down ")

	os.execute(" sleep 15 ")

	local GetPIDsmartDeviceLinkCore = assert(io.popen("pidof smartDeviceLinkCore"))

	local Result = GetPIDsmartDeviceLinkCore:read( '*l' )
	if 
		Result and
		Result ~= "" then
		self:FailTestCase(" smartDeviceLinkCore process is not stopped ")
	end 
end

--======================================================================================--
-- Postcondition: Set defaut values of SetAttemptsToOpenPolicyDB and OpenAttemptTimeoutMs, remove Storage folder
--======================================================================================--

function Test:PostCondition_SetAttemptsToOpenPolicyDB_OpenAttemptTimeoutMs_ToDefaultValues_DeleteStorageFolder()
	SetNewValuesInIniFile(self, "OpenAttemptTimeoutMs", "500") 
	SetNewValuesInIniFile(self, "AttemptsToOpenPolicyDB", "5") 

	local ExistDirectoryResult = Directory_exist( tostring(config.pathToSDL .. "storage"))
	if ExistDirectoryResult == true then
		local RmFolder  = assert( os.execute( "rm -rf " .. tostring(config.pathToSDL .. "storage" )))
		if RmFolder ~= true then
			userPrint(31, "Folder 'storage' is not deleted")
		end
	else
		userPrint(33, "Folder 'storage' is absent")
	end

end




