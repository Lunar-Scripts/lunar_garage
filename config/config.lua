Config = {}
Config.MaxDistance = 10.0 -- Max interact distance

---@alias VehicleType string

---@class BlipData
---@field Name string
---@field Sprite integer
---@field Size number
---@field Color integer

---@type table<VehicleType, table<'Garage' | 'Impound', BlipData>>
Config.Blips = {
    ['car'] = {
        Garage = {
            Name = 'Garage',
            Sprite = 357,
            Size = 0.5,
            Color = 17
        },
        Impound = {
            Name = 'Impound',
            Sprite = 357,
            Size = 0.5,
            Color = 3
        },
    },
    ['air'] = {
        Garage = {
            Name = 'Air Garage',
            Sprite = 357,
            Size = 0.5,
            Color = 17
        },
        Impound = {
            Name = 'Air Impound',
            Sprite = 357,
            Size = 0.5,
            Color = 3
        },
    },
    ['boat'] = {
        Garage = {
            Name = 'Boat Garage',
            Sprite = 357,
            Size = 0.5,
            Color = 17
        },
        Impound = {
            Name = 'Boat Impound',
            Sprite = 357,
            Size = 0.5,
            Color = 3
        },
    },
}

---@class LocationData
---@field Visible boolean Blip visibility on map.
---@field Type VehicleType The vehicle type.
---@field Position? vector3 Needs to be defined if PedPosition isn't.
---@field PedPosition? vector4 Needs to be defined if Position isn't.
---@field Model? number Needs to be defined if PedPosition is defined.
---@field SpawnPosition vector4 The vehicle spawn position.
---@field Jobs? string | string[] Optionally limit to jobs.

---@class GarageData : LocationData
---@field Interior string? The interior name defined in Config.GarageInteriors

---@type GarageData[]
Config.Garages = {
    {
        Visible = true,
        Type = 'car',
        Position = vector3(220.1418, -800.1686, 30.7227),
        SpawnPosition = vector4(229.3425, -801.4708, 30.5659, 161.8591)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(273.0, -343.85, 44.91),
        SpawnPosition = vector4(270.75, -340.51, 44.92, 342.03)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-71.46, -1821.83, 26.94),
        SpawnPosition = vector4(-66.51, -1828.01, 26.94, 235.64)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(1032.84, -765.1, 58.18),
        SpawnPosition = vector4(1023.2, -764.27, 57.96, 319.66)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-1248.69, -1425.71, 4.32),
        SpawnPosition = vector4(-1244.27, -1422.08, 4.32, 37.12)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-2961.58, 375.93, 15.02),
        SpawnPosition = vector4(-2964.96, 372.07, 14.78, 86.07)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(217.33, 2605.65, 46.04),
        SpawnPosition = vector4(216.94, 2608.44, 46.33, 14.07)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(1878.44, 3760.1, 32.94),
        SpawnPosition = vector4(1880.14, 3757.73, 32.93, 215.54)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(365.21, 295.6, 103.46),
        SpawnPosition = vector4(364.84, 289.73, 103.42, 164.23)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(1713.06, 4745.32, 41.96),
        SpawnPosition = vector4(1710.64, 4746.94, 41.95, 90.11)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(107.32, 6611.77, 31.98),
        SpawnPosition = vector4(110.84, 6607.82, 31.86, 265.28)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(328.6457, -210.4855, 54.0863),
        SpawnPosition = vector4(334.2747, -213.1827, 54.0863, 73.3548)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-176.8074, -1305.2096, 31.2980),
        SpawnPosition = vector4(-164.0872, -1306.4490, 31.3066, 9.2604)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(408.0792, -998.0554, 29.2663),
        SpawnPosition = vector4(408.0792, -998.0554, 29.2663, 50.8039)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(2422.3440, 4959.5835, 45.9706),
        SpawnPosition = vector4(2422.3440, 4959.5835, 45.9706, 44.7529)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-608.2778, -875.6619, 25.2812),
        SpawnPosition = vector4(-608.2778, -875.6619, 25.2812, 230.8461)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-1480.0311, -496.4789, 32.8068),
        SpawnPosition = vector4(-1480.0311, -496.4789, 32.8068, 215.6816)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-1667.8083, 72.3026, 63.5343),
        SpawnPosition = vector4(-1667.8083, 72.3026, 63.5343, 48.9008)
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-387.9319, -107.0117, 38.6853),
        SpawnPosition = vector4(-387.9319, -107.0117, 38.6853, 215.1336)
    },
    {
        Visible = true,
        Type = 'air',
        Position = vector3(-1182.7245, -2852.9495, 14.0404),
        SpawnPosition = vector4(-1178.4406, -2845.8442, 13.9457, 333.0016)
    },
    {
        Visible = true,
        Type = 'boat',
        Position = vector3(-802.3275, -1415.8136, 1.5952),
        SpawnPosition = vector4(-803.2337, -1421.8733, -0.4749, 230.6403)
    },
}

Config.GarageInteriors = {
    ['small'] = {
        -- The teleport coords
        Coords = vector4(0.0, 0.0, 0.0, 0.0), 
        -- The vehicle spot coords array
        Vehicles = {
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0)
        }
    },
    ['medium'] = {
        -- The teleport coords
        Coords = vector4(0.0, 0.0, 0.0, 0.0),
        -- The vehicle spot coords array
        Vehicles = {
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0)
        }
    },
    ['large'] = {
        -- The teleport coords
        Coords = vector4(0.0, 0.0, 0.0, 0.0),
        -- The vehicle spot coords array
        Vehicles = {
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0),
            vector4(0.0, 0.0, 0.0, 0.0)
        }
    },
}

Config.ImpoundPrice = 1000 --Price to return your vehicle.

---@class ImpoundData : LocationData

---@type ImpoundData[]
Config.Impounds = {
    {
        Visible = true,
        Type = 'car',
        Position = vector3(401.7906, -1631.6171, 29.2920),
        SpawnPosition = vector4(407.8341, -1645.6790, 29.2921, 228.1345)
    },
    {
        Visible = true,
        Type = 'air',
        Position = vector3(-1150.4854, -2871.9438, 13.9459),
        SpawnPosition = vector4(-1146.0892, -2864.6094, 13.9460, 331.5881)
    },
    {
        Visible = true,
        Type = 'boat',
        Position = vector3(-844.2191, -1366.7213, 1.6052),
        SpawnPosition = vector4(-843.4146, -1372.2310, -0.4749, 114.3669)
    },
}

Config.Contract = {
    Duration = 5000, -- The animation duration
    Item = 'contract' -- The item name
}