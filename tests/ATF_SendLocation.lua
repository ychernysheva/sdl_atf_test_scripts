Test = require('user_modules/connecttest_SendLocation')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local config = require('config')
local json  = require('json')
local module = require('testbase')

---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local stringParameter = require('user_modules/shared_testcases/testCasesForStringParameter')
local enumerationParameter = require('user_modules/shared_testcases/testCasesForEnumerationParameter')
local imageParameter = require('user_modules/shared_testcases/testCasesForImageParameter')
local arraySoftButtonsParameter = require('user_modules/shared_testcases/testCasesForArraySoftButtonsParameter')
local arrayStringParameter = require('user_modules/shared_testcases/testCasesForArrayStringParameter')
local integerParameter = require('user_modules/shared_testcases/testCasesForIntegerParameter')
local floatParamter = require('user_modules/shared_testcases/testCasesForFloatParameter')
local policyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
require('user_modules/AppTypes')
----------------------------------------------------------------------------
-- User required files
require('user_modules/AppTypes')
local SDLConfig = require('user_modules/shared_testcases/SmartDeviceLinkConfigurations')

---------------------------------------------------------------------------------------------
------------------------------------ Common Variables ---------------------------------------
---------------------------------------------------------------------------------------------
APIName = "SendLocation" -- set request name
strMaxLengthFileName255 = string.rep("a", 251)  .. ".png" -- set max length file name
--local storagePath = config.SDLStoragePath..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"	

local storagePath = config.pathToSDL .. SDLConfig:GetValue("AppStorageFolder") .. "/" .. tostring(config.application1.registerAppInterfaceParams.appID .. "_" .. tostring(config.deviceMAC) .. "/")

--Debug = {"graphic", "value"} --use to print request before sending to SDL.
Debug = {} -- empty {}: script will do not print request on console screen.

---------------------------------------------------------------------------------------------
-------------------------- Overwrite These Functions For This Script-------------------------
---------------------------------------------------------------------------------------------
--Specific functions for this script
--1. createRequest()
--2. createUIParameters(RequestParams)
--3. verify_SUCCESS_Case(RequestParams)
--4. verify_INVALID_DATA_Case(RequestParams)
---------------------------------------------------------------------------------------------

--Create default request parameters
function createRequest()

	return {		
		longitudeDegrees = 1.1,
		latitudeDegrees = 1.1
	}
	
end
---------------------------------------------------------------------------------------------

--Create UI expected result based on parameters from the request
function Test:createUIParameters(RequestParams)
	local param =  {}
	
	--locationImage
	if RequestParams["locationImage"]  ~= nil then
		param["locationImage"] =  RequestParams["locationImage"]
		if param["locationImage"].imageType == "DYNAMIC" then			
			param["locationImage"].value = storagePath .. param["locationImage"].value
		end	
	end	
		
	return param
end
---------------------------------------------------------------------------------------------

--This function sends a request from mobile and verify result on HMI and mobile for SUCCESS resultCode cases.
function Test:verify_SUCCESS_Case(RequestParams)
	local temp = json.encode(RequestParams)
	local cid = 0
	if string.find(temp, "{}") ~= nil or string.find(temp, "{{}}") ~= nil then						
		temp = string.gsub(temp, "{}", "[]")
		temp = string.gsub(temp, "{{}}", "[{}]")
		
		self.mobileSession.correlationId = self.mobileSession.correlationId + 1

		cid = self.mobileSession.correlationId

		local msg = 
		{
			serviceType      = 7,
			frameInfo        = 0,
			rpcType          = 0,
			rpcFunctionId    = 39,
			rpcCorrelationId = cid,				
			payload          = temp
		}
		self.mobileSession:Send(msg)
	else
		--mobile side: sending SendLocation request
		cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
	end
	
	UIParams = self:createUIParameters(RequestParams)
	
	--hmi side: expect Navigation.SendLocation request
	EXPECT_HMICALL("Navigation.SendLocation", UIParams)
	:Do(function(_,data)
		--hmi side: sending Navigation.SendLocation response
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)

	--mobile side: expect SetGlobalProperties response
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })			
end

---------------------------------------------------------------------------------------------

--This function sends a request from mobile with INVALID_DATA and verify result on mobile.
function Test:verify_INVALID_DATA_Case(RequestParams)
	local temp = json.encode(RequestParams)
	local cid = 0
	if string.find(temp, "{}") ~= nil or string.find(temp, "{{}}") ~= nil then						
		temp = string.gsub(temp, "{}", "[]")
		temp = string.gsub(temp, "{{}}", "[{}]")
		
		cid = self.mobileSession.correlationId + 1

		local msg = 
		{
			serviceType      = 7,
			frameInfo        = 0,
			rpcType          = 0,
			rpcFunctionId    = 39,
			rpcCorrelationId = cid,	
			payload          = temp
		}
		self.mobileSession:Send(msg)
	else
		--mobile side: sending SendLocation request
		cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
	end

	--mobile side: expect SendLocation response
	EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
	:Timeout(50)
	
end

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------
	
	--1. Activate application
	commonSteps:ActivationApp()
	
	--2. PutFiles ("a", "icon.png", "action.png", strMaxLengthFileName255)
	commonSteps:PutFile( "PutFile_MinLength", "a")
	commonSteps:PutFile( "PutFile_icon.png", "icon.png")
	commonSteps:PutFile( "PutFile_action.png", "action.png")
	commonSteps:PutFile( "PutFile_MaxLength_255Characters", strMaxLengthFileName255)
-----------------------------------------------------------------------------------------
	

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK I----------------------------------------
--------------------------------Check normal cases of Mobile request---------------------------
-----------------------------------------------------------------------------------------------

--Requirement id in JAMA or JIRA: 	
	--APPLINK-9735
        --APPLINK-16076
	
--Verification criteria: Verify request with valid and invalid values of parameters; SDL must treat integer value for params of float type as valid
-----------------------------------------------------------------------------------------------

	--List of parameters in the request:
	--1. name="longitudeDegrees" type="Float" minvalue="-180" maxvalue="180" mandatory="true"
	--2. name="latitudeDegrees" type="Float" minvalue="-90" maxvalue="90" mandatory="true"
	--3. name="locationName" type="String" maxlength="500" mandatory="false"
	--4. name="locationDescription" type="String" maxlength="500" mandatory="false"
	--5. name="addressLines" type="String" maxlength="500" minsize="0" maxsize="4" array="true" mandatory="false"
	--6. name="phoneNumber" type="String" maxlength="500" mandatory="false"
	--7. name="locationImage" type="Image" mandatory="false"
	
