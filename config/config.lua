Config = {}
Config.MaxDistance = 10.0 -- Max interact distance
Config.UseKeySystem = true -- Implemented only for qb-vehiclekeys, you can implement it for other systems in cl_edit.lua
Config.SpawnpointCheck = false -- Checks if the vehicle spawnpoint is empty before spawning it.

-- The global setting for target however you can still combine target/TextUI by omitting Position or PedPosition in garage/impound data
Config.Target = false

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
---@field Model? number | string Needs to be defined if PedPosition is defined.
---@field SpawnPosition vector4 The vehicle spawn position.
---@field Jobs? string | string[] Optionally limit to jobs.

---@class GarageData : LocationData
---@field Interior string? The interior name.

---@type GarageData[]
Config.Garages = {
    {
        Visible = true,
        Type = 'car',
        Position = vector3(220.1418, -800.1686, 30.7227),
        PedPosition = vector4(215.4677, -808.5453, 30.7597, 248.1795),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(229.3425, -801.4708, 30.5659, 161.8591),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(273.0, -343.85, 44.91),
        PedPosition = vector4(276.0835, -343.4283, 44.9198, 344.8690),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(270.75, -340.51, 44.92, 342.03),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-71.46, -1821.83, 26.94),
        PedPosition = vector4(-71.1413, -1829.9701, 26.9420, 230.2688),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-66.51, -1828.01, 26.94, 235.64),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(1032.84, -765.1, 58.18),
        PedPosition = vector4(1035.1685, -765.1791, 57.9946, 152.8775),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(1023.2, -764.27, 57.96, 319.66),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-1248.69, -1425.71, 4.32),
        PedPosition = vector4(-1253.3109, -1420.1212, 4.3231, 306.8438),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-1244.27, -1422.08, 4.32, 37.12),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-2961.58, 375.93, 15.02),
        PedPosition = vector4(-2961.7307, 375.5100, 14.8210, 171.7270),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-2964.96, 372.07, 14.78, 86.07),
        Interior = 'small'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(217.33, 2605.65, 46.04),
        PedPosition = vector4(217.9141, 2602.0601, 45.7792, 13.1270),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(216.94, 2608.44, 46.33, 14.07),
        Interior = 'small'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(1878.44, 3760.1, 32.94),
        PedPosition = vector4(1873.9102, 3752.6917, 32.9840, 306.1647),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(1880.14, 3757.73, 32.93, 215.54),
        Interior = 'small'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(365.21, 295.6, 103.46),
        PedPosition = vector4(363.3373, 296.9839, 103.5044, 251.6143),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(364.84, 289.73, 103.42, 164.23),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(1713.06, 4745.32, 41.96),
        PedPosition = vector4(1713.2983, 4742.9219, 42.0254, 16.6958),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(1710.64, 4746.94, 41.95, 90.11),
        Interior = 'small'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(107.32, 6611.77, 31.98),
        PedPosition = vector4(106.0233, 6613.0356, 31.9787, 230.0135),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(110.84, 6607.82, 31.86, 265.28),
        Interior = 'small'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(328.6457, -210.4855, 54.0863),
        PedPosition = vector4(337.9874, -214.8659, 54.0863, 73.4874),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(325.5470, -211.0033, 54.0863, 156.9495),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-176.8074, -1305.2096, 31.2980),
        PedPosition = vector4(-167.2547, -1310.2228, 31.3727, 8.5375),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-164.0872, -1306.4490, 31.3066, 9.2604),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(408.0792, -998.0554, 29.2663),
        PedPosition = vector4(410.2025, -1005.1442, 29.2667, 96.4086),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(408.0792, -998.0554, 29.2663, 50.8039),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(2422.3440, 4959.5835, 45.9706),
        PedPosition = vector4(2425.1272, 4960.6118, 46.1977, 140.0077),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(2421.7756, 4959.3447, 46.0200, 44.8010),
        Interior = 'small'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-608.2778, -875.6619, 25.2812),
        PedPosition = vector4(-613.7393, -881.1906, 25.1290, 327.8892),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-608.2778, -875.6619, 25.2812, 230.8461),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-1480.0311, -496.4789, 32.8068),
        PedPosition = vector4(-1471.2198, -490.6253, 32.8068, 129.3045),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-1480.0311, -496.4789, 32.8068, 215.6816),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-1667.8083, 72.3026, 63.5343),
        PedPosition = vector4(-1677.5203, 66.0455, 63.9183, 317.4938),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-1667.8083, 72.3026, 63.5343, 48.9008),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'car',
        Position = vector3(-387.9319, -107.0117, 38.6853),
        PedPosition = vector4(-389.6788, -101.4820, 38.7576, 212.3671),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-387.9319, -107.0117, 38.6853, 215.1336),
        Interior = 'large'
    },
    {
        Visible = true,
        Type = 'air',
        Position = vector3(-1182.7245, -2852.9495, 14.0404),
        PedPosition = vector4(-1186.2985, -2841.2820, 13.9461, 236.5903),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-1178.4406, -2845.8442, 13.9457, 333.0016),
    },
    {
        Visible = true,
        Type = 'boat',
        Position = vector3(-802.3275, -1415.8136, 1.5952),
        PedPosition = vector4(-797.7064, -1419.6964, 1.5952, 54.2872),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-803.2337, -1421.8733, -0.4749, 230.6403)
    },
}

