lib.locale()
lib.versionCheck('https://github.com/Lunar-Scripts/lunar_garage')

Utils = {}
local resourceName = GetCurrentResourceName()

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

---Spawns a persistent vehicle
---@param model number
---@param coords vector4
---@param type string
---@return number
function Utils.createVehicle(model, coords, type)
    local vehicle = CreateVehicleServerSetter(model, type, coords.x, coords.y, coords.z - 0.70, coords.w)

    for seatIndex = -1, 6 do
        local ped = GetPedInVehicleSeat(vehicle, seatIndex)
        local type = GetEntityPopulationType(ped)

        if type > 0 and type < 6 then
            DeleteEntity(ped)
        end
    end

    return vehicle
end