-----------------------------------------------------------------------------------------------
--Common Test cases:
--1. Positive cases
--2. All parameters are lower bound
--3. All parameters are upper bound
--4. Mandatory only

--1.2, 2.2, 3.2, 4.2 longitudeDegrees and latitudeDegrees are integer values
-----------------------------------------------------------------------------------------------

    --Check 1.1
     local Request = {
          	longitudeDegrees = 1.1,
		latitudeDegrees = 1.1,
		locationName = "location Name",
		locationDescription = "location Description",
		addressLines = 
		{ 
			"line1",
			"line2",
		}, 
		phoneNumber = "phone Number",
		locationImage =	
		{ 
			value = "icon.png",
			imageType = "DYNAMIC",
		}
    }
	function Test:SendLocation_PositiveAllParams()
		self:verify_SUCCESS_Case(Request)
	end

   --- End check 1.1
-------------------------------------------------------------------------------------------------
   --Check 1.2

local Request = {
      	        longitudeDegrees = 1,
		latitudeDegrees = 1,
		locationName = "location Name",
		locationDescription = "location Description",
		addressLines = 
		{ 
			"line1",
			"line2",
		}, 
		phoneNumber = "phone Number",
		locationImage =	
		{ 
			value = "icon.png",
			imageType = "DYNAMIC",
		}
    }
	function Test:SendLocation_Positive_IntDeegrees()
		self:verify_SUCCESS_Case(Request)
	end

   --- End check 1.2
-----------------------------------------------------------------------------------------------------

 --Check 2.1	

        local Request = {
      	        longitudeDegrees = -179.9,
		latitudeDegrees = -89.9,
		locationName ="a",
		locationDescription ="a",
		addressLines = {}, 
		phoneNumber ="a",
		locationImage =	
		{ 
			value ="a",
			imageType ="DYNAMIC",
		}
    }
	function Test:SendLocation_LowerBound()
		self:verify_SUCCESS_Case(Request)
	end
	

 --- End check 2.1

-----------------------------------------------------------------------------------------------------

 --Check 2.2	

        local Request = {
      	        longitudeDegrees = -180,
		latitudeDegrees = -90,
		locationName ="a",
		locationDescription ="a",
		addressLines = {}, 
		phoneNumber ="a",
		locationImage =	
		{ 
			value ="a",
			imageType ="DYNAMIC",
		}
    }
	function Test:SendLocation_LowerBound_IntDeegrees()
		self:verify_SUCCESS_Case(Request)
	end
	

 --- End check 2.2

--------------------------------------------------------------------------------------------------------

 --Check 3.1	

	local Request = {
					longitudeDegrees = 179.9,
					latitudeDegrees = 89.9,
					locationName =string.rep("a", 500),
					locationDescription = string.rep("a", 500),
					addressLines = 
					{ 
						string.rep("a", 500),
						string.rep("a", 500),
						string.rep("a", 500),
						string.rep("a", 500)
					}, 
					phoneNumber =string.rep("a", 500),
					locationImage =	
					{ 
						value =strMaxLengthFileName255,
						imageType ="DYNAMIC",
					}					
				}
	function Test:SendLocation_UpperBound()
		self:verify_SUCCESS_Case(Request)
	end

 --- End check 3.1

--------------------------------------------------------------------------------------------------------

 --Check 3.2	

	local Request = {
					longitudeDegrees = 180,
					latitudeDegrees = 90,
					locationName =string.rep("a", 500),
					locationDescription = string.rep("a", 500),
					addressLines = 
					{ 
						string.rep("a", 500),
						string.rep("a", 500),
						string.rep("a", 500),
						string.rep("a", 500)
					}, 
					phoneNumber =string.rep("a", 500),
					locationImage =	
					{ 
						value =strMaxLengthFileName255,
						imageType ="DYNAMIC",
					}					
				}
	function Test:SendLocation_UpperBound_IntDeegrees()
		self:verify_SUCCESS_Case(Request)
	end

 --- End check 3.2

--------------------------------------------------------------------------------------------------------

 --Check 4.1
	
	local Request = {
					longitudeDegrees = 1.1,
					latitudeDegrees = 1.1		
				}
	function Test:SendLocation_MandatoryOnly()
		self:verify_SUCCESS_Case(Request)
	end

 --- End check 4.1

--------------------------------------------------------------------------------------------------------

 --Check 4.2
	
	local Request = {
					longitudeDegrees = 1,
					latitudeDegrees = 1		
				}
	function Test:SendLocation_MandatoryOnly_IntDeegrees()
		self:verify_SUCCESS_Case(Request)
	end

 --- End check 4.2

-----------------------------------------------------------------------------------------------
--Test cases for parameters: locationName, locationDescription, phoneNumber
-----------------------------------------------------------------------------------------------
--List of test cases for String type parameter:
	--1. IsMissed
	--2. LowerBound
	--3. UpperBound
	--4. OutLowerBound/IsEmpty
	--5. OutUpperBound
	--6. IsWrongType
	--7. IsInvalidCharacters
-----------------------------------------------------------------------------------------------
	
	local Boundary = {1, 500}
	
	stringParameter:verify_String_Parameter(Request, {"locationName"}, Boundary, false)	
	stringParameter:verify_String_Parameter(Request, {"locationDescription"}, Boundary, false)	
	stringParameter:verify_String_Parameter(Request, {"phoneNumber"}, Boundary, false)		


-----------------------------------------------------------------------------------------------
--List of test cases for parameters: locationImage
-----------------------------------------------------------------------------------------------
--List of test cases for Image type parameter:
	--1. IsMissed
	--2. IsEmpty
	--3. IsWrongType
	--4. image.imageType: type=ImageType ("STATIC", "DYNAMIC")
	--5. image.value: type=String, minlength=0 maxlength=65535
-----------------------------------------------------------------------------------------------	

	local Request = createRequest()
	imageParameter:verify_Image_Parameter(Request, {"locationImage"}, {"a", strMaxLengthFileName255}, false)


