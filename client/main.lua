---@class Zone
---@field type string
---@field index integer?
---@field point CPoint?

---@type Zone?
local zone

local function SpawnVehicle(args)
    ---@type integer, VehicleProperties
    local index, props in args
    
    lib.requestModel(props.model)
    local netId = lib.callback.await('lunar_garage:takeOutVehicle', false, index, props.plate)
    
    while not NetworkDoesEntityExistWithNetworkId(netId) do Wait(0) end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    lib.setVehicleProperties(vehicle, props)
    TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
end

function GetVehicleLabel(model)
    local label = GetLabelText(GetDisplayNameFromVehicleModel(model))
    
    if label == 'NULL' then 
        label = GetDisplayNameFromVehicleModel(model)
    end

    return label
end

local function GetClassIcon(class)
    if class == 8 then
        return 'motorcycle'
    elseif class == 13 then
        return 'bicycle'
    elseif class == 15 then
        return 'helicopter'
    else
        return 'car'
    end
end

local function GetFuelBarColor(fuel)
    if fuel > 75.0 then
        return 'lime'
    elseif fuel > 50.0 then
        return 'yellow'
    elseif fuel > 25.0 then
        return 'orange'
    else
        return 'red'
    end
end

local function OpenGarageVehicles(args)
    local index, society in args
    local vehicles = lib.callback.await('lunar_garage:getOwnedVehicles', false, index, society)
    
    if #vehicles == 0 then
        ShowNotification(society and locale('no_owned_vehicles') or locale('no_society_vehicles'), 'error')
        return
    end

    ---@type ContextMenuArrayItem[]
    local options = {}

    for _, vehicle in ipairs(vehicles) do
        ---@type VehicleProperties
        local props = json.decode(vehicle.mods or vehicle.vehicle)

        local class = GetVehicleClassFromName(GetDisplayNameFromVehicleModel(props.model))

        ---@type ContextMenuArrayItem
        local option = {
            title = locale('vehicle_info', GetVehicleLabel(props.model), props.plate),
            icon = GetClassIcon(class),
            progress = class ~= 13 and props.fuelLevel,
            colorScheme = class ~= 13 and GetFuelBarColor(props.fuelLevel),
            metadata = {
                ---@diagnostic disable-next-line: assign-type-mismatch
                { label = locale('status'), value = vehicle.stored == 1 and locale('in_garage') or locale('out_garage') },
                
                ---@diagnostic disable-next-line: assign-type-mismatch
                { label = locale('fuel'), value = class ~= 13 and props.fuelLevel .. '%' or locale('no_fueltank') }
            },
            args = { index = index, props = props },
            onSelect = vehicle.stored == 1 and SpawnVehicle or function()
                ShowNotification(locale('not_in_garage'), 'error')
            end
        }

        table.insert(options, option)
    end

    lib.registerContext({
        id = 'garage_vehicles',
        title = society and locale('society_vehicles') or locale('player_vehicles'),
        options = options
    })

    lib.showContext('garage_vehicles')
end

local function OpenGarage(index)
    lib.registerContext({
        id = 'garage_menu',
        title = locale('garage_menu'),
        options = {
            {
                title = locale('player_vehicles'),
                description = locale('player_vehicles_desc'),
                icon = 'user',
                args = { index = index, society = false },
                onSelect = OpenGarageVehicles
            },
            {
                title = locale('society_vehicles'),
                description = locale('society_vehicles_desc'),
                icon = 'users',
                args = { index = index, society = true },
                onSelect = OpenGarageVehicles
            },
        }
    })

    lib.showContext('garage_menu')
end

local function SaveVehicle()
    if cache.seat ~= -1 then
        ShowNotification(locale('not_driver'), 'error')
        return
    end

    local vehicle = cache.vehicle
    local props = lib.getVehicleProperties(vehicle)

    if not props then return end

    local result = lib.callback.await('lunar_garage:saveVehicle', false, props)
    
    if result then
        TaskLeaveAnyVehicle(cache.ped, 0, 0)
        Wait(1000)
        DeleteEntity(vehicle)
        ShowNotification(locale('vehicle_saved'), 'success')
    else
        ShowNotification(locale('not_your_vehicle'), 'error')
    end
end