Config.GarageInteriors = {
    ['small'] = {
        -- The teleport coords
        Coords = vector4(637.1520, 4750.6572, -59.0000, 91.4643), 
        -- The vehicle spot coords array
        Vehicles = {
            vector4(623.0, 4750.4780, -59.5000, 179.0),
            vector4(626.0, 4750.4790, -59.5000, 179.0),
            vector4(629.0, 4750.5620, -59.5000, 179.0),
            vector4(632.0, 4750.5078, -59.5000, 179.0),
        }
    },
    ['large'] = {
        -- The teleport coords
        Coords = vector4(238.0297, -1004.8235, -99.0000, 90.0),
        -- The vehicle spot coords array
        Vehicles = {
            vector4(232.7722, -984.5818, -99.0000, 90.0),
            vector4(232.7722, -988.5818, -99.0000, 90.0),
            vector4(232.7722, -992.5818, -99.0000, 90.0),
            vector4(232.7722, -996.5818, -99.0000, 90.0),
            vector4(232.7722, -1000.5818, -99.0000, 90.0),
            vector4(223.7722, -984.5818, -99.0000, -90.0),
            vector4(223.7722, -988.5818, -99.0000, -90.0),
            vector4(223.7722, -992.5818, -99.0000, -90.0),
            vector4(223.7722, -996.5818, -99.0000, -90.0),
            vector4(223.7722, -1000.5818, -99.0000, -90.0),
        }
    }
}

Config.ImpoundPrice = 1000 --Price to return your vehicle.

---@class ImpoundData : LocationData

---@type ImpoundData[]
Config.Impounds = {
    {
        Visible = true,
        Type = 'car',
        Position = vector3(401.7906, -1631.6171, 29.2920),
        PedPosition = vector4(399.1730, -1629.3943, 29.2919, 232.0665),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(407.8341, -1645.6790, 29.2921, 228.1345)
    },
    {
        Visible = true,
        Type = 'air',
        Position = vector3(-1150.4854, -2871.9438, 13.9459),
        PedPosition = vector4(-1153.9452, -2860.0886, 13.9460, 241.3252),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-1146.0892, -2864.6094, 13.9460, 331.5881)
    },
    {
        Visible = true,
        Type = 'boat',
        Position = vector3(-844.2191, -1366.7213, 1.6052),
        PedPosition = vector4(-848.3743, -1368.4086, 1.6052, 291.1638),
        Model = `s_m_m_armoured_01`,
        SpawnPosition = vector4(-843.4146, -1372.2310, -0.4749, 114.3669)
    },
}

Config.Contract = {
    Duration = 5000, -- The animation duration
    Item = 'contract' -- The item name
}