-----------------------------------------------------------------------------------------------
--List of test cases for parameters: longitudeDegrees, latitudeDegrees
-----------------------------------------------------------------------------------------------
--List of test cases for softButtons type parameter:
	--1. IsMissed
	--2. IsEmpty
	--3. IsWrongType
	--4. IsLowerBound
	--5. IsUpperBound
	--6. IsOutLowerBound
	--7. IsOutUpperBound  
-----------------------------------------------------------------------------------------------
	
	local Request = createRequest()
	local Boundary_longitudeDegrees = {-180, 180}
	local Boundary_latitudeDegrees = {-90, 90}
	floatParamter:verify_Float_Parameter(Request, {"longitudeDegrees"}, Boundary_longitudeDegrees, true)
	floatParamter:verify_Float_Parameter(Request, {"latitudeDegrees"}, Boundary_latitudeDegrees, true)

-----------------------------------------------------------------------------------------------
--List of test cases for parameters: addressLines
-----------------------------------------------------------------------------------------------
--List of test cases for softButtons type parameter:
	--1. IsMissed
	--2. IsEmpty
	--3. IsWrongType
	--4. IsLowerBound
	--5. IsUpperBound
	--6. IsOutLowerBound
	--7. IsOutUpperBound    
-----------------------------------------------------------------------------------------------
	
	local Request = createRequest()
	local ArrayBoundary = {0, 4}
	local ElementBoundary = {1, 500}
	arrayStringParameter:verify_Array_String_Parameter(Request, {"addressLines"}, ArrayBoundary, ElementBoundary, false)

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK II----------------------------------------
-----------------------------Check special cases of Mobile request----------------------------
----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--Requirement id in JAMA or JIRA: 	
	--APPLINK-14765
	
--Verification criteria: SDL must cut off the fake parameters from requests, responses and notifications received from HMI

-----------------------------------------------------------------------------------------
--List of test cases for softButtons type parameter:
	--1. InvalidJSON 
	--2. CorrelationIdIsDuplicated
	--3. FakeParams and FakeParameterIsFromAnotherAPI
	--4. MissedAllParameters 
-----------------------------------------------------------------------------------------------

local function SpecialRequestChecks()

--Begin Test case NegativeRequestCheck
--Description: Check negative request


	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(self, "TestCaseGroupForAbnormal")
	
	--Begin Test case NegativeRequestCheck.1
	--Description: Invalid JSON

		function Test:SendLocation_InvalidJSON()

			  self.mobileSession.correlationId = self.mobileSession.correlationId + 1

			  local msg = 
			  {
				serviceType      = 7,
				frameInfo        = 0,
				rpcType          = 0,
				rpcFunctionId    = 39,
				rpcCorrelationId = self.mobileSession.correlationId,	
				--<<-- Missing :
				payload          = '{"longitudeDegrees" 1.1, "latitudeDegrees":1.1}'
			  }
			  self.mobileSession:Send(msg)
			  
			  self.mobileSession:ExpectResponse(self.mobileSession.correlationId, { success = false, resultCode = "INVALID_DATA" })
				
		end	

	--End Test case NegativeRequestCheck.1

	-----------------------------------------------------------------------------------------
	
	--Begin Test case NegativeRequestCheck.2
	--Description: Check CorrelationId duplicate value
		
		function Test:SendLocation_CorrelationIdIsDuplicated()
		
			--mobile side: sending SendLocation request
			local cid = self.mobileSession:SendRPC("SendLocation",
			{
				longitudeDegrees = 1.1,
				latitudeDegrees = 1.1
			})
			
			--request from mobile side
			local msg = 
			{
			  serviceType      = 7,
			  frameInfo        = 0,
			  rpcType          = 0,
			  rpcFunctionId    = 39,
			  rpcCorrelationId = cid,
			  payload          = '{"longitudeDegrees":1.1, "latitudeDegrees":1.1}'
			}
			
			
			--hmi side: expect Navigation.SendLocation request
			EXPECT_HMICALL("Navigation.SendLocation",
							{
								longitudeDegrees = 1.1,
								latitudeDegrees = 1.1
							})
			:Do(function(exp,data)
				if exp.occurences == 1 then
					self.mobileSession:Send(msg)
				end
				--hmi side: sending Navigation.SendLocation response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
			:Times(2)
			
			--response on mobile side
			EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
			:Times(2)			
		end
	--End Test case NegativeRequestCheck.2

	-----------------------------------------------------------------------------------------
	
	--Begin Test case NegativeRequestCheck.3
	--Description: Fake parameters check
	
		--Begin Test case NegativeRequestCheck.3.1
		--Description: With fake parameters (SUCCESS) 	
			function Test:SendLocation_WithFakeParam()
				
				local param  = 	{
									longitudeDegrees = 1.1,
									latitudeDegrees = 1.1,
									locationName ="location Name",
									locationDescription ="location Description",
									addressLines = 
									{ 
										"line1",
										"line2"										
									}, 
									phoneNumber ="phone Number",
									locationImage =	
									{ 
										value ="icon.png",
										imageType ="DYNAMIC",
										fakeParam ="fakeParam"
									}, 
									fakeParam ="fakeParam"
								}	
								
				--mobile side: sending SendLocation request					
				local cid = self.mobileSession:SendRPC("SendLocation", param)
							
				param.fakeParam = nil
				param.locationImage.fakeParam = nil
				--hmi side: expect the request
				UIParams = self:createUIParameters(param)
				EXPECT_HMICALL("Navigation.SendLocation", UIParams)
				:ValidIf(function(_,data)
					if data.params.fakeParam or 						
						data.params.locationImage.fakeParam then
							print(" \27[36m SDL re-sends fakeParam parameters to HMI \27[0m")
							return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending the response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
				
				--mobile side: expect the response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })			
			end						
		--End Test case NegativeRequestCheck.3.1
		
		-----------------------------------------------------------------------------------------

		--Begin Test case NegativeRequestCheck.3.2
		--Description: Check processing response with fake parameters from another API
			function Test:SendLocation_ParamsAnotherRequest()
				--mobile side: sending SendLocation request		
				local param  = 	{
									longitudeDegrees = 1.1,
									latitudeDegrees = 1.1,
									locationName ="location Name",
									locationDescription ="location Description",
									addressLines = 
									{ 
										"line1",
										"line2"										
									}, 
									phoneNumber ="phone Number",
									locationImage =	
									{ 
										value ="icon.png",
										imageType ="DYNAMIC",
										cmdID = 1005,
									}, 
									cmdID = 1005,
								}
								
				local cid = self.mobileSession:SendRPC("SendLocation", param)
				
				param.cmdID = nil
				param.locationImage.cmdID = nil
				
				--hmi side: expect the request
				UIParams = self:createUIParameters(param)
				EXPECT_HMICALL("Navigation.SendLocation", UIParams)
				:ValidIf(function(_,data)
					if data.params.cmdID or 						
						data.params.locationImage.cmdID then
							print(" \27[36m SDL re-sends cmdID parameters to HMI \27[0m")
							return false
					else 
						return true
					end
				end)
				:Do(function(_,data)
					--hmi side: sending the response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
				
				--mobile side: expect the response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })			
			end	
		--End Test case NegativeRequestCheck.3.2
	--End Test case NegativeRequestCheck.3

	-----------------------------------------------------------------------------------------

	--Begin Test case NegativeRequestCheck.4
	--Description: All parameters missing
	
		function Test:SendLocation_MissedAllParameters()
			--mobile side: sending SendLocation request		
			local cid = self.mobileSession:SendRPC("SendLocation", {} )			
			
			--mobile side: expect the response
			EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
			
		end
	--End Test case NegativeRequestCheck.4
