--ATF version: 2.2

Test = require('user_modules/connecttest_UpdateSDL')
require('cardinalities')
local mobile_session = require('mobile_session')

----------------------------------------------------------------------------
-- User required files
require('user_modules/AppTypes')
local policy = require('user_modules/shared_testcases/testCasesForPolicyTable')

----------------------------------------------------------------------------
-- User functions

-- time to wait after execution all expectations in test case
function DelayedExp(time)
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  	:Timeout(time+1000)
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, time)
end

-- print wit set collor and string to print
local function userPrint( color, message)
  print ("\27[" .. tostring(color) .. "m " .. tostring(message) .. " \27[0m")
end

-- Check directory existence 
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
		userPrint(31," Some unexpected result in Directory_exist function, CommandResult = " .. tostring(CommandResult))
		returnValue = false
	end

	return returnValue
end

-- Restart SDL
local function RestartSDL(prefix, DeleteStorage )

	Test["StopSDL_" .. tostring(prefix)] = function(self)
	  StopSDL()
	end

	if DeleteStorage then
		Test["DeleteStorageFolder_" .. tostring(prefix)] = function(self)
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
	end

	Test["StartSDL_" .. tostring(prefix)] = function(self)
	  StartSDL(config.pathToSDL, config.ExitOnCrash)
	end

	Test["InitHMI_" .. tostring(prefix)] = function(self)
	  self:initHMI()
	end

	Test["InitHMI_onReady_" .. tostring(prefix)] = function(self)
	  self:initHMI_onReady()
	end

	Test["ConnectMobile_" .. tostring(prefix)] = function(self)
	  self:connectMobile()
	end
end

-- Create session
local function CreateSession( self)
	self.mobileSession = mobile_session.MobileSession(
        self,
        self.mobileConnection)

	self.mobileSession:StartService(7)
end

-- App registration
local function RegisterApp(self, RegisterData)

  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", RegisterData)

  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
    :Do(function(_,data)
     self.HMIAppID = data.params.application.appID
    end)

  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })


  self.mobileSession:ExpectNotification("OnHMIStatus", 
    {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
end

-- Policy update
local function UpdatePolicy(self, PTName)
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
				requestType = "PROPRIETARY"
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
			EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{line1 = "Up-To-Date", messageCode = "StatusUpToDate", textBody = "Up-To-Date"}}}})
		end)
		
	end)
end

-- TODO: uncomment after resolving ATF defect APPLINK-19192
--======================================================================================--
-- Restart SDl with removing storage folder
-- RestartSDL('GeneralSetting', true )

--======================================================================================--
-- creation session
function Test:CreateSession()
	CreateSession( self)
end

--======================================================================================--
-- App registration
function Test:RegisterApp()

	RegisterApp(self, config.application1.registerAppInterfaceParams)

	EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})

  	DelayedExp(2000)
end

