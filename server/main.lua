ESX.RegisterServerCallback('lunar_garage:getVehicles', function(source, cb, garage)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ? and type = ?', { xPlayer.identifier, Config.Garages[garage].Type })
    cb(vehicles)
end)

RegisterNetEvent('lunar_garage:vehicleTakenOut')
AddEventHandler('lunar_garage:vehicleTakenOut', function(plate)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.update.await('UPDATE owned_vehicles SET stored = 0 WHERE plate = ? and owner = ?', { plate, xPlayer.identifier })
end)

ESX.RegisterServerCallback('lunar_garage:saveVehicle', function(source, cb, props)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicle = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ? and owner = ?', { props.plate, xPlayer.identifier })
    if #vehicle == 0 then
        cb(false)
        return
    end
    if json.decode(vehicle[1].vehicle).model == props.model then
        MySQL.update.await('UPDATE owned_vehicles SET vehicle = ?, stored = 1 WHERE plate = ?', { json.encode(props), props.plate })
        cb(true)
    else
        print('Cheater is trying to change vehicle hash, identifier: ' .. xPlayer.identifier)
        cb(false)
    end
end)

ESX.RegisterServerCallback('lunar_garage:getImpoundedVehicles', function(source, cb, garage)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ? and type = ? and stored = 0', { xPlayer.identifier, Config.Garages[garage].Type })
    cb(vehicles)
end)

ESX.RegisterServerCallback('lunar_garage:returnVehicle', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getAccount('money').money >= Config.ImpoundPrice then
        xPlayer.removeAccountMoney('money', Config.ImpoundPrice)
        cb(true)
    else
        cb(false)
    end
end)