--End Test case NegativeRequestCheck

end	

SpecialRequestChecks()


-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK III--------------------------------------
----------------------------------Check normal cases of HMI response---------------------------
-----------------------------------------------------------------------------------------------
--Requirement id in JAMA: APPLINK-14551, APPLINK-8083, APPLINK-14765
--Verification criteria: 
		--SDL behavior: cases when SDL must transfer "info" parameter via corresponding RPC to mobile app
		--SDL must return INVALID_DATA success:false to mobile app IN CASE any of the above requests comes with '\n' and '\t' symbols in param of 'string' type.
		--In case SDL cuts off fake parameters from response (request) that SDL should transfer to mobile app AND this response (request) is invalid SDL must respond GENERIC_ERROR (success:false, info: "Invalid message received from vehicle") to mobile app 

-----------------------------------------------------------------------------------------

--[[TODO: check after APPLINK-14765 is resolved	
-----------------------------------------------------------------------------------------------
--Parameter 1: resultCode
-----------------------------------------------------------------------------------------------
--List of test cases: 
	--1. IsMissed
	--2. IsValidValues
	--3. IsNotExist
	--4. IsEmpty
	--5. IsWrongType
	--6. IsInvalidCharacter - \n, \t 
-----------------------------------------------------------------------------------------------

local function verify_resultCode_parameter()

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(self, "TestCaseGroupForResultCodeParameter")
	-----------------------------------------------------------------------------------------
	
	--1. IsMissed
	Test[APIName.."_Response_resultCode_IsMissed"] = function(self)
	
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)

		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"Navigation.SendLocation", "code":0}}')
			  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"Navigation.SendLocation"}}')
		end)


		--mobile side: expect the response
		EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})
	end
	-----------------------------------------------------------------------------------------
	
	
	--2. IsValidValue
	local resultCodes = {		
		{resultCode = "INVALID_DATA", success =  false},
		{resultCode = "OUT_OF_MEMORY", success =  false},
		{resultCode = "TOO_MANY_PENDING_REQUESTS", success =  false},
		{resultCode = "APPLICATION_NOT_REGISTERED", success =  false},
		{resultCode = "GENERIC_ERROR", success =  false},
		{resultCode = "REJECTED", success =  false},
		{resultCode = "DISALLOWED", success =  false},			
	}
		
	for i =1, #resultCodes do
	
		Test[APIName.."_resultCode_IsValidValues_" .. resultCodes[i].resultCode .."_SendResponse"] = function(self)
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				self.hmiConnection:SendResponse(data.id, data.method, resultCodes[i].resultCode, {})
			end)

			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = resultCodes[i].success, resultCode = resultCodes[i].resultCode})							

		end		
		-----------------------------------------------------------------------------------------
		
		Test[APIName.."_resultCode_IsValidValues_" .. resultCodes[i].resultCode .."_SendError"] = function(self)
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				self.hmiConnection:SendError(data.id, data.method, resultCodes[i].resultCode, "info")
			end)

			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = resultCodes[i].success, resultCode = resultCodes[i].resultCode})							

		end	
	end
	
	-----------------------------------------------------------------------------------------

	--3. IsNotExist
	--4. IsEmpty
	--5. IsWrongType
	
	local testData = {	
		{value = "ANY", name = "IsNotExist"},
		{value = "", name = "IsEmpty"},
		{value = 123, name = "IsWrongType"},		
		}
	
	for i =1, #testData do
	
		Test[APIName.."_resultCode_" .. testData[i].name .."_SendResponse"] = function(self)
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				self.hmiConnection:SendResponse(data.id, data.method, testData[i].value, {})
			end)

			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})
		end
		-----------------------------------------------------------------------------------------
		
		Test[APIName.."_resultCode_" .. testData[i].name .."_SendError"] = function(self)
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				self.hmiConnection:SendError(data.id, data.method, testData[i].value)
			end)

			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})
		end
	end
end	

verify_resultCode_parameter()


-----------------------------------------------------------------------------------------------
--Parameter 2: method
-----------------------------------------------------------------------------------------------
--List of test cases: 
	--1. IsMissed
	--2. IsValidValue
	--3. IsNotExist
	--4. IsEmpty
	--5. IsWrongType
	--6. IsInvalidCharacter - \n, \t
-----------------------------------------------------------------------------------------------

