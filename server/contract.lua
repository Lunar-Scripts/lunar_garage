local function transferToPlayer(source, plate, label)
    local player = Framework.getPlayerFromId(source)

    if not player then return end

    local vehicle = MySQL.single.await(Queries.getVehicleStrict, { player:getIdentifier(), plate })

    if not vehicle then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_not_yours'), 'error')
        return
    end

    local targetId, price = lib.callback.await('lunar_garage:getTargetPlayer', source)

    if not targetId or source == targetId or not price or price < 0 then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('invalid_data'), 'error')
        return
    end

    if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(targetId))) > 10.0 then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('player_too_far'), 'error')
        return
    end

    local target = Framework.getPlayerFromId(targetId)

    if not target then return end

    local name = ('%s %s'):format(player:getFirstName(), player:getLastName())
    local success = lib.callback.await('lunar_garage:getAgreement', targetId, price, label, name)

    if not success then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('offer_declined'), 'error')
        return
    end

    if target:getAccountMoney('money') < price then
        return
    end

    MySQL.update.await(Queries.transferVehiclePlayer, { target:getIdentifier(), plate })
    player:removeItem(Config.Contract.Item, 1)
    target:removeAccountMoney('money', price)
    player:addAccountMoney('money', price)

    TriggerClientEvent('lunar_garage:contractAnim', source, locale('progress_selling'))
    Wait(Config.Contract.Duration)
    TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_sold'))
    Wait(500)
    TriggerClientEvent('lunar_garage:contractAnim', targetId, locale('progress_buying'))
    Wait(Config.Contract.Duration)
    TriggerClientEvent('lunar_garage:showNotification', targetId, locale('vehicle_bought'))
end

local function transferToSociety(source, plate)
    local player = Framework.getPlayerFromId(source)

    if not player then return end

    local vehicle = MySQL.single.await(Queries.getVehicleStrict, { player:getIdentifier(), plate })

    if not vehicle then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_not_yours'), 'error')
        return
    end

    local result = lib.callback.await('lunar_garage:societyPrompt', source, 'transfer')

    if not result then return end

    MySQL.update.await(Queries.transferVehicleSociety, { player:getJob(), plate })
    player:removeItem(Config.Contract.Item, 1)

    TriggerClientEvent('lunar_garage:contractAnim', source, locale('progress_transfering'))
    Wait(Config.Contract.Duration)
    TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_transfered'))
end

local function withdrawFromSociety(source, plate)
    local player = Framework.getPlayerFromId(source)

    if not player then return end

    local vehicle = MySQL.single.await(Queries.getVehicle, { player:getIdentifier(), plate })

    if not vehicle then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_not_yours'), 'error')
        return
    end

    local result = lib.callback.await('lunar_garage:societyPrompt', source, 'withdraw')

    if not result then return end

    MySQL.update.await(Queries.withdrawVehicleSociety, { plate })
    player:removeItem(Config.Contract.Item, 1)

    TriggerClientEvent('lunar_garage:contractAnim', source, locale('progress_withdrawing'))
    Wait(Config.Contract.Duration)
    TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_withdrawn'))
end

Framework.registerUsableItem(Config.Contract.Item, function(source)
    local option, plate, label = lib.callback.await('lunar_garage:getContractOption', source)

    if not option or not plate then return end

    if option == 'transfer_player' then
        transferToPlayer(source, plate, label)
    elseif option == 'transfer_society' then
        transferToSociety(source, plate)
    elseif option == 'withdraw_society' then
        withdrawFromSociety(source, plate)
    end
end)
