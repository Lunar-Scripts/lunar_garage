local function TransferToPlayer(source, plate, label)
    local player = Framework.GetPlayerFromId(source)

    if not player then return end

    local vehicle = MySQL.single.await(Queries.getVehicleStrict, { player:GetIdentifier(), plate })

    if not vehicle then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_not_yours'), 'error')
        return
    end

    local targetId, price = lib.callback.await('lunar_garage:getTargetPlayer', source)

    if not targetId or source == targetId or not price or price < 0 then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('invalid_data'), 'error')
        return
    end

    if not Utils.DistanceCheck(source, targetId, 10.0) then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('player_too_far'), 'error')
        return
    end

    local target = Framework.GetPlayerFromId(targetId)

    if not target then return end

    local name = ('%s %s'):format(player:GetFirstName(), player:GetLastName())
    local success = lib.callback.await('lunar_garage:getAgreement', targetId, price, label, name)

    if not success then return end

    MySQL.update.await(Queries.transferVehiclePlayer, { target:GetIdentifier(), plate })
    player:RemoveItem(Config.Contract.Item, 1)

    TriggerClientEvent('lunar_garage:contractAnim', source, locale('progress_selling'))
    Wait(Config.Contract.Duration)
    TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_sold'))
    Wait(500)
    TriggerClientEvent('lunar_garage:contractAnim', targetId, locale('progress_buying'))
    Wait(Config.Contract.Duration)
    TriggerClientEvent('lunar_garage:showNotification', targetId, locale('vehicle_bought'))
end

local function TransferToSociety(source, plate)
    local player = Framework.GetPlayerFromId(source)

    if not player then return end

    local vehicle = MySQL.single.await(Queries.getVehicleStrict, { player:GetIdentifier(), plate })

    if not vehicle then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_not_yours'), 'error')
        return
    end

    local result = lib.callback.await('lunar_garage:societyPrompt', source, 'transfer')

    if not result then return end

    MySQL.update.await(Queries.transferVehicleSociety, { player:GetJob(), plate })
    player:RemoveItem(Config.Contract.Item, 1)

    TriggerClientEvent('lunar_garage:contractAnim', source, locale('progress_transfering'))
    Wait(Config.Contract.Duration)
    TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_transfered'))
end

local function WithdrawFromSociety(source, plate)
    local player = Framework.GetPlayerFromId(source)

    if not player then return end

    local vehicle = MySQL.single.await(Queries.getVehicle, { player:GetIdentifier(), plate })

    if not vehicle then
        TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_not_yours'), 'error')
        return
    end

    local result = lib.callback.await('lunar_garage:societyPrompt', source, 'withdraw')

    if not result then return end

    MySQL.update.await(Queries.withdrawVehicleSociety, { plate })
    player:RemoveItem(Config.Contract.Item, 1)

    TriggerClientEvent('lunar_garage:contractAnim', source, locale('progress_withdrawing'))
    Wait(Config.Contract.Duration)
    TriggerClientEvent('lunar_garage:showNotification', source, locale('vehicle_withdrawn'))
end

Framework.RegisterUsableItem(Config.Contract.Item, function(source)
    local option, plate, label = lib.callback.await('lunar_garage:getContractOption', source)

    if not option or not plate then return end

    if option == 'transfer_player' then
        TransferToPlayer(source, plate, label)
    elseif option == 'transfer_society' then
        TransferToSociety(source, plate)
    elseif option == 'withdraw_society' then
        WithdrawFromSociety(source, plate)
    end
end)