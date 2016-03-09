Test = require('user_modules/connecttest_Resumption')
require('cardinalities')
local mobile_session = require('mobile_session')
local tcp = require('tcp_connection')
local file_connection = require('file_connection')
local mobile = require('mobile_connection')
require('user_modules/AppTypes')
local AppValuesOnHMIStatusFULL
local AppValuesOnHMIStatusLIMITED

local AppValuesOnHMIStatusDEFAULT
local AppValuesOnHMIStatusDEFAULTMediaApp
local AppValuesOnHMIStatusDEFAULTNonMediaApp

local DefaultHMILevel = "NONE"
local HMIAppID

local TimeRAImedia1
local TimeRAImedia2
local TimeRAInonmedia

AppValuesOnHMIStatusDEFAULT = {hmiLevel = "NONE", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE" }
AppValuesOnHMIStatusDEFAULTMediaApp = {hmiLevel = "NONE", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE" }
AppValuesOnHMIStatusDEFAULTNonMediaApp = {hmiLevel = "NONE", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE" }
AppValuesOnHMIStatusDEFAULTCommunicationApp = {hmiLevel = "NONE", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE" }

local notificationState = {VRSession = false, EmergencyEvent = false, PhoneCall = false}

local applicationData =
{
  mediaApp1 = {
    syncMsgVersion =
    {
      majorVersion = 2,
      minorVersion = 3
    },
    appName = "TestAppMedia1",
    isMediaApplication = true,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appHMIType = { "MEDIA" },
    appID = "0000002",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  },
  mediaApp2 = {
    syncMsgVersion =
    {
      majorVersion = 2,
      minorVersion = 3
    },
    appName = "TestAppMedia2",
    isMediaApplication = true,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appHMIType = { "MEDIA" },
    appID = "0000003",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  },
  nonmediaApp = {
    syncMsgVersion =
    {
      majorVersion = 2,
      minorVersion = 3
    },
    appName = "TestAppNonMedia",
    isMediaApplication = false,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appHMIType = { "DEFAULT" },
    appID = "0000004",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  },
  navigationApp = {
    syncMsgVersion =
    {
      majorVersion = 2,
      minorVersion = 3
    },
    appName = "TestAppNavigation",
    isMediaApplication = false,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appHMIType = { "NAVIGATION" },
    appID = "0000005",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  },
  communicationApp = {
    syncMsgVersion =
    {
      majorVersion = 2,
      minorVersion = 3
    },
    appName = "TestAppCommunication",
    isMediaApplication = false,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appHMIType = { "COMMUNICATION" },
    appID = "0000006",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  }
}

if
config.application1.registerAppInterfaceParams.isMediaApplication == true or
Test.appHMITypes["NAVIGATION"] == true or
Test.appHMITypes["COMMUNICATION"] == true then
  AppValuesOnHMIStatusFULL = {hmiLevel = "FULL", systemContext = "MAIN", audioStreamingState = "AUDIBLE"}
  AppValuesOnHMIStatusLIMITED = {hmiLevel = "LIMITED", systemContext = "MAIN", audioStreamingState = "AUDIBLE"}
elseif
  config.application1.registerAppInterfaceParams.isMediaApplication == false then
    AppValuesOnHMIStatusFULL = {hmiLevel = "FULL", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE"}
  end

  local HMIAppIDMediaApp1 = nil
  local HMIAppIDMediaApp2 = nil
  local HMIAppIDNonMediaApp = nil

  local function RegisterApp(self, session, RegisterData, DEFLevel)

    local correlationId = session:SendRPC("RegisterAppInterface", RegisterData)

    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
    :Do(function(_,data)
        -- self.applications[RegisterData.appName] = data.params.application.appID
        if RegisterData.appName == "TestAppMedia1" then
          HMIAppIDMediaApp = data.params.application.appID
          HMIAppIDMediaApp1 = HMIAppIDMediaApp
        elseif RegisterData.appName == "TestAppMedia2" then
          HMIAppIDMediaApp = data.params.application.appID
          HMIAppIDMediaApp2 = HMIAppIDMediaApp
        elseif RegisterData.appName == "TestAppNonMedia" then
          HMIAppIDNonMediaApp = data.params.application.appID
        elseif RegisterData.appName == "TestAppNavigation" then
          HMIAppIDNaviApp = data.params.application.appID
        elseif RegisterData.appName == "TestAppCommunication" then
          HMIAppIDComApp = data.params.application.appID
        end
      end)

    session:ExpectResponse(correlationId, { success = true })

    session:ExpectNotification("OnHMIStatus",
      DEFLevel)

  end

  local function IGNITION_OFF(self)
    StopSDL()

    --[[if appNumber == nil then
    appNumber = 1
  end
  ]]
  -- hmi side: sends OnExitAllApplications (SUSPENDED)
  self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
    {
      reason = "IGNITION_OFF"
    })

  -- hmi side: expect OnSDLClose notification
  EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")

  --[[-- hmi side: expect OnAppUnregistered notification
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
  :Times(appNumber)
  ]]
end

local function userPrint( color, message)
  print ("\27[" .. tostring(color) .. "m " .. tostring(message) .. " \27[0m")
end

function DelayedExp(time)
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  :Timeout(time+1000)
  RUN_AFTER(function()
      RAISE_EVENT(event, event)
      end, time)
  end

  local function ActivationApp(self)

    if
    notificationState.VRSession == true then
      self.hmiConnection:SendNotification("VR.Stopped", {})
    elseif
      notificationState.EmergencyEvent == true then
        self.hmiConnection:SendNotification("BasicCommunication.OnEmergencyEvent", {enabled = false})
      elseif
        notificationState.PhoneCall == true then
          self.hmiConnection:SendNotification("BasicCommunication.OnPhoneCall", {isActive = false})
        end

        -- hmi side: sending SDL.ActivateApp request
        local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})

        -- hmi side: expect SDL.ActivateApp response
        EXPECT_HMIRESPONSE(RequestId)
        :Do(function(_,data)
            -- In case when app is not allowed, it is needed to allow app
            if
            data.result.isSDLAllowed ~= true then

              -- hmi side: sending SDL.GetUserFriendlyMessage request
              local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                {language = "EN-US", messageCodes = {"DataConsent"}})

              -- hmi side: expect SDL.GetUserFriendlyMessage response
              -- TODO: comment until resolving APPLINK-16094
              -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)

                  -- hmi side: send request SDL.OnAllowSDLFunctionality
                  self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                    {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                  -- hmi side: expect BasicCommunication.ActivateApp request
                  EXPECT_HMICALL("BasicCommunication.ActivateApp")
                  :Do(function(_,data)

                      -- hmi side: sending BasicCommunication.ActivateApp response
                      self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                    end)
                  :Times(2)
                end)

            end
          end)

      end

      --Check pathToSDL, in case last symbol is not'/' add '/'
      local function checkSDLPathValue()
        findresult = string.find (config.pathToSDL, '.$')

        if string.sub(config.pathToSDL,findresult) ~= "/" then
          config.pathToSDL = config.pathToSDL..tostring("/")
        end
      end

      local function CloseSessionCheckLevel(self, targetLevel)
        if
        targetLevel == nil then
          self.mobileSession:Stop()
          EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {unexpectedDisconnect = true})
        elseif
          targetLevel == "FULL" and
          self.hmiLevel ~= "FULL" then
            ActivationApp(self)

            EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
            :Do(function(_,data)
                self.mobileSession:Stop()
                EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {unexpectedDisconnect = true})
              end)
          elseif
            targetLevel == "LIMITED" and
            self.hmiLevel ~= "LIMITED" then

              if self.hmiLevel ~= "FULL" then
                ActivationApp(self)
                EXPECT_NOTIFICATION("OnHMIStatus",
                  {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"},
                  {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
                :Do(function(exp,data)
                    if exp.occurences == 2 then
                      self.mobileSession:Stop()
                      EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {unexpectedDisconnect = true})
                    end
                  end)

                --hmi side: sending BasicCommunication.OnAppDeactivated notification
                self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
              else
                --hmi side: sending BasicCommunication.OnAppDeactivated notification
                self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})

                EXPECT_NOTIFICATION("OnHMIStatus",
                  {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
                :Do(function(exp,data)
                    self.mobileSession:Stop()
                    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {unexpectedDisconnect = true})
                  end)
              end
            elseif
              (targetLevel == "LIMITED" and
                self.hmiLevel == "LIMITED") or
              (targetLevel == "FULL" and
                self.hmiLevel == "FULL") then
                self.mobileSession:Stop()
                EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {unexpectedDisconnect = true})
              end
            end

            local function RegisterApp_HMILevelResumption_3_sec(self, HMILevel, reason)

              if HMILevel == "FULL" then
                local AppValuesOnHMIStatus = AppValuesOnHMIStatusFULL
              elseif HMILevel == "LIMITED" then
                local AppValuesOnHMIStatus = AppValuesOnHMIStatusLIMITED
              end

              local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
              -- got time after RAI request
              local time = timestamp()

              if reason == "IGN_OFF" then
                local RAIAfterOnReady = time - self.timeOnReady
                userPrint( 33, "Time of sending RAI request after OnReady notification " ..tostring(RAIAfterOnReady))
              end

              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
              :Do(function(_,data)
                  HMIAppID = data.params.application.appID
                  self.applications[config.application1.registerAppInterfaceParams.appName] = data.params.application.appID
                end)

              self.mobileSession:ExpectResponse(correlationId, { success = true })

              if HMILevel == "FULL" then
                EXPECT_HMICALL("BasicCommunication.ActivateApp")
                :Do(function(_,data)
                    self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                  end)
              elseif HMILevel == "LIMITED" then
                EXPECT_HMINOTIFICATION("BasicCommunication.OnResumeAudioSource", {appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
              end

              EXPECT_NOTIFICATION("OnHMIStatus",
                AppValuesOnHMIStatusDEFAULT,
                AppValuesOnHMIStatus)
              :ValidIf(function(exp,data)
                  if exp.occurences == 2 then
                    local time2 = timestamp()
                    local timeToresumption = time2 - time
                    if timeToresumption >= 3000 and
                    timeToresumption < 3100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return false
                    end

                  elseif exp.occurences == 1 then
                    return true
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(2)

              --mobile side: expect OnHashChange notification
              EXPECT_NOTIFICATION("OnHashChange")
              :Times(1)

            end

            local function RegisterApp_HMILevelResumption_6_sec(self, HMILevel, reason)

              if HMILevel == "FULL" then
                local AppValuesOnHMIStatus = AppValuesOnHMIStatusFULL
              elseif HMILevel == "LIMITED" then
                local AppValuesOnHMIStatus = AppValuesOnHMIStatusLIMITED
              end

              local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
              -- got time after RAI request
              local time = timestamp()

              if reason == "IGN_OFF" then
                local RAIAfterOnReady = time - self.timeOnReady
                userPrint( 33, "Time of sending RAI request after OnReady notification " ..tostring(RAIAfterOnReady))
              end

              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
              :Do(function(_,data)
                  HMIAppID = data.params.application.appID
                  self.applications[config.application1.registerAppInterfaceParams.appName] = data.params.application.appID
                end)

              self.mobileSession:ExpectResponse(correlationId, { success = true })

              if HMILevel == "FULL" then
                EXPECT_HMICALL("BasicCommunication.ActivateApp")
                :Do(function(_,data)
                    self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                  end)
              elseif HMILevel == "LIMITED" then
                EXPECT_HMINOTIFICATION("BasicCommunication.OnResumeAudioSource", {appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
              end

              EXPECT_NOTIFICATION("OnHMIStatus",
                AppValuesOnHMIStatusDEFAULT,
                AppValuesOnHMIStatus)
              :ValidIf(function(exp,data)
                  if exp.occurences == 2 then
                    local time2 = timestamp()
                    local timeToresumption = time2 - time
                    if timeToresumption >= 6000 and
                    timeToresumption < 6100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return false
                    end

                  elseif exp.occurences == 1 then
                    return true
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(2)

              --mobile side: expect OnHashChange notification
              EXPECT_NOTIFICATION("OnHashChange")
              :Times(1)

            end

            --Precondition: Unregister registered app
            local function UnregisterAppInterface_Success(self, sessionName, iappName)
              if sessionName == nil then
                sessionName = self.mobileSession
              end

              if iappName == nil then
                iappName = config.application1.registerAppInterfaceParams.appName
              end

              --mobile side: UnregisterAppInterface request
              local CorIdURAI = sessionName:SendRPC("UnregisterAppInterface", {})

              --hmi side: expected BasicCommunication.OnAppUnregistered
              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[iappName], unexpectedDisconnect = false})

              --mobile side: UnregisterAppInterface response
              sessionName:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})
              :Do(function()
                  sessionName:Stop()
                end)

            end

            -- Stop SDL, optionaly changing values ApplicationResumingTimeout, start SDL, HMI initialization, create mobile connection
            local function SetApplicationResumingTimeout(self, prefix, ApplicationResumingTimeoutValueToReplace, ApplicationResumingTimeout)

              checkSDLPathValue()

              SDLStoragePath = config.pathToSDL .. "storage/"

              local SDLini = config.pathToSDL .. tostring("smartDeviceLink.ini")

              Test["StopSDL_" .. tostring(prefix)] = function(self)
                StopSDL()
              end

              if ApplicationResumingTimeout == true then
                Test["Precondition_ApplicationResumingTimeoutChange_" .. tostring(prefix)] = function(self)
                  local StringToReplace = "ApplicationResumingTimeout = " .. tostring(ApplicationResumingTimeoutValueToReplace) .. "\n"
                  f = assert(io.open(SDLini, "r"))
                  if f then
                    fileContent = f:read("*all")
                    local MatchResult = string.match(fileContent, "ApplicationResumingTimeout%s-=%s-.-%s-\n")
                    if MatchResult ~= nil then
                      fileContentUpdated = string.gsub(fileContent, MatchResult, StringToReplace)
                      f = assert(io.open(SDLini, "w"))
                      f:write(fileContentUpdated)
                    else
                      userPrint(31, "Finding of 'ApplicationResumingTimeout = value' is failed. Expect string finding and replacing of value to " .. tostring(ApplicationResumingTimeoutValueToReplace))
                    end
                    f:close()
                  end
                end
              end

              Test["StartSDL_" .. tostring(prefix)] = function(self)
                StartSDL(config.pathToSDL, config.ExitOnCrash)
                DelayedExp(1000)
              end

              Test["InitHMI_" .. tostring(prefix)] = function(self)
                self:initHMI()
              end

              Test["InitHMIonReady_" .. tostring(prefix)] = function(self)
                self:initHMI_onReady()
              end

              Test["ConnectMobile_" .. tostring(prefix)] = function(self)
                self:connectMobile()
              end
            end

            --////////////////////////////////////////////////////////////////////////////////////////////--
            --Resumption of HMIlevel by closing session
            -- covers TC_Configure_ResumingTimeout_01 - APPLINK-15887
            -- Check that resuming HMI level starts after 3 second if no apps registered.
            --////////////////////////////////////////////////////////////////////////////////////////////--

            function Test:Precondition_ActivateToFull()
              userPrint(35, "================= Precondition ==================")
              if self.hmiLevel ~= "FULL" then
                ActivationApp(self)

                EXPECT_NOTIFICATION("OnHMIStatus", AppValuesOnHMIStatusFULL)
                :Do(function(_,data)
                    self.hmiLevel = data.payload.hmiLevel
                  end)
              end

            end

            function Test:CloseSession()
              CloseSessionCheckLevel(self, "FULL")
            end

            --======================================================================================--
            --Resumption of FULL hmiLevel
            --======================================================================================--

            --Precondition: Set ApplicationResumingTimeout = 3000 in .ini file

            SetApplicationResumingTimeout(self, "prefix", 3000, true)

            function Test:StartSession()
              self.mobileSession = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                config.application1.registerAppInterfaceParams)
            end

            function Test:Resumption_FULL_ByClosing_Session_3_sec()
              userPrint(34, "=================== Test Case ===================")

              self.mobileSession:StartService(7)
              :Do(function(_,data)
                  RegisterApp_HMILevelResumption_3_sec(self, "FULL")
                end)

            end

            function Test:Postcondition_UnregisterApp_Gracefully()
              UnregisterAppInterface_Success(self, self.mobileSession, self.applications)
            end

            --////////////////////////////////////////////////////////////////////////////////////////////--
            --Resumption of HMIlevel by closing session
            -- covers TC_Configure_ResumingTimeout_02 - APPLINK-15890
            -- Check that resuming HMI level starts after 6 second if no apps registered.
            --////////////////////////////////////////////////////////////////////////////////////////////--

            --Precondition: Set ApplicationResumingTimeout = 6000 in .ini file

            SetApplicationResumingTimeout(self, "prefix", 6000, true)

            function Test:StartSession()
              self:startSession()

            end

            function Test:Precondition_ActivateToFull()
              userPrint(35, "================= Precondition ==================")

              ActivationApp(self)

              EXPECT_NOTIFICATION("OnHMIStatus", AppValuesOnHMIStatusFULL)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)

            end

            function Test:CloseSession()
              CloseSessionCheckLevel(self, "FULL")
            end

            function Test:StartSession()

              self.mobileSession = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                config.application1.registerAppInterfaceParams)

            end

            --======================================================================================--
            --Resumption of FULL hmiLevel
            --======================================================================================--
            function Test:Resumption_FULL_ByClosing_Session_6_sec()
              userPrint(34, "=================== Test Case ===================")

              self.mobileSession:StartService(7)
              :Do(function(_,data)
                  RegisterApp_HMILevelResumption_6_sec(self, "FULL")
                end)

            end

            function Test:Postcondition_UnregisterApp_Gracefully()
              UnregisterAppInterface_Success(self, self.mobileSession, self.applications)
            end

            --////////////////////////////////////////////////////////////////////////////////////////////--
            --Resumption of HMIlevel by closing connection
            -- covers TC_Configure_ResumingTimeout_03 - APPLINK-15891
            -- Check that resuming HMI levels of 3 apps starts after 3 second if no apps registered before. (Non-media =Full, Media = Background, Media = Limited)
            --////////////////////////////////////////////////////////////////////////////////////////////--

            --Precondition: Set ApplicationResumingTimeout = 3000 in .ini file

            SetApplicationResumingTimeout(self, "prefix", 3000, true)

            -- Registration and activation of apps

            function Test:StartSession1()
              userPrint(35, "================= Precondition ==================")
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)
            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)
            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)
            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                end)
            end

            function Test:Precondition_ActivateMedia1()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp1 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus", AppValuesOnHMIStatusFULL)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateMedia2()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp2 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(2)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateNonMedia()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDNonMediaApp })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(3)

                      end)

                  end
                end)

            end

            function Test:CloseConnection()
              self.mobileConnection:Close()
            end

            function Test:ConnectMobile()
              self:connectMobile()
            end

            function Test:StartSession1()
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)

            end

            function Test:RegisterMediaApp1()

              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time1 = timestamp()
                end)

            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)

            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time2 = timestamp()
                end)

            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)

            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                  -- got time after RAI request
                  time3 = timestamp()
                end)
            end

            function Test:Resumption_FULLnonmedia_LIMITEDmedia_NONEmedia_3_sec()
              userPrint(34, "=================== Test Case ===================")

              EXPECT_HMICALL("BasicCommunication.ActivateApp",{appID = HMIAppIDNonMediaApp})
              :Do(function(_,data)
                  self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                end)

              EXPECT_HMINOTIFICATION("BasicCommunication.OnResumeAudioSource",
                {appID = HMIAppIDMediaApp2})
              :Times(1)

              self.mobileSession2:ExpectNotification("OnHMIStatus",
                {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time2
                    if timeToresumption >= 3000 and
                    timeToresumption < 3100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession3:ExpectNotification("OnHMIStatus",
                {hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time3
                    if timeToresumption >= 3000 and
                    timeToresumption < 3100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession1:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

            end

            function Test:Postcondition_UnregisterApps_Gracefully()
              --mobile side: UnregisterAppInterface request
              self.mobileSession1:SendRPC("UnregisterAppInterface", {})

              --hmi side: expected BasicCommunication.OnAppUnregistered
              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
                {appID = HMIAppIDMediaApp1, unexpectedDisconnect = false},
                {appID = HMIAppIDMediaApp2, unexpectedDisconnect = false},
                {appID = HMIAppIDNonMediaApp, unexpectedDisconnect = false})
              :Times(3)

              --mobile side: UnregisterAppInterface response
              self.mobileSession1:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession2:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession2:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession3:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession3:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

            end

            function Test:CloseSession1()
              self.mobileSession1:Stop()
            end

            function Test:CloseSession2()
              self.mobileSession2:Stop()
            end

            function Test:CloseSession3()
              self.mobileSession3:Stop()
            end

            --////////////////////////////////////////////////////////////////////////////////////////////--
            --Resumption of HMIlevel by closing connection
            -- covers TC_Configure_ResumingTimeout_04 - APPLINK-15892
            -- Check that resuming HMI levels of 3 apps starts after 6 second if no apps registered before (Non-media =Full, Media = Background, Media = Limited)
            --////////////////////////////////////////////////////////////////////////////////////////////--

            --Precondition: Set ApplicationResumingTimeout = 6000 in .ini file

            SetApplicationResumingTimeout(self, "prefix", 6000, true)

            -- Registration and activation of apps

            function Test:StartSession1()
              userPrint(35, "================= Precondition ==================")
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)
            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)
            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)
            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                end)
            end

            function Test:Precondition_ActivateMedia1()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp1 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus", AppValuesOnHMIStatusFULL)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateMedia2()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp2 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(2)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateNonMedia()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDNonMediaApp })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(3)

                      end)

                  end
                end)

            end

            function Test:CloseConnection()
              self.mobileConnection:Close()
            end

            function Test:ConnectMobile()
              self:connectMobile()
            end

            function Test:StartSession1()
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)

            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time4 = timestamp()
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)

            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time5 = timestamp()
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)

            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                  -- got time after RAI request
                  time6 = timestamp()
                end)
            end

            function Test:Resumption_FULLnonmedia_LIMITEDmedia_NONEmedia_6_sec()
              userPrint(34, "=================== Test Case ===================")

              EXPECT_HMICALL("BasicCommunication.ActivateApp",{appID = HMIAppIDNonMediaApp})
              :Do(function(_,data)
                  self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                end)

              EXPECT_HMINOTIFICATION("BasicCommunication.OnResumeAudioSource",
                {appID = HMIAppIDMediaApp2})
              :Times(1)

              self.mobileSession2:ExpectNotification("OnHMIStatus",
                {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time5
                    if timeToresumption >= 6000 and
                    timeToresumption < 6100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession3:ExpectNotification("OnHMIStatus",
                {hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time6
                    if timeToresumption >= 6000 and
                    timeToresumption < 6100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return false
                    end

                  elseif exp.occurences == 1 then
                    return true
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession1:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

            end

            function Test:Postcondition_UnregisterApps_Gracefully()
              --mobile side: UnregisterAppInterface request
              self.mobileSession1:SendRPC("UnregisterAppInterface", {})

              --hmi side: expected BasicCommunication.OnAppUnregistered
              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
                {appID = HMIAppIDMediaApp1, unexpectedDisconnect = false},
                {appID = HMIAppIDMediaApp2, unexpectedDisconnect = false},
                {appID = HMIAppIDNonMediaApp, unexpectedDisconnect = false})
              :Times(3)

              --mobile side: UnregisterAppInterface response
              self.mobileSession1:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession2:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession2:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession3:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession3:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

            end

            function Test:CloseSession1()
              self.mobileSession1:Stop()
            end

            function Test:CloseSession2()
              self.mobileSession2:Stop()
            end

            function Test:CloseSession3()
              self.mobileSession3:Stop()
            end

            --////////////////////////////////////////////////////////////////////////////////////////////--
            --Resumption of HMIlevel by closing connection
            -- covers TC_Configure_ResumingTimeout_05 - APPLINK-15893
            -- Check that resuming HMI level starts after 3 second if some app already registered
            --////////////////////////////////////////////////////////////////////////////////////////////--

            --Precondition: Set ApplicationResumingTimeout = 3000 in .ini file

            SetApplicationResumingTimeout(self, "prefix", 3000, true)

            function Test:StartSession1()
              userPrint(35, "================= Precondition ==================")
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)
            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession1, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:Precondition_ActivateMedia1()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp1 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus", AppValuesOnHMIStatusFULL)

                      end)

                  end
                end)

            end

            function Test:CloseConnection()
              self.mobileConnection:Close()
            end

            function Test:Precondition_OpenSecondConnectionCreateSession()
              local tcpConnection = tcp.Connection("192.168.100.199", config.mobilePort)
              local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
              self.mobileConnection2 = mobile.MobileConnection(fileConnection)
              self.mobileSession4= mobile_session.MobileSession(
                self,
                self.mobileConnection2)
              event_dispatcher:AddConnection(self.mobileConnection2)
              self.mobileSession4:ExpectEvent(events.connectedEvent, "Connection started")
              self.mobileConnection2:Connect()

              self.mobileSession4:StartService(7)

            end

            function Test:Precondition_RegisterApp_SecondDevice()

              RegisterApp(self, self.mobileSession4, applicationData.communicationApp, AppValuesOnHMIStatusDEFAULTCommunicationApp)

            end

            function Test:ConnectMobile()
              self:connectMobile()
            end

            function Test:StartSession1()
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)

            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession1, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time7 = timestamp()
                end)
            end

            function Test:Resumption_FULL_Some_App_already_registered_3_sec()
              userPrint(34, "=================== Test Case ===================")

              EXPECT_HMICALL("BasicCommunication.ActivateApp",{appID = HMIAppIDMediaApp1})
              :Do(function(_,data)
                  self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                end)

              self.mobileSession1:ExpectNotification("OnHMIStatus",
                {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time7
                    if timeToresumption >= 3000 and
                    timeToresumption < 3100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession4:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

            end

            function Test:Postcondition_UnregisterApps_Gracefully()
              --mobile side: UnregisterAppInterface request
              self.mobileSession1:SendRPC("UnregisterAppInterface", {})

              --hmi side: expected BasicCommunication.OnAppUnregistered
              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
                {appID = HMIAppIDMediaApp1, unexpectedDisconnect = false},
                {appID = HMIAppIDComApp, unexpectedDisconnect = false})
              :Times(2)

              --mobile side: UnregisterAppInterface response
              self.mobileSession1:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession4:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession4:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

            end

            --////////////////////////////////////////////////////////////////////////////////////////////--
            --Resumption of HMIlevel by closing connection
            -- covers TC_Configure_ResumingTimeout_06 - APPLINK-15894
            -- Check that resuming HMI level starts after 6 seconds if some app already registered
            --////////////////////////////////////////////////////////////////////////////////////////////--

            --Precondition: Set ApplicationResumingTimeout = 6000 in .ini file

            SetApplicationResumingTimeout(self, "prefix", 6000, true)

            function Test:StartSession1()
              userPrint(35, "================= Precondition ==================")
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)
            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession1, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:Precondition_ActivateMedia1()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp1 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus", AppValuesOnHMIStatusFULL)

                      end)

                  end
                end)

            end

            function Test:CloseConnection()
              self.mobileConnection:Close()
            end

            function Test:Precondition_OpenSecondConnectionCreateSession()
              local tcpConnection = tcp.Connection("192.168.100.199", config.mobilePort)
              local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
              self.mobileConnection2 = mobile.MobileConnection(fileConnection)
              self.mobileSession4= mobile_session.MobileSession(
                self,
                self.mobileConnection2)
              event_dispatcher:AddConnection(self.mobileConnection2)
              self.mobileSession4:ExpectEvent(events.connectedEvent, "Connection started")
              self.mobileConnection2:Connect()

              self.mobileSession4:StartService(7)

            end

            function Test:Precondition_RegisterApp_SecondDevice()

              RegisterApp(self, self.mobileSession4, applicationData.communicationApp, AppValuesOnHMIStatusDEFAULTCommunicationApp)

            end

            function Test:ConnectMobile()
              self:connectMobile()
            end

            function Test:StartSession1()
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)

            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession1, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time8 = timestamp()
                end)
            end

            function Test:Resumption_FULL_Some_App_already_registered_6_sec()
              userPrint(34, "=================== Test Case ===================")

              EXPECT_HMICALL("BasicCommunication.ActivateApp",{appID = HMIAppIDMediaApp1})
              :Do(function(_,data)
                  self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                end)

              self.mobileSession1:ExpectNotification("OnHMIStatus",
                {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time8
                    if timeToresumption >= 6000 and
                    timeToresumption < 6100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession4:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

            end

            function Test:Postcondition_UnregisterApps_Gracefully()
              --mobile side: UnregisterAppInterface request
              self.mobileSession1:SendRPC("UnregisterAppInterface", {})

              --hmi side: expected BasicCommunication.OnAppUnregistered
              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
                {appID = HMIAppIDMediaApp1, unexpectedDisconnect = false},
                {appID = HMIAppIDComApp, unexpectedDisconnect = false})
              :Times(2)

              --mobile side: UnregisterAppInterface response
              self.mobileSession1:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession4:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession4:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

            end

            --////////////////////////////////////////////////////////////////////////////////////////////--
            --Resumption of HMIlevel by closing connection
            -- covers TC_Configure_ResumingTimeout_07 - APPLINK-15895
            -- Check that resuming HMI levels of 3 apps starts after 3 seconds if some app registered before (App1=Full, app2=Background, app3=Limited).
            --////////////////////////////////////////////////////////////////////////////////////////////--

            --Precondition: Set ApplicationResumingTimeout = 3000 in .ini file

            SetApplicationResumingTimeout(self, "prefix", 3000, true)

            -- Registration and activation of apps

            function Test:StartSession1()
              userPrint(35, "================= Precondition ==================")
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)
            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)
            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)
            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                end)
            end

            function Test:Precondition_ActivateMedia1()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp1 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus", AppValuesOnHMIStatusFULL)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateMedia2()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp2 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(2)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateNonMedia()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDNonMediaApp })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(3)

                      end)

                  end
                end)

            end

            function Test:CloseConnection()
              self.mobileConnection:Close()
            end

            function Test:Precondition_OpenSecondConnectionCreateSession()
              local tcpConnection = tcp.Connection("192.168.100.199", config.mobilePort)
              local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
              self.mobileConnection2 = mobile.MobileConnection(fileConnection)
              self.mobileSession4= mobile_session.MobileSession(
                self,
                self.mobileConnection2)
              event_dispatcher:AddConnection(self.mobileConnection2)
              self.mobileSession4:ExpectEvent(events.connectedEvent, "Connection started")
              self.mobileConnection2:Connect()

              self.mobileSession4:StartService(7)

            end

            function Test:Precondition_RegisterApp_SecondDevice()

              RegisterApp(self, self.mobileSession4, applicationData.communicationApp, AppValuesOnHMIStatusDEFAULTCommunicationApp)

            end

            function Test:ConnectMobile()
              self:connectMobile()
            end

            function Test:StartSession1()
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)

            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time9 = timestamp()
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)

            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time10 = timestamp()
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)

            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                  -- got time after RAI request
                  time11 = timestamp()
                end)
            end

            function Test:Resumption_FULLnonmedia_LIMITEDmedia_NONEmedia_3_sec_Some_App_registered()
              userPrint(34, "=================== Test Case ===================")

              EXPECT_HMICALL("BasicCommunication.ActivateApp",{appID = HMIAppIDNonMediaApp})
              :Do(function(_,data)
                  self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                end)

              EXPECT_HMINOTIFICATION("BasicCommunication.OnResumeAudioSource",
                {appID = HMIAppIDMediaApp2})
              :Times(1)

              self.mobileSession2:ExpectNotification("OnHMIStatus",
                {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time10
                    if timeToresumption >= 3000 and
                    timeToresumption < 3100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession3:ExpectNotification("OnHMIStatus",
                {hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time11
                    if timeToresumption >= 3000 and
                    timeToresumption < 3100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession1:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

              self.mobileSession4:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

            end

            function Test:Postcondition_UnregisterApps_Gracefully()
              --mobile side: UnregisterAppInterface request
              self.mobileSession1:SendRPC("UnregisterAppInterface", {})

              --hmi side: expected BasicCommunication.OnAppUnregistered
              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
                {appID = HMIAppIDMediaApp1, unexpectedDisconnect = false},
                {appID = HMIAppIDMediaApp2, unexpectedDisconnect = false},
                {appID = HMIAppIDNonMediaApp, unexpectedDisconnect = false},
                {appID = HMIAppIDComApp, unexpectedDisconnect = false})
              :Times(4)

              --mobile side: UnregisterAppInterface response
              self.mobileSession1:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession2:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession2:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession3:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession3:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession4:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession4:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

            end

            function Test:CloseSession1()
              self.mobileSession1:Stop()
            end

            function Test:CloseSession2()
              self.mobileSession2:Stop()
            end

            function Test:CloseSession3()
              self.mobileSession3:Stop()
            end

            function Test:CloseConnection2()
              self.mobileConnection2:Close()
            end

            --////////////////////////////////////////////////////////////////////////////////////////////--
            --Resumption of HMIlevel by closing connection
            -- covers TC_Configure_ResumingTimeout_08 - APPLINK-15896
            -- Check that resuming HMI levels of 3 apps starts after 6 seconds if some app registered before (App1=Full, app2=Background, app3=Limited).
            --////////////////////////////////////////////////////////////////////////////////////////////--

            --Precondition: Set ApplicationResumingTimeout = 6000 in .ini file

            SetApplicationResumingTimeout(self, "prefix", 6000, true)

            -- Registration and activation of apps

            function Test:StartSession1()
              userPrint(35, "================= Precondition ==================")
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)
            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)
            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)
            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                end)
            end

            function Test:Precondition_ActivateMedia1()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp1 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus", AppValuesOnHMIStatusFULL)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateMedia2()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp2 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(2)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateNonMedia()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDNonMediaApp })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(3)

                      end)

                  end
                end)

            end

            function Test:CloseConnection()
              self.mobileConnection:Close()
            end

            function Test:Precondition_OpenSecondConnectionCreateSession()
              local tcpConnection = tcp.Connection("192.168.100.199", config.mobilePort)
              local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
              self.mobileConnection2 = mobile.MobileConnection(fileConnection)
              self.mobileSession4= mobile_session.MobileSession(
                self,
                self.mobileConnection2)
              event_dispatcher:AddConnection(self.mobileConnection2)
              self.mobileSession4:ExpectEvent(events.connectedEvent, "Connection started")
              self.mobileConnection2:Connect()

              self.mobileSession4:StartService(7)

            end

            function Test:Precondition_RegisterApp_SecondDevice()

              RegisterApp(self, self.mobileSession4, applicationData.communicationApp, AppValuesOnHMIStatusDEFAULTCommunicationApp)

            end

            function Test:ConnectMobile()
              self:connectMobile()
            end

            function Test:StartSession1()
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)

            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time12 = timestamp()
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)

            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time13 = timestamp()
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)

            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                  -- got time after RAI request
                  time14 = timestamp()
                end)
            end

            function Test:Resumption_FULLnonmedia_LIMITEDmedia_NONEmedia_6_sec_Some_App_registered()
              userPrint(34, "=================== Test Case ===================")

              EXPECT_HMICALL("BasicCommunication.ActivateApp",{appID = HMIAppIDNonMediaApp})
              :Do(function(_,data)
                  self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                end)

              EXPECT_HMINOTIFICATION("BasicCommunication.OnResumeAudioSource",
                {appID = HMIAppIDMediaApp2})
              :Times(1)

              self.mobileSession2:ExpectNotification("OnHMIStatus",
                {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time13
                    if timeToresumption >= 6000 and
                    timeToresumption < 6100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession3:ExpectNotification("OnHMIStatus",
                {hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time14
                    if timeToresumption >= 6000 and
                    timeToresumption < 6100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return false
                    end

                  elseif exp.occurences == 1 then
                    return true
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession1:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

              self.mobileSession4:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

            end

            function Test:Postcondition_UnregisterApps_Gracefully()
              --mobile side: UnregisterAppInterface request
              self.mobileSession1:SendRPC("UnregisterAppInterface", {})

              --hmi side: expected BasicCommunication.OnAppUnregistered
              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
                {appID = HMIAppIDMediaApp1, unexpectedDisconnect = false},
                {appID = HMIAppIDMediaApp2, unexpectedDisconnect = false},
                {appID = HMIAppIDNonMediaApp, unexpectedDisconnect = false},
                {appID = HMIAppIDComApp, unexpectedDisconnect = false})
              :Times(4)

              --mobile side: UnregisterAppInterface response
              self.mobileSession1:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession2:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession2:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession3:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession3:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession4:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession4:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

            end

            function Test:CloseSession1()
              self.mobileSession1:Stop()
            end

            function Test:CloseSession2()
              self.mobileSession2:Stop()
            end

            function Test:CloseSession3()
              self.mobileSession3:Stop()
            end

            function Test:CloseConnection2()
              self.mobileConnection2:Close()
            end

            --////////////////////////////////////////////////////////////////////////////////////////////--
            --Resumption of HMIlevel by Ignition off
            -- covers TC_Configure_ResumingTimeout_09 - APPLINK-15897
            -- Check that resuming HMI levels of 3 apps starts after 3 second if some app registered after IGN_CYCLE (App1=Full, app2=Background, app3=Limited)
            --////////////////////////////////////////////////////////////////////////////////////////////--

            --Precondition: Set ApplicationResumingTimeout = 3000 in .ini file

            SetApplicationResumingTimeout(self, "prefix", 3000, true)

            -- Registration and activation of apps

            function Test:StartSession1()
              userPrint(35, "================= Precondition ==================")
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)
            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)
            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)
            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                end)
            end

            function Test:Precondition_ActivateMedia1()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp1 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus", AppValuesOnHMIStatusFULL)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateMedia2()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp2 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(2)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateNonMedia()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDNonMediaApp })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(3)

                      end)

                  end
                end)

            end

            function Test:CloseConnection()
              self.mobileConnection:Close()
            end

            function Test:IGNITION_OFF()
              IGNITION_OFF(self)
            end

            function Test:StartSDL()
              StartSDL(config.pathToSDL, config.ExitOnCrash)
            end

            function Test:InitHMI()
              self:initHMI()
            end

            function Test:InitHMI_onReady()
              self:initHMI_onReady()
            end

            function Test:Precondition_OpenSecondConnectionCreateSession()
              local tcpConnection = tcp.Connection("192.168.100.199", config.mobilePort)
              local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
              self.mobileConnection2 = mobile.MobileConnection(fileConnection)
              self.mobileSession4= mobile_session.MobileSession(
                self,
                self.mobileConnection2)
              event_dispatcher:AddConnection(self.mobileConnection2)
              self.mobileSession4:ExpectEvent(events.connectedEvent, "Connection started")
              self.mobileConnection2:Connect()

              self.mobileSession4:StartService(7)

            end

            function Test:Precondition_RegisterApp_SecondDevice()

              RegisterApp(self, self.mobileSession4, applicationData.communicationApp, AppValuesOnHMIStatusDEFAULTCommunicationApp)

            end

            function Test:ConnectMobile()
              self:connectMobile()
            end

            function Test:StartSession1()
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)
            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time15 = timestamp()
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)
            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time16 = timestamp()
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)
            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                  -- got time after RAI request
                  time17 = timestamp()
                end)
            end

            function Test:Resumption_3_apps_IGN_OFF_3_sec_Some_App_registered()
              userPrint(34, "=================== Test Case ===================")

              EXPECT_HMICALL("BasicCommunication.ActivateApp",{appID = HMIAppIDNonMediaApp})
              :Do(function(_,data)
                  self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                end)

              EXPECT_HMINOTIFICATION("BasicCommunication.OnResumeAudioSource",
                {appID = HMIAppIDMediaApp2})
              :Times(1)

              self.mobileSession2:ExpectNotification("OnHMIStatus",
                {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time16
                    if timeToresumption >= 3000 and
                    timeToresumption < 3100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession3:ExpectNotification("OnHMIStatus",
                {hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time17
                    if timeToresumption >= 3000 and
                    timeToresumption < 3100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession1:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

              self.mobileSession4:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

            end

            function Test:Postcondition_UnregisterApps_Gracefully()
              --mobile side: UnregisterAppInterface request
              self.mobileSession1:SendRPC("UnregisterAppInterface", {})

              --hmi side: expected BasicCommunication.OnAppUnregistered
              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
                {appID = HMIAppIDMediaApp1, unexpectedDisconnect = false},
                {appID = HMIAppIDMediaApp2, unexpectedDisconnect = false},
                {appID = HMIAppIDNonMediaApp, unexpectedDisconnect = false},
                {appID = HMIAppIDComApp, unexpectedDisconnect = false})
              :Times(4)

              --mobile side: UnregisterAppInterface response
              self.mobileSession1:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession2:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession2:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession3:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession3:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession4:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession4:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

            end

            function Test:CloseSession1()
              self.mobileSession1:Stop()
            end

            function Test:CloseSession2()
              self.mobileSession2:Stop()
            end

            function Test:CloseSession3()
              self.mobileSession3:Stop()
            end

            function Test:CloseConnection2()
              self.mobileConnection2:Close()
            end

            --////////////////////////////////////////////////////////////////////////////////////////////--
            --Resumption of HMIlevel by Ignition off
            -- covers TC_Configure_ResumingTimeout_10 - APPLINK-15898
            -- Check that resuming HMI levels of 3 apps starts after 6 second if some app registered after IGN_CYCLE (App1=Full, app2=Background, app3=Limited)
            --////////////////////////////////////////////////////////////////////////////////////////////--

            --Precondition: Set ApplicationResumingTimeout = 6000 in .ini file

            SetApplicationResumingTimeout(self, "prefix", 6000, true)

            -- Registration and activation of apps

            function Test:StartSession1()
              userPrint(35, "================= Precondition ==================")
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)
            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)
            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)
            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                end)
            end

            function Test:Precondition_ActivateMedia1()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp1 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus", AppValuesOnHMIStatusFULL)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateMedia2()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDMediaApp2 })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(2)

                      end)

                  end
                end)

            end

            function Test:Precondition_ActivateNonMedia()
              --hmi side: sending SDL.ActivateApp
              local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = HMIAppIDNonMediaApp })
              -- hmi side: expect SDL.ActivateApp response
              EXPECT_HMIRESPONSE(RequestId)
              :Do(function(_,data)
                  -- In case when app is not allowed, it is needed to allow app
                  if
                  data.result.isSDLAllowed ~= true then

                    -- hmi side: sending SDL.GetUserFriendlyMessage request
                    local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
                      {language = "EN-US", messageCodes = {"DataConsent"}})

                    -- hmi side: expect SDL.GetUserFriendlyMessage response
                    -- TODO: comment until resolving APPLINK-16094
                    -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                    EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

                        -- hmi side: send request SDL.OnAllowSDLFunctionality
                        self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
                          {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

                        -- hmi side: expect BasicCommunication.ActivateApp request
                        EXPECT_HMICALL("BasicCommunication.ActivateApp")
                        :Do(function(_,data)

                            -- hmi side: sending BasicCommunication.ActivateApp response
                            self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

                          end)
                        :Times(2)

                        EXPECT_NOTIFICATION("OnHMIStatus",
                          { systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"},
                          { systemContext = "MAIN", hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE"})

                        :Times(3)

                      end)

                  end
                end)

            end

            function Test:CloseConnection()
              self.mobileConnection:Close()
            end

            function Test:IGNITION_OFF()
              IGNITION_OFF(self)
            end

            function Test:StartSDL()
              StartSDL(config.pathToSDL, config.ExitOnCrash)
            end

            function Test:InitHMI()
              self:initHMI()
            end

            function Test:InitHMI_onReady()
              self:initHMI_onReady()
            end

            function Test:Precondition_OpenSecondConnectionCreateSession()
              local tcpConnection = tcp.Connection("192.168.100.199", config.mobilePort)
              local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
              self.mobileConnection2 = mobile.MobileConnection(fileConnection)
              self.mobileSession4= mobile_session.MobileSession(
                self,
                self.mobileConnection2)
              event_dispatcher:AddConnection(self.mobileConnection2)
              self.mobileSession4:ExpectEvent(events.connectedEvent, "Connection started")
              self.mobileConnection2:Connect()

              self.mobileSession4:StartService(7)

            end

            function Test:Precondition_RegisterApp_SecondDevice()

              RegisterApp(self, self.mobileSession4, applicationData.communicationApp, AppValuesOnHMIStatusDEFAULTCommunicationApp)

            end

            function Test:ConnectMobile()
              self:connectMobile()
            end

            function Test:StartSession1()
              self.mobileSession1 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp1)
            end

            function Test:RegisterMediaApp1()
              self.mobileSession1:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession, applicationData.mediaApp1, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time18 = timestamp()
                end)
            end

            function Test:StartSession2()
              self.mobileSession2 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.mediaApp2)
            end

            function Test:RegisterMediaApp2()
              self.mobileSession2:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession2, applicationData.mediaApp2, AppValuesOnHMIStatusDEFAULTMediaApp)
                  -- got time after RAI request
                  time19 = timestamp()
                end)
            end

            function Test:StartSession3()
              self.mobileSession3 = mobile_session.MobileSession(
                self,
                self.mobileConnection,
                applicationData.nonmediaApp)
            end

            function Test:RegisterNonMedia()
              self.mobileSession3:StartService(7)
              :Do(function()
                  RegisterApp(self, self.mobileSession3, applicationData.nonmediaApp, AppValuesOnHMIStatusDEFAULTNonMediaApp)
                  -- got time after RAI request
                  time20 = timestamp()
                end)
            end

            function Test:Resumption_3_apps_IGN_OFF_6_sec_Some_App_registered()
              userPrint(34, "=================== Test Case ===================")

              EXPECT_HMICALL("BasicCommunication.ActivateApp",{appID = HMIAppIDNonMediaApp})
              :Do(function(_,data)
                  self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
                end)

              EXPECT_HMINOTIFICATION("BasicCommunication.OnResumeAudioSource",
                {appID = HMIAppIDMediaApp2})
              :Times(1)

              self.mobileSession2:ExpectNotification("OnHMIStatus",
                {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time19
                    if timeToresumption >= 6000 and
                    timeToresumption < 6100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession3:ExpectNotification("OnHMIStatus",
                {hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
              :ValidIf(function(exp,data)
                  if exp.occurences == 1 then
                    local time = timestamp()
                    local timeToresumption = time - time20
                    if timeToresumption >= 6000 and
                    timeToresumption < 6100 then
                      userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return true
                    else
                      userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~6000 " )
                      return false
                    end
                  end
                end)
              :Do(function(_,data)
                  self.hmiLevel = data.payload.hmiLevel
                end)
              :Times(1)

              self.mobileSession1:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

              self.mobileSession4:ExpectNotification("OnHMIStatus",{})
              :Times(0)

              DelayedExp(1000)

            end

            function Test:Postcondition_UnregisterApps_Gracefully()
              --mobile side: UnregisterAppInterface request
              self.mobileSession1:SendRPC("UnregisterAppInterface", {})

              --hmi side: expected BasicCommunication.OnAppUnregistered
              EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered",
                {appID = HMIAppIDMediaApp1, unexpectedDisconnect = false},
                {appID = HMIAppIDMediaApp2, unexpectedDisconnect = false},
                {appID = HMIAppIDNonMediaApp, unexpectedDisconnect = false},
                {appID = HMIAppIDComApp, unexpectedDisconnect = false})
              :Times(4)

              --mobile side: UnregisterAppInterface response
              self.mobileSession1:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession2:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession2:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession3:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession3:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

              --mobile side: UnregisterAppInterface request
              self.mobileSession4:SendRPC("UnregisterAppInterface", {})

              --mobile side: UnregisterAppInterface response
              self.mobileSession4:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})

            end

            function Test:CloseSession1()
              self.mobileSession1:Stop()
            end

            function Test:CloseSession2()
              self.mobileSession2:Stop()
            end

            function Test:CloseSession3()
              self.mobileSession3:Stop()
            end

            function Test:CloseConnection2()
              self.mobileConnection2:Close()
            end
