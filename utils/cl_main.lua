lib.locale()

Utils = {}

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

local scenarios = {
    'WORLD_HUMAN_AA_COFFEE',
    'WORLD_HUMAN_AA_SMOKE',
    'WORLD_HUMAN_SMOKING'
}

local count = 0

function Utils.createPed(coords, model, options)
    if not IsModelValid(model) then
        error('Invalid ped model: %s', model)
    end

    -- Convert action to qtarget
    if options then
        for _, option in pairs(options) do
            if option.onSelect then
                count += 1
                local event = ('options_%p_%s'):format(option.onSelect, count) -- Create unique name
                ---@type function
                local onSelect = option.onSelect
                AddEventHandler(event, function()
                    onSelect(option.args)
                end)
                option.event = event
                option.onSelect = nil
            end

            if option.icon then
                option.icon = ('fa-solid fa-%s'):format(option.icon)
            end
        end
    end

    local ped, id
    lib.points.new({
        coords = coords.xyz,
        distance = 100.0,
        onEnter = function()
            lib.requestModel(model)
            ped = CreatePed(4, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            TaskStartScenarioInPlace(ped, Utils.randomFromTable(scenarios))
            if options then
                id = ('garage_ped_%s'):format(ped)

                -- No need to add support for ox_target/qb-target, because this export is intercompatible
                exports.qtarget:AddCircleZone(id, coords.xyz, 0.75, {
                    name = id,
                    debugPoly = false
                }, {
                    options = options
                })
            end
        end,
        onExit = function()
            DeleteEntity(ped)
            SetModelAsNoLongerNeeded(model)
            ped = nil

            if id then
                exports.qtarget:RemoveZone(id)
                id = nil
            end
        end
    })
end

---@param point1 vector3 | vector4 | number
---@param point2 vector3 | vector4 | number
---@param distance number?
---@diagnostic disable-next-line: duplicate-set-field
function Utils.distanceCheck(point1, point2, distance)
    distance = distance or Config.MaxDistance

    if type(point1) == 'number' then
        point1 = GetEntityCoords(point1)
    end

    if type(point2) == 'number' then
        point2 = GetEntityCoords(point2)
    end

    return #(point1.xyz - point2.xyz) <= distance
end

function Utils.createBlip(coords, text, sprite, scale, color)
    local blip = AddBlipForCoord(coords.x, coords.y)

    SetBlipSprite (blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, scale)
    SetBlipColour (blip, color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

---@param jobs string | string[]
function Utils.hasJobs(jobs)
    if type(jobs) == 'string' then
        jobs = { jobs } ---@cast jobs string[]
    end

    for _, name in ipairs(jobs) do
        if Framework.getJob() ~= name then
            return false
        end
    end

    return true
end

---@class KeybindData
---@field name string
---@field description string
---@field defaultMapper? string (see: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/)
---@field defaultKey? string
---@field disabled? boolean
---@field disable? fun(self: CKeybind, toggle: boolean)

---@class Keybind : CKeybind
---@field addListener fun(name: string, cb: fun(self: CKeybind), args...: any)
---@field removeListener fun(name: string)

-- A wrapper around lib.addKeybind with extra functions.
---@param data KeybindData
---@return Keybind
function Utils.addKeybind(data)
    local bind = lib.addKeybind(data --[[@as KeybindProps]]) 

    local listeners = {}

    function bind.addListener(name, cb, ...)
        local args = ...
        listeners[name] = function()
            CreateThread(function()
                cb(args)
            end)
        end
    end

    function bind.removeListener(name)
        listeners[name] = nil
    end

    function bind.onReleased(self)
        for _, cb in pairs(listeners) do
            cb()
        end
    end

    return bind --[[@as Keybind]]
end