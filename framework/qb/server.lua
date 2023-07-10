if GetResourceState('qb-core') ~= 'started' then return end

Framework = { Name = 'qb-core' }
local sharedObject = exports['qb-core']:GetCoreObject()
QBCore = sharedObject
local player = {}
local saved = {}

---@diagnostic disable-next-line: duplicate-set-field
function Framework.GetPlayerFromId(id)
    if saved[id] then return saved[id] end

    local player = setmetatable({}, { __index = player })
    player.QBPlayer = sharedObject.Functions.GetPlayer(id)
    if not player.QBPlayer then return end
    player.source = id

    saved[id] = player
    return player
end

Framework.GetPlayers = sharedObject.Functions.GetQBPlayers

local ox_inventory = GetResourceState('ox_inventory') == 'started'

function Framework.GetItemLabel(item)
    if ox_inventory then
        return exports.ox_inventory:Items()[item]?.label
    end
    return sharedObject.Shared.Items[item]?.label
end

function player:HasGroup(name)
    return sharedObject.Functions.HasPermission(self.source, name) == name
end

function player:HasOneOfGroups(groups)
    for k,v in pairs(groups) do
        if sharedObject.Functions.HasPermission(self.source, k) then
            return true
        end
    end

    return false
end

function player:AddItem(name, count)
    self.QBPlayer.Functions.AddItem(name, count)
end

function player:RemoveItem(name, count)
    self.QBPlayer.Functions.RemoveItem(name, count)
end

function player:CanCarryItem(name, count)
    return true
end

function player:GetItemCount(name)
    return self.QBPlayer.Functions.GetItemByName(name)?.amount or 0
end

function player:GetAccountMoney(account)
    if account == 'money' then
        return self.QBPlayer.Functions.GetMoney('cash')
    else
        return self.QBPlayer.Functions.GetMoney(account)
    end
end

function player:AddAccountMoney(account, amount)
    if account == 'money' then
        self.QBPlayer.Functions.AddMoney('cash', amount)
    else
        self.QBPlayer.Functions.AddMoney(account, amount)
    end
end

function player:RemoveAccountMoney(account, amount)
    if account == 'money' then
        self.QBPlayer.Functions.RemoveMoney('cash', amount)
    else
        self.QBPlayer.Functions.RemoveMoney(account, amount)
    end
end

function player:GetJob()
    return self.QBPlayer.PlayerData.job.name
end

function player:GetIdentifier()       
    return self.QBPlayer.PlayerData.citizenid
end

function player:GetFirstName()
    return self.QBPlayer.PlayerData.charinfo.firstname
end

function player:GetLastName()
    return self.QBPlayer.PlayerData.charinfo.lastname
end