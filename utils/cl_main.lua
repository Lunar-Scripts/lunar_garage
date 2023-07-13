lib.locale()

Utils = {}

---@diagnostic disable-next-line: duplicate-set-field
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
---@diagnostic disable-next-line: duplicate-set-field
function Utils.RandomFromTable(t)
    local index = math.random(1, #t)
    return t[index], index
end

local scenarios = {
    'WORLD_HUMAN_AA_COFFEE',
    'WORLD_HUMAN_AA_SMOKE',
    'WORLD_HUMAN_SMOKING'
}

function Utils.CreatePed(coords, model, options)
    -- Convert action to qtarget
    if options then
        for _, option in pairs(options) do
            if option.onSelect then
                local event = ('options_%p'):format(option.onSelect) -- Create unique name
                AddEventHandler(event, function()
                    option.onSelect(option.args)
                end)
                option.event = event
            end
        end
    end

    local ped
    lib.points.new(coords.xyz, 100.0, {
        onEnter = function()
            lib.requestModel(model)
            ped = CreatePed(4, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            TaskStartScenarioInPlace(ped, Utils.RandomFromTable(scenarios))
            if options then
                local name = ('garage_ped_%s'):format(ped)

                -- No need to add support for ox_target/qb-target, because this export is intercompatible
                export.qtarget:AddCircleZone(name, coords.xyz, 0.75, {
                    name = name,
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
        end
    })
end


---@param coords vector3 | vector4
---@param distance number
function Utils.DistanceWait(coords, distance)
    while #(GetEntityCoords(cache.ped) - coords.xyz) > distance do
        Wait(200)
    end
end

function Utils.CreateBlip(coords, text, sprite, scale, color)
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

function Utils.CreateRadiusBlip(coords, text, scale, color)
    local blip = AddBlipForRadius(coords.x, coords.y, coords.z, scale)

    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, scale)
    SetBlipColour (blip, color)
    SetBlipAsShortRange(blip, true)
    SetBlipAlpha(blip, 150)
    return blip
end

function Utils.CreateEntityBlip(entity, text, sprite, scale, color)
    local blip = AddBlipForEntity(entity)

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

function Utils.MakeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(entity1, heading)
end

function Utils.MakeEntityFaceCoords(entity1, p2)
    local p1 = GetEntityCoords(entity1, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(entity1, heading)
end

---@param jobs string | string[]
function Utils.HasJobs(jobs)
    if type(jobs) == 'string' then
        jobs = { jobs } ---@cast jobs string[]
    end

    for _, name in ipairs(jobs) do
        if Framework.GetJob() ~= name then
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
---@field addListener fun(name: string, cb: fun(self: CKeybind))
---@field removeListener fun(name: string)

-- A wrapper around lib.addKeybind with extra functions.
---@param data KeybindData
---@return Keybind
function Utils.AddKeybind(data)
    local bind = lib.addKeybind(data --[[@as KeybindProps]]) 

    local listeners = {}

    function bind.addListener(name, cb)
        listeners[name] = function(self)
            CreateThread(function()
                cb(self)
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