--======================================================================================--
-- Consent device
function Test:ConsentDevice()
	--hmi side: sending SDL.GetUserFriendlyMessage request
	local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
						{language = "EN-US", messageCodes = {"DataConsent"}})

	--hmi side: expect SDL.GetUserFriendlyMessage response
	--TODO: Update after resolving APPLINK-16094 EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
	EXPECT_HMIRESPONSE(RequestId)
		:Do(function(_,data)

			--hmi side: send request SDL.OnAllowSDLFunctionality
			self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
				{allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
		end)
end

--======================================================================================--
--Check update status after registration
function Test:GetStatus_UpdateNeeded_AfterRegistration()
	userPrint(34, "=================== Test Case ===================")
	--hmi side: sending SDL.GetStatusUpdate request
	local RequestIdUpdateSDL = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")

	--hmi side: expect SDL.GetStatusUpdate response from HMI
	EXPECT_HMIRESPONSE(RequestIdUpdateSDL,{result = {code = 0, method = "SDL.GetStatusUpdate", status = "UPDATE_NEEDED" }})
end

--======================================================================================--
-- Update policy after receiving OnStatusUpdate ("UPDATE_NEEDED")
policy:updatePolicy('files/PTU_UpdateNeeded.json')

--======================================================================================--
-- Update status after policy update
function Test:GetStatus_UpToDate_AfterUpdate()
	--hmi side: sending SDL.GetStatusUpdate request
	local RequestIdUpdateSDL = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")

--hmi side: expect SDL.GetStatusUpdate response from HMI
	EXPECT_HMIRESPONSE(RequestIdUpdateSDL,{result = {code = 0, method = "SDL.GetStatusUpdate", status = "UP_TO_DATE" }})
end

-- APPLINK-18277: 05[P][MAN]_TC_User_requests_update_via_HMI
--======================================================================================--
-- Changing update status to "UPDATE_NEEDED" after receiving SDL.UpdateSDL request
--======================================================================================--
function Test:Status_UpdateNeeded_AfterReceiving_UpfateSDL_CurrentStatusUpToDate()
	userPrint(34, "=================== Test Case ===================")

	--hmi side: sending SDL.UpdateSDL request
	local RequestIdUpdateSDL = self.hmiConnection:SendRequest("SDL.UpdateSDL")

	EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
	
	--hmi side: expect SDL.UpdateSDL response from HMI
	EXPECT_HMIRESPONSE(RequestIdUpdateSDL,{result = {code = 0, method = "SDL.UpdateSDL", result = "UPDATE_NEEDED" }})
		:Do(function()
			UpdatePolicy(self, 'files/PTU_UpdateNeeded.json')
		end)

	DelayedExp(2000)

end

--======================================================================================--
--Get status update after policy update
function Test:GetStatus_UpdateNeeded_AfterUpdateSDL()
	userPrint(34, "=================== Test Case ===================")
	--hmi side: sending SDL.GetStatusUpdate request
	local RequestIdUpdateSDL = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")

--hmi side: expect SDL.GetStatusUpdate response from HMI
	EXPECT_HMIRESPONSE(RequestIdUpdateSDL,{result = {code = 0, method = "SDL.GetStatusUpdate", status = "UP_TO_DATE" }})
end

--======================================================================================--
-- Absence of OnStatusUpdate from SDL after receiving SDL.UpdateSDL request
--======================================================================================--
function Test:StatusUpdateNeeded_AfterReceiving_UpfateSDL_AbsenceOnStatusUpdate()
	userPrint(34, "=================== Test Case ===================")

	--hmi side: sending SDL.UpdateSDL request
	local RequestIdUpdateSDL = self.hmiConnection:SendRequest("SDL.UpdateSDL")

	EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
	
	--hmi side: expect SDL.UpdateSDL response from HMI
	EXPECT_HMIRESPONSE(RequestIdUpdateSDL,{result = {code = 0, method = "SDL.UpdateSDL", result = "UPDATE_NEEDED" }})

	EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
		:Times(0)

	DelayedExp(2000)

end

--======================================================================================--
-- Get status update
function Test:GetStatus_UpdateNeeded_AfterUpdateSDL2()
	userPrint(34, "=================== Test Case ===================")

	--hmi side: sending SDL.GetStatusUpdate request
	local RequestIdUpdateSDL = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")

--hmi side: expect SDL.GetStatusUpdate response from HMI
	EXPECT_HMIRESPONSE(RequestIdUpdateSDL,{result = {code = 0, method = "SDL.GetStatusUpdate", status = "UPDATE_NEEDED" }})
end


--======================================================================================--
--Precondition for test cases below
--======================================================================================--
function Test:Precondition_PolicyUpdate_ToSet_ModuleConfigValues()
	UpdatePolicy(self, 'files/PTU_UpdateNeeded.json')
end

-- APPLINK-18274: 02[P][MAN]_TC_Update_starts_when_reached_exchange_after_x_ignition_cycles
--======================================================================================--
-- Policy table update sequence starts when ignition cycles parameter reached listed in local policy table in "Module_config"\"exchange_after_x_ignition_cycles".
--======================================================================================--

--Get status update, in case status is not Up_To_Date perform update
function Test:Precondition_GetStatus_InSecondIGNCycle()
	--hmi side: sending SDL.GetStatusUpdate request
	local RequestIdUpdateSDL = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")

	--hmi side: expect SDL.GetStatusUpdate response from HMI
	EXPECT_HMIRESPONSE(RequestIdUpdateSDL,{result = {code = 0, method = "SDL.GetStatusUpdate", status = "UP_TO_DATE" }})
		:Do(function(_,data)
			if data.result.status ~= "UP_TO_DATE" then
				UpdatePolicy(self, 'files/PTU_UpdateNeeded.json')
			end
		end)
end

--======================================================================================--
--Perform 3 restarting of SDL
RestartSDL("FirstIteration")

RestartSDL("SecondIteration")

RestartSDL("ThirdIteration")

--======================================================================================--
--Cretion session
function Test:Precondition_CreateSession_UpdateAfterIGNCycles()
	CreateSession( self)
end

--======================================================================================--
--ConsentDevice
function Test:Precondition_ConsentDevice_UpdateAfterIGNCycles()
	--hmi side: sending SDL.GetUserFriendlyMessage request
	local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
						{language = "EN-US", messageCodes = {"DataConsent"}})

	--hmi side: expect SDL.GetUserFriendlyMessage response
	--TODO: Update after resolving APPLINK-16094 EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
	EXPECT_HMIRESPONSE(RequestId)
		:Do(function(_,data)

			--hmi side: send request SDL.OnAllowSDLFunctionality
			self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
				{allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
		end)
end

--======================================================================================--
-- Check receiving OnStatusUpdate("UPDATE_NEEDED") from SDL by PTU triggered because exchange_after_x_ignition_cycles value is exceeded
function Test:OnStatusUpdate_UpdateNeededInUpdateTrigeredBySDL_UpdateAfterIGNCycles()
	userPrint(34, "=================== Test Case ===================")

	RegisterApp(self, config.application1.registerAppInterfaceParams)

	EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
		:Do(function()

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
						requestType = "PROPRIETARY"
					},
				'files/PTU_UpdateNeeded.json')
				
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
					EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{line1 = "Up-To-Date", messageCode = "StatusUpToDate", textBody = "Up-To-Date"}}}})
				end)
				
			end)
		end)

