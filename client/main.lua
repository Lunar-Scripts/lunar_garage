local currentZone, currentData = nil, nil

function ShowUI(message, icon)
    if icon == 0 then
        lib.showTextUI(message)
    else
        lib.showTextUI(message, {
            icon = icon
        })
    end
end

function HideUI()
    lib.hideTextUI()
end

RegisterKeyMapping('opengarage', 'Access garage', 'keyboard', 'e')
RegisterKeyMapping('savevehicle', 'Save vehicle', 'keyboard', 'g')

RegisterCommand('opengarage', function()
    local playerPed = PlayerPedId()
    if currentZone == nil or ESX.IsPlayerLoaded() == false or IsEntityDead(playerPed) then
        return
    end
    if currentZone == 'open' then
        ESX.TriggerServerCallback('lunar_garage:getVehicles', function(vehicles) 
            if #vehicles > 0 then
                local elements = {}
                for k,v in ipairs(vehicles) do
                    local props = json.decode(v.vehicle)
                    if IsModelInCdimage(props.model) then
                        local label = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
                        if label == 'NULL' then 
                            label = GetDisplayNameFromVehicleModel(props.model)
                        end
                        if v.stored == true or v.stored == 1 then
                            table.insert(elements, {
                                title = _U('vehicle', label),
                                description = _U('license_plate', props.plate),
                                metadata = { { label = 'Status', value = _U('in_garage') } },
                                onSelect = SpawnVehicle,
                                args = props,
                            })
                        else
                            table.insert(elements, {
                                title = _U('vehicle', label),
                                description = _U('license_plate', props.plate),
                                metadata = { { label = 'Status', value = _U('out_garage') } },
                                onSelect = function(args)
                                    TriggerEvent(Config.Notify, _U('impounded'))
                                end,
                            })
                        end
                    end
                end
                lib.registerContext({
                    id = 'garage',
                    title = _U('garage'),
                    options = elements,
                })
                lib.showContext('garage')
            else
                TriggerEvent(Config.Notify, _U('no_vehicles'))
            end
        end, currentData)
    elseif currentZone == 'impound' then
        ESX.TriggerServerCallback('lunar_garage:getImpoundedVehicles', function(vehicles) 
            if #vehicles > 0 then
                local elements = {}
                for k,v in ipairs(vehicles) do
                    local props = json.decode(v.vehicle)
                    if IsModelInCdimage(props.model) then
                        local label = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
                        if label == 'NULL' then 
                            label = GetDisplayNameFromVehicleModel(props.model)
                        end
                        table.insert(elements, {
                            title = _U('vehicle', label),
                            description = _U('license_plate', props.plate),
                            onSelect = RetrieveVehicle,
                            args = props,
                        })
                    end
                end
                lib.registerContext({
                    id = 'impound',
                    title = _U('impound'),
                    options = elements,
                })
                lib.showContext('impound')
            else
                TriggerEvent(Config.Notify, _U('no_impound_vehicles'))
            end
        end, currentData)
    end
end, false)

RegisterCommand('savevehicle', function()
    local playerPed = PlayerPedId()
    if currentZone ~= 'save' or ESX.IsPlayerLoaded() == false or IsEntityDead(playerPed) then
        return
    end
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local props = ESX.Game.GetVehicleProperties(vehicle)
    ESX.TriggerServerCallback('lunar_garage:saveVehicle', function(success) 
        if success then
            TaskLeaveVehicle(playerPed, vehicle, 0)
            Wait(1000)
            ESX.Game.DeleteVehicle(vehicle)
            TriggerEvent(Config.Notify, _U('save_success'))
        else
            TriggerEvent(Config.Notify, _U('not_yours'))
        end
    end, props)
end, false)

function SpawnVehicle(props)
    local garage = Config.Garages[currentData]
    ESX.Game.SpawnVehicle(props.model, garage.SpawnPosition, garage.SpawnPosition.w, function(vehicle)
        if DoesEntityExist(vehicle) then
            ESX.Game.SetVehicleProperties(vehicle, props)
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
            TriggerServerEvent('lunar_garage:vehicleTakenOut', props.plate)
        end
    end)
end

function RetrieveVehicle(props)
    local impound = Config.Impounds[currentData]
    ESX.TriggerServerCallback('lunar_garage:returnVehicle', function(success) 
        if success then
            ESX.Game.SpawnVehicle(props.model, impound.SpawnPosition, impound.SpawnPosition.w, function(vehicle) 
                if DoesEntityExist(vehicle) then
                    ESX.Game.SetVehicleProperties(vehicle, props)
                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                end
            end)
        else
            TriggerEvent(Config.Notify, _U('not_enough_money'))
        end
    end, props.plate)
end

Citizen.CreateThread(function()
    for k,v in pairs(Config.Garages) do
        --Implicitly visible if someone forgets to add it in config.lua
        if v.Visible ~= false then
            local blip = AddBlipForCoord(v.Position.x, v.Position.y, v.Position.z)
            local info = Config.Blips[v.Type].Garage
            SetBlipSprite(blip, info.Type)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, info.Size)
            SetBlipColour(blip, info.Color)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(info.Name)
            EndTextCommandSetBlipName(blip)
        end
    end
    for k,v in pairs(Config.Impounds) do
        --Implicitly visible if someone forgets to add it in config.lua
        if v.Visible ~= false then
            local blip = AddBlipForCoord(v.Position.x, v.Position.y, v.Position.z)
            local info = Config.Blips[v.Type].Impound
            SetBlipSprite(blip, info.Type)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, info.Size)
            SetBlipColour(blip, info.Color)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(info.Name)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(500)
        if ESX.IsPlayerLoaded() then
            local playerPed = PlayerPedId()
            for k,v in ipairs(Config.Garages) do
                local dist = #(v.Position - GetEntityCoords(playerPed))
                if dist < Config.MaxDistance and currentZone ~= 'open' and not IsPedInAnyVehicle(playerPed, false) then
                    ShowUI(_U('open_prompt'), 'warehouse')
                    currentZone = 'open'
                    currentData = k
                elseif dist > Config.MaxDistance and currentZone == 'open' and currentData == k then
                    HideUI()
                    currentZone = nil
                    currentData = nil
                end
                if dist < Config.MaxDistance and currentZone ~= 'save' and IsPedInAnyVehicle(playerPed, false) then
                    ShowUI(_U('save_prompt'), 'floppy-disk')
                    currentZone = 'save'
                    currentData = k
                elseif dist > Config.MaxDistance and currentZone == 'save' and currentData == k then
                    HideUI()
                    currentZone = nil
                    currentData = nil
                end
            end
            for k,v in ipairs(Config.Impounds) do
                local dist = #(v.Position - GetEntityCoords(playerPed))
                if dist < Config.MaxDistance and currentZone ~= 'impound' and not IsPedInAnyVehicle(playerPed, false) then
                    ShowUI(_U('impound_prompt'), 'warehouse')
                    currentZone = 'impound'
                    currentData = k
                elseif dist > Config.MaxDistance and currentZone == 'impound' and currentData == k then
                    HideUI()
                    currentZone = nil
                    currentData = nil
                end
            end
        end
    end
end)