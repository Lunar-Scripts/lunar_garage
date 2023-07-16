lib.locale()
lib.versionCheck('https://github.com/Lunar-Scripts/lunar_garage')

Utils = {}
local resourceName = GetCurrentResourceName()

---@param point1 vector3 | vector4 | string | number
---@param point2 vector3 | vector4 | string | number
---@param distance number?
---@diagnostic disable-next-line: duplicate-set-field
function Utils.distanceCheck(point1, point2, distance)
    distance = distance or Config.MaxDistance

    if type(point1) == 'number' or type(point1) == 'string' then
        local ped = GetPlayerPed(point1)

        if ped == 0 then return false end

        point1 = GetEntityCoords(ped)
    end

    if type(point2) == 'number' or type(point2) == 'string' then
        local ped = GetPlayerPed(point2)

        if ped == 0 then return false end

        point2 = GetEntityCoords(ped)
    end

    return #(point1.xyz - point2.xyz) <= distance
end

---@diagnostic disable-next-line: duplicate-set-field
function Utils.getTableSize(t)
    local count = 0

	for _,_ in pairs(t) do
		count = count + 1
	end

	return count
end

---@generic K, V
---@param t table<K, V>
---@return V, K
---@diagnostic disable-next-line: duplicate-set-field
function Utils.randomFromTable(t)
    local index = math.random(1, #t)
    return t[index], index
end

function Utils.logToDiscord(source, xPlayer, message)
    if SvConfig.Webhook == 'WEBHOOK_HERE' then return end

    local connect = {
        {
            ["color"] = "16768885",
            ["title"] = GetPlayerName(source) .. " (" .. xPlayer:GetIdentifier() .. ")",
            ["description"] = message,
            ["footer"] = {
                ["text"] = os.date('%H:%M - %d. %m. %Y', os.time()),
                ["icon_url"] = 'https://cdn.discordapp.com/attachments/793081015433560075/1048643072952647700/lunar.png',
            },
        }
    }
    PerformHttpRequest(SvConfig.Webhook, function(err, text, headers) end,
        'POST', json.encode({ username = resourceName, embeds = connect }), { ['Content-Type'] = 'application/json' })
end

function Utils.createVehicle(model, coords)
    local vehicle = CreateVehicleServerSetter(model, 'automobile', coords.x, coords.y, coords.z - 0.5, coords.w)

    for seatIndex = -1, 6 do
        local ped = GetPedInVehicleSeat(vehicle, seatIndex)
        local type = GetEntityPopulationType(ped)

        if type > 0 and type < 6 then
            DeleteEntity(ped)
        end
    end

    return vehicle
end