local function verify_method_parameter()

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(self, "TestCaseGroupForMethodParameter")
	-----------------------------------------------------------------------------------------
	
	--1. IsMissed
	Test[APIName.."_Response_method_IsMissed_GENERIC_ERROR"] = function(self)
	
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)

		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"Navigation.SendLocation", "code":0}}')
			  self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"code":0}}')
			  
		end)


		--mobile side: expect the response
		EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})		
	end
	-----------------------------------------------------------------------------------------
	
	--2. IsValidValue	
	Test[APIName.."_Response_method_IsValidValue_SendResponse"] = function(self)
		
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)

		--mobile side: expect SetGlobalProperties response
		EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})							

	end		
	-----------------------------------------------------------------------------------------
	
	Test[APIName.."_Response_method_IsValidValue_SendError"] = function(self)
		
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			self.hmiConnection:SendError(data.id, data.method, "GENERIC_ERROR", "info")
		end)

		--mobile side: expect SetGlobalProperties response
		EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "info"})
	end	
	-----------------------------------------------------------------------------------------
	
	--3. IsNotExist
	--4. IsEmpty
	--5. IsWrongType
	--6. IsInvalidCharacter - \n, \t		
	local Methods = {	
		{method = "ANY", name = "IsNotExist"},
		{method = "", name = "IsEmpty"},
		{method = 123, name = "IsWrongType"},
		{method = "a\nb", name = "IsInvalidCharacter_NewLine"},
		{method = "a\tb", name = "IsInvalidCharacter_Tab"}}
	
	for i =1, #Methods do
	
		Test[APIName.."_Response_method_" .. Methods[i].name .."_GENERIC_ERROR_SendResponse"] = function(self)
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				--self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				self.hmiConnection:SendResponse(data.id, Methods[i].method, "SUCCESS", {})
				
			end)

			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})			
		end
		-----------------------------------------------------------------------------------------
		
		Test[APIName.."_Response_method_" .. Methods[i].name .."_GENERIC_ERROR_SendError"] = function(self)
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				--self.hmiConnection:SendError(data.id, data.method, "UNSUPPORTED_RESOURCE", "info")
				  self.hmiConnection:SendError(data.id, Methods[i].method, "UNSUPPORTED_RESOURCE", "info")
				
			end)

			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})
		end
	end
end	

verify_method_parameter()
--]]


-----------------------------------------------------------------------------------------------
--Parameter 3: info
-----------------------------------------------------------------------------------------------
--List of test cases: 
	--1. IsMissed
	--2. IsLowerBound
	--3. IsUpperBound
	--4. IsOutUpperBound
	--5. IsEmpty/IsOutLowerBound
	--6. IsWrongType
	--7. InvalidCharacter - \n, \t
-----------------------------------------------------------------------------------------------

local function verify_info_parameter()

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(self, "TestCaseGroupForInfoParameter")
	
	-----------------------------------------------------------------------------------------
	
	--1. IsMissed
	Test[APIName.."_info_IsMissed_SendResponse"] = function(self)
	
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)

		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)


		--mobile side: expect the response
		EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
		:ValidIf (function(_,data)
			if data.payload.info then
				print(" \27[32m SDL resends invalid info parameter to mobile app. \27[0m")
				return false
			else 
				return true
			end
		end)
	end
	-----------------------------------------------------------------------------------------
	
	Test[APIName.."_info_IsMissed_SendError"] = function(self)
	
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)

		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			self.hmiConnection:SendError(data.id, data.method, "GENERIC_ERROR")
		end)


		--mobile side: expect the response
		-- TODO: update after resolving APPLINK-14765
		-- EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
		EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA"})
		:ValidIf (function(_,data)
			if data.payload.info then
				print(" \27[32m SDL resends info parameter to mobile app. info = \"" .. data.payload.info .. "\" \27[0m")
				return false
			else 
				return true
			end
		end)
	end
	-----------------------------------------------------------------------------------------

	--2. IsLowerBound
	--3. IsUpperBound
	local testData = {	
		{value = "a", name = "IsLowerBound"},
		{value = commonFunctions:createString(1000), name = "IsUpperBound"}}
	
	for i =1, #testData do	
		Test[APIName.."_info_" .. testData[i].name .."_SendResponse"] = function(self)
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {message = testData[i].value})
			end)

			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", info = testData[i].value})
		end
		-----------------------------------------------------------------------------------------
		
		Test[APIName.."_info_" .. testData[i].name .."_SendError"] = function(self)
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				self.hmiConnection:SendError(data.id, data.method, "GENERIC_ERROR", testData[i].value)
			end)

			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = testData[i].value})
		end
	end
	-----------------------------------------------------------------------------------------
	
	
	--4. IsOutUpperBound
	Test[APIName.."_info_IsOutUpperBound_SendResponse"] = function(self)
	
		local infoMaxLength = commonFunctions:createString(1000)
		
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {message = infoMaxLength .. "1"})
		end)

		--mobile side: expect SetGlobalProperties response
		EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS", info = infoMaxLength})		
	end
	-----------------------------------------------------------------------------------------
	
	Test[APIName.."_info_IsOutUpperBound_SendError"] = function(self)
	
		local infoMaxLength = commonFunctions:createString(1000)
		
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			self.hmiConnection:SendError(data.id, data.method, "GENERIC_ERROR", infoMaxLength .."1")
		end)

		--mobile side: expect SetGlobalProperties response
		EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = infoMaxLength})		
	end
	-----------------------------------------------------------------------------------------
	
	--5. IsEmpty/IsOutLowerBound	
	--6. IsWrongType
	--7. InvalidCharacter - \n, \t, white spaces only
	
	local testData = {	
		{value = "", name = "IsEmpty_IsOutLowerBound"},
		{value = 123, name = "IsWrongType"},
		{value = "a\nb", name = "IsInvalidCharacter_NewLine"},
		{value = "a\tb", name = "IsInvalidCharacter_Tab"},
		{value = "    ", name = "WhiteSpacesOnly"}}
	
	for i =1, #testData do
	
		Test[APIName.."_info_" .. testData[i].name .."_SendResponse"] = function(self)
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {message = testData[i].value})
			end)

			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
			:ValidIf (function(_,data)
				if data.payload.info then
					print(" \27[32m  SDL resends info parameter to mobile app. info = \"" .. data.payload.info .. "\" \27[0m")
					return false
				else 
					return true
				end
			end)
		end
		-----------------------------------------------------------------------------------------
		
		Test[APIName.."_info_" .. testData[i].name .."_SendError"] = function(self)
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				self.hmiConnection:SendError(data.id, data.method, "GENERIC_ERROR", testData[i].value)
			end)

			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
			:ValidIf (function(_,data)
				if data.payload.info then
					print(" \27[32m SDL resends info parameter to mobile app. info = \"" .. data.payload.info .. "\" \27[0m")
					return false
				else 
					return true
				end				
			end)	
		end
	end
end	

verify_info_parameter()

