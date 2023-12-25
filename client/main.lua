local function getVehicleType(model)
    if IsThisModelABike(model) then
        return 'bike'
    end

    -- Not really sure if quadbike is considered an automobile or a bike
    if IsThisModelACar(model) or IsThisModelAQuadbike(model) then
        return 'automobile'
    end

    if IsThisModelABoat(model) or IsThisModelAJetski(model) then
        return 'boat'
    end

    if IsThisModelAPlane(model) then
        return 'plane'
    end

    if IsThisModelAHeli(model) then
        return 'heli'
    end

    CreateVehicleServerSetter()
end

-- Taken from ox_lib, but higher timeout value and modified
RegisterNetEvent('lunar_garage:setVehicleProperties', function(netId, data)
    local timeout = 10000

    while not NetworkDoesEntityExistWithNetworkId(netId) and timeout > 0 do
        Wait(0)
        timeout -= 1
    end

    if timeout > 0 then
        local vehicle = NetToVeh(netId)

        if NetworkGetEntityOwner(vehicle) ~= cache.playerId then return end

        lib.setVehicleProperties(vehicle, data)
    end
end)

function SpawnVehicle(args)
    ---@type integer, VehicleProperties
    local index, props in args
    
    local garage = Config.Garages[index]
    
    if Config.SpawnpointCheck and lib.getClosestVehicle(garage.SpawnPosition.xyz, 3.0, false) then
        ShowNotification(locale('spawn_occupied'), 'error')
        return
    end

    lib.requestModel(props.model)
    local type = getVehicleType(props.model)
    local netId = lib.callback.await('lunar_garage:takeOutVehicle', false, index, props.plate, type)
    
    while not NetworkDoesEntityExistWithNetworkId(netId) do Wait(0) end

    local vehicle = NetworkGetEntityFromNetworkId(netId)

    CreateThread(function()
        while true do
            if NetworkGetEntityOwner(vehicle) == cache.playerId then
                lib.setVehicleProperties(vehicle, props)
                return
            end

            local plate = GetVehicleNumberPlateText(vehicle)

            if plate == props.plate then
                return
            end

            Wait(0)
        end
    end)

    -- The player doesn't get warped in the vehicle sometimes, repeat it and timeout after 2000 attempts
    for _ = 1, 2000 do
        TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
    
        if GetVehiclePedIsIn(cache.ped, false) == vehicle then
            break
        end

        Wait(0)
    end

    SetVehicleFuel(vehicle, props.fuelLevel or 100.0)
    SetVehicleOwner(props.plate)
end

function GetVehicleLabel(model)
    local label = GetLabelText(GetDisplayNameFromVehicleModel(model))
    
    if label == 'NULL' then 
        label = GetDisplayNameFromVehicleModel(model)
    end

    return label
end

local function getClassIcon(class)
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

local function getFuelBarColor(fuel)
    -- fuelLevel not defined in vehicleProps??
    if not fuel then return 'lime' end

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

local function openGarageVehicles(args)
    local index, society in args
    local vehicles = lib.callback.await('lunar_garage:getOwnedVehicles', false, index, society)
    
    if #vehicles == 0 then
        ShowNotification(society and locale('no_society_vehicles') or locale('no_owned_vehicles'), 'error')
        return
    end

    ---@type ContextMenuArrayItem[]
    local options = {}

    for _, vehicle in ipairs(vehicles) do
        ---@type VehicleProperties
        local props = json.decode(vehicle.mods or vehicle.vehicle)

        local class = GetVehicleClassFromName(GetDisplayNameFromVehicleModel(props.model))
        local fuelLevel = props.fuelLevel or 100.0

        ---@type ContextMenuArrayItem
        local option = {
            title = locale('vehicle_info', GetVehicleLabel(props.model), props.plate),
            icon = getClassIcon(class),
            progress = class ~= 13 and fuelLevel,
            colorScheme = class ~= 13 and getFuelBarColor(fuelLevel),
            metadata = {
                ---@diagnostic disable-next-line: assign-type-mismatch
                { label = locale('status'), value = locale(vehicle.state) },
                
                ---@diagnostic disable-next-line: assign-type-mismatch
                { label = locale('fuel'), value = class ~= 13 and fuelLevel .. '%' or locale('no_fueltank') }
            },
            args = { index = index, props = props },
            onSelect = vehicle.state == 'in_garage' and SpawnVehicle or function()
                if vehicle.state == 'out_garage' then
                    local coords = lib.callback.await('lunar_garage:getVehicleCoords', false, vehicle.plate)
                    SetNewWaypoint(coords.x, coords.y)
                    ShowNotification(locale('out_garage_message'))
                elseif vehicle.state == 'in_impound' then
                    ShowNotification(locale('in_impound_message'), 'error')
                end
            end
        }

        table.insert(options, option)
    end

    lib.registerContext({
        id = 'garage_vehicles',
        title = society and locale('society_vehicles') or locale('player_vehicles'),
        menu = 'garage_menu',
        options = options
    })

    lib.showContext('garage_vehicles')
