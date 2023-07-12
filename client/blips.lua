---@param garage LocationData
local function CreateGarageBlip(garage)
    local data = Config.Blips[garage.Type]?.Garage

    if data then
        Utils.CreateBlip(garage.Position or garage.PedPosition, data.Name, data.Sprite, data.Size, data.Color)
    else
        warn('Missing blip data for vehicle type: %s', garage.Type)
    end
end

---@param impound LocationData
local function CreateImpoundBlip(impound)
    local data = Config.Blips[impound.Type]?.Impound

    if data then
        Utils.CreateBlip(impound.Position or impound.PedPosition, data.Name, data.Sprite, data.Size, data.Color)
    else
        warn('Missing blip data for vehicle type: %s', impound.Type)
    end
end

for _, garage in ipairs(Config.Garages) do
    if garage.Visible then
        CreateGarageBlip(garage)
    end
end

for _, impound in ipairs(Config.Impounds) do
    if impound.Visible then
        CreateImpoundBlip(impound)
    end
end