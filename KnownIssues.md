# Known FAILS in test scripts:

* ATF_Speak.lua:
  * Speak_ttsChunks_IsUpperBound_SUCCESS
  * Speak_ttsChunks_IsOutUpperBound_INVALID_DATA
  * Speak_CorrelationID_IsDuplicated
  * Speak_Response_resultCode_IsValidValue_UNSUPPORTED_RESOURCE_SendError
  * Speak_Response_resultCode_IsValidValue_WARNINGS_SendError
  * Activation_App (sometimes)

* ATF_AddSubMenu.lua take updated script from attach:
  * ActivateSecondApp (sometimes)

* ATF_OnDriverDistraction.lua:
  * Activate_Media_App2

* ATF_SetMediaClockTimer.lua:

* ATF_Slider.lua:
  * Slider_AllParametersUpperBound_SUCCESS
  * Slider_sliderFooter_IsUpperBound_SUCCESS
  * Activation_App

Checked on SDL commit SDL commit [dfdf6699d4bbee126f614007b6af4ae0660a5bd8](https://github.com/smartdevicelink/sdl_core/commit/dfdf6699d4bbee126f614007b6af4ae0660a5bd8)