local function RetrieveVehicle(args)
    ---@type integer, VehicleProperties
    local index, props in args
    
    lib.requestModel(props.model)
    local success, netId = lib.callback.await('lunar_garage:retrieveVehicle', false, index, props.plate)

    if not success then
        ShowNotification(locale('not_enough_money'), 'error')
        return
    end

    while not NetworkDoesEntityExistWithNetworkId(netId) do Wait(0) end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    lib.setVehicleProperties(vehicle, props)
    TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
end

local function OpenImpoundVehicles(args)
    local index, society in args
    local vehicles = lib.callback.await('lunar_garage:getImpoundedVehicles', false, index, society)
    
    if #vehicles == 0 then
        ShowNotification(locale('no_impounded_vehicles'), 'error')
        return
    end

    ---@type ContextMenuArrayItem[]
    local options = {}

    for _, vehicle in ipairs(vehicles) do
        ---@type VehicleProperties
        local props = json.decode(vehicle.mods or vehicle.vehicle)

        local class = GetVehicleClassFromName(GetDisplayNameFromVehicleModel(props.model))

        ---@type ContextMenuArrayItem
        local option = {
            title = locale('vehicle_info', GetVehicleLabel(props.model), props.plate),
            icon = GetClassIcon(class),
            progress = class ~= 13 and props.fuelLevel,
            colorScheme = class ~= 13 and GetFuelBarColor(props.fuelLevel),
            metadata = {
                ---@diagnostic disable-next-line: assign-type-mismatch
                { label = locale('fuel'), value = class ~= 13 and props.fuelLevel .. '%' or locale('no_fueltank') }
            },
            args = { index = index, props = props },
            onSelect = RetrieveVehicle
        }

        table.insert(options, option)
    end

    lib.registerContext({
        id = 'impound_vehicles',
        title = society and locale('society_vehicles') or locale('player_vehicles'),
        options = options
    })

    lib.showContext('impound_vehicles')
end

local function OpenImpound(index)
    lib.registerContext({
        id = 'impound_menu',
        title = locale('impound_menu'),
        options = {
            {
                title = locale('player_vehicles'),
                description = locale('player_vehicles_desc'),
                icon = 'user',
                args = { index = index, society = false },
                onSelect = OpenImpoundVehicles
            },
            {
                title = locale('society_vehicles'),
                description = locale('society_vehicles_desc'),
                icon = 'users',
                args = { index = index, society = true },
                onSelect = OpenImpoundVehicles
            },
        }
    })

    lib.showContext('impound_menu')
end

---@param garage GarageData
local function EnterInterior(garage)
    if not garage.Interior then return end

    local interior = Config.GarageInteriors[garage.Interior]

    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do Wait(100) end

    local lastCoords = cache.coords
    SetEntityCoords(cache.ped, interior.Coords.x, interior.Coords.y, interior.Coords.z)

    local vehicles = lib.callback.await('lunar_garage:enterInterior', false, garage.Type)
    ---@type number[]
    local entities = {}

    local vehicleIndex = 1
    for i = 1, #interior.Vehicles do
        local coords = interior.Vehicles[i]
        local spawned = false

        repeat
            local vehicle = vehicles[vehicleIndex]

            if not vehicle then goto skip end

            ---@type VehicleProperties
            local props = json.decode(vehicle.vehicle or vehicle.mods)

            if props?.model and IsModelValid(props.model) then
                lib.requestModel(props.model)
                Framework.SpawnLocalVehicle(props.model, coords.xyz, coords.w, function(entity)
                    lib.setVehicleProperties(entity, props)
                    table.insert(entities, entity)
                end)
                spawned = true
            end
            vehicleIndex += 1
        until spawned
    end

    ::skip::

    Wait(1000)
    DoScreenFadeIn(500)
    
    while not IsScreenFadedIn() do Wait(100) end

    if #vehicles > #interior.Vehicles then
        ShowNotification(locale('too_many_vehicles'), 'error')
    end

    local point = lib.points.new(interior.Coords.xyz, 1.0, {
        onEnter = function(self)
            ShowUI(locale('exit_garage', FirstBind.currentKey), 'door-open')
            zone = { type = 'exit', point = self }
        end,
        onExit = function()
            HideUI()
        end
    })

    -- Override remove function
    function point.remove()
        HideUI()
        DoScreenFadeOut(500)

        while not IsScreenFadedOut() do Wait(100) end

        for _, entity in ipairs(entities) do
            DeleteEntity(entity)
        end

        SetEntityCoords(cache.ped, lastCoords.x, lastCoords.y, lastCoords.z)
        Wait(1000)
        DoScreenFadeIn(500)
    end