--[[TODO: check after APPLINK-14765 is resolved	
-----------------------------------------------------------------------------------------------
--Parameter 4: correlationID 
-----------------------------------------------------------------------------------------------
--List of test cases: 
	--1. CorrelationIDMissing
	--2. CorrelationIDWrongType
	--3. CorrelationIDNotExisted
	--4. CorrelationIDNegative
	--5. CorrelationIDNull
-----------------------------------------------------------------------------------------------

local function verify_correlationID_parameter()


	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("TestCaseGroupForCorrelationIDParameter")
	
	-----------------------------------------------------------------------------------------
	
	--1. CorrelationIDMissing	
	Test[APIName.."_Response_CorrelationIDMissing"] = function(self)
	
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)

		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"Navigation.SendLocation", "code":0}}')
			self.hmiConnection:Send('{"jsonrpc":"2.0","result":{"method":"Navigation.SendLocation", "code":0}}')
		end)

		--mobile side: expect the response
		EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})		
	end
	-----------------------------------------------------------------------------------------
	
	--2. CorrelatioIDWrongType
	Test[APIName.."_Response_CorrelationIDWrongType"] = function(self)	
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)

		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			self.hmiConnection:SendResponse(tostring(data.id), data.method, "SUCCESS", {})
		end)

		--mobile side: expect the response
		EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})		
	end
	-----------------------------------------------------------------------------------------
	
	--3. CorrelationIDNotExisted
	Test[APIName.."_Response_CorrelationIDNotExisted"] = function(self)
		
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)

		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			self.hmiConnection:SendResponse(9999, data.method, "SUCCESS", {})
		end)

		--mobile side: expect the response
		EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})				
	end
	-----------------------------------------------------------------------------------------
	
	--4. CorrelationIDNegative
	Test[APIName.."_Response_CorrelationIDNegative"] = function(self)
	
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)

		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			self.hmiConnection:SendResponse(-1, data.method, "SUCCESS", {})
		end)

		--mobile side: expect the response
		EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})		
	end
	
	-----------------------------------------------------------------------------------------
	--5. CorrelationIDNull	
	Test[APIName.."_Response_CorrelationIDNull"] = function(self)
	
		--mobile side: sending the request
		local RequestParams = createRequest()
		local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)

		
		--hmi side: expect the request
		UIParams = self:createUIParameters(RequestParams)
		
		EXPECT_HMICALL("Navigation.SendLocation", UIParams)
		:Do(function(_,data)
			--hmi side: sending the response
			self.hmiConnection:Send('"id":null,"jsonrpc":"2.0","result":{"code":0,"method":"Navigation.SendLocation"}}')
		end)

		--mobile side: expect the response
		EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})		
	end
end	

verify_correlationID_parameter()

--]]	

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK IV----------------------------------------
------------------------------Check special cases of HMI response-----------------------------
----------------------------------------------------------------------------------------------

--Requirement id in JAMA: APPLINK-14765
--Verification criteria:  	In case SDL cuts off fake parameters from response (request) that SDL should transfer to mobile app AND this response (request) is invalid SDL must respond GENERIC_ERROR (success:false, info: "Invalid message received from vehicle") to mobile app 

-----------------------------------------------------------------------------------------------

--List of test cases for softButtons type parameter:
	--1. InvalidJsonSyntax
	--2. InvalidStructure
	--2. DuplicatedCorrelationId
	--3. FakeParams and FakeParameterIsFromAnotherAPI
	--4. MissedAllPArameters
	--5. NoResponse
	--6. SeveralResponsesToOneRequest with the same and different resultCode
-----------------------------------------------------------------------------------------------

local function SpecialResponseChecks()

