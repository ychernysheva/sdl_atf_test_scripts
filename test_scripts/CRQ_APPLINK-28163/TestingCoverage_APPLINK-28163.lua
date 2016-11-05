--[[CRQ: APPLINK-28163: [GENIVI] SDL must retrieve the value of 'menuIcon' and 'menuTitle' parameters from .ini file]]

--[[Clarifications
  -- APPLINK-29383: Should SDL consider parameters menuIcon/MenuTitle as empty if they are missing in INI file
  ]]

--[[General Precondition: Update sdl_preloaded_pt.json to allow ResetGlobalProperties]]

--[[Testing coverage]]
  --APPLINK-20657: [ResetGlobalProperties] "MENUICON" reset
  --APPLINK-22707: [INI file] [ApplicationManager] MenuIcon
  --[[Tests:
    TC01_menuIcon_absolute_path_INI
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = absolute path
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = absolute path})
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.

    TC02_menuIcon_relative_path_INI
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = relative path
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = relative path})
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.

    TC03_menuIcon_absolute_path_INI_PrecSGP
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = absolute path
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }) and check
          3.1 UI.SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = absolute path})
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.

    TC04_menuIcon_relative_path_INI_PrecSGP
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = relative path
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }) and check
          3.1 UI.SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.        
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = relative path})
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.

  	TC05_menuIcon_relative_path_INI_PrecSGP_Resumption
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = relative path
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }) and check
          3.1 UI.SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.        
        4. Perform resumption because of IGN_OFF -> IGN_ON. => menuIcon is resumed
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = relative path})
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.

    TC06_menuIcon_absolute_path_INI_PrecSGP_Resumption
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = absolute path
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }) and check
          3.1 UI.SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.        
        4. Perform resumption because of IGN_OFF -> IGN_ON. => menuIcon is resumed
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = absolute path})
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.  

    TC07_menuIcon_relative_path_INI_PrecSGP_Resumption_MobileDisconnect
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = relative path
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }) and check
          3.1 UI.SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.        
        4. Perform resumption because of mobile disconnect -> connect. => menuIcon is resumed
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = relative path})
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.

    TC08_menuIcon_absolute_path_INI_PrecSGP_Resumption_MobileDisconnect
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = absolute path
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }) and check
          3.1 UI.SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.        
        4. Perform resumption because of mobile disconnect -> connect. => menuIcon is resumed
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = absolute path})
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.

    TC19_menuIcon_empty_path_INI
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = 
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties() is received without parameter menuIcon
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received. 

    TC20_menuIcon_empty_path_INI_PrecSGP
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = 
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }) and check
          3.1 UI.SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.        
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties() is received without parameter menuIcon
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.   

    TC21_menuIcon_empty_path_INI_PrecSGP_Resumption
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = 
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }) and check
          3.1 UI.SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.        
        4. Perform resumption because of IGN_OFF -> IGN_ON. => menuIcon is resumed          
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties() is received without parameter menuIcon
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.

    TC22_menuIcon_empty_path_INI_PrecSGP_Resumption_MobileDisconnect
      -- Precondition
        1. Check that menuIcon exists in INI file.
        2. Update menuIcon = 
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }) and check
          3.1 UI.SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.        
        4. Perform resumption because of mobile disconnect -> connect. => menuIcon is resumed          
  	  -- Test
  	    1. Send ResetGlobalProperties(properties = "MENUICON") and check:
  	      1.1 UI.SetGlobalProperties() is received without parameter menuIcon
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.  
  ]]

  --APPLINK-20656: [ResetGlobalProperties] "MENUNAME" reset
  --APPLINK-22706: [INI file] [ApplicationManager] MenuTitle
  --[[Tests:
    TC09_menuTitle_INI
      -- Precondition
        1. Check in INI file menuTitle = "MENU"
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUNAME") and check:
  	      1.1 UI.SetGlobalProperties(menuTitle = "MENU")
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.    

    TC10_menuTitle_INI_PrecSGP
      -- Precondition
        1. Check in INI file menuTitle = "MENU"
        2. Send SetGlobalProperties(menuTitle = "Menu Title") and check
          3.1 UI.SetGlobalProperties(menuTitle = "Menu Title")
          3.2 TTS.SetGlobalProperties is not sent.        
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUNAME") and check:
  	      1.1 UI.SetGlobalProperties(menuTitle = "MENU")
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.    

    TC11_menuTitle_INI_PrecSGP_Resumption
      -- Precondition
        1. Check in INI file menuTitle = "MENU"
        2. Send SetGlobalProperties(menuTitle = "Menu Title") and check
          3.1 UI.SetGlobalProperties(menuTitle = "Menu Title")
          3.2 TTS.SetGlobalProperties is not sent.
        3. Perform resumption because of IGN_OFF -> IGN_ON. => menuTitle is resumed      
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUNAME") and check:
  	      1.1 UI.SetGlobalProperties(menuTitle = "MENU")
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.  

    TC12_menuTitle_INI_PrecSGP_Resumption_MobileDisconnect
      -- Precondition
        1. Check in INI file menuTitle = "MENU"
        2. Send SetGlobalProperties(menuTitle = "Menu Title") and check
          3.1 UI.SetGlobalProperties(menuTitle = "Menu Title")
          3.2 TTS.SetGlobalProperties is not sent.
        3. Perform resumption because of mobile disconnect->connect. => menuTitle is resumed      
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUNAME") and check:
  	      1.1 UI.SetGlobalProperties(menuTitle = "MENU")
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.  
  ]]

  --APPLINK-20657: [ResetGlobalProperties] "MENUICON" reset
  --APPLINK-22707: [INI file] [ApplicationManager] MenuIcon
  --APPLINK-20656: [ResetGlobalProperties] "MENUNAME" reset
  --APPLINK-22706: [INI file] [ApplicationManager] MenuTitle
  --[[Tests:
    TC13_menuIcon_absolute_path_menuTitle_INI
      -- Precondition
        1. Check that menuIcon exists and menuTitle = "MENU" in INI file.
        2. Update menuIcon = absolute path
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = absolute path}, menuTitle = "MENU")
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.

    TC14_menuIcon_relative_path_menuTitle_INI
      -- Precondition
        1. Check that menuIcon exists and menuTitle = "MENU" in INI file.
        2. Update menuIcon = relative path
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = relative path}, menuTitle = "MENU")
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.   

    TC15_menuIcon_absolute_path_menuTitle_INI_PrecSGP
      -- Precondition
        1. Check that menuIcon exists and menuTitle = "MENU" in INI file.
        2. Update menuIcon = absolute path
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }, menuTitle = "Menu Title") and check
          3.1 UI.SetGlobalProperties(menuTitle = "Menu Title", menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.    
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = absolute path}, menuTitle = "MENU")
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.      

    TC16_menuIcon_relative_path_menuTitle_INI_PrecSGP
      -- Precondition
        1. Check that menuIcon exists and menuTitle = "MENU" in INI file.
        2. Update menuIcon = relative path
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }, menuTitle = "Menu Title") and check
          3.1 UI.SetGlobalProperties(menuTitle = "Menu Title", menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.    
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = relative path}, menuTitle = "MENU")
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.

    TC17_menuIcon_relative_path_menuTitle_INI_PrecSGP_Resumption
      -- Precondition
        1. Check that menuIcon exists and menuTitle = "MENU" in INI file.
        2. Update menuIcon = relative path
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }, menuTitle = "Menu Title") and check
          3.1 UI.SetGlobalProperties(menuTitle = "Menu Title", menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.   
        4. Perform resumption because of IGN_OFF -> IGN_ON. => menuTitle and menuIcon are resumed 
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = relative path}, menuTitle = "MENU")
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.   

    TC18_menuIcon_absolute_path_menuTitle_INI_PrecSGP_Resumption
      -- Precondition
        1. Check that menuIcon exists and menuTitle = "MENU" in INI file.
        2. Update menuIcon = absolute path
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }, menuTitle = "Menu Title") and check
          3.1 UI.SetGlobalProperties(menuTitle = "Menu Title", menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.   
        4. Perform resumption because of IGN_OFF -> IGN_ON. => menuTitle and menuIcon are resumed 
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
  	      1.1 UI.SetGlobalProperties(menuIcon = {imageType = "DYNAMIC", value = absolute path}, menuTitle = "MENU")
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.     

    TC23_menuIcon_empty_path_menuTitle_INI
      -- Precondition
        1. Check that menuIcon exists and menuTitle = "MENU" in INI file.
        2. Update menuIcon = 
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
  	      1.1 UI.SetGlobalProperties(menuTitle = "MENU"), menuIcon is not sent.
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received. 

    TC24_menuIcon_empty_path_menuTitle_INI_PrecSGP
      -- Precondition
        1. Check that menuIcon exists and menuTitle = "MENU" in INI file.
        2. Update menuIcon = 
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }, menuTitle = "Menu Title") and check
          3.1 UI.SetGlobalProperties(menuTitle = "Menu Title", menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.   
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
  	      1.1 UI.SetGlobalProperties(menuTitle = "MENU"), menuIcon is not sent.
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.   

    TC25_menuIcon_empty_path_menuTitle_INI_PrecSGP_Resumption
      -- Precondition
        1. Check that menuIcon exists and menuTitle = "MENU" in INI file.
        2. Update menuIcon = 
        3. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }, menuTitle = "Menu Title") and check
          3.1 UI.SetGlobalProperties(menuTitle = "Menu Title", menuIcon = { value = "action.png", imageType = "DYNAMIC" })
          3.2 TTS.SetGlobalProperties is not sent.   
        4. Perform resumption because of IGN_OFF -> IGN_ON. => menuTitle and menuIcon are resumed 
  	  -- Test  
  	    1. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
  	      1.1 UI.SetGlobalProperties(menuTitle = "MENU"), menuIcon is not sent.
  	      1.2 TTS.SetGlobalProperties is not sent.
  	      1.3 OnHashChange is received.  

  	MANUAL test: [01][HP][MAN]_TC_MenuIcon_INI_file_Empty
  	  1. Check that menuIcon exists and menuTitle = "MENU" in INI file. By default in INI file menuIcon = relative path; param_menuIcon = menuIcon
      2. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }, menuTitle = "Menu Title") and check
        2.1 UI.SetGlobalProperties(menuTitle = "Menu Title", menuIcon = { value = "action.png", imageType = "DYNAMIC" })
        2.2 TTS.SetGlobalProperties is not sent.
      3. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
        3.1 UI.SetGlobalProperties ( menuTitle = "MENU", menuIcon = { imageType = "DYNAMIC", value = param_menuIcon})
        3.2 TTS.SetGlobalProperties is not sent.
        3.3 MENU button is displayed with icon defined in param_menuIcon
      4. IGN_OFF and update param_menuIcon = menuIcon = relative path. IGN_ON
      5. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }, menuTitle = "Menu Title") and check
        5.1 UI.SetGlobalProperties(menuTitle = "Menu Title", menuIcon = { value = "action.png", imageType = "DYNAMIC" })
        5.2 TTS.SetGlobalProperties is not sent.
      6. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
        6.1 UI.SetGlobalProperties ( menuTitle = "MENU", menuIcon = { imageType = "DYNAMIC", value = param_menuIcon})
        6.2 TTS.SetGlobalProperties is not sent.
        6.3 MENU button is displayed with icon defined in param_menuIcon
      7. IGN_OFF and update menuIcon = empty. IGN_ON
      8. Send SetGlobalProperties(menuIcon = { value = "action.png", imageType = "DYNAMIC" }, menuTitle = "Menu Title") and check
        8.1 UI.SetGlobalProperties(menuTitle = "Menu Title", menuIcon = { value = "action.png", imageType = "DYNAMIC" })
        8.2 TTS.SetGlobalProperties is not sent.
      9. Send ResetGlobalProperties(properties = "MENUICON", "MENUNAME" ) and check:
        9.1 UI.SetGlobalProperties ( menuTitle = "MENU"), menuIcon is not sent.
        9.2 TTS.SetGlobalProperties is not sent.
        9.3 MENU button is displayed without any icon.
  ]]