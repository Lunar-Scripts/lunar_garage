-- Used to store vehicles that have been taken out
---@type table<string, number>
local activeVehicles = {}

lib.callback.register('lunar_garage:getOwnedVehicles', function(source, index, society)
    local player = Framework.getPlayerFromId(source)
    if not player then return end
    
    local garage = Config.Garages[index]

    if society then
        local vehicles = MySQL.query.await(Queries.getGarageSociety, {
            player:getJob(), garage.Type
        })

        for _, vehicle in ipairs(vehicles) do
            if vehicle.stored == 1 then
                vehicle.state = 'in_garage'
            elseif activeVehicles[vehicle.plate] then
                local entity = activeVehicles[vehicle.plate]
                if GetVehiclePetrolTankHealth(entity) <= 0 or GetVehicleBodyHealth(entity) <= 0 then
                    DeleteEntity(entity)
                    activeVehicles[vehicle.plate] = nil
                    vehicle.state = 'in_impound'
                else
                    vehicle.state = 'out_garage'
                end
            else
                vehicle.state = 'in_impound'
            end
        end

        return vehicles
    else
        local vehicles = MySQL.query.await(Queries.getGarage, {
            player:getIdentifier(), garage.Type
        })

        for _, vehicle in ipairs(vehicles) do
            if vehicle.stored == 1 then
                vehicle.state = 'in_garage'
            elseif activeVehicles[vehicle.plate] then
                local entity = activeVehicles[vehicle.plate]
                if GetVehiclePetrolTankHealth(entity) <= 0 or GetVehicleBodyHealth(entity) <= 0 then
                    DeleteEntity(entity)
                    activeVehicles[vehicle.plate] = nil
                    vehicle.state = 'in_impound'
                else
                    vehicle.state = 'out_garage'
                end
            else
                vehicle.state = 'in_impound'
            end
        end

        return vehicles
    end
end)

lib.callback.register('lunar_garage:getImpoundedVehicles', function(source, index, society)
    local player = Framework.getPlayerFromId(source)
    if not player then return end
    
    local impound = Config.Impounds[index]

    if society then
        local vehicles = MySQL.query.await(Queries.getImpoundSociety, {
            player:getJob(), impound.Type
        })

        local filtered = {}

        for _, vehicle in ipairs(vehicles) do
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
        local vehicles = MySQL.query.await(Queries.getImpound, {
            player:getIdentifier(), impound.Type
        })

        local filtered = {}

        for _, vehicle in ipairs(vehicles) do
            local entity = activeVehicles[vehicle.plate]

            if not entity then
                table.insert(filtered, vehicle)
            elseif not DoesEntityExist(entity) or GetVehiclePetrolTankHealth(entity) <= 0 or GetVehicleBodyHealth(entity) <= 0 then
                DeleteEntity(entity)
                activeVehicles[vehicle.plate] = nil
                table.insert(filtered, vehicle)
            end
        end

        return filtered
    end
end)

lib.callback.register('lunar_garage:takeOutVehicle', function(source, index, plate)
    local player = Framework.getPlayerFromId(source)
    if not player then return end

    local vehicle = MySQL.single.await(Queries.getStoredVehicle, {
        player:getIdentifier(), player:getJob(), plate, 1
    })

    if vehicle then
        MySQL.update.await(Queries.setStoredVehicle, { 0, plate })
        local garage = Config.Garages[index]
        local coords = garage.SpawnPosition
        local model = json.decode(vehicle.vehicle).model
        local entity = Utils.createVehicle(model, coords)

        activeVehicles[plate] = entity;

        return NetworkGetNetworkIdFromEntity(entity)
    end
end)

lib.callback.register('lunar_garage:saveVehicle', function(source, props)
    local player = Framework.getPlayerFromId(source)
    if not player then return end

    local vehicle = MySQL.single.await(Queries.getOwnedVehicle, {
        player:getIdentifier(), player:getJob(), props.plate
    })
    
    if vehicle then
        local oldProps = json.decode(vehicle.mods or vehicle.vehicle)

        if props.model ~= oldProps.model then
            return false
        end

        MySQL.update.await(Queries.setStoredVehicle, { 1, props.plate })
        MySQL.update.await(Queries.setVehicleProps, { json.encode(props), props.plate })

        activeVehicles[props.plate] = nil;

        return true
    end
    
    return false
end)

lib.callback.register('lunar_garage:retrieveVehicle', function(source, index, plate)
    if activeVehicles[plate] then return end

    local player = Framework.getPlayerFromId(source)
    if not player then return end

    local vehicle = MySQL.single.await(Queries.getOwnedVehicle, {
        player:getIdentifier(), player:getJob(), plate
    })

    if vehicle then
        if player:getAccountMoney('money') < Config.ImpoundPrice then return false end

        player:removeAccountMoney('money', Config.ImpoundPrice)

        local impound = Config.Impounds[index]
        local coords = impound.SpawnPosition
        local props = json.decode(vehicle.vehicle or vehicle.mods)
        local entity = Utils.createVehicle(props.model, coords)
        
        activeVehicles[props.model] = entity

        return true, NetworkGetNetworkIdFromEntity(entity)
    end

    return false
end)

lib.callback.register('lunar_garage:getVehicleCoords', function(source, plate)
    local entity = activeVehicles[plate]

    if not entity then return end

    return GetEntityCoords(entity)
end)