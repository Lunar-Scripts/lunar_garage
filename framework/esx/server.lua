if GetResourceState('es_extended') ~= 'started' then return end

Framework = { name = 'es_extended' }
local sharedObject = exports['es_extended']:getSharedObject()
local player = {}
local saved = {}

---@diagnostic disable-next-line: duplicate-set-field
Framework.getPlayerFromId = function(id)
    if saved[id] then return saved[id] end

    local player = setmetatable({}, { __index = player })
    player.xPlayer = sharedObject.GetPlayerFromId(id)
    if not player.xPlayer then return end
    player.source = id

    saved[id] = player
    return player
end

Framework.registerUsableItem = sharedObject.RegisterUsableItem

Framework.getPlayers = sharedObject.GetExtendedPlayers

Framework.getItemLabel = sharedObject.GetItemLabel

function player:hasGroup(name)
    return self.xPlayer.getGroup() == name
end

function player:hasOneOfGroups(groups)
    return groups[self.xPlayer.getGroup()] or false
end

function player:addItem(name, count)
    self.xPlayer.addInventoryItem(name, count)
end

function player:removeItem(name, count)
    self.xPlayer.removeInventoryItem(name, count)
end

function player:canCarryItem(name, count)
    return self.xPlayer.canCarryItem(name, count)
end

function player:getItemCount(name)
    return self.xPlayer.getInventoryItem(name).count
end

function player:getAccountMoney(account)
    return self.xPlayer.getAccount(account).money
end

function player:addAccountMoney(account, amount)
    self.xPlayer.addAccountMoney(account, amount)
end

function player:removeAccountMoney(account, amount)
    self.xPlayer.removeAccountMoney(account, amount)
end

function player:getJob()
    return self.xPlayer.getJob().name
end

function player:getIdentifier()
    return self.xPlayer.getIdentifier()
end

function player:getFirstName()
    return self.xPlayer.get('firstName')
end

function player:getLastName()
    return self.xPlayer.get('lastName')
end