end

local function openGarage(index)
    lib.registerContext({
        id = 'garage_menu',
        title = locale('garage_menu'),
        options = {
            {
                title = locale('player_vehicles'),
                description = locale('player_vehicles_desc'),
                icon = 'user',
                arrow = true,
                args = { index = index, society = false },
                onSelect = openGarageVehicles
            },
            {
                title = locale('society_vehicles'),
                description = locale('society_vehicles_desc'),
                icon = 'users',
                arrow = true,
                args = { index = index, society = true },
                onSelect = openGarageVehicles
            },
        }
    })

    lib.showContext('garage_menu')
end

---@param vehicle number?
local function saveVehicle(vehicle)
    if not vehicle and cache.seat ~= -1 then
        ShowNotification(locale('not_driver'), 'error')
        return
    end

    local vehicle = cache.vehicle or vehicle
    local props = lib.getVehicleProperties(vehicle)

    if not props then return end

    props.plate = props.plate:strtrim(' ') -- Trim whitespace
    props.fuelLevel = GetVehicleFuel(vehicle)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local result = lib.callback.await('lunar_garage:saveVehicle', false, props, netId)
    
    if result then
        if cache.vehicle then
            TaskLeaveAnyVehicle(cache.ped, 0, 0)
            Wait(1000)
        end

        ShowNotification(locale('vehicle_saved'), 'success')
    else
        ShowNotification(locale('not_your_vehicle'), 'error')
    end
end

local function retrieveVehicle(args)
    ---@type integer, VehicleProperties
    local index, props in args
    
    lib.requestModel(props.model)
    local type = getVehicleType(props.model)
    local success, netId = lib.callback.await('lunar_garage:retrieveVehicle', false, index, props.plate, type)

    if not success then
        ShowNotification(locale('not_enough_money'), 'error')
        return
    end

    while not NetworkDoesEntityExistWithNetworkId(netId) do Wait(0) end

    local vehicle = NetworkGetEntityFromNetworkId(netId)

    CreateThread(function()
        while true do
            if NetworkGetEntityOwner(vehicle) == cache.playerId then
                lib.setVehicleProperties(vehicle, props)
                return
            end

            local plate = GetVehicleNumberPlateText(vehicle)

            if plate == props.plate then
                return
            end

            Wait(0)
        end
    end)

    -- The player doesn't get warped in the vehicle sometimes, repeat it and timeout after 2000 attempts
    for _ = 1, 2000 do
        TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
        
        if GetVehiclePedIsIn(cache.ped, false) == vehicle then
            break
        end

        Wait(0)
    end

    SetVehicleFuel(vehicle, props.fuelLevel)
    SetVehicleOwner(props.plate)
end

local function openImpoundVehicles(args)
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
        local fuelLevel = props.fuelLevel or 100.0

        ---@type ContextMenuArrayItem
        local option = {
            title = locale('vehicle_info', GetVehicleLabel(props.model), props.plate),
            icon = getClassIcon(class),
            progress = class ~= 13 and fuelLevel,
            colorScheme = class ~= 13 and getFuelBarColor(fuelLevel),
            metadata = {
                ---@diagnostic disable-next-line: assign-type-mismatch
                { label = locale('fuel'), value = class ~= 13 and fuelLevel .. '%' or locale('no_fueltank') }
            },
            args = { index = index, props = props },
            onSelect = retrieveVehicle
        }

        table.insert(options, option)
    end

    lib.registerContext({
        id = 'impound_vehicles',
        title = society and locale('society_vehicles') or locale('player_vehicles'),
        menu = 'impound_menu',
        options = options
    })

    lib.showContext('impound_vehicles')
end

