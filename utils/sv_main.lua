lib.locale()
lib.versionCheck('https://github.com/Lunar-Scripts/lunar_garage')

Utils = {}
local resourceName = GetCurrentResourceName()

---@param point1 vector3 | vector4 | string
---@param point2 vector3 | vector4 | string
---@param distance number?
function Utils.DistanceCheck(point1, point2, distance)
    distance = distance or Config.InteractDistance

    if type(point1) == 'string' then
        local ped = GetPlayerPed(point1)
        point1 = GetEntityCoords(ped)
    end

    if type(point2) == 'string' then
        local ped = GetPlayerPed(point2)
        point2 = GetEntityCoords(ped)
    end

    return #(point1.xyz - point2.xyz) <= distance
end

function Utils.GetTableSize(t)
    local count = 0

	for _,_ in pairs(t) do
		count = count + 1
	end

	return count
end

---@generic K, V
---@param t table<K, V>
---@return V, K
function Utils.RandomFromTable(t)
    local index = math.random(1, #t)
    return t[index], index
end

function Utils.LogToDiscord(source, xPlayer, message)
    if SvConfig.Webhook == 'WEBHOOK_HERE' then return end

    local connect = {
        {
            ["color"] = "16768885",
            ["title"] = GetPlayerName(source).." (".. xPlayer:GetIdentifier() ..")",
            ["description"] = message,
            ["footer"] = {
                ["text"] = os.date('%H:%M - %d. %m. %Y', os.time()),
                ["icon_url"] = 'https://cdn.discordapp.com/attachments/793081015433560075/1048643072952647700/lunar.png',
            },
        }
    }
    PerformHttpRequest(SvConfig.Webhook, function(err, text, headers) end,
        'POST', json.encode({username = resourceName, embeds = connect}), { ['Content-Type'] = 'application/json' })
end