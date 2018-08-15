local xml = require('xml')

local api_doc = xml.open("data/MOBILE_API.xml")

local mobileAPI = {}

function mobileAPI.GetVersion()
    local interface = api_doc:xpath("//interface")
    local version_str = ""
    for _, s in ipairs(interface) do
        version_str = s:attr("version")
        local version_arr = {0,0,0}
        local index = 0
        for i in string.gmatch(version_str, "([^.]+)") do
            version_arr[index] = i
            index = index + 1
        end
        local minVersion = {
            majorVersion = version_arr[0],
            minorVersion = version_arr[1],
            patchVersion = version_arr[2]
        }
        return minVersion
    end
end

return mobileAPI