local function openImpound(index)
    lib.registerContext({
        id = 'impound_menu',
        title = locale('impound_menu'),
        options = {
            {
                title = locale('player_vehicles'),
                description = locale('player_vehicles_desc'),
                icon = 'user',
                arrow = true,
                args = { index = index, society = false },
                onSelect = openImpoundVehicles
            },
            {
                title = locale('society_vehicles'),
                description = locale('society_vehicles_desc'),
                icon = 'users',
                arrow = true,
                args = { index = index, society = true },
                onSelect = openImpoundVehicles
            },
        }
    })

    lib.showContext('impound_menu')
end 

local function garagePrompt(index, data)
    if cache.vehicle then
        ShowUI(('[%s] - %s'):format(Binds.second.currentKey, locale('save_vehicle')), 'floppy-disk')
        Binds.second.addListener('garage', function()
            saveVehicle()
        end)
    else
        local prompt

        if data.Interior then
            prompt = ('[%s] - %s  \n  [%s] - %s'):format(Binds.first.currentKey, locale('open_garage'), Binds.second.currentKey, locale('enter_interior'))
        else
            prompt = (('[%s] - %s'):format(Binds.first.currentKey, locale('open_garage')))
        end

        ShowUI(prompt, 'warehouse')
        Binds.first.addListener('garage', function()
            openGarage(index)
        end)
        Binds.second.addListener('garage', function()
            EnterInterior(index)
        end)
    end
end

local currentGarageIndex

lib.onCache('vehicle', function(vehicle)
    if not currentGarageIndex then return end

    local garage = Config.Garages[currentGarageIndex]

    if not garage then return end
    
    -- Update value manually, because it gets updated after the call of onCache
    cache.vehicle = vehicle
    garagePrompt(currentGarageIndex, garage)
end)

for index, data in ipairs(Config.Garages) do
    if (not Config.Target or not data.PedPosition) and data.Position then
        lib.zones.sphere({
            coords = data.Position,
            radius = Config.MaxDistance,
            onEnter = function()
                if data.Jobs and not Utils.hasJobs(data.Jobs) then return end

                garagePrompt(index, data)
                currentGarageIndex = index
            end,
            onExit = function()
                HideUI()
                Binds.first.removeListener('garage')
                Binds.second.removeListener('garage')
                currentGarageIndex = nil
            end
        })
    elseif (Config.Target or not data.Position) and data.PedPosition then
        if not data.Model then
            warn(('Skipping garage - missing Model, index: %s'):format(index))
            goto continue
        end

        Utils.createPed(data.PedPosition, data.Model, {
            {
                label = locale('open_garage'),
                icon = 'warehouse',
                job = data.Jobs,
                args = index,
                onSelect = openGarage
            },
            {
                label = locale('enter_interior'),
                icon = 'right-to-bracket',
                job = data.Jobs,
                args = index,
                canInteract = function()
                    return data.Interior ~= nil
                end,
                onSelect = EnterInterior
            },
            {
                label = locale('save_vehicle'),
                icon = 'floppy-disk',
                job = data.Jobs,
                onSelect = function()
                    local vehicle = GetVehiclePedIsIn(cache.ped, true)

                    if Utils.distanceCheck(cache.ped, vehicle, 20.0) then
                        saveVehicle(vehicle)
                    end
                end
            }
        })
    else
        warn(('Skipping garage - missing Position or PedPosition, index: %s'):format(index))
    end

    ::continue::
end

for index, data in ipairs(Config.Impounds) do
    if (not Config.Target or not data.PedPosition) and data.Position then
        lib.zones.sphere({
            coords = data.Position,
            radius = Config.MaxDistance,
            onEnter = function()
                if data.Jobs and not Utils.hasJobs(data.Jobs) then return end

                ShowUI(('[%s] - %s'):format(Binds.first.currentKey, locale('open_impound')), 'warehouse')
                Binds.first.addListener('impound', function()
                    openImpound(index)
                end)
            end,
            onExit = function()
                HideUI()
                Binds.first.removeListener('impound')
            end
        })
    elseif (Config.Target or not data.Position) and data.PedPosition then
        if not data.Model then
            warn(('Skipping impound - missing Model, index: %s'):format(index))
            goto continue
        end

        Utils.createPed(data.PedPosition, data.Model, {
            {
                label = locale('open_impound'),
                icon = 'warehouse',
                job = data.Jobs,
                args = index,
                onSelect = openImpound
            }
        })
    else
        warn(('Skipping impound - missing Position or PedPosition, index: %s'):format(index))
    end

    ::continue::
end