if GetResourceState('es_extended') ~= 'started' then return end

Framework = { Name = 'es_extended' }
local sharedObject = exports['es_extended']:getSharedObject()
local player = {}
local saved = {}

--Framework functions
Framework.GetPlayerFromId = function(id)
    if saved[id] then return saved[id] end
    
    local player = setmetatable({}, { __index = player })
    player.xPlayer = sharedObject.GetPlayerFromId(id)
    if not player.xPlayer then return end
    player.source = id
    
    saved[id] = player
    return player
end

Framework.GetPlayers = sharedObject.GetExtendedPlayers

Framework.GetItemLabel = sharedObject.GetItemLabel

function player:HasGroup(name)
    return self.xPlayer.getGroup() == name
end

function player:HasOneOfGroups(groups)
    return groups[self.xPlayer.getGroup()] or false
end

function player:AddItem(name, count)
    self.xPlayer.addInventoryItem(name, count)
end

function player:RemoveItem(name, count)
    self.xPlayer.removeInventoryItem(name, count)
end

function player:CanCarryItem(name, count)
    return self.xPlayer.canCarryItem(name, count)
end

function player:GetItemCount(name)
    return self.xPlayer.getInventoryItem(name).count
end

function player:GetAccountMoney(account)
    return self.xPlayer.getAccount(account).money
end

function player:AddAccountMoney(account, amount)
    self.xPlayer.addAccountMoney(account, amount)
end

function player:RemoveAccountMoney(account, amount)
    self.xPlayer.removeAccountMoney(account, amount)
end

function player:GetJob()
    return self.xPlayer.getJob().name
end

function player:GetIdentifier()
    return self.xPlayer.getIdentifier()
end

function player:GetFirstName()
    return self.xPlayer.get('firstName')
end

function player:GetLastName()
    return self.xPlayer.get('lastName')
end