---@param garage GarageData
local function createGarageBlip(garage)
    local data = Config.Blips[garage.Type]?.Garage

    if data then
        Utils.createBlip(garage.Position or garage.PedPosition, data.Name, data.Sprite, data.Size, data.Color)
    else
        warn('Missing blip data for vehicle type: %s', garage.Type)
    end
end

---@param impound ImpoundData
local function createImpoundBlip(impound)
    local data = Config.Blips[impound.Type]?.Impound

    if data then
        Utils.createBlip(impound.Position or impound.PedPosition, data.Name, data.Sprite, data.Size, data.Color)
    else
        warn('Missing blip data for vehicle type: %s', impound.Type)
    end
end

for _, garage in ipairs(Config.Garages) do
    if garage.Visible then
        createGarageBlip(garage)
    end
end

for _, impound in ipairs(Config.Impounds) do
    if impound.Visible then
        createImpoundBlip(impound)
    end
end