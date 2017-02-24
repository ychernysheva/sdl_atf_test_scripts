require('atf.util')

local testCasesForPolicyCeritificates = {}

local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local json = require('json')

--[[@update_preloaded_pt: update sdl_preloaded_pt
! @parameters:
! app_id - Id of application that will be included sdl_preloaded_pt.json
! include_certificate - true / false: true - certificate will be added in module_config
!   true - certificate will be added in module_config
!   false - certificate will not be added in module_config
! update_retry_sequence - array with new values for seconds_between_retries.
]]
function testCasesForPolicyCeritificates.update_preloaded_pt(app_id, include_certificate, update_retry_sequence)
  commonPreconditions:BackupFile("sdl_preloaded_pt.json")
  local config_path = commonPreconditions:GetPathToSDL()

  local pathToFile = config_path .. 'sdl_preloaded_pt.json'
  local file = io.open(pathToFile, "r")
  local json_data = file:read("*all")
  file:close()

  local data = json.decode(json_data)
  if(data.policy_table.functional_groupings["DataConsent-2"]) then
    data.policy_table.functional_groupings["DataConsent-2"].rpcs = json.null
  end

  data.policy_table.functional_groupings["Base-4"].rpcs.SetAudioStreamingIndicator = nil
  data.policy_table.functional_groupings["Base-4"].rpcs.SetAudioStreamingIndicator = { hmi_levels = { "BACKGROUND", "FULL", "LIMITED" }}

  if (update_retry_sequence ~= nil) then
    data.policy_table.module_config.seconds_between_retries = update_retry_sequence
    data.policy_table.module_config.timeout_after_x_seconds = 30
  end

  if(app_id ~= nil) then
    data.policy_table.app_policies[app_id] = nil
	  data.policy_table.app_policies[app_id] =
	  {
	    keep_context = false,
	    steal_focus = false,
	    priority = "NONE",
	    default_hmi = "NONE",
	    groups = {"Base-4"}
	  }
	end

  if(include_certificate == true) then
    io.input("files/Security/spt_credential.pem")
		data.policy_table.module_config.certificate = ""
    local str_certificate = ""
		for line in io.lines() do
	    str_certificate = str_certificate .. line .."\r\n"
	  end

    data.policy_table.module_config.certificate = str_certificate
  end

  file = io.open(config_path .. 'sdl_preloaded_pt.json', "w")
  file:write(json.encode(data))
  file:close()
end

--[[@create_ptu_certificate_exist: creates PTU file:
! ptu_certificate_exist.json: module_config section contains certificate.
! @parameters:
! include_certificate - true / false: true - certificate will be added in module_config
!   true - certificate will be added in module_config
!   false - certificate will not be added in module_config
! invalid_ptu - will add omit values + remove seconds_between_retries section -> PT file will become invalid.
]]
function testCasesForPolicyCeritificates.create_ptu_certificate_exist(include_certificate, invalid_ptu)
  local config_path = commonPreconditions:GetPathToSDL()
  local pathToFile = config_path .. 'sdl_preloaded_pt.json'

  local file = io.open(pathToFile, "r")
  local json_data = file:read("*all")
  file:close()

  local data = json.decode(json_data)
  if(data.policy_table.functional_groupings["DataConsent-2"]) then
    data.policy_table.functional_groupings["DataConsent-2"].rpcs = json.null
  end

  if(invalid_ptu ~= true) then
    data.policy_table.module_config.preloaded_pt = nil
    data.policy_table.module_config.preloaded_date = nil
  else
    data.policy_table.module_config.preloaded_pt = true
    data.policy_table.module_config.preloaded_date = "2017-04-13"
    data.policy_table.module_config.seconds_between_retries = nil
  end

	if(include_certificate == true) then
		io.input("files/Security/spt_credential.pem")
		data.policy_table.module_config.certificate = ""
		local str_certificate = ""
    for line in io.lines() do
      str_certificate = str_certificate .. line .."\r\n"
    end

    data.policy_table.module_config.certificate = str_certificate
	end

  data = json.encode(data)
  file = io.open("files/ptu_certificate_exist.json", "w")
  file:write(data)
  file:close()
end

return testCasesForPolicyCeritificates