end

-- APPLINK-18275: 03[P][MAN]_TC_Update_starts_after_N_km_based_on_odometer
--======================================================================================--
-- Local Policy Table update after N kilometers, based on the odometer.
--======================================================================================--

--Get status update, in case status is not Up_To_Date perform update
function Test:GetStatus_UpToDate_AfterUpdate_InSecondIGNCycle()
	--hmi side: sending SDL.GetStatusUpdate request
	local RequestIdUpdateSDL = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")

	--hmi side: expect SDL.GetStatusUpdate response from HMI
	EXPECT_HMIRESPONSE(RequestIdUpdateSDL,{result = {code = 0, method = "SDL.GetStatusUpdate", status = "UP_TO_DATE" }})
		:Do(function(_,data)
			if data.result.status ~= "UP_TO_DATE" then
				UpdatePolicy(self, 'files/PTU_UpdateNeeded.json')
			end
		end)
end

--======================================================================================--
-- Activation app
function Test:ActivationApp()
			
			--hmi side: sending SDL.ActivateApp request
			local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.HMIAppID })

			--hmi side: expect SDL.ActivateApp response
			EXPECT_HMIRESPONSE(RequestId)
				:Do(function(_,data)
					--In case when app is not allowed, it is needed to allow app
					if
						data.result.isSDLAllowed ~= true then

							--hmi side: sending SDL.GetUserFriendlyMessage request
							local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
												{language = "EN-US", messageCodes = {"DataConsent"}})

							--hmi side: expect SDL.GetUserFriendlyMessage response
							--TODO: Update after resolving APPLINK-16094 EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
							EXPECT_HMIRESPONSE(RequestId)
								:Do(function(_,data)

									--hmi side: send request SDL.OnAllowSDLFunctionality
									self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
										{allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})


									--hmi side: expect BasicCommunication.ActivateApp request
									EXPECT_HMICALL("BasicCommunication.ActivateApp")
										:Do(function(_,data)

											--hmi side: sending BasicCommunication.ActivateApp response
											self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

										end)
										:Times(2)


								end)

				end
			end)
			
			--mobile side: expect notification
			EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"}) 
		end

--======================================================================================--
-- Check receiving OnStatusUpdate("UPDATE_NEEDED") from SDL by PTU triggered because exchange_after_x_kilometers value is exceeded

function Test:OnStatusUpdate_UpdateNeeded_ByChangingOdomenter()
	userPrint(34, "=================== Test Case ===================")
	self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = 2000 })	

	EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
		:Do(function()

			EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
				:Do(function(_,data)
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)

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
						requestType = "PROPRIETARY"
					},
				'files/PTU_UpdateNeeded.json')
				
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
					EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{line1 = "Up-To-Date", messageCode = "StatusUpToDate", textBody = "Up-To-Date"}}}})
				end)
				
			end)
		end)
end

-- APPLINK-18463:12[P][MAN]_TC_PM_validates_LPT_for_int_exchange_after_x_days
--======================================================================================--
--PM verifies that “exchange_after_x_days” in the PTU is integer value.
--======================================================================================--
--Check update status, execute update in case status is not Up_to_date

