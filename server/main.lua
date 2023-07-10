-- Used to store vehicles that have been taken out
---@type table<string, number>
local activeVehicles = {}

lib.callback.register('lunar_garage:getOwnedVehicles', function(source, index, society)
    local player = Framework.GetPlayerFromId(source)
    if not player then return end
    
    local garage = Config.Garages[index]

    if society then
        local vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE job = ? and type = ?', {
            player:GetJob(), garage.Type
        })

        return vehicles
    else
        local vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ? and type = ? and job is NULL', {
            player:GetIdentifier(), garage.Type
        })

        return vehicles
    end
end)

lib.callback.register('lunar_garage:getImpoundedVehicles', function(source, index, society)
    local player = Framework.GetPlayerFromId(source)
    if not player then return end
    
    local impound = Config.Impounds[index]

    if society then
        local vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE job = ? and type = ? and stored = 0', {
            player:GetJob(), impound.Type
        })

        local filtered = {}

        for _, vehicle in vehicles do
            local entity = activeVehicles[vehicle.plate]

            if not entity then
                table.insert(filtered, vehicle)
            elseif GetVehiclePetrolTankHealth(entity) <= 0 or GetVehicleBodyHealth(entity) <= 0 then
                DeleteEntity(entity)
                activeVehicles[vehicle.plate] = nil
                table.insert(filtered, vehicle)
            end
        end

        return filtered
    else
        local vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ? and type = ? and job is NULL and stored = 0', {
            player:GetIdentifier(), impound.Type
        })

        return vehicles
    end
end)

lib.callback.register('lunar_garage:takeOutVehicle', function(source, index, plate)
    local player = Framework.GetPlayerFromId(source)
    if not player then return end

    local vehicle = MySQL.single.await('SELECT * FROM owned_vehicles WHERE (owner = ? or job = ?) and plate = ? and stored = 1', {
        player:GetIdentifier(), player:GetJob(), plate
    })

    if vehicle then
        MySQL.update.await('UPDATE owned_vehicles SET stored = 1 WHERE plate = ?', { plate })
        local garage = Config.Garages[index]
        local coords = garage.SpawnPosition
        local model = json.decode(vehicle.vehicle).model
        local entity = CreateVehicleServerSetter(model, 'automobile', coords.x, coords.y, coords.z - 0.5, coords.w)

        for seatIndex = -1, 6 do
            local ped = GetPedInVehicleSeat(entity, seatIndex)
            local type = GetEntityPopulationType(ped)

            if type > 0 and type < 6 then
                DeleteEntity(ped)
            end
        end

        activeVehicles[plate] = entity;

        return NetworkGetNetworkIdFromEntity(entity)
    end
end)

lib.callback.register('lunar_garage:saveVehicle', function(source, props)
    local player = Framework.GetPlayerFromId(source)
    if not player or not props then return end

    local vehicle = MySQL.single.await('SELECT * FROM owned_vehicles WHERE (owner = ? or job = ?) and plate = ?', {
        player:GetIdentifier(), player:GetJob(), props.plate
    })

    if vehicle then
        MySQL.update.await('UPDATE owned_vehicles SET stored = 1 WHERE plate = ?', { props.plate })
        return true
    end
    
    return false
end)

lib.callback.register('lunar_garage:retrieveVehicle', function(source, index, plate)
    if activeVehicles[plate] then return end

    local player = Framework.GetPlayerFromId(source)
    if not player then return end

    local vehicle = MySQL.single.await('SELECT * FROM owned_vehicles WHERE (owner = ? or job = ?) and plate = ?', {
        player:GetIdentifier(), player:GetJob(), plate
    })

    if vehicle then
        local impound = Config.Impounds[index]
        local coords = impound.SpawnPosition
        local model = json.decode(vehicle.vehicle).model
        local entity = CreateVehicleServerSetter(model, 'automobile', coords.x, coords.y, coords.z - 0.5, coords.w)

        for seatIndex = -1, 6 do
            local ped = GetPedInVehicleSeat(entity, seatIndex)
            local type = GetEntityPopulationType(ped)

            if type > 0 and type < 6 then
                DeleteEntity(ped)
            end
        end

        return NetworkGetNetworkIdFromEntity(entity)
    end
end)