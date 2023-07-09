if GetResourceState('qb-core') ~= 'started' then return end

Framework = { Name = 'qb-core' }
local sharedObject = exports['qb-core']:GetCoreObject()

function Framework.IsPlayerLoaded()
    return next(sharedObject.Functions.GetPlayerData()) ~= nil
end

function Framework.GetJob()
    if not Framework.IsPlayerLoaded() then
        return false
    end

    return sharedObject.Functions.GetPlayerData().job.name
end

Framework.HasItem = sharedObject.Functions.HasItem

function Framework.SpawnVehicle(model, coords, heading, cb)
    sharedObject.Functions.SpawnVehicle(model, cb, vector4(coords.x, coords.y, coords.z, heading), true)
end

function Framework.SpawnLocalVehicle(model, coords, heading, cb)
    sharedObject.Functions.SpawnVehicle(model, cb, vector4(coords.x, coords.y, coords.z, heading), false)
end

Framework.DeleteVehicle = sharedObject.Functions.DeleteVehicle

Framework.GetPlayersInArea = sharedObject.Functions.GetPlayersFromCoords