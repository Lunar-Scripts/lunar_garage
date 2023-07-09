if GetResourceState('es_extended') ~= 'started' then return end

Framework = { Name = 'es_extended' }
local sharedObject = exports['es_extended']:getSharedObject()

AddEventHandler('esx:setPlayerData', function(key, val, last)
    if GetInvokingResource() == 'es_extended' then
        sharedObject.PlayerData[key] = val
        if OnPlayerData then
            OnPlayerData(key, val, last)
        end
    end
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    sharedObject.PlayerData = xPlayer
    sharedObject.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    sharedObject.PlayerLoaded = false
    sharedObject.PlayerData = {}
end)

Framework.IsPlayerLoaded = sharedObject.IsPlayerLoaded

Framework.GetJob = function()
    if not Framework.IsPlayerLoaded() then
        return false
    end

    return sharedObject.PlayerData.job.name
end

Framework.HasItem = function(name)
    local playerData = sharedObject.GetPlayerData()
    for k,v in ipairs(playerData.inventory) do
        if v.name == name then
            return true
        end
    end
    return false
end

Framework.SpawnVehicle = sharedObject.Game.SpawnVehicle

Framework.SpawnLocalVehicle = sharedObject.Game.SpawnLocalVehicle

Framework.DeleteVehicle = sharedObject.Game.DeleteVehicle

Framework.GetPlayersInArea = sharedObject.Game.GetPlayersInArea