--Begin Test case NegativeResponseCheck
--Description: Check all negative response cases
	
	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(self, "NewTestCasesGroupForNegativeResponseCheck")

	--Begin Test case NegativeResponseCheck.1
	--Description: Invalid JSON
		
		--[[ToDo: Check after APPLINK-14765 is resolved
		
		function Test:SendLocation_InvalidJsonSyntaxResponse()
		
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
			
			--hmi side: expect the request
			local UIParams = self:createUIParameters(RequestParams)
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending the response
				--":" is changed by ";" after {"id"
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"Navigation.SendLocation", "code":0}}')
				  self.hmiConnection:Send('{"id";'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"Navigation.SendLocation", "code":0}}')
			end)
				
			--mobile side: expect the response
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})						
		end			
	--End Test case NegativeResponseCheck.1
	
	-----------------------------------------------------------------------------------------
	
	--Begin Test case NegativeResponseCheck.2
	--Description: Invalid structure of response
			
		function Test:SendLocation_InvalidStructureResponse()

			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
								
			--hmi side: expect the request
			local UIParams = self:createUIParameters(RequestParams)
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)		
			:Do(function(_,data)
				--hmi side: sending the response
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"Navigation.SendLocation", "code":0}}')
				self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0", "code":0, "result":{"method":"Navigation.SendLocation"}}')
			end)							
		
			--mobile side: expect response 
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})
		end		
	--End Test case NegativeResponseCheck.2
]]

	-----------------------------------------------------------------------------------------
	
	--Begin Test case NegativeResponseCheck.3
	--Description: Check processing response with fake parameters
		
		--Requirement id in JAMA/or Jira ID: APPLINK-14765
		--Verification criteria: SDL must cut off the fake parameters from requests, responses and notifications received from HMI
		
		--Begin Test case NegativeResponseCheck.3.1
		--Description: Parameter is not from API		
			function Test:SendLocation_FakeParamsInResponse()
			
				--mobile side: sending the request
				local RequestParams = createRequest()
				local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
									
				--hmi side: expect the request
				local UIParams = self:createUIParameters(RequestParams)
				EXPECT_HMICALL("Navigation.SendLocation", UIParams)		
				:Do(function(exp,data)
					--hmi side: sending the response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {fake = "fake"})
				end)
				
							
				--mobile side: expect the response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				:ValidIf (function(_,data)
					if data.payload.fake then
						print(" \27[32m SDL resend fake parameter to mobile app \27[0m")
						return false
					else 
						return true
					end
				end)						
			end
		--End Test case NegativeResponseCheck.3.1
		
		-----------------------------------------------------------------------------------------
		
		--Begin Test case NegativeResponseCheck.3.2
		--Description: Parameter is not from another API
			function Test:SendLocation_AnotherParameterInResponse()			
				--mobile side: sending the request
				local RequestParams = createRequest()
				local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
									
				--hmi side: expect the request
				local UIParams = self:createUIParameters(RequestParams)
				EXPECT_HMICALL("Navigation.SendLocation", UIParams)		
				:Do(function(exp,data)
					--hmi side: sending the response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {sliderPosition = 5})
				end)
							
				--mobile side: expect the response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				:ValidIf (function(_,data)
					if data.payload.sliderPosition then
						print(" \27[32m SDL resend fake parameter to mobile app \27[0m")
						return false
					else 
						return true
					end
				end)							
			end			
		--End Test case NegativeResponseCheck.3.2		
	--End Test case NegativeResponseCheck.3

	-----------------------------------------------------------------------------------------
	
	--Begin NegativeResponseCheck.4
	--Description: Check processing response without all parameters		
	--[[TODO: Check after APPLINK-14765 is resolved
		function Test:SendLocation_Response_MissedAllPArameters()
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)

			
			--hmi side: expect the request
			UIParams = self:createUIParameters(RequestParams)
			
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)
			:Do(function(_,data)
				--hmi side: sending Navigation.SendLocation response
				--self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"Navigation.SendLocation", "code":0}}')
				self.hmiConnection:Send('{}')
			end)
			
			--mobile side: expect the response
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR",  info = "Invalid message received from vehicle"})			
		end
	]]
	--End NegativeResponseCheck.4

	-----------------------------------------------------------------------------------------
	
	--Begin Test case NegativeResponseCheck.5
	--Description: Request without responses from HMI
	
		function Test:SendLocation_NoResponse()
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
								
			--hmi side: expect the request
			local UIParams = self:createUIParameters(RequestParams)
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)		
			
			
			--mobile side: expect SetGlobalProperties response
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR"})
			:Timeout(12000)
		end		
	--End NegativeResponseCheck.5
		
	-----------------------------------------------------------------------------------------
	
	--Begin Test case NegativeResponseCheck.6
	--Description: Several response to one request
			
		function Test:SendLocation_SeveralResponsesToOneRequest()
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
								
			--hmi side: expect the request
			local UIParams = self:createUIParameters(RequestParams)
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)		
			:Do(function(exp,data)
				--hmi side: sending the response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				self.hmiConnection:SendError(data.id, data.method, "GENERIC_ERROR", "")
				self.hmiConnection:SendError(data.id, data.method, "REJECTED", "")					
			end)
										
			--mobile side: expect response 
			EXPECT_RESPONSE(cid, {  success = true, resultCode = "SUCCESS"})				
		end
	--End Test case NegativeResponseCheck.6
	
	-----------------------------------------------------------------------------------------
--[[TODO: Check after APPLINK-14765 is resolved	
	--Begin Test case NegativeResponseCheck.7
	--Description: Wrong response to correct correlationID
		function Test:SendLocation_WrongResponse()
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
								
			--hmi side: expect the request
			local UIParams = self:createUIParameters(RequestParams)
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)		
			:Do(function(exp,data)
				--hmi side: sending the response
				self.hmiConnection:Send('{"error":{"code":4,"message":"SendLocation is REJECTED"},"id":'..tostring(data.id)..',"jsonrpc":"2.0","result":{"code":0,"method":"Navigation.SendLocation"}}')			
			end)
										
			--mobile side: expect response 
			EXPECT_RESPONSE(cid, { success = false, resultCode = "GENERIC_ERROR", info = "Invalid message received from vehicle"})	
		end
	--End Test case NegativeResponseCheck.7	
--]]
--End Test case NegativeResponseCheck	

end	

SpecialResponseChecks()

	
-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Requirement id in JAMA: APPLINK-9735, SDLAQ-CRS-2396
--Verification criteria: 
	--[[
		--An RPC request is not allowed by the backend. Policies Manager validates it as "disallowed".
		1) SDL must support the following result-codes:
		
		1.3) USER_DISALLOWED -
		SDL must return 'user_dissallowed, success:false' in case the SendLocation RPC is included to the group disallowed by the user.

		1.4.) WARNINGS
		In case SDL receives WARNINGS from HMI, SDL must transfer this resultCode with adding 'success:true' to mobile app.
		The use case: requested image is corrupted or does not exist by the defined path -> HMI displays all other requested info and returns WARNINGS with problem description -> SDL transfers 'warnings, success:true' to mobile app.
	--]]
local function ResultCodeChecks()

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(self, "NewTestCasesGroupForResultCodeChecks")
	
	--Begin Test case ResultCodeChecks.1
	--Description: Check resultCode APPLICATION_NOT_REGISTERED

		--Precondition
		function Test:Precondition_CreationNewSession()
			-- Connected expectation
			self.mobileSession2 = mobile_session.MobileSession(
																	self,
																	self.mobileConnection
																)			   
		end
		
		function Test:SendLocation_resultCode_APPLICATION_NOT_REGISTERED()

			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession2:SendRPC("SendLocation", RequestParams)
														
			--mobile side: expect response 
			self.mobileSession2:ExpectResponse(cid, {  success = false, resultCode = "APPLICATION_NOT_REGISTERED"})			
		end
	--End Test case ResultCodeChecks.1

	-----------------------------------------------------------------------------------------

	--Begin Test case ResultCodeChecks.2
	--Description: Check resultCode DISALLOWED
			
		--Begin Test case ResultCodeChecks.2.1
		--Description: Check resultCode DISALLOWED when HMI level is NONE
	
			--Covered by test case SendLocation_HMIStatus_NONE
			
		--End Test case ResultCodeChecks.2.1
		
		-----------------------------------------------------------------------------------------

