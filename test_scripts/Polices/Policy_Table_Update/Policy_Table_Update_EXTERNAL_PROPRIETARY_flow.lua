--[[CRQ: APPLINK-29495: Policies - Policy Table Update (EXTERNAL_PROPRIETARY flow)

--[[Clarifications
  -- APPLINK-29758: Can you clarify the state of PTU(UPDATE_NEEDED) in previous ign_cycle according to APPLINK-18946
  -- APPLINK-29759: Non-conformity between requirements APPLINK-18966 and APPLINK-24148
  ]]

--[[General Precondition: all configuration files, policy, storage should be initial]]

--[[Testing coverage]]
  -- ToDo: until coverage check for other transports!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  --APPLINK-18952: [PolicyTableUpdate] Request PTU - an app registered is not listed in PT (device consented)
  --[[Tests:
	TC_01_PTU_AppID_NotListed_PT
    -- Preconditions
      1. Connect Device ID1. According to APPLINK-24148: isPermissionsConsentNeeded:false, Device is always consented.
    -- Test
	  1. Register App with ID = App1.
	  ExpRes: PTU is requested.
	TC_02_PTU_AppID_Listed_PT
    -- Preconditions
      1. Connect Device ID1. According to APPLINK-24148: isPermissionsConsentNeeded:false, Device is always consented.
	  2. Register App with ID = App1.
	  3. PTU is requested.
	  4. Unregister App with ID = App1. (app ID should be still listed in PT)
    -- Test
	  1. Register again App with ID = App1.
	  ExpRes: PTU should not be triggered.
	  2. Register again App with ID = App2.
	  ExpRes: PTU is requested.
	TC_03_PTU_AppIDs_NotListed_PT_DifferentDevices
    -- Preconditions
      1. Connect Device ID1. According to APPLINK-24148: isPermissionsConsentNeeded:false, Device is always consented.
	  2. Register App with ID = App1.
	  3. PTU is requested.
    -- Test
	  1. Connect Device ID2; Register App with ID = App2.
	  ExpRes: PTU is requested.
	TC_04_PTU_SameAppIDs_DifferentDevices
    -- Preconditions
      1. Connect Device ID1. According to APPLINK-24148: isPermissionsConsentNeeded:false, Device is always consented.
	  2. Register App with ID = App1.
	  3. PTU is requested.
    -- Test
	  1. Connect Device ID2; Register App with ID = App1, the same for DeviceID 1.
	  ExpRes: PTU is requested.
  ]]
  
  APPLINK-18946: [PolicyTableUpdate] Policy Table Update in case of failed retry strategy during previour IGN_ON (SDL.PolicyUpdate)
  --[[Tests:
    -- Waiting for clarification of APPLINK-29758: Can you clarify the state of PTU(UPDATE_NEEDED) in previous ign_cycle according to APPLINK-18946
	]]
	
  APPLINK-18966: [PolicyTableUpdate] PoliciesManager must initiate PTU in case getting 'device consent' from the user
  --[[Tests:
    -- Waiting for clarification of APPLINK-29759: Non-conformity between requirements APPLINK-18966 and APPLINK-24148
    ]]

  APPLINK-18967: [PolicyTableUpdate] PTU using consented device in case a user didn't consent the one which application required PTU
  --[[Tests:
    -- Waiting for clarification of APPLINK-29759: Non-conformity between requirements APPLINK-18966 and APPLINK-24148
    ]]
	
  APPLINK-23586: [Policies]: SDL.OnPolicyUpdate initiation of PTU
  --[[Tests:
    TC_05_User_initiates_PTU: [HP]
	-- Preconditions:
	  1. App is running on this device, and registerd on SDL
	-- Test
	  1. HMI -> SDL: SDL.OnPolicyUpdate
	  ExpRes: SDL->HMI: BasicCommunication.PolicyUpdate
	  1. PTS is created by SDL
	  2. HMI -> SDL: SDL.PolicyUpdate(SUCCESS)
	-- ToDo: During testing coverage check is there negative cases to be covered.
    ]]
	
  APPLINK-18991: [PolicyTableUpdate] PoliciesManager must initiate PTU on a User request	
  --[[Tests:
    TC_06_User_request_PTU: [HP]
	-- Preconditions:
	  1. App has registered and is in allowed HMILevel
	-- Test
	  1. HMI->SDL: SDL.UpdateSDL
	  ExpRes: SDL->HMI: SDL->HMI:SDL.UpdateSDL
	  1. PTS is created by SDL
	  2. HMI -> SDL: SDL.PolicyUpdate(SUCCESS)
	-- ToDo: During testing coverage check is there negative cases to be covered.
	]]
  
  APPLINK-17932: [PolicyTableUpdate] Request to update PT - after "N" ignition cycles
  --[[Tests:
    TC_07_No_PTU_After_N_ignition_cycles: [N]
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_ignition_cycles = #Ign_Cycle
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Check in PT "module_config": value of 'ignition_cycles_since_last_exchange' = <N>. Should be less than #Ign_Cycle
	    -- For First IGN_Cycle: <N> = 0
	  4. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  5. Clear PTS.
	-- Test:
	  1. IGN_OFF
	  2. HMI->SDL:BasicCommunication.OnIgnitionCycleOver
	  3. IGN_ON
	  ExpRes:
	  1. Increment "module_meta" -> "ignition_cycles_since_last_exchange" value = <N> + 1
	  2. SDL should not initiate PTU: SDL.OnStatusUpdate(UPDATE_NEEDED) should not be sent
	  3. PTS is not created by SDL: SDL.PolicyUpdate() //PTU sequence started is not sent
	
	TC_08_PTU_After_N_ignition_cycles: [HP]
	-- Preconditions:
	  1. Update in sdl_preloaded_pt.json, value of exchange_after_x_ignition_cycles = 2
	  2. First Ign_Cycle
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Check in PT "module_config": value of 'ignition_cycles_since_last_exchange' = 0. Should be less than exchange_after_x_ignition_cycles(2)
	  4. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  5. Clear PTS.
	  6. IGN_OFF
	  7. HMI->SDL:BasicCommunication.OnIgnitionCycleOver
	  8. IGN_ON => (ignition_cycles_since_last_exchange = 1) < exchange_after_x_ignition_cycles(2)
	  9. SDL should not initiate PTU; PTS is not created by SDL
	  10. IGN_OFF
	-- Test:
	  1. IGN_ON => (ignition_cycles_since_last_exchange = 2) == exchange_after_x_ignition_cycles(2)
	  2. HMI->SDL:BasicCommunication.OnIgnitionCycleOver
	  ExpRes:
	  1. SDL should initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
	  2. PTS is created by SDL: SDL-> HMI: SDL.PolicyUpdate() //PTU sequence started
	-- Postconditions:
	  1. IGN_OFF
	  2. HMI->SDL:BasicCommunication.OnIgnitionCycleOver
	  3. IGN_ON => (ignition_cycles_since_last_exchange = 3) > exchange_after_x_ignition_cycles(2)
	  4. SDL should not initiate PTU; PTS is not created by SDL
	
	TC_09_PTU_After_N_ignition_cycles: LongTerm test
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_ignition_cycles = #Ign_Cycle
	  2. First Ign_Cycle
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Check in PT "module_config": value of 'ignition_cycles_since_last_exchange' = 0. Should be less than exchange_after_x_ignition_cycles(2)
	  4. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  5. Clear PTS.
	  Do until (ignition_cycles_since_last_exchange = <N>) == #Ign_Cycle
	    6.1 IGN_OFF
	    6.2 HMI->SDL:BasicCommunication.OnIgnitionCycleOver
	    6.3 IGN_ON => (ignition_cycles_since_last_exchange = <N>) < exchange_after_x_ignition_cycles(#Ign_Cycle)
	    6.4 SDL should not initiate PTU; PTS is not created by SDL
	    6.5 IGN_OFF
	  End Do
	  As result of action 6 => ignition_cycles_since_last_exchange = #Ign_Cycle - 1
	
	-- Test:
	  1. IGN_ON => ignition_cycles_since_last_exchange = #Ign_Cycle
	  2. HMI->SDL:BasicCommunication.OnIgnitionCycleOver
	  ExpRes:
	  1. SDL should initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
	  2. PTS is created by SDL: SDL-> HMI: SDL.PolicyUpdate() //PTU sequence started
	-- Postconditions:
	  1. IGN_OFF
	  2. HMI->SDL:BasicCommunication.OnIgnitionCycleOver
	  3. IGN_ON => (ignition_cycles_since_last_exchange = #Ign_Cycle + 1) > exchange_after_x_ignition_cycles(#Ign_Cycle)
	  4. SDL should not initiate PTU; PTS is not created by SDL
    ]]
    
  APPLINK-17965: [PolicyTableUpdate] Request to update PT - after "N" kilometers
  --[[Tests:
    TC_10_No_PTU_After_N_kilometers:
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_kilometers = #ExchangeKilometers
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  4. Check the value of odometer received at this PTU = #Odometer1
	  => #ValueToCheck = #Odometer1 + #ExchangeKilometers
	-- Test:
	  1. HMI->SDL:OnVehcileData ("odometer": #ValueToCheck - #Odometer1)
	  ExpRes:
	  1. SDL should not initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is not sent.
	  2. PTS should not be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is not sent/
	
    TC_11_No_PTU_After_N_kilometers:
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_kilometers = #ExchangeKilometers
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  4. Check the value of odometer received at this PTU = #Odometer1
	  => #ValueToCheck = #Odometer1 + #ExchangeKilometers
	-- Test:
	  1. HMI->SDL:OnVehcileData ("odometer": #ValueToCheck - 1)
	  ExpRes:
	  1. SDL should not initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is not sent.
	  2. PTS should not be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is not sent/

	TC_12_PTU_After_N_kilometers:
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_kilometers = #ExchangeKilometers
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  4. Check the value of odometer received at this PTU = #Odometer1
	  => #ValueToCheck = #Odometer1 + #ExchangeKilometers
	-- Test:
	  1. HMI->SDL:OnVehcileData ("odometer": #ValueToCheck)
	  ExpRes:
	  1. SDL should initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is sent.
	  2. PTS should be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is sent//PTU sequence started
	  
    TC_13_PTU_After_N_kilometers:
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_kilometers = #ExchangeKilometers
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  4. Check the value of odometer received at this PTU = #Odometer1
	  => #ValueToCheck = #Odometer1 + #ExchangeKilometers
	-- Test:
	  1. HMI->SDL:OnVehcileData ("odometer": #ValueToCheck + 1)
	  ExpRes:
	  1. SDL should initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is sent.
	  2. PTS should be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is sent//PTU sequence started
	
	TC_14_PTU_After_N_kilometers:
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_kilometers = #ExchangeKilometers
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  4. Check the value of odometer received at this PTU = #Odometer1
	  => #ValueToCheck = #Odometer1 + #ExchangeKilometers
	  5. HMI->SDL:OnVehcileData ("odometer": #ValueToCheck + 1)
	  ExpRes:
	  1. SDL should initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is sent.
	  2. PTS should be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is sent//PTU sequence started
	  3. Check the value of odometer received at this PTU = #Odometer2
	  => #ValueToCheck = #Odometer2 + #ExchangeKilometers
	  4. Finish PTU sequence.
	-- Test:
	  1. HMI->SDL:OnVehcileData ("odometer": #ValueToCheck + 1)
	  ExpRes:
	  1. SDL should initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is sent.
	  2. PTS should be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is sent//PTU sequence started
    ]]

  APPLINK-17968: [PolicyTableUpdate] Request PTU - after "N" days
  --[[Tests:
    TC_15_No_PTU_After_N_days:
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_kilometers = #ExchangeDays
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  4. Check the value of date received at this PTU = #Date1
	  => #ValueToCheck = #Date1 + #ExchangeDays
	-- Test:
	  1. HMI->SDL: SDL gets the current date ("date": #ValueToCheck - #Date1)
	  ExpRes:
	  1. SDL should not initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is not sent.
	  2. PTS should not be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is not sent/
	
    TC_16_No_PTU_After_N_days:
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_kilometers = #ExchangeDays
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  4. Check the value of date received at this PTU = #Date1
	  => #ValueToCheck = #Date1 + #ExchangeDays
	-- Test:
	  1. HMI->SDL: SDL gets the current date ("date": #ValueToCheck - 1)
	  ExpRes:
	  1. SDL should not initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is not sent.
	  2. PTS should not be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is not sent/

	TC_17_PTU_After_N_days:
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_kilometers = #ExchangeDays
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  4. Check the value of date received at this PTU = #Date1
	  => #ValueToCheck = #Date1 + #ExchangeDays
	-- Test:
	  1. HMI->SDL: SDL gets the current date ("date": #ValueToCheck)
	  ExpRes:
	  1. SDL should initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is sent.
	  2. PTS should be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is sent//PTU sequence started
	  
    TC_18_PTU_After_N_days:
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_kilometers = #ExchangeDays
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  4. Check the value of date received at this PTU = #Date1
	  => #ValueToCheck = #Date1 + #ExchangeDays
	-- Test:
	  1. HMI->SDL: SDL gets the current date ("date": #ValueToCheck + 1)
	  ExpRes:
	  1. SDL should initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is sent.
	  2. PTS should be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is sent//PTU sequence started
	
	TC_19_PTU_After_N_days:
	-- Preconditions:
	  1. Check in sdl_preloaded_pt.json, value of exchange_after_x_kilometers = #ExchangeDays
	  2. Device an app with app_ID is running is consented. Application is running on SDL
	  3. Successful PTU scenarios is finished => SDL -> HMI: OnStatusUpdate(UP_TO_DATE)
	  4. Check the value of date received at this PTU = #Date1
	  => #ValueToCheck = #Date1 + #ExchangeDays
	  5. HMI->SDL: SDL gets the current date ("date": #ValueToCheck + 1)
	  ExpRes:
	  1. SDL should initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is sent.
	  2. PTS should be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is sent//PTU sequence started
	  3. Check the value of date received at this PTU = #date2
	  => #ValueToCheck = #date2 + #ExchangeDays
	  4. Finish PTU sequence.
	-- Test:
	  1. HMI->SDL: SDL gets the current date ("date": #ValueToCheck + 1)
	  ExpRes:
	  1. SDL should initiate PTU: SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED) is sent.
	  2. PTS should be created by SDL: SDL-> HMI: SDL.PolicyUpdate() is sent//PTU sequence started
  ]]
  
  APPLINK-19010: [PolicyTableUpdate] BlueTooth: PoliciesManager must initiate the triggered PTU ONLY AFTER the SDP query is complete
  --[[Tests:
    TC_20_BT_PTU
	-- Preconditions:
	  1. Device an app with app_ID1 not listed in PTU is running on mobile. 
  ]]
  --Reqs "No "certificate" at "module_config" section" would be covered at the end because still not implemented!
 
  
  
  
  
  
  
  
  
  
  
  