function Test:Precondition_CheckUpdateStatus()
	--hmi side: sending SDL.GetStatusUpdate request
	local RequestIdUpdateSDL = self.hmiConnection:SendRequest("SDL.GetStatusUpdate")

	--hmi side: expect SDL.GetStatusUpdate response from HMI
	EXPECT_HMIRESPONSE(RequestIdUpdateSDL)
		:Do(function(_,data)
			if data.result.status ~= "UP_TO_DATE" then
				UpdatePolicy(self, 'files/PTU_UpdateNeeded.json')
			end
		end)
end

--======================================================================================--
--Set Os time more on 10 days
local CurrentUnixDate
local SettingCommand

function Test:Precondition_SetNewDate()

	local aHandle = assert( io.popen( "echo $password" , 'r'))
	local passwordValue = aHandle:read( '*l' ) 

	if 	passwordValue and
		passwordValue ~= "" then
			SettingCommand = "echo $password | sudo -S"
	else
		SettingCommand = "sudo"
	end

	local CurrentUnixDateCommand = assert( io.popen( "date +%s" , 'r'))
	CurrentUnixDate = tonumber(CurrentUnixDateCommand:read( '*l' ))

	-- 864000 is 5 days in seconds
	local TimeToSetUp = CurrentUnixDate + 864000

	os.execute(" sleep 0.5  ")

	local ConvertedTimeToSetUpCommand = assert( io.popen( "date -d @".. tostring(TimeToSetUp) .." +%T " , 'r'))
	local ConvertedTimeToSetUp = ConvertedTimeToSetUpCommand:read( '*l' )

	local ConvertedDateToSetUpCommand = assert( io.popen( "date -d @".. tostring(TimeToSetUp) .." +%D " , 'r'))
	local ConvertedDateToSetUp = ConvertedDateToSetUpCommand:read( '*l' )

	local DateTimeToSetUp = tostring(ConvertedDateToSetUp) .. " " .. tostring(ConvertedTimeToSetUp) 

	local SetUpDate  = assert( os.execute( tostring(SettingCommand) .. " date +%D%T -s \"".. tostring(DateTimeToSetUp) .."\""))

	EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
		:Times(0)

	DelayedExp(1000)
end

-- Restart SDL
RestartSDL("RestartSDL")

--======================================================================================--
-- Check receiving OnStatusUpdate("UPDATE_NEEDED") from SDL by PTU triggered because exchange_after_x_days value is exceeded

function Test:OnStatusUpdate_UpdateNeeded_ByChangingOsDate()
		userPrint(34, "=================== Test Case ===================")
		EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
			:Do(function()

				EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
					:Do(function(_,data)
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)

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
							requestType = "PROPRIETARY"
						},
					'files/PTU_UpdateNeeded.json')
					
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
						EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{line1 = "Up-To-Date", messageCode = "StatusUpToDate", textBody = "Up-To-Date"}}}})
					end)
					
				end)
			end)

	DelayedExp(2000)

end

--======================================================================================--
--Set Date to initial value
function Test:Postcondition_SetUpOsTimeBack()

	CurrentUnixDateUpdatedCommand = assert( io.popen( "date +%s" , 'r'))
	local CurrentUnixDateUpdated = tonumber(CurrentUnixDateUpdatedCommand:read( '*l' ))

	local Difference = CurrentUnixDateUpdated - CurrentUnixDate - 864000

	print( "Difference " .. tostring(Difference) )

	local TimeToSetBack = CurrentUnixDate + Difference

	print( "TimeToSetBack " .. tostring(TimeToSetBack) )

	os.execute(" sleep 0.5  ")


	local ConvertedTimeToSetUpBackCommand = assert( io.popen( "date -d @".. tostring(TimeToSetBack) .." +%T " , 'r'))
	local ConvertedTimeToSetUpBack = ConvertedTimeToSetUpBackCommand:read( '*l' )

	local ConvertedDateToSetUpBackCommand = assert( io.popen( "date -d @".. tostring(TimeToSetBack) .." +%D " , 'r'))
	local ConvertedDateToSetUpBack = ConvertedDateToSetUpBackCommand:read( '*l' )

	local DateTimeToSetUpBack = tostring(ConvertedDateToSetUpBack) .. " " .. tostring(ConvertedTimeToSetUpBack) 

	print ( "DateTimeToSetUpBack" .. DateTimeToSetUpBack )


	local SetUpDate  = assert( os.execute( tostring(SettingCommand) .. " date +%D%T -s \"".. tostring(DateTimeToSetUpBack) .."\""))

end