end

FirstBind = lib.addKeybind({
    name = 'garage_interact1',
    description = 'Open garage/impound',
    defaultKey = 'E',
    onPressed = function()
        if not zone then return end

        if zone.type == 'garage' then
            OpenGarage(zone.index)
        elseif zone.type == 'impound' then
            OpenImpound(zone.index)
        elseif zone.type == 'exit' then
            zone.point:remove()
        end
    end
})

SecondBind = lib.addKeybind({
    name = 'garage_interact2',
    description = 'Save vehicle/Go into garage',
    defaultKey = 'G',
    onPressed = function()
        if zone and zone.type == 'garage' then
            local garage = Config.Garages[zone.index]
            if cache.vehicle then
                SaveVehicle()
            elseif garage.Interior then
                EnterInterior(garage)
            end
        end
    end
})

for index, data in ipairs(Config.Garages) do
    if data.Position and data.PedPosition then
        error('Position and PedPosition can\'t be defined at the same time!')
    end
    
    if data.Position then
        lib.zones.sphere({
            coords = data.Position,
            radius = Config.MaxDistance,
            onEnter = function()
                if data.Jobs and not Utils.HasJobs(data.Jobs) then return end

                if cache.vehicle then
                    ShowUI(('[%s] - %s'):format(SecondBind.currentKey, locale('save_vehicle')), 'floppy-disk')
                else
                    local prompt

                    if data.Interior then
                        prompt = ('[%s] - %s  \n  [%s] - %s'):format(FirstBind.currentKey, locale('open_garage'), SecondBind.currentKey, locale('enter_interior'))
                    else
                        prompt = (('[%s] - %s'):format(FirstBind.currentKey, locale('open_garage')))
                    end

                    ShowUI(prompt, 'warehouse')
                end
                zone = { type = 'garage', index = index }
            end,
            onExit = function()
                if zone?.type == 'garage' then
                    HideUI()
                    zone = nil
                end
            end
        })

        lib.onCache('vehicle', function(vehicle)
            if zone?.type ~= 'garage' then return end
                
            if vehicle then
                ShowUI(('[%s] - %s'):format(SecondBind.currentKey, locale('save_vehicle')), 'floppy-disk')
            else
                local prompt

                if data.Interior then
                    prompt = ('[%s] - %s  \n  [%s] - %s'):format(FirstBind.currentKey, locale('open_garage'), SecondBind.currentKey, locale('enter_interior'))
                else
                    prompt = (('[%s] - %s'):format(FirstBind.currentKey, locale('open_garage')))
                end

                ShowUI(prompt, 'warehouse')
            end
        end)
    elseif data.PedPosition then
        if not data.Model then
            warn('Skipping garage - missing Model, index: %s', index)
            goto continue
        end

        Utils.CreatePed(data.PedPosition, data.Model, {
            {
                label = locale('open_garage'),
                icon = 'warehouse',
                job = data.Jobs,
                args = { index = index, society = society },
                action = OpenGarage
            }
        })
    else
        warn('Skipping garage - missing Position or PedPosition, index: %s', index)
    end

    ::continue::
end

for index, data in ipairs(Config.Impounds) do
    if data.Position and data.PedPosition then
        error('Position and PedPosition can\'t be defined at the same time!')
    end
    
    if data.Position then
        lib.zones.sphere({
            coords = data.Position,
            radius = Config.MaxDistance,
            onEnter = function()
                if data.Jobs and not Utils.HasJobs(data.Jobs) then return end 

                ShowUI(('[%s] - %s'):format(FirstBind.currentKey, locale('open_impound')), 'warehouse')
                zone = { type = 'impound', index = index }
            end,
            onExit = function()
                if zone?.type == 'impound' then
                    HideUI()
                    zone = nil
                end
            end
        })
    elseif data.PedPosition then
        if not data.Model then
            warn('Skipping impound - missing Model, index: %s', index)
            goto continue
        end

        Utils.CreatePed(data.PedPosition, data.Model, {
            {
                label = locale('open_impound'),
                icon = 'warehouse',
                job = data.Jobs,
                args = index,
                action = OpenImpound
            }
        })
    else
        warn('Skipping impound - missing Position or PedPosition, index: %s', index)
    end

    ::continue::
end