lib.callback.register('lunar_garage:getContractOption', function()
    if cache.vehicle then
        ShowNotification(locale('cant_in_vehicle'), 'error')
        return
    end

    local vehicle = lib.getClosestVehicle(cache.coords, 3.0, false)

    if not vehicle then
        ShowNotification(locale('no_vehicle_near_you'), 'error')
        return 
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local label = GetVehicleLabel(GetEntityModel(vehicle))
    local option = promise.new()

    local function Resolve(name)
        option:resolve(name)
    end

    lib.registerContext({
        id = 'contract',
        title = locale('contract'),
        onClose = function()
            option:resolve()
        end,
        options = {
            {
                title = locale('transfer_player'),
                icon = 'user',
                args = 'transfer_player',
                onSelect = Resolve
            },
            {
                title = locale('transfer_society'),
                icon = 'users',
                args = 'transfer_society',
                onSelect = Resolve
            },
            {
                title = locale('withdraw_society'),
                icon = 'rotate-left',
                args = 'withdraw_society',
                onSelect = Resolve
            }
        }
    })

    lib.showContext('contract')

    return Citizen.Await(option), plate, label
end)

lib.callback.register('lunar_garage:getTargetPlayer', function()
    local input = lib.inputDialog(locale('pick_player'), {
        locale('player_id'), locale('sell_price') 
    })

    if not input then return end

    return tonumber(input[1]), tonumber(input[2])
end)

lib.callback.register('lunar_garage:getAgreement', function(price, label, name)
    local result = lib.alertDialog({
        header = locale('offer'),
        content = locale('offer_content', name, label, price),
        centered = true,
        labels = {
            confirm = locale('offer_confirm'),
            cancel = locale('offer_cancel')
        }
    })

    return result == 'confirm'
end)

---@param type 'transfer' | 'withdraw'
lib.callback.register('lunar_garage:societyPrompt', function(type)
    local result = lib.alertDialog({
        header = locale('society_prompt'),
        content = type == 'transfer' and locale('society_transfer') or locale('society_withdraw'),
        centered = true,
        labels = {
            confirm = locale('society_confirm'),
            cancel = locale('society_cancel'),
        }
    })

    return result == 'confirm'
end)

RegisterNetEvent('lunar_garage:contractAnim', function(message)
    lib.progressBar({
        label = message,
        duration = Config.Contract.Duration,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    })
end)