--[[TODO debug after resolving APPLINK-13101
		
		--Begin Test case ResultCodeChecks.2.2
		--Description: Check resultCode DISALLOWED when request is not assigned to app
			
			policyTable:checkPolicyWhenAPIIsNotExist()
			
		--End Test case ResultCodeChecks.2.2
		
		-----------------------------------------------------------------------------------------
		
		--Begin Test case ResultCodeChecks.2.3
		--Description: Check resultCode USER_DISALLOWED when request is assigned to app but user does not allow
		
			policyTable:checkPolicyWhenUserDisallowed({"FULL", "LIMITED"})	
			
		--End Test case ResultCodeChecks.2.3		
	--]]	
	
	--End Test case ResultCodeChecks.2

	-----------------------------------------------------------------------------------------

	--Begin Test case ResultCodeChecks.3
	--Description: Check resultCode WARNINGS
			
		function Test:SendLocation_resultCode_WARNINGS()
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
								
			--hmi side: expect the request
			local UIParams = self:createUIParameters(RequestParams)
			EXPECT_HMICALL("Navigation.SendLocation", UIParams)		
			:Do(function(exp,data)
				--hmi side: sending the response
				self.hmiConnection:SendResponse(data.id, data.method, "UNSUPPORTED_RESOURCE", {message = "HMI doesn't support STATIC, DYNAMIC or any image types which exist in request data"})
			end)
										
			--mobile side: expect response 
			EXPECT_RESPONSE(cid, {  success = true, resultCode = "WARNINGS", info = "HMI doesn't support STATIC, DYNAMIC or any image types which exist in request data"})
		end								
	--End Test case ResultCodeChecks.3
end

ResultCodeChecks()

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VI----------------------------------------
-------------------------Sequence with emulating of user's action(s)--------------------------
----------------------------------------------------------------------------------------------

--Description: TC's checks SDL behaviour by processing
	-- different request sequence with timeout
	-- with emulating of user's actions	

-- Not Applicable


----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VII---------------------------------------
--------------------------------------Different HMIStatus-------------------------------------
----------------------------------------------------------------------------------------------

--Description: Check different HMIStatus
	
local function DifferentHMIlevelChecks()

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(self, "NewTestCasesGroupForSequenceChecks")
	-----------------------------------------------------------------------------------------
	
	--Begin Test case DifferentHMIlevelChecks.1
	--Description: Check request is disallowed in NONE HMI level
		function Test:Precondition_DeactivateToNone()
			--hmi side: sending BasicCommunication.OnExitApplication notification
			self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication", {appID = self.applications["Test Application"], reason = "USER_EXIT"})

			EXPECT_NOTIFICATION("OnHMIStatus",
				{ systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"})
		end	
		
		function Test:SendLocation_HMIStatus_NONE()
			
			--mobile side: sending the request
			local RequestParams = createRequest()
			local cid = self.mobileSession:SendRPC("SendLocation", RequestParams)
																			
			--mobile side: expect response 
			EXPECT_RESPONSE(cid, {  success = false, resultCode = "DISALLOWED"})
		end				
							
		--Postcondition: Activate app
		commonSteps:ActivationApp(self)

	--End Test case DifferentHMIlevelChecks.1
	-----------------------------------------------------------------------------------------
			
	--Begin Test case DifferentHMIlevelChecks.2
	--Description: Check HMI level Full
	
		--It is covered by above test cases

	--End Test case DifferentHMIlevelChecks.2
	-----------------------------------------------------------------------------------------
	
	--Begin Test case DifferentHMIlevelChecks.3
	--Description: Check HMI level LIMITED
	if 
		Test.isMediaApplication == true or
		Test.appHMITypes["NAVIGATION"] == true then
		
			--Precondition: Deactivate app to LIMITED HMI level				
			commonSteps:ChangeHMIToLimited(self)

			function Test:SendLocation_HMIStatus_LIMITED()
				local RequestParams = createRequest()
				self:verify_SUCCESS_Case(RequestParams)
			end
	
	--End Test case DifferentHMIlevelChecks.3
	
		-- Precondition 1: Opening new session	
		function Test:AddNewSession()
		  -- Connected expectation
			self.mobileSession2 = mobile_session.MobileSession(
			self,
			self.mobileConnection)
			
			self.mobileSession2:StartService(7)
		end	

		-- Precondition 2: Register app2	
		function Test:RegisterAppInterface_App2() 

			--mobile side: RegisterAppInterface request 
			local CorIdRAI = self.mobileSession2:SendRPC("RegisterAppInterface",
														{
															syncMsgVersion = 
															{ 
																majorVersion = 2,
																minorVersion = 2,
															}, 
															appName ="SPT2",
															isMediaApplication = true,
															languageDesired ="EN-US",
															hmiDisplayLanguageDesired ="EN-US",
															appID ="2",
															ttsName = 
															{ 
																{ 
																	text ="SyncProxyTester2",
																	type ="TEXT",
																}, 
															}, 
															vrSynonyms = 
															{ 
																"vrSPT2",
															}
														}) 
		 
			--hmi side: expect BasicCommunication.OnAppRegistered request
			EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
			{
				application = 
				{
					appName = "SPT2"
				}
			})
			:Do(function(_,data)
				self.applications["Test Application2"] = data.params.application.appID
			end)
			
			--mobile side: RegisterAppInterface response 
			self.mobileSession2:ExpectResponse(CorIdRAI, { success = true, resultCode = "SUCCESS"})
				:Timeout(2000)

			self.mobileSession2:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
		end

		-- Precondition 3: Activate an other media app to change app to BACKGROUND
		function Test:Activate_Media_App2()
			--HMI send ActivateApp request			
			local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application2"]})
			EXPECT_HMIRESPONSE(RequestId)
			:Do(function(_,data)

				if data.result.isSDLAllowed ~= true then
					local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
					EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
					:Do(function(_,data)
						--hmi side: send request SDL.OnAllowSDLFunctionality
						self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = 1, name = "127.0.0.1"}})
					end)

					EXPECT_HMICALL("BasicCommunication.ActivateApp")
					:Do(function(_,data)
						self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
					end)
					:Times(2)
				end
			end)

			self.mobileSession2:ExpectNotification("OnHMIStatus", {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"}) 
			:Timeout(12000)
			
			self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"}) 
			
		end	
	
	elseif Test.isMediaApplication == false then
		--Precondition: Deactivate app to BACKGOUND HMI level				
		commonSteps:DeactivateToBackground(self)
	end
	
	-----------------------------------------------------------------------------------------
	
	--Begin Test case DifferentHMIlevelChecks.4
	--Description: Check HMI level BACKGOUND
		function Test:SendLocation_HMIStatus_BACKGOUND()
			local RequestParams = createRequest()
			self:verify_SUCCESS_Case(RequestParams)
		end
	--End Test case DifferentHMIlevelChecks.4
end

DifferentHMIlevelChecks()
  
return Test
